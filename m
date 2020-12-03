Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.0 required=3.0 tests=BAYES_00,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABB0AC6369E
	for <linux-fscrypt@archiver.kernel.org>; Thu,  3 Dec 2020 02:08:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 74F43221EB
	for <linux-fscrypt@archiver.kernel.org>; Thu,  3 Dec 2020 02:08:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727078AbgLCCIp (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 2 Dec 2020 21:08:45 -0500
Received: from mail.kernel.org ([198.145.29.99]:45500 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726535AbgLCCIp (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 2 Dec 2020 21:08:45 -0500
From:   Eric Biggers <ebiggers@kernel.org>
Authentication-Results: mail.kernel.org; dkim=permerror (bad message/signature format)
To:     linux-mmc@vger.kernel.org
Cc:     linux-arm-msm@vger.kernel.org, devicetree@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>,
        Ulf Hansson <ulf.hansson@linaro.org>,
        Andy Gross <agross@kernel.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Asutosh Das <asutoshd@codeaurora.org>,
        Rob Herring <robh+dt@kernel.org>,
        Neeraj Soni <neersoni@codeaurora.org>,
        Barani Muthukumaran <bmuthuku@codeaurora.org>,
        Peng Zhou <peng.zhou@mediatek.com>,
        Stanley Chu <stanley.chu@mediatek.com>,
        Konrad Dybcio <konradybcio@gmail.com>
Subject: [PATCH v2 2/9] mmc: cqhci: rename cqhci.c to cqhci-core.c
Date:   Wed,  2 Dec 2020 18:05:09 -0800
Message-Id: <20201203020516.225701-3-ebiggers@kernel.org>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201203020516.225701-1-ebiggers@kernel.org>
References: <20201203020516.225701-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Rename cqhci.c to cqhci-core.c so that another source file can be added
to the cqhci module without having to rename the module.

Acked-by: Adrian Hunter <adrian.hunter@intel.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 drivers/mmc/host/Makefile                  | 1 +
 drivers/mmc/host/{cqhci.c => cqhci-core.c} | 0
 2 files changed, 1 insertion(+)
 rename drivers/mmc/host/{cqhci.c => cqhci-core.c} (100%)

diff --git a/drivers/mmc/host/Makefile b/drivers/mmc/host/Makefile
index 451c25fc2c692..20c2f9463d0dc 100644
--- a/drivers/mmc/host/Makefile
+++ b/drivers/mmc/host/Makefile
@@ -104,6 +104,7 @@ obj-$(CONFIG_MMC_SDHCI_BRCMSTB)		+= sdhci-brcmstb.o
 obj-$(CONFIG_MMC_SDHCI_OMAP)		+= sdhci-omap.o
 obj-$(CONFIG_MMC_SDHCI_SPRD)		+= sdhci-sprd.o
 obj-$(CONFIG_MMC_CQHCI)			+= cqhci.o
+cqhci-y					+= cqhci-core.o
 obj-$(CONFIG_MMC_HSQ)			+= mmc_hsq.o
 
 ifeq ($(CONFIG_CB710_DEBUG),y)
diff --git a/drivers/mmc/host/cqhci.c b/drivers/mmc/host/cqhci-core.c
similarity index 100%
rename from drivers/mmc/host/cqhci.c
rename to drivers/mmc/host/cqhci-core.c
-- 
2.29.2

