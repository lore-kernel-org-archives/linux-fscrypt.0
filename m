Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.0 required=3.0 tests=BAYES_00,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AA25C8302D
	for <linux-fscrypt@archiver.kernel.org>; Thu,  3 Dec 2020 02:09:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5EF9222272
	for <linux-fscrypt@archiver.kernel.org>; Thu,  3 Dec 2020 02:09:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387723AbgLCCJa (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 2 Dec 2020 21:09:30 -0500
Received: from mail.kernel.org ([198.145.29.99]:45646 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387527AbgLCCJZ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 2 Dec 2020 21:09:25 -0500
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
Subject: [PATCH v2 6/9] firmware: qcom_scm: update comment for ICE-related functions
Date:   Wed,  2 Dec 2020 18:05:13 -0800
Message-Id: <20201203020516.225701-7-ebiggers@kernel.org>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201203020516.225701-1-ebiggers@kernel.org>
References: <20201203020516.225701-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

The SCM calls QCOM_SCM_ES_INVALIDATE_ICE_KEY and
QCOM_SCM_ES_CONFIG_SET_ICE_KEY are also needed for eMMC inline
encryption support, not just for UFS.  Update the comments accordingly.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 drivers/firmware/qcom_scm.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/firmware/qcom_scm.c b/drivers/firmware/qcom_scm.c
index 7be48c1bec96d..f57779fc7ee93 100644
--- a/drivers/firmware/qcom_scm.c
+++ b/drivers/firmware/qcom_scm.c
@@ -965,8 +965,11 @@ EXPORT_SYMBOL(qcom_scm_ice_available);
  * qcom_scm_ice_invalidate_key() - Invalidate an inline encryption key
  * @index: the keyslot to invalidate
  *
- * The UFSHCI standard defines a standard way to do this, but it doesn't work on
- * these SoCs; only this SCM call does.
+ * The UFSHCI and eMMC standards define a standard way to do this, but it
+ * doesn't work on these SoCs; only this SCM call does.
+ *
+ * It is assumed that the SoC has only one ICE instance being used, as this SCM
+ * call doesn't specify which ICE instance the keyslot belongs to.
  *
  * Return: 0 on success; -errno on failure.
  */
@@ -995,10 +998,13 @@ EXPORT_SYMBOL(qcom_scm_ice_invalidate_key);
  *		    units, e.g. 1 = 512 bytes, 8 = 4096 bytes, etc.
  *
  * Program a key into a keyslot of Qualcomm ICE (Inline Crypto Engine), where it
- * can then be used to encrypt/decrypt UFS I/O requests inline.
+ * can then be used to encrypt/decrypt UFS or eMMC I/O requests inline.
+ *
+ * The UFSHCI and eMMC standards define a standard way to do this, but it
+ * doesn't work on these SoCs; only this SCM call does.
  *
- * The UFSHCI standard defines a standard way to do this, but it doesn't work on
- * these SoCs; only this SCM call does.
+ * It is assumed that the SoC has only one ICE instance being used, as this SCM
+ * call doesn't specify which ICE instance the keyslot belongs to.
  *
  * Return: 0 on success; -errno on failure.
  */
-- 
2.29.2

