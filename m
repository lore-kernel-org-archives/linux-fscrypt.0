Received: from mout-b-210.mailbox.org (mout-b-210.mailbox.org [195.10.208.40])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEF43385D8A;
	Tue, 21 Jul 2026 14:18:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.10.208.40
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784643492; cv=none; b=ekN22iOs3QZv3MUoqWkH8y7jikNSsI40bMxPEPJUSNvi8rmvxJcX3Oc/HdR8SN2Mqwyy6KciNI4WwkP7aejOuzcOV3vnigaWLu0bsujOeBl+BYAzuJl8I0LDhQltI9ztL4sPhpyNC8Ida0DZg/zLDPhxNhJE2GXIpyBiqcOK5zk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784643492; c=relaxed/simple;
	bh=4XMSSYeWGWr5pycq0X+lJ1beMqz58PF3+qRdMwTkOmU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jvfAieKJpNUrFqrsHfCOXOEvvlutBGHUD6STnJDkwZdFj1rD9mtsTNWTyjr2GMnPE4qDl1v+6+BxNT902+bz7FNMSma/BzY1IrAFPctbo0jjgwSeMatl70JUO/NoEVARhE8SRr7R21JZIwVN35+uz90D2q9ywwwqVerjE1JuLig=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=mandelbit.com; spf=pass smtp.mailfrom=mandelbit.com; dkim=pass (2048-bit key) header.d=mandelbit.com header.i=@mandelbit.com header.b=Za5buqjn; arc=none smtp.client-ip=195.10.208.40
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=mandelbit.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mandelbit.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mandelbit.com header.i=@mandelbit.com header.b="Za5buqjn"
Received: from smtp102.mailbox.org (smtp102.mailbox.org [10.196.197.102])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange x25519 server-signature RSA-PSS (4096 bits) server-digest SHA512)
	(No client certificate requested)
	by mout-b-210.mailbox.org (Postfix) with ESMTPS id 4h4K2k0dsqzFqxk;
	Tue, 21 Jul 2026 16:07:26 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mandelbit.com;
	s=MBO0001; t=1784642846;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=l7ophslGW/dSefBKTR4gUdzh1JD9Snwrm6mKJ6ZRaYM=;
	b=Za5buqjnzXgrmft9nhackNgjklTMpncgXordKGK4DDjywrL3mXMBwHPuvpJ3GNnA0akaia
	1SzhTR/VLU16xNiXqx+clNsDatlIhaId5attyPr1w5c1hVVdUCshJIGwuWM/2S5s48kz41
	H5iP6v0PB/zPUVO1HpGtTuYF4L1A/oOFGKaTIJLv/vwRllUFxYsrlVr9GgjGEqqZeJLzjT
	0qMbNUWVyzrMMp1tpWROqnTs8DjDBwEvZz109VYWfvDUV+lHmW+4HaWOjigO9uo6+QvJau
	E9Pz7NtdX0xzG7uFx/+2AjiWjwwkzZTpOdBFiArHfhJVFrFkB+MC27l6vbuhwA==
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
Subject: [PATCH 1/5] lib/crypto: add HKDF-SHA{256,384,512}
Date: Tue, 21 Jul 2026 16:06:40 +0200
Message-ID: <20260721140644.780006-2-marco@mandelbit.com>
In-Reply-To: <20260721140644.780006-1-marco@mandelbit.com>
References: <20260721140644.780006-1-marco@mandelbit.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fscrypt and NVMe authentication each carry private HKDF (RFC 5869)
code. Add common HKDF-SHA{256,384,512} helpers based on fscrypt's
implementation to lib/crypto, so both users can share the code.

Represent info as an array of segments processed as if concatenated.
This avoids temporary concatenation buffers.

Implement the helpers using the direct HMAC library API, so they cannot
fail, perform no allocations, and make no indirect calls. HKDF-Extract
stores the PRK as a prepared HMAC key, so key preparation is not
repeated for each HKDF-Expand call.

Use a template to instantiate the code for SHA-256, SHA-384, and
SHA-512. Add the resulting objects to libsha256 and libsha512.

