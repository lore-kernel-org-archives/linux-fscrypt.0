Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792500768;
	b=PD8AXWmqBLfXRskisCBrX6vmpnHicoefyVmhmR2jXAHqFo/7kSFyrqwbVLv88MIAwOMi
	 166jYQH0Py8/uhvV4pe1XUsyFiMVBdU+T9+ot+g9VMBohDCpqDdNrqwYoJ3JyB5D76VzS
	 KC4h5wvYXqDpNgKKm2i26kxGAooZ3Rriec78iW24vga8fE4paXQTjrylYcr1iKgEQyHGq
	 j540AnS8KlyLjBiPWpGtkIn9H+dGAnTp0oj/q94ebe9hfPHj2hU+RTkh+cu3lYhp10MPK
	 UvZlXfTTK0q4aUpNt6yp9eedKM8/4Uj2AcHCY6S4ECK1qFx7O7PB4vP9tY/wh/9cmvw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792500768;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=11oaeN/8N1hoT44N2YuHBHNc8eMWNhQWc/HCa490GyE=;
	b=dw5gsmuIu+k9R6VlyvtCLgv2hpXrgApDVkfKpBfkuLDBIa2H1Gg4pzEjjauw418I7DdB
	 TwEMZAzcIGBes5l0rxyDU2pIbEUw0OTZNexrD7nfW9O56ycpQc3aryIFDrSLRQ9nEa71I
	 7I7EEQbWdZ0BHtCDPCigX4FGFBCVV0ZFLUwvAS67gL5wpdGAloFprZUM7avifxVT+4sbs
	 dMY8cfCETHLg/dlnEiJDONwuYkT1bwg0NEm+lmE1k1BlX52P3nteCPkHv2MjDXbL/5zuP
	 ONzyLr0ZAIQNL5LBKorQQAhNxBe2bIHDLW6nsMOJrS66XwF5iKau1dyOLIKAY7KF0hQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=McLOe5RV;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b="T/AfZl//";
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC946606A319
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 12:52:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BC946606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=McLOe5RV;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=T/AfZl//
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792500766;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=11oaeN/8N1hoT44N2YuHBHNc8eMWNhQWc/HCa490GyE=;
	b=McLOe5RVF1eF4Cqx8inMAn4Ywgs5h2J8sEBdEfRvPKb4T6iRwOoPcVfUg+iw6+O/C/eBqo
	dZcVhmUQoytdxgtRA2jemKF8HKMub7MkiPyHHRcsaaZOKMq+uGV/zDkGX5A+ZE0IXHW+Vv
	nauzdx+Wxk1vWu0CRgw8b2MWVYhvL6c=
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com
 [209.85.208.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-587-FU_4SBlrPnaJEOC755kwPA-1; Tue, 20 Oct 2026 12:52:45 +0000
X-MC-Unique: FU_4SBlrPnaJEOC755kwPA-1
X-Mimecast-MFC-AGG-ID: FU_4SBlrPnaJEOC755kwPA_1792500764
Received: by mail-ed1-f71.google.com with SMTP id 4fb4d7f45d1cf-6afbe6b47b7so3368303a12.0
        for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 05:52:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792500764; x=1793105564; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=11oaeN/8N1hoT44N2YuHBHNc8eMWNhQWc/HCa490GyE=;
        b=T/AfZl//r11NPAOFNc6kxNyuPPkrEHu303Itf6+ltvC/eN3J3A7jFZbeSBI2Uo23W5
         en3bqsNlpGaL9alJ+YnCKafbmF3PBw2TNH+r89LMbRLkwazf70J46GtwYmOhtnxwOER2
         n8f+u+j4LevGrryQc/gb82PQs7Sha+aMmdhEKK5oJBIpdrfIOG+P6Rkyk5US2m/yTC4s
         YtDwsRXGvMO1d1IXMr0DWs+meKK8baEkSTpJJThhonXzCYIjnjqzs59eH/CRpcf89pro
         ATuaA7rBlrrO2eubzPQvwvZZDUm+kZo+aFuOEw1BJSz9YKUPh+WGxQ9N46Pzp7rOUUlv
         FCBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792500764; x=1793105564;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=11oaeN/8N1hoT44N2YuHBHNc8eMWNhQWc/HCa490GyE=;
        b=GOFAUcMDibV89YZV09zLDJlho9tf1mTQQx3MkjnNh4+0U/0ts99oNKNANxS6+coZEX
         0DZ+t3CxfAvz0wWJO4+3Z8ryVwFiviW+HEzCvc+lDJxyaRSeCe+FsYO9rMXt0yl8mP0z
         vliNkygDdsG9ED4t+eRUS2nFfu2C+gLNbsqtec33+oIVzdwBg25n3WRoLTGTLKUbzikv
         QeSgGtc9BT53k90f8Uu6QK37nD+JYyCkdi7HnWq2NTCmfh/aiSbHqUGXMtlKucwHTAPP
         1P2TjYcoB2FS3CstSmxzLVtDG23xUYQyw05bhteGa0KNYQjs/GaAdvMQRvX5/t8wWsoV
         pQ1Q==
X-Forwarded-Encrypted: i=1; AKwUvBy2U3gYYZDWBrcPuIsIqHj8daUcPGk7H6jjvWDp315xgzOYzGJCgAFEOMrcqcc1bfmTZz5nK/LGX39j3R4C@vger.kernel.org
X-Gm-Message-State: AFq9FYJDvq8Fj/niWI7naj23XQE4D7OBzSkVh5GUO5vi/d9e4o7XES7p
	B/5QJdbygQbyYob4e1lPZboGivrB+56utNQI5Mk/SRNAp+yMY4Ctd+27giViY8ZzibKnM1Rhqt8
	fQ9KPNhTUm3MzvXj8fnA19oqy3DXZlhGxSvbNU+fw6wgBl1pHAyEzL/fhef/rUET7uSY=
X-Gm-Gg: AYBFou2HULI6xj/18WJXLubAxo0s2DQLM6V3FFPEhFFrTg95kR+FzQa+HFxWEDZ4iOK
	FO2jBHlqONj8xt3OjYgnYAucLuYSM7pCxEV4dAuDGsMBp9EQ1l8bR09sG+LN5mu9S3iWgKP0K5v
	dSJ+/wWo5upHsasEsjBT8C6rwEX04I5gpREQ1a8kSmhLCvubkjmyqS6twHIuDYGrlCYLf3Zy4RG
	Fq+JcmRi20ieLDAlUZEauHymNNrvcctVoedRt0789/wI9R4Ti9qDWwte2eQi1LmP3koyemmjPm1
	VLOfZfYDn/ns2vtcGCf1uI8aXljqHyLcrQT4gT/B0k5tgq+x3pJdvHmwBWytWCjB8pRvPbP3baD
	gDiwpQBpOfyKYDKjwvE/zC8pgG9wr4VK5QfdGMXmRqiB3jnx049bQjwmXfsAOwIBCB8JCrGPn/m
	9HNkKt/7l/ZFvoZ07eL/Ua4Hi5GVZ/71SOj2KuNQPNRjRouVP4A2zj+Uy/CTrYBy6+QnRVykYRH
	hA=
X-Received: by 2002:a05:6402:4495:b0:6b1:497d:1c64 with SMTP id 4fb4d7f45d1cf-6b3a82153damr6927981a12.45.1792500764025;
        Tue, 20 Oct 2026 05:52:44 -0700 (PDT)
X-Received: by 2002:a05:6402:4495:b0:6b1:497d:1c64 with SMTP id 4fb4d7f45d1cf-6b3a82153damr6927967a12.45.1792500763580;
        Tue, 20 Oct 2026 05:52:43 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b3c74eb8a7sm2982781a12.2.2026.10.20.05.52.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 05:52:43 -0700 (PDT)
From: Alex Markuze <amarkuze@redhat.com>
To: ceph-devel@vger.kernel.org
Cc: Alex Markuze <amarkuze@redhat.com>,
	idryomov@gmail.com,
	xiubo.li@clyso.com,
	slava@dubeyko.com,
	viro@zeniv.linux.org.uk,
	brauner@kernel.org,
	jack@suse.cz,
	linux-fsdevel@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	ebiggers@kernel.org,
	tytso@mit.edu,
	jaegeuk@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 2/5] fscrypt: allow filesystems to disable symlink target caching
