Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 453D1C43331
	for <linux-fscrypt@archiver.kernel.org>; Mon,  4 Jan 2021 18:49:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1492D22482
	for <linux-fscrypt@archiver.kernel.org>; Mon,  4 Jan 2021 18:49:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727674AbhADStI (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 4 Jan 2021 13:49:08 -0500
Received: from mail.kernel.org ([198.145.29.99]:48018 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727660AbhADStI (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 4 Jan 2021 13:49:08 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id F2EF12225E;
        Mon,  4 Jan 2021 18:48:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1609786107;
        bh=l9qA1xr6rFaBfchx04jLeHDtxn2wMDoreitB3JMFNSw=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=bWx44oFKt5Yx11TXQHI11asEJAeEPs9XuBCKP5efQPssaGPR2Vsd+JdcEpEunQl0y
         xTDbC3aDPN2RFuxEREX2uQ6birjbCzXGbu86eXcifryKs6iyBZoBak9HSL2LPl0oxm
         DqztaV6RU2m87XhBtlbpLtSbfhfeooGrjh7em7wvQUllkJlXpg/mKKZ0FJK5r5sKfs
         FwafROSFy0EDZRUlkik++upDBlDaxMAPBqEC8y9+0LEisAfK3KngsGUctYgVHGW4O0
         JY15q/qSrSXLa+v9E5eQTV9by3COmgYNv/AEG/1jZb/6YPUx5ulKrZ2yZ8GWIWqGjE
         BM5SkyEIBZGhw==
From:   Eric Biggers <ebiggers@kernel.org>
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
Subject: [PATCH v4 2/9] mmc: cqhci: rename cqhci.c to cqhci-core.c
Date:   Mon,  4 Jan 2021 10:45:35 -0800
Message-Id: <20210104184542.4616-3-ebiggers@kernel.org>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210104184542.4616-1-ebiggers@kernel.org>
References: <20210104184542.4616-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Rename cqhci.c to cqhci-core.c so that another source file can be added
to the cqhci module without having to rename the module.

Acked-by: Adrian Hunter <adrian.hunter@intel.com>
Reviewed-and-tested-by: Peng Zhou <peng.zhou@mediatek.com>
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
2.30.0