Signed-off-by: Marco Baffo <marco@mandelbit.com>
---
 include/crypto/hkdf.h      | 131 +++++++++++++++++++++++++++++++++++++
 lib/crypto/Makefile        |   4 +-
 lib/crypto/hkdf-sha256.c   |  22 +++++++
 lib/crypto/hkdf-sha512.c   |  34 ++++++++++
 lib/crypto/hkdf-template.h |  97 +++++++++++++++++++++++++++
 5 files changed, 286 insertions(+), 2 deletions(-)
 create mode 100644 include/crypto/hkdf.h
 create mode 100644 lib/crypto/hkdf-sha256.c
 create mode 100644 lib/crypto/hkdf-sha512.c
 create mode 100644 lib/crypto/hkdf-template.h

diff --git a/include/crypto/hkdf.h b/include/crypto/hkdf.h
new file mode 100644
index 000000000000..dda4dce9f037
--- /dev/null
+++ b/include/crypto/hkdf.h
@@ -0,0 +1,131 @@
+/* SPDX-License-Identifier: GPL-2.0-only */
+/*
+ * HKDF: HMAC-based Key Derivation Function (RFC 5869)
+ *
+ * Derived from fs/crypto/hkdf.c
+ * Copyright 2019 Google LLC
+ */
+
+#ifndef _CRYPTO_HKDF_H
+#define _CRYPTO_HKDF_H
+
+#include <crypto/sha2.h>
+
+/*
+ * HKDF has two steps:
+ *
+ * 1. Extract: derive a pseudorandom key from input keying material and salt.
+ * 2. Expand: derive output keying material from the pseudorandom key and info.
+ */
+
+/**
+ * struct hkdf_seg - one segment of the HKDF-Expand 'info' parameter
+ * @data: the segment data
+ * @len: length of @data in bytes
+ *
+ * The segments are processed as if concatenated, so a composite info can be
+ * passed without assembling it in a temporary buffer first.
+ */
+struct hkdf_seg {
+	const void *data;
+	size_t len;
+};
+
+/**
+ * hkdf_sha256_extract() - HKDF-Extract using HMAC-SHA256
+ * @prk: (output) the pseudorandom key, prepared for hkdf_sha256_expand()
+ * @salt: optional non-secret salt, or NULL for the RFC 5869 default
+ *	  (all-zero) salt
+ * @salt_len: length of @salt in bytes (must be 0 if @salt is NULL)
+ * @ikm: input keying material
+ * @ikm_len: length of @ikm in bytes
+ *
+ * Extract a SHA256_DIGEST_SIZE-byte pseudorandom key from @ikm.  If @ikm is
+ * already a pseudorandom key of that size, prepare @prk with
+ * hmac_sha256_preparekey() instead.
+ */
+void hkdf_sha256_extract(struct hmac_sha256_key *prk,
+			 const u8 *salt, size_t salt_len,
+			 const u8 *ikm, size_t ikm_len);
+
+/**
+ * hkdf_sha256_expand() - HKDF-Expand using HMAC-SHA256
+ * @prk: pseudorandom key from hkdf_sha256_extract() or
+ *	 hmac_sha256_preparekey()
+ * @info: info segments, processed as if concatenated.  Use different info for
+ *	  different purposes.
+ * @info_nsegs: number of segments in @info
+ * @okm: (output) the output keying material
+ * @okm_len: length of @okm in bytes, at most 255 * SHA256_DIGEST_SIZE
+ *
+ * Expand @prk into @okm_len bytes of output keying material (RFC 5869
+ * section 2.3).  The same (@prk, @info) always yields the same output.
+ * Different @info values yield independent outputs, but different @okm_len do
+ * not: a shorter output is a truncation of a longer one.  This may be called many
+ * times per @prk and is thread-safe.
+ */
+void hkdf_sha256_expand(const struct hmac_sha256_key *prk,
+			const struct hkdf_seg *info, size_t info_nsegs,
+			u8 *okm, size_t okm_len);
+
+/**
+ * hkdf_sha384_extract() - HKDF-Extract using HMAC-SHA384
+ * @prk: (output) the pseudorandom key, prepared for hkdf_sha384_expand()
+ * @salt: optional non-secret salt, or NULL for the RFC 5869 default
+ *	  (all-zero) salt
+ * @salt_len: length of @salt in bytes (must be 0 if @salt is NULL)
+ * @ikm: input keying material
+ * @ikm_len: length of @ikm in bytes
+ *
+ * SHA-384 variant of hkdf_sha256_extract().
+ */
+void hkdf_sha384_extract(struct hmac_sha384_key *prk,
+			 const u8 *salt, size_t salt_len,
+			 const u8 *ikm, size_t ikm_len);
+
+/**
+ * hkdf_sha384_expand() - HKDF-Expand using HMAC-SHA384
+ * @prk: pseudorandom key from hkdf_sha384_extract() or
+ *	 hmac_sha384_preparekey()
+ * @info: info segments, processed as if concatenated
+ * @info_nsegs: number of segments in @info
+ * @okm: (output) the output keying material
+ * @okm_len: length of @okm in bytes, at most 255 * SHA384_DIGEST_SIZE
+ *
+ * SHA-384 variant of hkdf_sha256_expand().
+ */
+void hkdf_sha384_expand(const struct hmac_sha384_key *prk,
+			const struct hkdf_seg *info, size_t info_nsegs,
+			u8 *okm, size_t okm_len);
+
+/**
+ * hkdf_sha512_extract() - HKDF-Extract using HMAC-SHA512
+ * @prk: (output) the pseudorandom key, prepared for hkdf_sha512_expand()
+ * @salt: optional non-secret salt, or NULL for the RFC 5869 default
+ *	  (all-zero) salt
+ * @salt_len: length of @salt in bytes (must be 0 if @salt is NULL)
+ * @ikm: input keying material
+ * @ikm_len: length of @ikm in bytes
+ *
+ * SHA-512 variant of hkdf_sha256_extract().
+ */
+void hkdf_sha512_extract(struct hmac_sha512_key *prk,
+			 const u8 *salt, size_t salt_len,
+			 const u8 *ikm, size_t ikm_len);
+
+/**
+ * hkdf_sha512_expand() - HKDF-Expand using HMAC-SHA512
+ * @prk: pseudorandom key from hkdf_sha512_extract() or
+ *	 hmac_sha512_preparekey()
+ * @info: info segments, processed as if concatenated
+ * @info_nsegs: number of segments in @info
+ * @okm: (output) the output keying material
+ * @okm_len: length of @okm in bytes, at most 255 * SHA512_DIGEST_SIZE
+ *
+ * SHA-512 variant of hkdf_sha256_expand().
+ */
+void hkdf_sha512_expand(const struct hmac_sha512_key *prk,
+			const struct hkdf_seg *info, size_t info_nsegs,
+			u8 *okm, size_t okm_len);
+
+#endif /* _CRYPTO_HKDF_H */
diff --git a/lib/crypto/Makefile b/lib/crypto/Makefile
index f1e9bf89785f..96173c1a0a31 100644
--- a/lib/crypto/Makefile
+++ b/lib/crypto/Makefile
@@ -300,7 +300,7 @@ endif # CONFIG_CRYPTO_LIB_SHA1_ARCH
 ################################################################################
 
 obj-$(CONFIG_CRYPTO_LIB_SHA256) += libsha256.o
