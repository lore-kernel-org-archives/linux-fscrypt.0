Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792528025;
	b=bAtCCUPO+9ZAgOvDKcgT7Qfz39t6kNVdP/lB9mkAE7kMDYBXB95OzHj6hOkaauP+DVAM
	 ls3YEVxPkJ4HoaSmXTPrR5D3sSgEJio50H+gL9ip3vATDPPjDFkh++cGJMy46oMN926B/
	 PAymg4BT34ZLDUGM1fqHIJB8l84wAohH2t3YfP0fdh6rLlO5OK3le99YxNKgOxMvyfQA/
	 IAu5xbdtUn6bFJ72CTHC5vt6WMzWghaojCRTHtvTpuWDrP04kKJtNrZqwYsEkoZAdRThT
	 l5zeLkeK7FyF+BPdUlmXhE12t9y0qsIXf53BA1FJUCTZHg5u0WsZKna05ybT8TPOEkw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792528025;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=11oaeN/8N1hoT44N2YuHBHNc8eMWNhQWc/HCa490GyE=;
	b=SLBLWQtNnSu2qul6LP/v/8SRWXn/2AZxF/viyFiDcGiH/JefzJE4bROA3U2lkAHpeJhY
	 0LeRnNn18+7Kz/z/1GbvZjn7FImaQlK+QHzCOEruaz2qGG4nNmua+FXSutTuLWV15av5Q
	 RACUz5AtMA0fC6HLEzznVz/RJXnocuY8hPCXPRgLUZVtuNaKK16NxLWz9N9BwmD5hd/2p
	 76HwOHx27zcrueuliRzEZczx7EKOcgFBd8VlS32EnYcogf2ERzW14RKGLi4Ay8F0Fqppi
	 tTXwmWdaV1ODGKOyjXv+ibH+OvS/+Il8qmxWb0d2NFB4IMGbRysYYjxay7hwXH4dkWg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=B9FhoizM;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=F9t+xOcV;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3E72606A31E
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 20:27:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A3E72606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=B9FhoizM;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=F9t+xOcV
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792528023;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=11oaeN/8N1hoT44N2YuHBHNc8eMWNhQWc/HCa490GyE=;
	b=B9FhoizMBGB9AIOLMDK+Q/AD9D01TRiQmZviUH/QAyWdS88YfWz604bL7Z4DoUkWCZwZaS
	c/FnXwTlwYAo7SgIDrJe8WICFAGW1cjTZaciNaGnlPNj9p9HKfrrWHTx4rc24tEjV/Y3vc
	WN4uvynyp+jbqHTAFZwSPIsCkimDYGE=
