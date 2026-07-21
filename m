Received: from mout-b-112.mailbox.org (mout-b-112.mailbox.org [195.10.208.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4458938CFED;
	Tue, 21 Jul 2026 14:16:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.10.208.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784643395; cv=none; b=GfNJnyIYHM7ZlN9hQbFQ3SZYJbyqvfCj8258RdsfP3/wGaUfO/hLhJS2pbsHQRqvxL59OfIgrXum/lnMe9d+C0pxzGTqWKjjeUVc/3m8FU2Cj92eyCc5XhnkXUWaPetLPkIPwjMVy6qwIRjbE5UdZuLpM7OMUTEaJKDpo4IQyLo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784643395; c=relaxed/simple;
	bh=ZVXTAcoPOMZxS+cyfGO3eOHhZH9MgO9Pdc9CYN7Zz9w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sQsv26jn9xEJKpUq9tFFjJ6MK8rmYsn6xIXOX+39jyDje04kP67eHBrVvrmq3aWHsfeJbade8CbOY2NFGBZ4TCuoRpDf4tBLhzIEcMSiv0bJOZAFSITx98w86uCoWl+F8nWB3ZyaGhZuhVpKBue28mcr9/nZejqEQgTZvF40z24=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=mandelbit.com; spf=pass smtp.mailfrom=mandelbit.com; dkim=pass (2048-bit key) header.d=mandelbit.com header.i=@mandelbit.com header.b=IHLUncq+; arc=none smtp.client-ip=195.10.208.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=mandelbit.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mandelbit.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mandelbit.com header.i=@mandelbit.com header.b="IHLUncq+"
Received: from smtp102.mailbox.org (smtp102.mailbox.org [IPv6:2001:67c:2050:b231:465::102])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange x25519 server-signature RSA-PSS (4096 bits) server-digest SHA512)
	(No client certificate requested)
	by mout-b-112.mailbox.org (Postfix) with ESMTPS id 4h4K3Z1JwMz5wjs;
	Tue, 21 Jul 2026 16:08:10 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mandelbit.com;
	s=MBO0001; t=1784642890;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=fEcFHyMklMggUILJ2hpXyk39iZmKc7NZk+gvN6un2mQ=;
	b=IHLUncq+lylS9wBKnPK6R3FOVwp7V/DqTx9Hd+6PuCbfqgWRxjqsh3ohk5xgG2qlrbfI/2
	MhM3lMv2bKxJDU44eFTqaVk0JXGN89k90tT6+y5pGepMnjLLwGpsyTqlHTrL+i14lMzXhS
	XSt5Hiznv9mZsedY1EECeq/t5qjCu/zwe3FlojIxZoLy4UntAvmrr8ew+T5c2VUUGncG+M
	ctDpa1YrpBLmvSMi3AbdAP6GiscUKId4FeJ2+J1z7LczSfVk6Hnb1hIpku+TNqsWhRiL02
	fPglRTjMmhsQODAR/ljDN/s5C4ZPpwVQYytQs5f10Fsrqrwr26TT8OnFXukuog==
Authentication-Results: outgoing_mbo_mout;
	dkim=none;
	spf=pass (outgoing_mbo_mout: domain of marco@mandelbit.com designates 2001:67c:2050:b231:465::102 as permitted sender) smtp.mailfrom=marco@mandelbit.com
From: Marco Baffo <marco@mandelbit.com>
To: linux-crypto@vger.kernel.org
Cc: herbert@gondor.apana.org.au,
	davem@davemloft.net,
	ebiggers@kernel.org,
	Jason@zx2c4.com,
	ardb@kernel.org,
	tytso@mit.edu,
	jaegeuk@kernel.org,
	linux-fscrypt@vger.kernel.org,
	kbusch@kernel.org,
	axboe@kernel.dk,
	hch@lst.de,
	sagi@grimberg.me,
	hare@suse.de,
	linux-nvme@lists.infradead.org,
	andrew+netdev@lunn.ch,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	antonio@openvpn.net,
	sd@queasysnail.net,
	linux-kernel@vger.kernel.org,
	Marco Baffo <marco@mandelbit.com>
Subject: [PATCH 4/5] nvme-auth: use HKDF library functions for TLS PSK derivation
Date: Tue, 21 Jul 2026 16:06:43 +0200
Message-ID: <20260721140644.780006-5-marco@mandelbit.com>
In-Reply-To: <20260721140644.780006-1-marco@mandelbit.com>
References: <20260721140644.780006-1-marco@mandelbit.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Rspamd-Queue-Id: 4h4K3Z1JwMz5wjs

NVMe currently implements HKDF locally in nvme_auth_derive_tls_psk()
and allocates a temporary buffer for the HKDF-Expand input. Use the
common SHA-256 and SHA-384 HKDF helpers instead.

Pass the HkdfLabel fields as separate info segments, eliminating the
temporary allocation and its failure path.

The derived keys are unchanged. The segments are processed as if
concatenated, the expand counter byte is appended by the helper, and
the empty salt is equivalent to the previous digest-sized all-zero
salt after HMAC key padding.

Signed-off-by: Marco Baffo <marco@mandelbit.com>
---
 drivers/nvme/common/auth.c | 120 +++++++++++++++++++++----------------
 1 file changed, 68 insertions(+), 52 deletions(-)

diff --git a/drivers/nvme/common/auth.c b/drivers/nvme/common/auth.c
index 77f1d22512f8..b44922dd1cf6 100644
--- a/drivers/nvme/common/auth.c
+++ b/drivers/nvme/common/auth.c
@@ -10,6 +10,7 @@
 #include <linux/scatterlist.h>
 #include <linux/unaligned.h>
 #include <crypto/dh.h>
+#include <crypto/hkdf.h>
 #include <crypto/sha2.h>
 #include <linux/nvme.h>
 #include <linux/nvme-auth.h>
@@ -691,14 +692,19 @@ EXPORT_SYMBOL_GPL(nvme_auth_generate_digest);
 int nvme_auth_derive_tls_psk(int hmac_id, const u8 *psk, size_t psk_len,
 			     const char *psk_digest, u8 **ret_psk)
 {
-	static const u8 default_salt[NVME_AUTH_MAX_DIGEST_SIZE];
 	static const char label[] = "tls13 nvme-tls-psk";
-	const size_t label_len = sizeof(label) - 1;
-	u8 prk[NVME_AUTH_MAX_DIGEST_SIZE];
-	size_t hash_len, ctx_len;
-	u8 *hmac_data = NULL, *tls_key;
-	size_t i;
-	int ret;
+	const u8 label_len = sizeof(label) - 1;
+	union {
+		struct hmac_sha256_key sha256;
+		struct hmac_sha384_key sha384;
+	} prk;
+	struct hkdf_seg info[6];
+	size_t hash_len;
+	u8 output_len[2];
+	u8 ctx_len;
+	char ctx_prefix[4];
+	size_t digest_len;
+	u8 *tls_key;
 
 	hash_len = nvme_auth_hmac_hash_len(hmac_id);
 	if (hash_len == 0) {
@@ -717,64 +723,74 @@ int nvme_auth_derive_tls_psk(int hmac_id, const u8 *psk, size_t psk_len,
 		return -EINVAL;
 	}
 
-	/* HKDF-Extract */
-	ret = nvme_auth_hmac(hmac_id, default_salt, hash_len, psk, psk_len,
-			     prk);
-	if (ret)
-		goto out;
-
 	/*
-	 * HKDF-Expand-Label (RFC 8446 section 7.1), with output length equal to
-	 * the hash length (so only a single HMAC operation is needed)
+	 * HKDF-Expand-Label (RFC 8446 section 7.1).  The HKDF-Expand info
+	 * parameter is an encoded HkdfLabel containing the output length,
+	 * label, and context.
 	 */
 
-	hmac_data = kmalloc(/* output length */ 2 +
-			    /* label */ 1 + label_len +
-			    /* context (max) */ 1 + 3 + 1 + strlen(psk_digest) +
-			    /* counter */ 1,
-			    GFP_KERNEL);
-	if (!hmac_data) {
-		ret = -ENOMEM;
-		goto out;
-	}
 	/* output length */
-	i = 0;
-	hmac_data[i++] = hash_len >> 8;
-	hmac_data[i++] = hash_len;
+	output_len[0] = hash_len >> 8;
+	output_len[1] = hash_len;
+	info[0] = (struct hkdf_seg){
+		.data = output_len,
+		.len = sizeof(output_len),
+	};
 
 	/* label */
-	static_assert(label_len <= 255);
-	hmac_data[i] = label_len;
-	memcpy(&hmac_data[i + 1], label, label_len);
-	i += 1 + label_len;
+	static_assert(sizeof(label) - 1 <= 255);
+	info[1] = (struct hkdf_seg){
+		.data = &label_len,
+		.len = sizeof(label_len),
+	};
+	info[2] = (struct hkdf_seg){
+		.data = label,
+		.len = label_len,
+	};
 
 	/* context */
-	ctx_len = sprintf(&hmac_data[i + 1], "%02d %s", hmac_id, psk_digest);
-	if (ctx_len > 255) {
-		ret = -EINVAL;
-		goto out;
-	}
-	hmac_data[i] = ctx_len;
-	i += 1 + ctx_len;
+	digest_len = strlen(psk_digest);
+	if (digest_len > 255 - (sizeof(ctx_prefix) - 1))
+		return -EINVAL;
 
-	/* counter (this overwrites the NUL terminator written by sprintf) */
-	hmac_data[i++] = 1;
+	snprintf(ctx_prefix, sizeof(ctx_prefix), "%02d ", hmac_id);
+	ctx_len = sizeof(ctx_prefix) - 1 + digest_len;
+	info[3] = (struct hkdf_seg){
+		.data = &ctx_len,
+		.len = sizeof(ctx_len),
+	};
+	info[4] = (struct hkdf_seg){
+		.data = ctx_prefix,
+		.len = sizeof(ctx_prefix) - 1,
+	};
+	info[5] = (struct hkdf_seg){
+		.data = psk_digest,
+		.len = digest_len,
+	};
+
+	tls_key = kmalloc(psk_len, GFP_KERNEL);
+	if (!tls_key)
+		return -ENOMEM;
 
-	tls_key = kzalloc(psk_len, GFP_KERNEL);
-	if (!tls_key) {
-		ret = -ENOMEM;
-		goto out;
-	}
-	ret = nvme_auth_hmac(hmac_id, prk, hash_len, hmac_data, i, tls_key);
-	if (ret) {
+	switch (hmac_id) {
+	case NVME_AUTH_HASH_SHA256:
+		hkdf_sha256_extract(&prk.sha256, NULL, 0, psk, psk_len);
+		hkdf_sha256_expand(&prk.sha256, info, ARRAY_SIZE(info),
+				   tls_key, psk_len);
+		break;
+	case NVME_AUTH_HASH_SHA384:
+		hkdf_sha384_extract(&prk.sha384, NULL, 0, psk, psk_len);
+		hkdf_sha384_expand(&prk.sha384, info, ARRAY_SIZE(info),
+				   tls_key, psk_len);
+		break;
+	default:
+		WARN_ON_ONCE(1);
 		kfree_sensitive(tls_key);
-		goto out;
+		return -EINVAL;
 	}
+	memzero_explicit(&prk, sizeof(prk));
 	*ret_psk = tls_key;
-out:
-	kfree_sensitive(hmac_data);
-	memzero_explicit(prk, sizeof(prk));
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nvme_auth_derive_tls_psk);
 
-- 
2.43.0

