Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D43E53E310
	for <linux-fscrypt@vger.kernel.org>; Thu, 15 Oct 2026 17:46:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792086403; cv=none; b=b+USVoc437i6fq1kWbFV9TGZS7No5txqjaqQqJnWJ60VF3OJm4ueEaKwXgExzbixSF+mnuVCb/6dnfvvlfyTbbLhpwYV3rmFN5rulx2jXStjwlYKOLExbpTONiq5Cq+h53hyMfkuDHGbl5JRCvsMuNQmgbKadMyqSSI/14u8es0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792086403; c=relaxed/simple;
	bh=3ucozJp1Vb41Q178Z0Uce4IWui2IT+J8Bb+v709B0LE=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=BAHv+I8T859g3hzd46YltB5tdEh29CA1ZC3Nj6b/5NuNjV9ZmR4eObZustnxliHNJqpKJydBGjIX5tnYYPf5+vBA06y2lr+/AwfYcwjjyZ+ViINiK2qoO5YQr0s2mgFMrfN9Em8eE4hMWJ5R+ZmlBBZbInI7TF4E5Cg2rOEqCis=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=gda+x4aN; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=fn0/0OMx; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="gda+x4aN";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="fn0/0OMx"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792086394;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=LQyA1+wc/ZZYzITRZkdnU2lflpO2io/1YEZU0uiNRh8=;
	b=gda+x4aNbqgfBqY6vUWHvdgerfH2n/0TztC+n6bg0G0Z/jx/UcMt/jpDrtpVYM1KspSGsn
	FSospYMcom375Ru+8eQ/SWiAeq/yyVVsjxHaffnrgNLWSC8+Y815Q3dwyl/uklMQU5EAQS
	tjL0Gfl2Y401yI529PatTXK0bH1lLtA=
