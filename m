Return-Path: <SRS0=A8Az=WR=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: [PATCH 4/9] mmc: dw_mmc-exynos: support FMP
Date: Wed, 21 Aug 2019 15:42:22 +0900
Message-ID: <004001d557eb$9697f5d0$c3c7e170$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190821064223epcas2p18a14724427711e22c6c76b24bce1c8e0@epcas2p1.samsung.com>
To: 'Ulf Hansson' <ulf.hansson@linaro.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Krzysztof Kozlowski' <krzk@kernel.org>, linux-mmc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'  <tytso@mit.edu>,  'Chao Yu'  <chao@kernel.org>,  'Jaegeuk Kim' " <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>'Theodore Ts'o' <tytso@mit.edu>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Jaehoon Chung' <jh80.chung@samsung.com>, linux-fscrypt@vger.kernel.org, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Exynos MMC uses FMP to encrypt data stored on MMC device.
FMP H/W reads crypto information from MMC descriptor.
So, when using FMP H/W, the format of MMC descriptor should be extended.
The FMP driver is registered with the diskcipher algorithm,
so exynos MMC calls diskcipher API to use FMP.

Cc: Ulf Hansson <ulf.hansson@linaro.org>
Cc: Kukjin Kim <kgene@kernel.org>
Cc: Krzysztof Kozlowski <krzk@kernel.org>
Signed-off-by: Boojin Kim <boojin.kim@samsung.com>
---
 drivers/mmc/host/Kconfig         |  8 ++++++
 drivers/mmc/host/dw_mmc-exynos.c | 62
++++++++++++++++++++++++++++++++++++++++
 drivers/mmc/host/dw_mmc.c        | 26 +++++++++++++++++
 3 files changed, 96 insertions(+)

diff --git a/drivers/mmc/host/Kconfig b/drivers/mmc/host/Kconfig
index 14d89a1..f6c5a54 100644
--- a/drivers/mmc/host/Kconfig
+++ b/drivers/mmc/host/Kconfig
@@ -761,6 +761,14 @@ config MMC_DW_EXYNOS
 	  Synopsys DesignWare Memory Card Interface driver. Select this
option
 	  for platforms based on Exynos4 and Exynos5 SoC's.
 
+config MMC_DW_EXYNOS_FMP
+	tristate "EXYNOS Flash Memory Protector for MMC_DW"
+	depends on MMC_DW_EXYNOS
+	---help---
+	  This selects the EXYNOS MMC_DW FMP Driver.
+
+	  If you have a controller with this interface, say Y or M here.
+
 config MMC_DW_HI3798CV200
 	tristate "Hi3798CV200 specific extensions for Synopsys DW Memory
Card Interface"
 	depends on MMC_DW
diff --git a/drivers/mmc/host/dw_mmc-exynos.c
b/drivers/mmc/host/dw_mmc-exynos.c
index 5e3d95b..d3848ba 100644
--- a/drivers/mmc/host/dw_mmc-exynos.c
+++ b/drivers/mmc/host/dw_mmc-exynos.c
@@ -14,10 +14,12 @@
 #include <linux/of_gpio.h>
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
+#include <crypto/fmp.h>
 
 #include "dw_mmc.h"
 #include "dw_mmc-pltfm.h"
 #include "dw_mmc-exynos.h"
