Return-Path: <SRS0=1m1K=DB=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 642D5C4346E
	for <linux-fscrypt@archiver.kernel.org>; Thu, 24 Sep 2020 05:48:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 15BDC23600
	for <linux-fscrypt@archiver.kernel.org>; Thu, 24 Sep 2020 05:48:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600926529;
	bh=ZBd12iiaWrJLLa5wlKz4XAdvI+v27GCLwdJDLWNHLIY=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=BfOZm7V3UW7yvrGuiUV7DMh69vNmCWSTgJAY+Ea6z68EKYPxckgHwcb5RvFWndHv8
	 6fqqlwONZNM6+FsvEP6cAJIJrD4TawnOaSrypaIn7VDIikAnT+5DZNVcWKqRlah1bh
	 XFnPbZxPcvPjOtb7mJjZ9Nf90/O7hC00PSR86MNk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726844AbgIXFss (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 24 Sep 2020 01:48:48 -0400
Received: from mail.kernel.org ([198.145.29.99]:34612 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726683AbgIXFss (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 24 Sep 2020 01:48:48 -0400
Received: from sol.attlocal.net (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 5527A235FD;
        Thu, 24 Sep 2020 05:48:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600926527;
        bh=ZBd12iiaWrJLLa5wlKz4XAdvI+v27GCLwdJDLWNHLIY=;
        h=From:To:Cc:Subject:Date:From;
        b=yxcfpsFWdaISRwAI+JVWSVcxnMGJEi4ShtKIgyoJgyvWOVArjZfAHg8LIHipiUC6V
         QMGF7qU5twNettIbNqxJCnUBLmarGE/ysxglhg3oHN61q/vyHwjZyzoCBNs0tdGBKd
         hdHf1ETiZYCxPPjHI7/27bpsdedx2WvOrXU8y9L0=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        ceph-devel@vger.kernel.org, Daniel Rosenberg <drosen@google.com>,
        Jeff Layton <jlayton@kernel.org>
Subject: [PATCH] fscrypt: export fscrypt_d_revalidate()
Date:   Wed, 23 Sep 2020 22:47:21 -0700
Message-Id: <20200924054721.187797-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.28.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Dentries that represent no-key names must have a dentry_operations that
includes fscrypt_d_revalidate().  Currently, this is handled by
fscrypt_prepare_lookup() installing fscrypt_d_ops.

However, ceph support for encryption
(https://lore.kernel.org/r/20200914191707.380444-1-jlayton@kernel.org)
can't use fscrypt_d_ops, since ceph already has its own
dentry_operations.

Similarly, ext4 and f2fs support for directories that are both encrypted
and casefolded
(https://lore.kernel.org/r/20200923010151.69506-1-drosen@google.com)
can't use fscrypt_d_ops either, since casefolding requires some dentry
operations too.

To satisfy both users, we need to move the responsibility of installing
the dentry_operations to filesystems.

In preparation for this, export fscrypt_d_revalidate() and give it a
!CONFIG_FS_ENCRYPTION stub.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---

Compared to the versions of this patch from Jeff and Daniel, I've
improved the commit message and added a !CONFIG_FS_ENCRYPTION stub,
which was missing.  I'm planning to apply this for 5.10 in preparation
for both the ceph patchset and the encrypt+casefold patchset.


 fs/crypto/fname.c       | 3 ++-
 include/linux/fscrypt.h | 7 +++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index c65979452844..1fbe6c24d705 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -530,7 +530,7 @@ EXPORT_SYMBOL_GPL(fscrypt_fname_siphash);
  * Validate dentries in encrypted directories to make sure we aren't potentially
  * caching stale dentries after a key has been added.
  */
-static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
+int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 {
 	struct dentry *dir;
 	int err;
@@ -569,6 +569,7 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 
 	return valid;
 }
+EXPORT_SYMBOL_GPL(fscrypt_d_revalidate);
 
 const struct dentry_operations fscrypt_d_ops = {
 	.d_revalidate = fscrypt_d_revalidate,
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index f1757e73162d..a8f7a43f031b 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -197,6 +197,7 @@ int fscrypt_fname_disk_to_usr(const struct inode *inode,
 bool fscrypt_match_name(const struct fscrypt_name *fname,
 			const u8 *de_name, u32 de_name_len);
 u64 fscrypt_fname_siphash(const struct inode *dir, const struct qstr *name);
+int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags);
 
 /* bio.c */
 void fscrypt_decrypt_bio(struct bio *bio);
@@ -454,6 +455,12 @@ static inline u64 fscrypt_fname_siphash(const struct inode *dir,
 	return 0;
 }
 
+static inline int fscrypt_d_revalidate(struct dentry *dentry,
+				       unsigned int flags)
+{
+	return 1;
+}
+
 /* bio.c */
 static inline void fscrypt_decrypt_bio(struct bio *bio)
 {
-- 
2.28.0

