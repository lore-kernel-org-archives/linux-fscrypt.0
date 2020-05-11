Return-Path: <SRS0=HejS=6Z=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71849C54E4B
	for <linux-fscrypt@archiver.kernel.org>; Mon, 11 May 2020 19:16:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 50A2D20752
	for <linux-fscrypt@archiver.kernel.org>; Mon, 11 May 2020 19:16:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1589224598;
	bh=2izxiaGUPO1H4O0NjBC09EHeAyN3lBintH1KSBHdM7I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=DL/feDc/3b668eHjnl3l/0o36VmVz7Qg08VdY2RMmgquBn9HccFxdyV0e8axAi0Vx
	 4PY/Q59t8sQYSQMszPAs0vLeTHCOQdxmsyMfjw+ZN5VDb4IZa/0jNK2ntOHCVnhsdA
	 hl1Lhf/6DU/2r5vMHM1S++fIm9Pj7O+JrByF8zhg=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731272AbgEKTQi (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 11 May 2020 15:16:38 -0400
Received: from mail.kernel.org ([198.145.29.99]:33850 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728613AbgEKTQh (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 11 May 2020 15:16:37 -0400
Received: from sol.hsd1.ca.comcast.net (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id E57F720736;
        Mon, 11 May 2020 19:16:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1589224597;
        bh=2izxiaGUPO1H4O0NjBC09EHeAyN3lBintH1KSBHdM7I=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=IGot39VZ4JxU3bOq3SYiM+yhf0lCV0+Bj+ZcrTnwEAran6zZKi8fSNOwAfUiNgzpD
         4m5aUV/F2Y8CA2vHCzezmFNd6qy8RvOJsMzyq2lxrfo7xH60QSycSYKYdTsgRcnylR
         7Oh6MBOJr5GV79WfzTLrM8N3EoS7N8qr9dkbdL50=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Subject: [PATCH 2/3] fscrypt: name all function parameters
Date:   Mon, 11 May 2020 12:13:57 -0700
Message-Id: <20200511191358.53096-3-ebiggers@kernel.org>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20200511191358.53096-1-ebiggers@kernel.org>
References: <20200511191358.53096-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Name all the function parameters.  This makes it so that we don't have a
mix of both styles, so it won't be ambiguous what to use in new fscrypt
patches.  This also matches the checkpatch expectation.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/linux/fscrypt.h | 46 ++++++++++++++++++++++-------------------
 1 file changed, 25 insertions(+), 21 deletions(-)

diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index cb2c41f8dfdee7..210a05dd9ecd4a 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -56,10 +56,11 @@ struct fscrypt_name {
 struct fscrypt_operations {
 	unsigned int flags;
 	const char *key_prefix;
-	int (*get_context)(struct inode *, void *, size_t);
-	int (*set_context)(struct inode *, const void *, size_t, void *);
-	bool (*dummy_context)(struct inode *);
-	bool (*empty_dir)(struct inode *);
+	int (*get_context)(struct inode *inode, void *ctx, size_t len);
+	int (*set_context)(struct inode *inode, const void *ctx, size_t len,
+			   void *fs_data);
+	bool (*dummy_context)(struct inode *inode);
+	bool (*empty_dir)(struct inode *inode);
 	unsigned int max_namelen;
 	bool (*has_stable_inodes)(struct super_block *sb);
 	void (*get_ino_and_lblk_bits)(struct super_block *sb,
@@ -137,13 +138,15 @@ static inline struct page *fscrypt_pagecache_page(struct page *bounce_page)
 extern void fscrypt_free_bounce_page(struct page *bounce_page);
 
 /* policy.c */
-extern int fscrypt_ioctl_set_policy(struct file *, const void __user *);
-extern int fscrypt_ioctl_get_policy(struct file *, void __user *);
-extern int fscrypt_ioctl_get_policy_ex(struct file *, void __user *);
+extern int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg);
+extern int fscrypt_ioctl_get_policy(struct file *filp, void __user *arg);
+extern int fscrypt_ioctl_get_policy_ex(struct file *filp, void __user *arg);
 extern int fscrypt_ioctl_get_nonce(struct file *filp, void __user *arg);
-extern int fscrypt_has_permitted_context(struct inode *, struct inode *);
-extern int fscrypt_inherit_context(struct inode *, struct inode *,
-					void *, bool);
+extern int fscrypt_has_permitted_context(struct inode *parent,
+					 struct inode *child);
+extern int fscrypt_inherit_context(struct inode *parent, struct inode *child,
+				   void *fs_data, bool preload);
+
 /* keyring.c */
 extern void fscrypt_sb_free(struct super_block *sb);
 extern int fscrypt_ioctl_add_key(struct file *filp, void __user *arg);
@@ -153,23 +156,24 @@ extern int fscrypt_ioctl_remove_key_all_users(struct file *filp,
 extern int fscrypt_ioctl_get_key_status(struct file *filp, void __user *arg);
 
 /* keysetup.c */
-extern int fscrypt_get_encryption_info(struct inode *);
-extern void fscrypt_put_encryption_info(struct inode *);
-extern void fscrypt_free_inode(struct inode *);
+extern int fscrypt_get_encryption_info(struct inode *inode);
+extern void fscrypt_put_encryption_info(struct inode *inode);
+extern void fscrypt_free_inode(struct inode *inode);
 extern int fscrypt_drop_inode(struct inode *inode);
 
 /* fname.c */
-extern int fscrypt_setup_filename(struct inode *, const struct qstr *,
-				int lookup, struct fscrypt_name *);
+extern int fscrypt_setup_filename(struct inode *inode, const struct qstr *iname,
+				  int lookup, struct fscrypt_name *fname);
 
 static inline void fscrypt_free_filename(struct fscrypt_name *fname)
 {
 	kfree(fname->crypto_buf.name);
 }
 
-extern int fscrypt_fname_alloc_buffer(const struct inode *, u32,
-				struct fscrypt_str *);
-extern void fscrypt_fname_free_buffer(struct fscrypt_str *);
+extern int fscrypt_fname_alloc_buffer(const struct inode *inode,
+				      u32 max_encrypted_len,
+				      struct fscrypt_str *crypto_str);
+extern void fscrypt_fname_free_buffer(struct fscrypt_str *crypto_str);
 extern int fscrypt_fname_disk_to_usr(const struct inode *inode,
 				     u32 hash, u32 minor_hash,
 				     const struct fscrypt_str *iname,
@@ -180,9 +184,9 @@ extern u64 fscrypt_fname_siphash(const struct inode *dir,
 				 const struct qstr *name);
 
 /* bio.c */
-extern void fscrypt_decrypt_bio(struct bio *);
-extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
-				 unsigned int);
+extern void fscrypt_decrypt_bio(struct bio *bio);
+extern int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
+				 sector_t pblk, unsigned int len);
 
 /* hooks.c */
 extern int fscrypt_file_open(struct inode *inode, struct file *filp);
-- 
2.26.2