+#include "../core/queue.h"
 
 /* Variations in Exynos specific dw-mshc controller */
 enum dw_mci_exynos_type {
@@ -508,6 +510,62 @@ static int dw_mci_exynos_prepare_hs400_tuning(struct
dw_mci *host,
 	return 0;
 }
 
+#ifdef CONFIG_MMC_DW_EXYNOS_FMP
+static struct bio *get_bio(struct dw_mci *host,
+				struct mmc_data *data, bool cmdq_enabled)
+{
+	struct bio *bio = NULL;
+	struct mmc_queue_req *mq_rq = NULL;
+	struct request *req = NULL;
+	struct mmc_blk_request *brq = NULL;
+
+	if (!host || !data) {
+		pr_err("%s: Invalid MMC:%p data:%p\n", __func__, host,
data);
+		return NULL;
+	}
+
+	if (cmdq_enabled) {
+		pr_err("%s: no support cmdq yet:%p\n", __func__, host);
+		bio = NULL;
+	} else {
+		brq = container_of(data, struct mmc_blk_request, data);
+		if (!brq)
+			return NULL;
+
+		mq_rq = container_of(brq, struct mmc_queue_req, brq);
+		if (virt_addr_valid(mq_rq))
+			req = mmc_queue_req_to_req(mq_rq);
+			if (virt_addr_valid(req))
+				bio = req->bio;
+	}
+	return bio;
+}
+
+static int dw_mci_exynos_crypto_engine_cfg(struct dw_mci *host,
+					void *desc, struct mmc_data *data,
+					struct page *page, int page_index,
+					int sector_offset, bool
cmdq_enabled)
+{
+	struct bio *bio = get_bio(host, host->data, cmdq_enabled);
+
+	if (!bio)
+		return 0;
+
+	return exynos_fmp_crypt_cfg(bio, desc, page_index, sector_offset);
+}
+
+static int dw_mci_exynos_crypto_engine_clear(struct dw_mci *host,
+					void *desc, bool cmdq_enabled)
+{
+	struct bio *bio = get_bio(host, host->data, cmdq_enabled);
+
+	if (!bio)
+		return 0;
+
+	return exynos_fmp_crypt_clear(bio, desc);
+}
+#endif
+
 /* Common capabilities of Exynos4/Exynos5 SoC */
 static unsigned long exynos_dwmmc_caps[4] = {
 	MMC_CAP_1_8V_DDR | MMC_CAP_8_BIT_DATA | MMC_CAP_CMD23,
@@ -524,6 +582,10 @@ static const struct dw_mci_drv_data exynos_drv_data = {
 	.parse_dt		= dw_mci_exynos_parse_dt,
 	.execute_tuning		= dw_mci_exynos_execute_tuning,
 	.prepare_hs400_tuning	= dw_mci_exynos_prepare_hs400_tuning,
+#ifdef CONFIG_MMC_DW_EXYNOS_FMP
+	.crypto_engine_cfg = dw_mci_exynos_crypto_engine_cfg,
+	.crypto_engine_clear = dw_mci_exynos_crypto_engine_clear,
+#endif
 };
 
 static const struct of_device_id dw_mci_exynos_match[] = {
diff --git a/drivers/mmc/host/dw_mmc.c b/drivers/mmc/host/dw_mmc.c
index 0cdf574..4de476a 100644
--- a/drivers/mmc/host/dw_mmc.c
+++ b/drivers/mmc/host/dw_mmc.c
@@ -79,6 +79,32 @@ struct idmac_desc_64addr {
 
 	u32		des6;	/* Lower 32-bits of Next Descriptor Address
*/
 	u32		des7;	/* Upper 32-bits of Next Descriptor Address
*/
+#if defined(CONFIG_MMC_DW_EXYNOS_FMP)
+	u32 des8;		/* File IV 0 */
+	u32 des9;		/* File IV 1 */
+	u32 des10;		/* File IV 2 */
+	u32 des11;		/* File IV 3 */
+	u32 des12;		/* File EncKey 0 */
+	u32 des13;		/* File EncKey 1 */
+	u32 des14;		/* File EncKey 2 */
+	u32 des15;		/* File EncKey 3 */
+	u32 des16;		/* File EncKey 4 */
+	u32 des17;		/* File EncKey 5 */
+	u32 des18;		/* File EncKey 6 */
+	u32 des19;		/* File EncKey 7 */
+	u32 des20;		/* File TwKey 0 */
+	u32 des21;		/* File TwKey 1 */
+	u32 des22;		/* File TwKey 2 */
+	u32 des23;		/* File TwKey 3 */
+	u32 des24;		/* File TwKey 4 */
+	u32 des25;		/* File TwKey 5 */
+	u32 des26;		/* File TwKey 6 */
+	u32 des27;		/* File TwKey 7 */
+	u32 des28;		/* Disk IV 0 */
+	u32 des29;		/* Disk IV 1 */
+	u32 des30;		/* Disk IV 2 */
+	u32 des31;		/* Disk IV 3 */
+#endif
 };
 
 struct idmac_desc {
-- 
2.7.4