Date: Tue, 20 Oct 2026 12:52:34 +0000
Message-Id: <4ef1532159c9312287a604efda1e6a3c0621112a.1792498351.git.amarkuze@redhat.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <cover.1792498351.git.amarkuze@redhat.com>
References: <cover.1792498351.git.amarkuze@redhat.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fscrypt caches decrypted symlink targets in inode->i_link. The VFS
can return that target without calling the filesystem's ->get_link(),
so access checks in that callback cannot revoke a previously cached
link. CephFS subvolume quarantine needs those checks even when
readlinkat() uses an empty path on an O_PATH descriptor opened before
quarantine.

Add a filesystem opt-out that prevents both creation-time and lookup-
time cache installation. Leave cache readers unchanged: the option is
fixed before inode creation, so they find no cached target. Uncached
targets use the existing delayed-free callback.

Opting out costs a temporary allocation and decryption on each access
to an encrypted symlink, including readlink, traversal and lstat. Other
filesystems keep their existing caching behavior. The Ceph opt-in is
in the quarantine enforcement patch in this series.

Signed-off-by: Alex Markuze <amarkuze@redhat.com>
---
 fs/crypto/hooks.c       | 28 +++++++++++++++-------------
 include/linux/fscrypt.h |  7 +++++++
 2 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index a7a8a3f581a0..6bc7ac82ec34 100644
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
+	/* Cache the plaintext target unless the filesystem revalidates it. */
+	if (!inode->i_sb->s_cop->no_symlink_cache) {
+		err = -ENOMEM;
+		inode->i_link = kmemdup(target, len + 1, GFP_NOFS);
+		if (!inode->i_link)
+			goto err_free_sd;
+	}
 
 	if (!disk_link->name)
 		disk_link->name = (unsigned char *)sd;