-libsha256-y := sha256.o
+libsha256-y := sha256.o hkdf-sha256.o
 ifeq ($(CONFIG_CRYPTO_LIB_SHA256_ARCH),y)
 CFLAGS_sha256.o += -I$(src)/$(SRCARCH)
 
@@ -329,7 +329,7 @@ endif # CONFIG_CRYPTO_LIB_SHA256_ARCH
 ################################################################################
 
 obj-$(CONFIG_CRYPTO_LIB_SHA512) += libsha512.o
-libsha512-y := sha512.o
+libsha512-y := sha512.o hkdf-sha512.o
 ifeq ($(CONFIG_CRYPTO_LIB_SHA512_ARCH),y)
 CFLAGS_sha512.o += -I$(src)/$(SRCARCH)
 
diff --git a/lib/crypto/hkdf-sha256.c b/lib/crypto/hkdf-sha256.c
new file mode 100644
index 000000000000..27004293b805
--- /dev/null
+++ b/lib/crypto/hkdf-sha256.c
@@ -0,0 +1,22 @@
+// SPDX-License-Identifier: GPL-2.0-only
+/*
+ * HKDF-SHA256 library functions (RFC 5869)
+ *
+ * Derived from fs/crypto/hkdf.c
+ * Copyright 2019 Google LLC
+ */
+
+#include <crypto/hkdf.h>
+#include <linux/string.h>
+
+#define HKDF_EXTRACT		hkdf_sha256_extract
+#define HKDF_EXPAND		hkdf_sha256_expand
+#define HMAC_KEY		hmac_sha256_key
+#define HMAC_CTX		hmac_sha256_ctx
+#define HMAC_PREPAREKEY		hmac_sha256_preparekey
+#define HMAC_INIT		hmac_sha256_init
+#define HMAC_UPDATE		hmac_sha256_update
+#define HMAC_FINAL		hmac_sha256_final
+#define HMAC_USINGRAWKEY	hmac_sha256_usingrawkey
+#define HKDF_HASHLEN		SHA256_DIGEST_SIZE
+#include "hkdf-template.h"
diff --git a/lib/crypto/hkdf-sha512.c b/lib/crypto/hkdf-sha512.c
new file mode 100644
index 000000000000..f03f9dad1beb
--- /dev/null
+++ b/lib/crypto/hkdf-sha512.c
@@ -0,0 +1,34 @@
+// SPDX-License-Identifier: GPL-2.0-only
+/*
+ * HKDF-SHA384 and HKDF-SHA512 library functions (RFC 5869)
+ *
+ * Derived from fs/crypto/hkdf.c
+ * Copyright 2019 Google LLC
+ */
+
+#include <crypto/hkdf.h>
+#include <linux/string.h>
+
+#define HKDF_EXTRACT		hkdf_sha384_extract
+#define HKDF_EXPAND		hkdf_sha384_expand
+#define HMAC_KEY		hmac_sha384_key
+#define HMAC_CTX		hmac_sha384_ctx
+#define HMAC_PREPAREKEY		hmac_sha384_preparekey
+#define HMAC_INIT		hmac_sha384_init
+#define HMAC_UPDATE		hmac_sha384_update
+#define HMAC_FINAL		hmac_sha384_final
+#define HMAC_USINGRAWKEY	hmac_sha384_usingrawkey
+#define HKDF_HASHLEN		SHA384_DIGEST_SIZE
+#include "hkdf-template.h"
+
+#define HKDF_EXTRACT		hkdf_sha512_extract
+#define HKDF_EXPAND		hkdf_sha512_expand
+#define HMAC_KEY		hmac_sha512_key
+#define HMAC_CTX		hmac_sha512_ctx
+#define HMAC_PREPAREKEY		hmac_sha512_preparekey
+#define HMAC_INIT		hmac_sha512_init
+#define HMAC_UPDATE		hmac_sha512_update
+#define HMAC_FINAL		hmac_sha512_final
+#define HMAC_USINGRAWKEY	hmac_sha512_usingrawkey
+#define HKDF_HASHLEN		SHA512_DIGEST_SIZE
+#include "hkdf-template.h"
diff --git a/lib/crypto/hkdf-template.h b/lib/crypto/hkdf-template.h
new file mode 100644
index 000000000000..a1d6bbfdc689
--- /dev/null
+++ b/lib/crypto/hkdf-template.h
@@ -0,0 +1,97 @@
+/* SPDX-License-Identifier: GPL-2.0-only */
+/*
+ * Implementation of HKDF ("HMAC-based Extract-and-Expand Key Derivation
+ * Function"), aka RFC 5869.  See also the original paper (Krawczyk 2010):
+ * "Cryptographic Extraction and Key Derivation: The HKDF Scheme".
+ *
+ * Derived from fs/crypto/hkdf.c
+ * Copyright 2019 Google LLC
+ *
+ * This file is a template that generates HKDF on top of a specific HMAC
+ * library.  The including file must define the following macros, and may
+ * include this file multiple times to instantiate multiple variants:
+ *
+ *	HKDF_EXTRACT		name of the HKDF-Extract function
+ *	HKDF_EXPAND		name of the HKDF-Expand function
+ *	HMAC_KEY		HMAC prepared-key type, without 'struct'
+ *	HMAC_CTX		HMAC context type, without 'struct'
+ *	HMAC_PREPAREKEY		the hmac_*_preparekey() function
+ *	HMAC_INIT		the hmac_*_init() function
+ *	HMAC_UPDATE		the hmac_*_update() function
+ *	HMAC_FINAL		the hmac_*_final() function
+ *	HMAC_USINGRAWKEY	the hmac_*_usingrawkey() function
+ *	HKDF_HASHLEN		hash digest size in bytes
+ */
+
+/*
+ * HKDF-Extract (RFC 5869 section 2.2).  Compute a pseudorandom key of
+ * HKDF_HASHLEN bytes from the input keying material and optional salt, and
+ * prepare it as an HMAC key.
+ *
+ * A NULL or empty 'salt', or any all-zero salt up to the HMAC block size,
+ * gives the same PRK as the RFC 5869 default salt of HKDF_HASHLEN zero bytes.
+ * If 'salt' is NULL, 'salt_len' must be 0.
+ */
+void HKDF_EXTRACT(struct HMAC_KEY *prk, const u8 *salt, size_t salt_len,
+		  const u8 *ikm, size_t ikm_len)
+{
+	u8 prk_bytes[HKDF_HASHLEN];
+
+	HMAC_USINGRAWKEY(salt ? salt : (const u8 *)"", salt_len,
+			 ikm, ikm_len, prk_bytes);
+	HMAC_PREPAREKEY(prk, prk_bytes, sizeof(prk_bytes));
+	memzero_explicit(prk_bytes, sizeof(prk_bytes));
+}
+EXPORT_SYMBOL_GPL(HKDF_EXTRACT);
+
+/*
+ * HKDF-Expand (RFC 5869 section 2.3).  Expand the pseudorandom key 'prk' into
+ * 'okm_len' bytes of output keying material, parameterized by the
+ * application-specific info, given as 'info_nsegs' segments that are
+ * processed as if concatenated:
+ *
+ *	T(0) = empty
+ *	T(n) = HMAC(PRK, T(n-1) | info | n)	for n = 1, 2, ...
+ *	OKM  = first okm_len bytes of T(1) | T(2) | ...
+ *
+ * This is thread-safe and may be called by multiple threads in parallel.
+ */
+void HKDF_EXPAND(const struct HMAC_KEY *prk, const struct hkdf_seg *info,
+		 size_t info_nsegs, u8 *okm, size_t okm_len)
+{
+	struct HMAC_CTX ctx;
+	u8 counter = 1;
+	u8 tmp[HKDF_HASHLEN];
+
+	WARN_ON_ONCE(okm_len > 255 * HKDF_HASHLEN);
+
+	for (size_t i = 0; i < okm_len; i += HKDF_HASHLEN) {
+		HMAC_INIT(&ctx, prk);
+		if (i != 0)
+			HMAC_UPDATE(&ctx, &okm[i - HKDF_HASHLEN],
+				    HKDF_HASHLEN);
+		for (size_t j = 0; j < info_nsegs; j++)
+			HMAC_UPDATE(&ctx, info[j].data, info[j].len);
+		HMAC_UPDATE(&ctx, &counter, 1);
+		if (okm_len - i < HKDF_HASHLEN) {
+			HMAC_FINAL(&ctx, tmp);
+			memcpy(&okm[i], tmp, okm_len - i);
+			memzero_explicit(tmp, sizeof(tmp));
+		} else {
+			HMAC_FINAL(&ctx, &okm[i]);
+		}
+		counter++;
+	}
+}
+EXPORT_SYMBOL_GPL(HKDF_EXPAND);
+
+#undef HKDF_EXTRACT
+#undef HKDF_EXPAND
+#undef HMAC_KEY
+#undef HMAC_CTX
+#undef HMAC_PREPAREKEY
+#undef HMAC_INIT
+#undef HMAC_UPDATE
+#undef HMAC_FINAL
+#undef HMAC_USINGRAWKEY
+#undef HKDF_HASHLEN
-- 
2.43.0