Received: from mail-qv1-f69.google.com (mail-qv1-f69.google.com
 [209.85.219.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-493-GAljSZ6-M2qmk-3BHkCsjQ-1; Tue, 20 Oct 2026 20:27:02 +0000
X-MC-Unique: GAljSZ6-M2qmk-3BHkCsjQ-1
X-Mimecast-MFC-AGG-ID: GAljSZ6-M2qmk-3BHkCsjQ_1792528022
Received: by mail-qv1-f69.google.com with SMTP id 6a1803df08f44-917a7fffbe0so1752956d6.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 13:27:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792528022; x=1793132822; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=11oaeN/8N1hoT44N2YuHBHNc8eMWNhQWc/HCa490GyE=;
        b=F9t+xOcVCMZ2b6NV69G5TCTuuexVxgSwJb8b4gdLlulNr93AVnkzT4kvccau4eU15z
         TO83oJyTPjixkOv79QhmGt9iqBdVvtg7SAjTdz5Jz2F98+Q2qt/YfXlB74Wi7JFMevfp
         MSBJTu6eAQQKsP4YY3hs5Xp+ht4o08DoySgobd/eASbr2ZZ3dMHw1KtlSa/zVTfquYJN
         UrAdOuYoLutIDHx3exJebqY/s4ax2BevQkRQBoik3Etmg9HKzFtYC+t/BiXCiTJSrR6u
         xEOJovelL4xLruoY5/tTWvhKWLXTu50ui1dckyHya9pkghXZD7AlQvbRN8gBRRIHfJsR
         gfMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792528022; x=1793132822;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=11oaeN/8N1hoT44N2YuHBHNc8eMWNhQWc/HCa490GyE=;
        b=Qp/lZFC9jkmwlk4ZNBSnzUFqIASFYQvrFp6IomjdSh4n841OVK+fW4THBRUNGIEt+b
         ke+PwzCEZnyXxAN0eVgWOtc5JGeJ0w1885SSReGFCQgHGfyuYP8BW0yd2RZu20sUM249
         bB810qTZD9dFsq2hnldC19gF1f9ZG27/r6hsmkR7yTjCdRaQ55i4ILOaCtPPKfE1gkjj
         G2wvP5Pokta5mjpVglBNkXXAZn5NbWP2Mn0TSRadW7DeiIVkKpefSsSJFr7avz3bSQec
         AZlnw6IdcM/M1gfM7p9xiNgS9VSWPgZQJkAFG9f8qtkOwrrK7t3tv9MIdp+SD/ADlL2I
         JsMg==
X-Forwarded-Encrypted: i=1; AKwUvBy/85+j8enOSoyoAmX8mWf5TcEH5g31uhF+dfwSjMVCARcLy6FRd2ogVyP/EotaI8yEsst5ZlwNJ3bFcU98@vger.kernel.org
X-Gm-Message-State: AFq9FYIIt8L6g9J8UPrtsxTNEjOS4RSjMy5keVKk9WQ6bdvneVyusoVw
	YiRHEYxK5PNtCx3tLzBy+HVcOz3AzAhl0H9nkUqE9qKyicjT4684D/9MzNb5gH1FUMlowFA0LVO
	I1rlJEoHJFA3Ap/S0pgDgaYhdQf6pDvH1YRr5b/IVK6HrZf/hjnO2nhNpb843qUcJpgc=
X-Gm-Gg: AYBFou3BHu2NXE6sVVG3JJIaB/3V/PQWDPRyOLg2XSHkl1QYbJkZgKbZt7ga3pZhas5
	xEQCfXW8ERIwydxcrfKOeLl87SsiHJblxyMS1D598lxwp4xq2/aiTXH9RwMO4gTC3Bypk6kQeIs
	/yLgfKI/v1waWVxyASTcmDPLrGCCfJh95m5tQnBXLDy5myyrWhJ9s5jovJZV7Jdko77cFoOwQUl
	Gzt4+MuEhW5qmAu3yUHgB+TMdHEqBS5fc0DYyhqiC11iaIQc21LhqzjY8owOFEDs/4aMvvC1FSw
	ALAcaRHaykWg7X6BS3XxwCkCXUY+E7Dq8t1ywJzNHXeIbo+W+mTPL2CKxV/X+rMyNXzJBGvnKeW
	OEBSRbhD/8IOeZYhyMJmb/ihJ+acsexp/7gBLq0liWZ6XYkoXxi5ypluKAvBR+JtqtqVD2CtHoe
	YyKir7gLTtrQv5A96GzCualFgNE7qOM5E22LDUblC6O1vbXEq/jX0yalWWHZZaB4iSAH9+nlzF5
	fI=
X-Received: by 2002:a05:6214:598b:b0:91b:5d3a:f13a with SMTP id 6a1803df08f44-91bdf62e3e4mr201889086d6.57.1792528021681;
        Tue, 20 Oct 2026 13:27:01 -0700 (PDT)
X-Received: by 2002:a05:6214:598b:b0:91b:5d3a:f13a with SMTP id 6a1803df08f44-91bdf62e3e4mr201888746d6.57.1792528021147;
        Tue, 20 Oct 2026 13:27:01 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91c10a45336sm7461436d6.3.2026.10.20.13.26.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 13:27:00 -0700 (PDT)
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
Subject: [PATCH v5 2/5] fscrypt: allow filesystems to disable symlink target caching
Date: Tue, 20 Oct 2026 20:26:47 +0000
Message-Id: <4ef1532159c9312287a604efda1e6a3c0621112a.1792527529.git.amarkuze@redhat.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <cover.1792527529.git.amarkuze@redhat.com>
References: <cover.1792527529.git.amarkuze@redhat.com>
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