Received: from mail-dy1-f199.google.com (mail-dy1-f199.google.com
 [74.125.82.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-297-WIF5Wep7OCWwpJ7uhP8UOg-1; Thu, 15 Oct 2026 17:46:32 +0000
X-MC-Unique: WIF5Wep7OCWwpJ7uhP8UOg-1
X-Mimecast-MFC-AGG-ID: WIF5Wep7OCWwpJ7uhP8UOg_1792086391
Received: by mail-dy1-f199.google.com with SMTP id 5a478bee46e88-30bcb065bfdso9769007eec.0
        for <linux-fscrypt@vger.kernel.org>; Thu, 15 Oct 2026 10:46:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792086390; x=1792691190; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=LQyA1+wc/ZZYzITRZkdnU2lflpO2io/1YEZU0uiNRh8=;
        b=fn0/0OMx0r9SoQ7utO37ulxRK0wjSNj4krFE7fx8RSd1kXghp9nbCZBrGLWbj6/X/M
         SSDdFdXhqMz83Tv8OKAHOV0F+dnidacdDAJPD/IsHzqsnIIn1MfKqKnk0bxD6Xq+Pfda
         ik1ljt/KOWtD1kjKLYiQDu3O94nKoD4okE5FiJsTbDbrW9fFiUyEdznPIRfDR7Qjrx/j
         pSFsImU1dom+KyQQT6V45fLmNygKM5WNLbosUZy3KnSOedDofN7GsFtoy4pPd+D3H87d
         NYBniJcdveNY9eiFHqcEswbH4zNWUv1SXHvXHpvk1HlvaD0ScivupTK36wXPukP+9KsW
         zo3Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792086390; x=1792691190;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=LQyA1+wc/ZZYzITRZkdnU2lflpO2io/1YEZU0uiNRh8=;
        b=23v9CrQla4FtUJNxs3+lIlDGUcr3Sul/7pcm93QopACvpZWx4jQQYVr/03/9o/nLw4
         Z4sL7RX5oRMq7kuH2wGbFTFSNfzF0yCcsvXo5J6gu/JsALYCvxK2sTGuvsURbF7OIpVY
         0eo2H5+tdAIlqvUKe+vzWesUMcrzOi6WJ+L7lDzt2qpSo9yGzWpjBdjngpFe7azDVxBl
         dLbRD2GHHW69WZl5SygLbdOSTbvmSwugCHsuZEAxy8vETLHFR2NPacG7lO4Itl54ot82
         80tQcjdQNt7xXH7tou4jLd3vZBbzAiVd7N3KqSLU75TXOZE3oDWuUMI6isuKqacs5/j3
         Anrw==
X-Gm-Message-State: AFq9FYIPzHBJuxscQLiV9qc+Un8PsaMmaWE8/aROW3UpyQxO1LwP8ahq
	LKAmeWrP1iEh2VdM/faUH+NccZ/KiUxXldXiYGJI5nJSF5lOLK4s0JuobkgFkyb5aJypFjMGUlm
	jBuMBk5qYGQkP5pKdlzezFFsuDbiEqfpm8R1vIGihvbRXHZIQm9QU/t93aWSVKkPoFYAG1Azf+2
	Ja4vs8d4LchSLU71sixt2iYI5MjTml1/RzOyT2+pRB2vPv37K6q6uqDw==
X-Gm-Gg: AYBFou0MYnhHtDGJmHfyEjnlmxm0E7lzQhX2l0siX17jj0WFXf/xfQUQNslflGLg2mA
	2CL97IXwKtSuP66c0ZAFkY78+8n/3bCdtghPwhS+X/5hX9/seH2/P1/pmhdyelsbTi7cxpTcQyM
	0riG5KUfzbiNVGJxaNO7oHmDpui68kUdj1EVQ+9tUtcqWkOIpgtspLMUtWo0ivxpCuXVE0ZDGpx
	bGg4CsSRZGuz+JvHV5r1xsjHIZxlHGD8OsIXHkUp2d8CimCF6X5cWCvDWTlTeIN3CWBGKzlgvtn
	xATwVv9C/1b9SmmKG3jgXLHnE2rNL8gvaoqEYg1QuKmv4ReJEso9iqGj60WWxEFWw/8vMmUzOd3
	7O2vrH51JWfk4Bz6CghlN569qD4NIkobcrZd7HhEaVUVkW39VL98YnWn5poAQang8Vye/d+6Jsb
	KjsY7b/8PAiTADhzpeiMH+vO6K0XVisp+5LsI92WsVaqmHdQSmYUQmVApQ5BwLzWI52NDx/ts8Z
	5o=
X-Received: by 2002:a05:7022:b0d4:b0:15b:7f7a:730d with SMTP id a92af1059eb24-16a603445b0mr27652554c88.28.1792086390227;
        Thu, 15 Oct 2026 10:46:30 -0700 (PDT)
X-Received: by 2002:a05:7022:b0d4:b0:15b:7f7a:730d with SMTP id a92af1059eb24-16a603445b0mr27652495c88.28.1792086389268;
        Thu, 15 Oct 2026 10:46:29 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-182a164a7f3sm452719c88.1.2026.10.15.10.46.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Oct 2026 10:46:28 -0700 (PDT)
From: Alex Markuze <amarkuze@redhat.com>
To: linux-fscrypt@vger.kernel.org
Cc: Alex Markuze <amarkuze@redhat.com>,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	Xiubo Li <xiubo.li@clyso.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	ceph-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] fscrypt: allow filesystems to disable symlink target caching
Date: Thu, 15 Oct 2026 17:46:24 +0000
Message-Id: <a01d0a297a3e174d21741a3ad586ce546327603e.1792081664.git.amarkuze@redhat.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fscrypt stores decrypted symlink targets in inode->i_link. The VFS can
use this field without calling the filesystem's ->get_link() callback.
The target can remain valid after the access policy changes.

The CephFS subvolume quarantine series adds access checks to
->get_link(). Quarantine can revoke access after a target is cached. The
VFS cache can bypass these checks.

The no_symlink_cache option in fscrypt_operations gives filesystems
control of this cache. It applies during target creation, lookup and
getattr. With this option set, the helpers do not read or update
->i_link. The filesystem callback can then revalidate access.

Uncached targets use the existing delayed-free callback. Each uncached
lookup allocates a temporary buffer and decrypts or encodes the target.
This lets Ceph reuse fscrypt's target validation and buffer ownership.

The default setting keeps the current cache behavior for other
filesystems. Ceph selects the option so cached targets cannot bypass its
->get_link() checks.

Signed-off-by: Alex Markuze <amarkuze@redhat.com>
---
 fs/ceph/crypto.c        |  1 +
 fs/crypto/hooks.c       | 37 ++++++++++++++++++++++---------------
 include/linux/fscrypt.h |  7 +++++++
 3 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/fs/ceph/crypto.c b/fs/ceph/crypto.c
index 9e0ebb071840..de786a0e626c 100644
--- a/fs/ceph/crypto.c
+++ b/fs/ceph/crypto.c
@@ -92,6 +92,7 @@ static struct fscrypt_operations ceph_fscrypt_ops = {
 	.inode_info_offs	= (int)offsetof(struct ceph_inode_info, i_crypt_info) -
 				  (int)offsetof(struct ceph_inode_info, netfs.inode),
 	.needs_bounce_pages	= 1,
+	.no_symlink_cache	= 1,
 	.get_context		= ceph_crypt_get_context,
 	.set_context		= ceph_crypt_set_context,
 	.get_dummy_policy	= ceph_get_dummy_policy,
diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index a7a8a3f581a0..e1eb0fce7948 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -321,11 +321,13 @@ int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
 	 */
 	sd->encrypted_path[ciphertext_len] = '\0';
 
-	/* Cache the plaintext symlink target for later use by get_link() */
-	err = -ENOMEM;
-	inode->i_link = kmemdup(target, len + 1, GFP_NOFS);
-	if (!inode->i_link)
-		goto err_free_sd;
+	/* Cache the plaintext symlink target if the filesystem allows it. */
+	if (!inode->i_sb->s_cop->no_symlink_cache) {
+		err = -ENOMEM;
+		inode->i_link = kmemdup(target, len + 1, GFP_NOFS);
+		if (!inode->i_link)
+			goto err_free_sd;
+	}
 
 	if (!disk_link->name)
 		disk_link->name = (unsigned char *)sd;
@@ -358,17 +360,21 @@ const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
 {
 	const struct fscrypt_symlink_data *sd;
 	struct fscrypt_str cstr, pstr;
-	bool has_key;
+	bool has_key, cache;
 	int err;
 
 	/* This is for encrypted symlinks only */
 	if (WARN_ON_ONCE(!IS_ENCRYPTED(inode)))
 		return ERR_PTR(-EINVAL);
 
+	cache = !inode->i_sb->s_cop->no_symlink_cache;
+
 	/* If the decrypted target is already cached, just return it. */
-	pstr.name = READ_ONCE(inode->i_link);
-	if (pstr.name)
-		return pstr.name;
+	if (cache) {
+		pstr.name = READ_ONCE(inode->i_link);
+		if (pstr.name)
+			return pstr.name;
+	}
 
 	/*
 	 * Try to set up the symlink's encryption key, but we can continue
@@ -411,12 +417,12 @@ const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
 	pstr.name[pstr.len] = '\0';
 
 	/*
-	 * Cache decrypted symlink targets in i_link for later use.  Don't cache
-	 * symlink targets encoded without the key, since those become outdated
-	 * once the key is added.  This pairs with the READ_ONCE() above and in
-	 * the VFS path lookup code.
+	 * Cache decrypted symlink targets in i_link if the filesystem allows it.
+	 * Don't cache symlink targets encoded without the key, since those
+	 * become outdated once the key is added.  This pairs with the
+	 * READ_ONCE() above and in the VFS path lookup code.
 	 */
-	if (!has_key ||
+	if (!cache || !has_key ||
 	    cmpxchg_release(&inode->i_link, NULL, pstr.name) != NULL)
 		set_delayed_call(done, kfree_link, pstr.name);
 
@@ -460,7 +466,8 @@ int fscrypt_symlink_getattr(const struct path *path, struct kstat *stat)
 	 * decrypted target or the no-key encoded target), we can just get it in
 	 * the same way the VFS does during path resolution and readlink().
 	 */
-	link = READ_ONCE(inode->i_link);
+	link = inode->i_sb->s_cop->no_symlink_cache ?
+		NULL : READ_ONCE(inode->i_link);
 	if (!link) {
 		link = inode->i_op->get_link(dentry, inode, &done);
 		if (IS_ERR(link))
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 28f2108e29f3..faeff5812885 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -107,6 +107,13 @@ struct fscrypt_operations {
 	 */
 	unsigned int supports_subblock_data_units : 1;
 
+	/*
+	 * If set, don't cache decrypted symlink targets in ->i_link.  This
+	 * ensures that the VFS calls ->get_link() for every access, allowing
+	 * the filesystem to revalidate the symlink before returning its target.
+	 */
+	unsigned int no_symlink_cache : 1;
+
 	/*
 	 * This field exists only for backwards compatibility reasons and should
 	 * only be set by the filesystems that are setting it already.  It

base-commit: ed0502cb11f84fff29f374238e526ae94d9bdfde
-- 
2.34.1