@@ -411,12 +413,12 @@ const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
 	pstr.name[pstr.len] = '\0';
 
 	/*
-	 * Cache decrypted symlink targets in i_link for later use.  Don't cache
-	 * symlink targets encoded without the key, since those become outdated
-	 * once the key is added.  This pairs with the READ_ONCE() above and in
-	 * the VFS path lookup code.
+	 * Cache decrypted targets unless the filesystem revalidates them.
+	 * Don't cache targets encoded without the key, since those become
+	 * outdated once the key is added. This pairs with the READ_ONCE()
+	 * above and in the VFS path lookup code.
 	 */
-	if (!has_key ||
+	if (inode->i_sb->s_cop->no_symlink_cache || !has_key ||
 	    cmpxchg_release(&inode->i_link, NULL, pstr.name) != NULL)
 		set_delayed_call(done, kfree_link, pstr.name);
 
@@ -442,9 +444,9 @@ EXPORT_SYMBOL_GPL(fscrypt_get_symlink);
  * This requires reading the symlink target from disk if needed, setting up the
  * inode's encryption key if possible, and then decrypting or encoding the
  * symlink target.  This makes lstat() more heavyweight than is normally the
- * case.  However, decrypted symlink targets will be cached in ->i_link, so
- * usually the symlink won't have to be read and decrypted again later if/when
- * it is actually followed, readlink() is called, or lstat() is called again.
+ * case. Unless the filesystem sets no_symlink_cache, decrypted targets
+ * are cached in ->i_link, avoiding another read and decryption when the
+ * symlink is followed, readlink() is called, or lstat() is called again.
  *
  * Return: 0 on success, -errno on failure
  */
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 28f2108e29f3..ab77e685c75c 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -107,6 +107,13 @@ struct fscrypt_operations {
 	 */
 	unsigned int supports_subblock_data_units : 1;
 
+	/*
+	 * Don't populate ->i_link, so every access calls ->get_link() and the
+	 * filesystem can revalidate access. Set before creating any inodes;
+	 * this option cannot invalidate previously cached targets.
+	 */
+	unsigned int no_symlink_cache : 1;
+
 	/*
 	 * This field exists only for backwards compatibility reasons and should
 	 * only be set by the filesystems that are setting it already.  It

