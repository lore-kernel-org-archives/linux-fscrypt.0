Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:45160 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732394AbeHGAqO (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 Aug 2018 20:46:14 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH 9/9] crypto: hpolyc - add support for the HPolyC encryption mode
Date: Mon,  6 Aug 2018 15:33:00 -0700
Message-Id: <20180806223300.113891-10-ebiggers@kernel.org>
In-Reply-To: <20180806223300.113891-1-ebiggers@kernel.org>
References: <20180806223300.113891-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add support for HPolyC, which is a tweakable, length-preserving
encryption mode that encrypts each message using XChaCha sandwiched
between two passes of Poly1305, and one invocation of a block cipher
such as AES.  HPolyC was designed by Paul Crowley and is fully specified
by our paper https://eprint.iacr.org/2018/720.pdf
("HPolyC: length-preserving encryption for entry-level processors").
HPolyC is similar to some existing modes such as XCB, HCTR, HCH, and
HMC, but by necessity it has some novelties.  See the paper for details;
this patch only provides a brief overview and an explanation of why
HPolyC is needed in the crypto API.

HPolyC is suitable for disk/file encryption with dm-crypt and fscrypt,
where currently the only other suitable options in the kernel are block
cipher modes such as XTS.  Moreover, on low-end devices whose processors
lack AES instructions (e.g. ARM Cortex-A7), AES-XTS is much too slow to
provide an acceptable user experience, resulting in "lightweight" block
ciphers such as Speck being the only viable option on these devices.
However, Speck is considered controversial in some circles; and other
published lightweight block ciphers are too slow in software, haven't
received sufficient cryptanalysis, or have other issues.

Stream ciphers such as ChaCha perform much better but are insecure if
naively used directly in dm-crypt or fscrypt, due to the IV reuse when
data is overwritten.  Even restricting the threat model to offline
attacks only isn't enough, since modern flash storage devices make no
guarantee that "overwrites" are really overwrites, due to wear-leveling.

Of course, the ideal solution is to store unique nonces on-disk, ideally
alongside authentication tags.  Unfortunately, this is usually
impractical.  Hardware support for per-sector metadata is extremely
rare, especially in consumer-grade devices.  Software workarounds for
this limitation struggle with the crash consistency problem (often
ignored by academic cryptographers): the crypto metadata MUST be written
atomically with regards to the data.  This can be solved with data
journaling, e.g. as dm-integrity does, but that has a severe performance
penalty.  Or, for file-level encryption only, per-block metadata is
possible on copy-on-write and log-structured filesystems.  However, the
most common Linux filesystems, ext4 and xfs, are neither; and even f2fs
is not fully log-structured as it sometimes overwrites data in-place.  A
solution that works for more than just btrfs and zfs is needed.

So, we're mostly stuck with length-preserving encryption for now.
HPolyC therefore provides a way to securely use ChaCha in this context.
Essentially, it uses a hash-XOR-hash construction where a Poly1305 hash
of the tweak and message is used as the nonce for XChaCha, resulting in
a different nonce whenever either the message or tweak is changed.  A
block cipher invocation is also needed, but only once per message.  Note
that Poly1305 is much faster than ChaCha20, making HPolyC faster than
might be first assumed; still, due to the overhead of the two Poly1305
passes, some users will need ChaCha12 to get acceptable performance.
See the Performance section of the paper.  (Currently, ChaCha12 is still
secure, though it has a lower security margin.)

HPolyC has a proof (section 5 of the paper) that shows it is secure if
the underlying primitives are secure, subject to a security bound.
Unless there is a mistake in this proof, one therefore does not need to
"trust" HPolyC; they need only trust XChaCha (which itself has a
security reduction to ChaCha) and AES.  Unlike XTS, HPolyC is also a
true wide-block mode, or tweakable super-pseudorandom permutation:
changing one plaintext bit affects all ciphertext bits, and vice versa.

HPolyC supports any message length >= 16 bytes without any need for
"ciphertext stealing".  Thus, it will also be useful for fscrypt
filenames encryption, where CBC-CTS is currently used.

We implement HPolyC as a template that wraps existing Poly1305, XChaCha,
and block cipher implementations.  So, it can be used with either
XChaCha20 or XChaCha12, and with any block cipher with a 256-bit key and
128-bit block size -- though we recommend and plan to use AES-256, even
on processors without AES instructions, as the block cipher performance
is not critical when it's invoked only once per message.  We include
test vectors for HPolyC-XChaCha20-AES and HPolyC-XChaCha12-AES.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 crypto/Kconfig   |  28 +++
 crypto/Makefile  |   1 +
 crypto/hpolyc.c  | 577 +++++++++++++++++++++++++++++++++++++++++++++++
 crypto/testmgr.c |  12 +
 crypto/testmgr.h | 158 +++++++++++++
 5 files changed, 776 insertions(+)
 create mode 100644 crypto/hpolyc.c

diff --git a/crypto/Kconfig b/crypto/Kconfig
index d35d423bb4d1..4b412116b888 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -495,6 +495,34 @@ config CRYPTO_KEYWRAP
 	  Support for key wrapping (NIST SP800-38F / RFC3394) without
 	  padding.
 
+config CRYPTO_HPOLYC
+	tristate "HPolyC support"
+	select CRYPTO_CHACHA20
+	select CRYPTO_POLY1305
+	help
+	  HPolyC is a tweakable, length-preserving encryption
+	  construction that encrypts each message using XChaCha
+	  sandwiched between two passes of Poly1305, and one invocation
+	  of a block cipher such as AES on a single 128-bit block.
+
+	  Unlike bare stream ciphers such as ChaCha and
+	  ciphertext-expanding modes (e.g. AEADs), HPolyC is suitable for
+	  disk and file contents encryption, e.g. with dm-crypt or
+	  fscrypt, where normally only block ciphers in the XTS, LRW, or
+	  CBC-ESSIV modes of operation are suitable.  HPolyC was designed
+	  primarily for this use case on low-end processors that lack AES
+	  instructions, resulting in traditional modes being too slow
+	  unless used with certain "lightweight" block ciphers such as
+	  Speck, but where XChaCha and Poly1305 are reasonably fast.
+
+	  HPolyC's security is proven reducible to that of the underlying
+	  XChaCha variant and block cipher, subject to a security bound.
+	  Unlike XTS, HPolyC is a true wide-block encryption mode, so it
+	  actually provides an even stronger notion of security than XTS,
+	  subject to the security bound.
+
+	  If unsure, say N.
+
 comment "Hash modes"
 
 config CRYPTO_CMAC
diff --git a/crypto/Makefile b/crypto/Makefile
index 0701c4577dc6..e0af9efd6a08 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -83,6 +83,7 @@ obj-$(CONFIG_CRYPTO_LRW) += lrw.o
 obj-$(CONFIG_CRYPTO_XTS) += xts.o
 obj-$(CONFIG_CRYPTO_CTR) += ctr.o
 obj-$(CONFIG_CRYPTO_KEYWRAP) += keywrap.o
+obj-$(CONFIG_CRYPTO_HPOLYC) += hpolyc.o
 obj-$(CONFIG_CRYPTO_GCM) += gcm.o
 obj-$(CONFIG_CRYPTO_CCM) += ccm.o
 obj-$(CONFIG_CRYPTO_CHACHA20POLY1305) += chacha20poly1305.o
diff --git a/crypto/hpolyc.c b/crypto/hpolyc.c
new file mode 100644
index 000000000000..d62f289e2705
--- /dev/null
+++ b/crypto/hpolyc.c
@@ -0,0 +1,577 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * HPolyC: length-preserving encryption for entry-level processors
+ *
+ * Reference: https://eprint.iacr.org/2018/720.pdf
+ *
+ * Copyright (c) 2018 Google LLC
+ */
+
+#include <crypto/algapi.h>
+#include <crypto/chacha.h>
+#include <crypto/internal/hash.h>
+#include <crypto/internal/skcipher.h>
+#include <crypto/scatterwalk.h>
+#include <linux/module.h>
+
+#include "internal.h"
+
+/* Poly1305 and block cipher block size */
+#define HPOLYC_BLOCK_SIZE		16
+
+/* Key sizes in bytes */
+#define HPOLYC_STREAM_KEY_SIZE		32	/* XChaCha stream key (K_S) */
+#define HPOLYC_HASH_KEY_SIZE		16	/* Poly1305 hash key (K_H) */
+#define HPOLYC_BLKCIPHER_KEY_SIZE	32	/* Block cipher key (K_E) */
+
+/*
+ * The HPolyC specification allows any tweak (IV) length <= UINT32_MAX bits, but
+ * Linux's crypto API currently only allows algorithms to support a single IV
+ * length.  We choose 12 bytes, which is the longest tweak that fits into a
+ * single 16-byte Poly1305 block (as HPolyC reserves 4 bytes for the tweak
+ * length), for the fastest performance.  And it's good enough for disk
+ * encryption which really only needs an 8-byte tweak anyway.
+ */
+#define HPOLYC_IV_SIZE		12
+
+struct hpolyc_instance_ctx {
+	struct crypto_ahash_spawn poly1305_spawn;
+	struct crypto_skcipher_spawn xchacha_spawn;
+	struct crypto_spawn blkcipher_spawn;
+};
+
+struct hpolyc_tfm_ctx {
+	struct crypto_ahash *poly1305;
+	struct crypto_skcipher *xchacha;
+	struct crypto_cipher *blkcipher;
+	u8 poly1305_key[HPOLYC_HASH_KEY_SIZE];	/* K_H (unclamped) */
+};
+
+struct hpolyc_request_ctx {
+
+	/* First part of data passed to the two Poly1305 hash steps */
+	struct {
+		u8 rkey[HPOLYC_BLOCK_SIZE];
+		u8 skey[HPOLYC_BLOCK_SIZE];
+		__le32 tweak_len;
+		u8 tweak[HPOLYC_IV_SIZE];
+	} hash_head;
+	struct scatterlist hash_sg[2];
+
+	/*
+	 * Buffer for rightmost portion of data, i.e. the last 16-byte block
+	 *
+	 *    P_L => P_M => C_M => C_R when encrypting, or
+	 *    C_R => C_M => P_M => P_L when decrypting.
+	 *
+	 * Also used to build the XChaCha IV as C_M || 1 || 0^63 || 0^64.
+	 */
+	u8 rbuf[XCHACHA_IV_SIZE];
+
+	bool enc; /* true if encrypting, false if decrypting */
+
+	/* Sub-requests, must be last */
+	union {
+		struct ahash_request poly1305_req;
+		struct skcipher_request xchacha_req;
+	} u;
+};
+
+/*
+ * Given the 256-bit XChaCha stream key K_S, derive the 128-bit Poly1305 hash
+ * key K_H and the 256-bit block cipher key K_E as follows:
+ *
+ *     K_H || K_E || ... = XChaCha(key=K_S, nonce=1||0^191)
+ *
+ * Note that this denotes using bits from the XChaCha keystream, which here we
+ * get indirectly by encrypting a buffer containing all 0's.
+ */
+static int hpolyc_setkey(struct crypto_skcipher *tfm, const u8 *key,
+			 unsigned int keylen)
+{
+	struct hpolyc_tfm_ctx *tctx = crypto_skcipher_ctx(tfm);
+	struct {
+		u8 iv[XCHACHA_IV_SIZE];
+		u8 derived_keys[HPOLYC_HASH_KEY_SIZE +
+				HPOLYC_BLKCIPHER_KEY_SIZE];
+		struct scatterlist sg;
+		struct crypto_wait wait;
+		struct skcipher_request req; /* must be last */
+	} *data;
+	int err;
+
+	/* Set XChaCha key */
+	crypto_skcipher_clear_flags(tctx->xchacha, CRYPTO_TFM_REQ_MASK);
+	crypto_skcipher_set_flags(tctx->xchacha,
+				  crypto_skcipher_get_flags(tfm) &
+				  CRYPTO_TFM_REQ_MASK);
+	err = crypto_skcipher_setkey(tctx->xchacha, key, keylen);
+	crypto_skcipher_set_flags(tfm,
+				  crypto_skcipher_get_flags(tctx->xchacha) &
+				  CRYPTO_TFM_RES_MASK);
+	if (err)
+		return err;
+
+	/* Derive the Poly1305 and block cipher keys */
+	data = kzalloc(sizeof(*data) + crypto_skcipher_reqsize(tctx->xchacha),
+		       GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+	data->iv[0] = 1;
+	sg_init_one(&data->sg, data->derived_keys, sizeof(data->derived_keys));
+	crypto_init_wait(&data->wait);
+	skcipher_request_set_tfm(&data->req, tctx->xchacha);
+	skcipher_request_set_callback(&data->req, CRYPTO_TFM_REQ_MAY_SLEEP |
+						  CRYPTO_TFM_REQ_MAY_BACKLOG,
+				      crypto_req_done, &data->wait);
+	skcipher_request_set_crypt(&data->req, &data->sg, &data->sg,
+				   sizeof(data->derived_keys), data->iv);
+	err = crypto_wait_req(crypto_skcipher_encrypt(&data->req),
+			      &data->wait);
+	if (err)
+		goto out;
+
+	/*
+	 * Save the Poly1305 key.  It is not clamped here, since that is handled
+	 * by the Poly1305 implementation.
+	 */
+	memcpy(tctx->poly1305_key, data->derived_keys, HPOLYC_HASH_KEY_SIZE);
+
+	/* Set block cipher key */
+	crypto_cipher_clear_flags(tctx->blkcipher, CRYPTO_TFM_REQ_MASK);
+	crypto_cipher_set_flags(tctx->blkcipher,
+				crypto_skcipher_get_flags(tfm) &
+				CRYPTO_TFM_REQ_MASK);
+	err = crypto_cipher_setkey(tctx->blkcipher,
+				   &data->derived_keys[HPOLYC_HASH_KEY_SIZE],
+				   HPOLYC_BLKCIPHER_KEY_SIZE);
+	crypto_skcipher_set_flags(tfm,
+				  crypto_cipher_get_flags(tctx->blkcipher) &
+				  CRYPTO_TFM_RES_MASK);
+out:
+	kzfree(data);
+	return err;
+}
+
+static inline void async_done(struct crypto_async_request *areq, int err,
+			      int (*next_step)(struct skcipher_request *, u32))
+{
+	struct skcipher_request *req = areq->data;
+
+	if (err)
+		goto out;
+
+	err = next_step(req, req->base.flags & ~CRYPTO_TFM_REQ_MAY_SLEEP);
+	if (err == -EINPROGRESS || err == -EBUSY)
+		return;
+out:
+	skcipher_request_complete(req, err);
+}
+
+/*
+ * Following completion of the second hash step, do the second bitwise inversion
+ * to complete the identity a - b = ~(a + ~(b)), then copy the result to the
+ * last block of the destination scatterlist.  This completes HPolyC.
+ */
+static int hpolyc_finish(struct skcipher_request *req, u32 flags)
+{
+	struct hpolyc_request_ctx *rctx = skcipher_request_ctx(req);
+	int i;
+
+	for (i = 0; i < HPOLYC_BLOCK_SIZE; i++)
+		rctx->rbuf[i] ^= 0xff;
+
+	scatterwalk_map_and_copy(rctx->rbuf, req->dst,
+				 req->cryptlen - HPOLYC_BLOCK_SIZE,
+				 HPOLYC_BLOCK_SIZE, 1);
+	return 0;
+}
+
+static void hpolyc_hash2_done(struct crypto_async_request *areq, int err)
+{
+	async_done(areq, err, hpolyc_finish);
+}
+
+/*
+ * Following completion of the XChaCha step, do the second hash step to compute
+ * the last output block.  Note that the last block needs to be subtracted
+ * rather than added, which isn't compatible with typical Poly1305
+ * implementations.  Thus, we use the identity a - b = ~(a + (~b)).
+ */
+static int hpolyc_hash2_step(struct skcipher_request *req, u32 flags)
+{
+	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
+	const struct hpolyc_tfm_ctx *tctx = crypto_skcipher_ctx(tfm);
+	struct hpolyc_request_ctx *rctx = skcipher_request_ctx(req);
+	int i;
+
+	/* If decrypting, decrypt C_M with the block cipher to get P_M */
+	if (!rctx->enc)
+		crypto_cipher_decrypt_one(tctx->blkcipher, rctx->rbuf,
+					  rctx->rbuf);
+
+	for (i = 0; i < HPOLYC_BLOCK_SIZE; i++)
+		rctx->hash_head.skey[i] = rctx->rbuf[i] ^ 0xff;
+
+	sg_chain(rctx->hash_sg, 2, req->dst);
+
+	ahash_request_set_tfm(&rctx->u.poly1305_req, tctx->poly1305);
+	ahash_request_set_crypt(&rctx->u.poly1305_req, rctx->hash_sg,
+				rctx->rbuf, sizeof(rctx->hash_head) +
+				req->cryptlen - HPOLYC_BLOCK_SIZE);
+	ahash_request_set_callback(&rctx->u.poly1305_req, flags,
+				   hpolyc_hash2_done, req);
+	return crypto_ahash_digest(&rctx->u.poly1305_req) ?:
+		hpolyc_finish(req, flags);
+}
+
+static void hpolyc_xchacha_done(struct crypto_async_request *areq, int err)
+{
+	async_done(areq, err, hpolyc_hash2_step);
+}
+
+static int hpolyc_xchacha_step(struct skcipher_request *req, u32 flags)
+{
+	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
+	const struct hpolyc_tfm_ctx *tctx = crypto_skcipher_ctx(tfm);
+	struct hpolyc_request_ctx *rctx = skcipher_request_ctx(req);
+	unsigned int xchacha_len;
+
+	/* If encrypting, encrypt P_M with the block cipher to get C_M */
+	if (rctx->enc)
+		crypto_cipher_encrypt_one(tctx->blkcipher, rctx->rbuf,
+					  rctx->rbuf);
+
+	/* Initialize the rest of the XChaCha IV (first part is C_M) */
+	rctx->rbuf[HPOLYC_BLOCK_SIZE] = 1;
+	memset(&rctx->rbuf[HPOLYC_BLOCK_SIZE + 1], 0,
+	       sizeof(rctx->rbuf) - (HPOLYC_BLOCK_SIZE + 1));
+
+	/*
+	 * XChaCha needs to be done on all the data except the last 16 bytes;
+	 * for disk encryption that usually means 4080 or 496 bytes.  But ChaCha
+	 * implementations tend to be most efficient when passed a whole number
+	 * of 64-byte ChaCha blocks, or sometimes even a multiple of 256 bytes.
+	 * And here it doesn't matter whether the last 16 bytes are written to,
+	 * as the second hash step will overwrite them.  Thus, round the XChaCha
+	 * length up to the next 64-byte boundary if possible.
+	 */
+	xchacha_len = req->cryptlen - HPOLYC_BLOCK_SIZE;
+	if (round_up(xchacha_len, CHACHA_BLOCK_SIZE) <= req->cryptlen)
+		xchacha_len = round_up(xchacha_len, CHACHA_BLOCK_SIZE);
+
+	skcipher_request_set_tfm(&rctx->u.xchacha_req, tctx->xchacha);
+	skcipher_request_set_crypt(&rctx->u.xchacha_req, req->src, req->dst,
+				   xchacha_len, rctx->rbuf);
+	skcipher_request_set_callback(&rctx->u.xchacha_req, flags,
+				      hpolyc_xchacha_done, req);
+	return crypto_skcipher_encrypt(&rctx->u.xchacha_req) ?:
+		hpolyc_hash2_step(req, flags);
+}
+
+static void hpolyc_hash1_done(struct crypto_async_request *areq, int err)
+{
+	async_done(areq, err, hpolyc_xchacha_step);
+}
+
+/*
+ * HPolyC encryption/decryption.
+ *
+ * The first step is to Poly1305-hash the tweak and source data to get P_M (if
+ * encrypting) or C_M (if decrypting), storing the result in rctx->rbuf.
+ * Linux's Poly1305 doesn't use the usual keying mechanism and instead
+ * interprets the data as (rkey, skey, real data), so we pass:
+ *
+ *    1. rkey = poly1305_key
+ *    2. skey = last block of data (P_R or C_R)
+ *    3. tweak block (assuming 12-byte tweak, so it fits in one block)
+ *    4. rest of the data
+ *
+ * We put 1-3 in rctx->hash_head and chain it to the rest from req->src.
+ *
+ * Note: as a future optimization, a keyed version of Poly1305 that is keyed
+ * with the 'rkey' could be implemented, allowing vectorized implementations of
+ * Poly1305 to precompute powers of the key.  Though, that would be most
+ * beneficial on small messages, whereas in the disk/file encryption use case,
+ * longer 512-byte or 4096-byte messages are the most performance-critical.
+ *
+ * Afterwards, we continue on to the XChaCha step.
+ */
+static int hpolyc_crypt(struct skcipher_request *req, bool enc)
+{
+	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
+	const struct hpolyc_tfm_ctx *tctx = crypto_skcipher_ctx(tfm);
+	struct hpolyc_request_ctx *rctx = skcipher_request_ctx(req);
+
+	if (req->cryptlen < HPOLYC_BLOCK_SIZE)
+		return -EINVAL;
+
+	rctx->enc = enc;
+
+	BUILD_BUG_ON(sizeof(rctx->hash_head) % HPOLYC_BLOCK_SIZE != 0);
+	BUILD_BUG_ON(HPOLYC_HASH_KEY_SIZE != HPOLYC_BLOCK_SIZE);
+	BUILD_BUG_ON(sizeof(__le32) + HPOLYC_IV_SIZE != HPOLYC_BLOCK_SIZE);
+	memcpy(rctx->hash_head.rkey, tctx->poly1305_key, HPOLYC_BLOCK_SIZE);
+	scatterwalk_map_and_copy(rctx->hash_head.skey, req->src,
+				 req->cryptlen - HPOLYC_BLOCK_SIZE,
+				 HPOLYC_BLOCK_SIZE, 0);
+	rctx->hash_head.tweak_len = cpu_to_le32(8 * HPOLYC_IV_SIZE);
+	memcpy(rctx->hash_head.tweak, req->iv, HPOLYC_IV_SIZE);
+
+	sg_init_table(rctx->hash_sg, 2);
+	sg_set_buf(&rctx->hash_sg[0], &rctx->hash_head,
+		   sizeof(rctx->hash_head));
+	sg_chain(rctx->hash_sg, 2, req->src);
+
+	ahash_request_set_tfm(&rctx->u.poly1305_req, tctx->poly1305);
+	ahash_request_set_crypt(&rctx->u.poly1305_req, rctx->hash_sg,
+				rctx->rbuf, sizeof(rctx->hash_head) +
+				req->cryptlen - HPOLYC_BLOCK_SIZE);
+	ahash_request_set_callback(&rctx->u.poly1305_req, req->base.flags,
+				   hpolyc_hash1_done, req);
+	return crypto_ahash_digest(&rctx->u.poly1305_req) ?:
+		hpolyc_xchacha_step(req, req->base.flags);
+}
+
+static int hpolyc_encrypt(struct skcipher_request *req)
+{
+	return hpolyc_crypt(req, true);
+}
+
+static int hpolyc_decrypt(struct skcipher_request *req)
+{
+	return hpolyc_crypt(req, false);
+}
+
+static int hpolyc_init_tfm(struct crypto_skcipher *tfm)
+{
+	struct skcipher_instance *inst = skcipher_alg_instance(tfm);
+	struct hpolyc_instance_ctx *ictx = skcipher_instance_ctx(inst);
+	struct hpolyc_tfm_ctx *tctx = crypto_skcipher_ctx(tfm);
+	struct crypto_ahash *poly1305;
+	struct crypto_skcipher *xchacha;
+	struct crypto_cipher *blkcipher;
+	int err;
+
+	poly1305 = crypto_spawn_ahash(&ictx->poly1305_spawn);
+	if (IS_ERR(poly1305))
+		return PTR_ERR(poly1305);
+
+	xchacha = crypto_spawn_skcipher(&ictx->xchacha_spawn);
+	if (IS_ERR(xchacha)) {
+		err = PTR_ERR(xchacha);
+		goto err_free_poly1305;
+	}
+
+	blkcipher = crypto_spawn_cipher(&ictx->blkcipher_spawn);
+	if (IS_ERR(blkcipher)) {
+		err = PTR_ERR(blkcipher);
+		goto err_free_xchacha;
+	}
+
+	tctx->poly1305 = poly1305;
+	tctx->xchacha = xchacha;
+	tctx->blkcipher = blkcipher;
+
+	crypto_skcipher_set_reqsize(tfm,
+				    offsetof(struct hpolyc_request_ctx, u) +
+				    max(FIELD_SIZEOF(struct hpolyc_request_ctx,
+						     u.poly1305_req) +
+					crypto_ahash_reqsize(poly1305),
+					FIELD_SIZEOF(struct hpolyc_request_ctx,
+						     u.xchacha_req) +
+					crypto_skcipher_reqsize(xchacha)));
+	return 0;
+
+err_free_xchacha:
+	crypto_free_skcipher(xchacha);
+err_free_poly1305:
+	crypto_free_ahash(poly1305);
+	return err;
+}
+
+static void hpolyc_exit_tfm(struct crypto_skcipher *tfm)
+{
+	struct hpolyc_tfm_ctx *tctx = crypto_skcipher_ctx(tfm);
+
+	crypto_free_ahash(tctx->poly1305);
+	crypto_free_skcipher(tctx->xchacha);
+	crypto_free_cipher(tctx->blkcipher);
+}
+
+static void hpolyc_free_instance(struct skcipher_instance *inst)
+{
+	struct hpolyc_instance_ctx *ictx = skcipher_instance_ctx(inst);
+
+	crypto_drop_ahash(&ictx->poly1305_spawn);
+	crypto_drop_skcipher(&ictx->xchacha_spawn);
+	crypto_drop_spawn(&ictx->blkcipher_spawn);
+	kfree(inst);
+}
+
+static int hpolyc_create(struct crypto_template *tmpl, struct rtattr **tb)
+{
+	struct crypto_attr_type *algt;
+	u32 mask;
+	const char *xchacha_name;
+	const char *blkcipher_name;
+	struct skcipher_instance *inst;
+	struct hpolyc_instance_ctx *ictx;
+	struct crypto_alg *poly1305_alg;
+	struct hash_alg_common *poly1305;
+	struct crypto_alg *blkcipher_alg;
+	struct skcipher_alg *xchacha_alg;
+	int err;
+
+	algt = crypto_get_attr_type(tb);
+	if (IS_ERR(algt))
+		return PTR_ERR(algt);
+
+	if ((algt->type ^ CRYPTO_ALG_TYPE_SKCIPHER) & algt->mask)
+		return -EINVAL;
+
+	mask = crypto_requires_sync(algt->type, algt->mask);
+
+	xchacha_name = crypto_attr_alg_name(tb[1]);
+	if (IS_ERR(xchacha_name))
+		return PTR_ERR(xchacha_name);
+
+	blkcipher_name = crypto_attr_alg_name(tb[2]);
+	if (IS_ERR(blkcipher_name))
+		return PTR_ERR(blkcipher_name);
+
+	inst = kzalloc(sizeof(*inst) + sizeof(*ictx), GFP_KERNEL);
+	if (!inst)
+		return -ENOMEM;
+	ictx = skcipher_instance_ctx(inst);
+
+	/* Poly1305 */
+
+	poly1305_alg = crypto_find_alg("poly1305", &crypto_ahash_type, 0, mask);
+	if (IS_ERR(poly1305_alg)) {
+		err = PTR_ERR(poly1305_alg);
+		goto out_free_inst;
+	}
+	poly1305 = __crypto_hash_alg_common(poly1305_alg);
+	err = crypto_init_ahash_spawn(&ictx->poly1305_spawn, poly1305,
+				      skcipher_crypto_instance(inst));
+	if (err) {
+		crypto_mod_put(poly1305_alg);
+		goto out_free_inst;
+	}
+	err = -EINVAL;
+	if (poly1305->digestsize != HPOLYC_BLOCK_SIZE)
+		goto out_drop_poly1305;
+
+	/* XChaCha */
+
+	err = crypto_grab_skcipher(&ictx->xchacha_spawn, xchacha_name, 0, mask);
+	if (err)
+		goto out_drop_poly1305;
+	xchacha_alg = crypto_spawn_skcipher_alg(&ictx->xchacha_spawn);
+	err = -EINVAL;
+	if (xchacha_alg->min_keysize != HPOLYC_STREAM_KEY_SIZE ||
+	    xchacha_alg->max_keysize != HPOLYC_STREAM_KEY_SIZE)
+		goto out_drop_xchacha;
+	if (xchacha_alg->base.cra_blocksize != 1)
+		goto out_drop_xchacha;
+	if (crypto_skcipher_alg_ivsize(xchacha_alg) != XCHACHA_IV_SIZE)
+		goto out_drop_xchacha;
+
+	/* Block cipher */
+
+	err = crypto_grab_spawn(&ictx->blkcipher_spawn, blkcipher_name,
+				CRYPTO_ALG_TYPE_CIPHER, CRYPTO_ALG_TYPE_MASK);
+	if (err)
+		goto out_drop_xchacha;
+	blkcipher_alg = ictx->blkcipher_spawn.alg;
+	err = -EINVAL;
+	if (blkcipher_alg->cra_blocksize != HPOLYC_BLOCK_SIZE)
+		goto out_drop_blkcipher;
+	if (blkcipher_alg->cra_cipher.cia_min_keysize >
+	    HPOLYC_BLKCIPHER_KEY_SIZE ||
+	    blkcipher_alg->cra_cipher.cia_max_keysize <
+	    HPOLYC_BLKCIPHER_KEY_SIZE)
+		goto out_drop_blkcipher;
+
+	/* Instance fields */
+
+	err = -ENAMETOOLONG;
+	if (snprintf(inst->alg.base.cra_name, CRYPTO_MAX_ALG_NAME,
+		     "hpolyc(%s,%s)",
+		     xchacha_alg->base.cra_name,
+		     blkcipher_alg->cra_name) >= CRYPTO_MAX_ALG_NAME)
+		goto out_drop_blkcipher;
+	if (snprintf(inst->alg.base.cra_driver_name, CRYPTO_MAX_ALG_NAME,
+		     "hpolyc(%s,%s,%s)",
+		     poly1305_alg->cra_driver_name,
+		     xchacha_alg->base.cra_driver_name,
+		     blkcipher_alg->cra_driver_name) >= CRYPTO_MAX_ALG_NAME)
+		goto out_drop_blkcipher;
+
+	inst->alg.base.cra_blocksize = HPOLYC_BLOCK_SIZE;
+	inst->alg.base.cra_ctxsize = sizeof(struct hpolyc_tfm_ctx);
+	inst->alg.base.cra_alignmask = xchacha_alg->base.cra_alignmask |
+					poly1305_alg->cra_alignmask;
+	/*
+	 * The block cipher is only invoked once per message, so for long
+	 * messages (e.g. sectors for disk encryption) its performance doesn't
+	 * matter nearly as much as that of XChaCha and Poly1305.  Thus, weigh
+	 * the block cipher's ->cra_priority less.
+	 */
+	inst->alg.base.cra_priority = (2 * xchacha_alg->base.cra_priority +
+				       2 * poly1305_alg->cra_priority +
+				       blkcipher_alg->cra_priority) / 5;
+
+	inst->alg.setkey = hpolyc_setkey;
+	inst->alg.encrypt = hpolyc_encrypt;
+	inst->alg.decrypt = hpolyc_decrypt;
+	inst->alg.init = hpolyc_init_tfm;
+	inst->alg.exit = hpolyc_exit_tfm;
+	inst->alg.min_keysize = HPOLYC_STREAM_KEY_SIZE;
+	inst->alg.max_keysize = HPOLYC_STREAM_KEY_SIZE;
+	inst->alg.ivsize = HPOLYC_IV_SIZE;
+
+	inst->free = hpolyc_free_instance;
+
+	err = skcipher_register_instance(tmpl, inst);
+	if (err)
+		goto out_drop_blkcipher;
+
+	return 0;
+
+out_drop_blkcipher:
+	crypto_drop_spawn(&ictx->blkcipher_spawn);
+out_drop_xchacha:
+	crypto_drop_skcipher(&ictx->xchacha_spawn);
+out_drop_poly1305:
+	crypto_drop_ahash(&ictx->poly1305_spawn);
+out_free_inst:
+	kfree(inst);
+	return err;
+}
+
+/* hpolyc(xchacha_name, blkcipher_name) */
+static struct crypto_template hpolyc_tmpl = {
+	.name = "hpolyc",
+	.create = hpolyc_create,
+	.module = THIS_MODULE,
+};
+
+static int hpolyc_module_init(void)
+{
+	return crypto_register_template(&hpolyc_tmpl);
+}
+
+static void __exit hpolyc_module_exit(void)
+{
+	crypto_unregister_template(&hpolyc_tmpl);
+}
+
+module_init(hpolyc_module_init);
+module_exit(hpolyc_module_exit);
+
+MODULE_DESCRIPTION("HPolyC length-preserving encryption mode");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Eric Biggers <ebiggers@google.com>");
+MODULE_ALIAS_CRYPTO("hpolyc");
diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index c06aeb1f01bc..c0511ffd997e 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -3184,6 +3184,18 @@ static const struct alg_test_desc alg_test_descs[] = {
 		.suite = {
 			.hash = __VECS(hmac_sha512_tv_template)
 		}
+	}, {
+		.alg = "hpolyc(xchacha12,aes)",
+		.test = alg_test_skcipher,
+		.suite = {
+			.cipher = __VECS(hpolyc_xchacha12_aes_tv_template)
+		},
+	}, {
+		.alg = "hpolyc(xchacha20,aes)",
+		.test = alg_test_skcipher,
+		.suite = {
+			.cipher = __VECS(hpolyc_xchacha20_aes_tv_template)
+		},
 	}, {
 		.alg = "jitterentropy_rng",
 		.fips_allowed = 1,
diff --git a/crypto/testmgr.h b/crypto/testmgr.h
index ba5c31ada273..27242c74a1fb 100644
--- a/crypto/testmgr.h
+++ b/crypto/testmgr.h
@@ -32568,6 +32568,164 @@ static const struct cipher_testvec xchacha12_tv_template[] = {
 	},
 };
 
+/*
+ * Some HPolyC-XChaCha20-AES test vectors, taken from the reference code:
+ * https://github.com/google/hpolyc/blob/master/test_vectors/ours/HPolyC/HPolyC_XChaCha20_32_AES256.json
+ */
+static const struct cipher_testvec hpolyc_xchacha20_aes_tv_template[] = {
+	{
+		.key	= "\x86\x1b\xc2\xf4\xa4\x19\xa7\x5f"
+			  "\x86\xe4\xbd\x55\xc0\x36\x66\xae"
+			  "\x1b\x79\x72\x6f\x95\xc5\x85\xb7"
+			  "\xb7\xf6\x5d\xa4\xff\xef\xcd\x2f",
+		.klen	= 32,
+		.iv	= "\x23\x4f\xff\xd4\x5a\xcc\x74\x56"
+			  "\x9c\x01\x08\xb8",
+		.ptext	= "\xb1\x5b\x42\xc7\x95\xfa\x2f\xac"
+			  "\xee\x90\xe0\xa2\x97\x1c\xba\x40",
+		.ctext	= "\xa4\x02\xf0\xd1\x51\x69\x00\x5d"
+			  "\x87\x61\x9b\xa2\x75\x23\x40\x94",
+		.len	= 16,
+	}, {
+		.key	= "\xce\x94\xdc\xc7\x33\xd6\x43\x99"
+			  "\x03\x51\x3f\x6f\xee\x8e\xea\x83"
+			  "\x1c\x99\x1a\x31\x88\xf9\x28\x81"
+			  "\x10\xd9\x68\x8c\xfd\x36\x3f\x81",
+		.klen	= 32,
+		.iv	= "\xbb\x17\x6f\x18\xbc\x07\xb1\xbc"
+			  "\x21\x16\xdf\x8e",
+		.ptext	= "\x0a\xcc\x14\x3b\x1f\x4e\x69\x88"
+			  "\xe7\xe5\x69\xbb\x0d\xa5\xd6\x28"
+			  "\xfb\x14\xe1\xec\xa9\x4c\x1c\x0e"
+			  "\xe6\x0e\xce\xa4\x0b\xcc\x12",
+		.ctext	= "\xed\xfa\x38\x58\x8a\x9b\xd5\xb0"
+			  "\xda\xd5\xe7\x10\xe0\xd5\xbb\x1f"
+			  "\xe2\xd7\xe7\x61\x71\x2e\x58\xc7"
+			  "\xd9\x2d\x49\xbc\x7b\xa3\x7e",
+		.len	= 31,
+	}, {
+		.key	= "\x59\x62\xdc\xdc\xd3\xb5\x6b\x49"
+			  "\xc6\xc2\xc4\xdf\xbc\x23\x66\x7a"
+			  "\x93\x9a\x11\xb6\x59\xd6\x60\x01"
+			  "\x17\x18\x76\xe2\x60\x1c\x28\xad",
+		.klen	= 32,
+		.iv	= "\xac\x80\x02\x91\xfa\xd5\x31\xfe"
+			  "\xfa\xff\xec\x00",
+		.ptext	= "\xd5\x6d\x14\x2e\x21\xb4\x45\x69"
+			  "\xf4\x48\x0d\x27\x09\x69\xba\xa0"
+			  "\xe6\x2a\xd4\x23\xdb\xf4\xc3\xc6"
+			  "\x1c\xab\x74\x74\x15\x7b\x95\x0c"
+			  "\x13\x8b\x39\x74\x23\x12\x9e\xb2"
+			  "\x2a\x6a\xf6\x82\x75\xcc\x97\x3c"
+			  "\x74\xc7\x06\x90\x78\xca\x78\x7a"
+			  "\x6b\x5b\xda\xf7\xec\x07\x13\xc6"
+			  "\xd5\x51\xa2\x23\x20\x3d\xb8\x49"
+			  "\x40\x12\x99\x88\x8e\x60\x0e\x0c"
+			  "\x90\x51\x49\x5e\x52\x94\xbf\x47"
+			  "\x86\xbe\xc8\x8e\x04\xc4\xd2\x8f"
+			  "\x17\x9f\xdb\xc2\xf3\x8d\xbb\x36"
+			  "\xe8\x97\x0c\xe8\x83\xf6\xa4\xd4"
+			  "\x23\xdb\x5e\x64\xe8\x17\x80\xf5"
+			  "\xe0\x4f\x33\xdf\xc5\xac\x79\x44",
+		.ctext	= "\xde\x99\xb2\xb4\x53\xf7\xf4\xd6"
+			  "\xdd\x2e\x42\x02\xd5\x05\x4d\x20"
+			  "\xb1\xef\xa1\x6e\x9d\xa3\x58\x7c"
+			  "\x25\xfa\xd5\x5e\x79\xb4\xd6\xd1"
+			  "\x84\xad\x74\xa1\x27\x72\xc7\x37"
+			  "\x4e\x0e\x1e\x94\xa0\x87\x2f\xfa"
+			  "\xa5\xbf\xe2\xbd\x21\xd1\xe9\x16"
+			  "\xc9\x19\xcf\xfa\x84\x0a\x19\x66"
+			  "\x33\xf9\xbf\xff\xab\x6b\x87\xd2"
+			  "\x92\x69\xc3\xeb\x54\xbc\x1b\xd9"
+			  "\x58\x12\x17\xd4\x90\xa2\xc6\xe1"
+			  "\xbe\x15\x8b\x9d\x06\xde\x80\x76"
+			  "\x69\x03\xc7\x87\xff\x28\x03\x3a"
+			  "\xbe\x11\x3a\xd3\x26\x27\x9d\x91"
+			  "\x4a\x3f\x99\x10\x10\x51\xd3\x63"
+			  "\x5e\x13\x41\xd2\x82\x16\xbc\xb7",
+		.len	= 128,
+	},
+};
+
+/*
+ * Some HPolyC-XChaCha12-AES test vectors, taken from the reference code:
+ * https://github.com/google/hpolyc/blob/master/test_vectors/ours/HPolyC/HPolyC_XChaCha12_32_AES256.json
+ */
+static const struct cipher_testvec hpolyc_xchacha12_aes_tv_template[] = {
+	{
+		.key	= "\x86\x1b\xc2\xf4\xa4\x19\xa7\x5f"
+			  "\x86\xe4\xbd\x55\xc0\x36\x66\xae"
+			  "\x1b\x79\x72\x6f\x95\xc5\x85\xb7"
+			  "\xb7\xf6\x5d\xa4\xff\xef\xcd\x2f",
+		.klen	= 32,
+		.iv	= "\x23\x4f\xff\xd4\x5a\xcc\x74\x56"
+			  "\x9c\x01\x08\xb8",
+		.ptext	= "\xb1\x5b\x42\xc7\x95\xfa\x2f\xac"
+			  "\xee\x90\xe0\xa2\x97\x1c\xba\x40",
+		.ctext	= "\x9d\xe4\x4b\xa8\x34\x89\x93\x19"
+			  "\x7c\x89\x11\x0e\x50\x80\xa4\x8b",
+		.len	= 16,
+	}, {
+		.key	= "\xce\x94\xdc\xc7\x33\xd6\x43\x99"
+			  "\x03\x51\x3f\x6f\xee\x8e\xea\x83"
+			  "\x1c\x99\x1a\x31\x88\xf9\x28\x81"
+			  "\x10\xd9\x68\x8c\xfd\x36\x3f\x81",
+		.klen	= 32,
+		.iv	= "\xbb\x17\x6f\x18\xbc\x07\xb1\xbc"
+			  "\x21\x16\xdf\x8e",
+		.ptext	= "\xf4\x4c\x81\xb5\x26\xf4\x59\x5f"
+			  "\x5f\x8f\xa7\xc9\xa4\x3f\xf0\x5d"
+			  "\x00\xd7\x58\xe4\x5a\xb8\xc3\xf5"
+			  "\xe1\xf5\x7d\xff\xca\x8a\x00",
+		.ctext	= "\xed\xfa\x38\x58\x8a\x9b\xd5\xb0"
+			  "\xda\xd5\xe7\x10\xe0\xd5\xbb\x1f"
+			  "\xe2\xd7\xe7\x61\x71\x2e\x58\xc7"
+			  "\xd9\x2d\x49\xbc\x7b\xa3\x7e",
+		.len	= 31,
+	}, {
+		.key	= "\x59\x62\xdc\xdc\xd3\xb5\x6b\x49"
+			  "\xc6\xc2\xc4\xdf\xbc\x23\x66\x7a"
+			  "\x93\x9a\x11\xb6\x59\xd6\x60\x01"
+			  "\x17\x18\x76\xe2\x60\x1c\x28\xad",
+		.klen	= 32,
+		.iv	= "\xac\x80\x02\x91\xfa\xd5\x31\xfe"
+			  "\xfa\xff\xec\x00",
+		.ptext	= "\xd5\x6d\x14\x2e\x21\xb4\x45\x69"
+			  "\xf4\x48\x0d\x27\x09\x69\xba\xa0"
+			  "\xe6\x2a\xd4\x23\xdb\xf4\xc3\xc6"
+			  "\x1c\xab\x74\x74\x15\x7b\x95\x0c"
+			  "\x13\x8b\x39\x74\x23\x12\x9e\xb2"
+			  "\x2a\x6a\xf6\x82\x75\xcc\x97\x3c"
+			  "\x74\xc7\x06\x90\x78\xca\x78\x7a"
+			  "\x6b\x5b\xda\xf7\xec\x07\x13\xc6"
+			  "\xd5\x51\xa2\x23\x20\x3d\xb8\x49"
+			  "\x40\x12\x99\x88\x8e\x60\x0e\x0c"
+			  "\x90\x51\x49\x5e\x52\x94\xbf\x47"
+			  "\x86\xbe\xc8\x8e\x04\xc4\xd2\x8f"
+			  "\x17\x9f\xdb\xc2\xf3\x8d\xbb\x36"
+			  "\xe8\x97\x0c\xe8\x83\xf6\xa4\xd4"
+			  "\x23\xdb\x5e\x64\xe8\x17\x80\xf5"
+			  "\xe0\x4f\x33\xdf\xc5\xac\x79\x44",
+		.ctext	= "\x04\x52\x8e\x33\xb7\xa5\x37\xd7"
+			  "\x3a\x4d\x98\x3c\x25\x87\x8b\x7d"
+			  "\xa8\x10\xfe\x20\x4e\xdc\x19\xf3"
+			  "\x34\x01\xa6\x3d\xb7\xf3\x14\x4d"
+			  "\x10\xcb\xae\x4b\xe6\x5f\xa9\x50"
+			  "\xee\xe4\x41\x0c\xae\xa5\x51\x66"
+			  "\x28\xa5\x16\xed\x55\xa3\x8a\x86"
+			  "\x15\x33\x92\x98\xa3\x73\x70\x9d"
+			  "\xeb\x11\xb6\xf4\xdd\x53\xa9\xa3"
+			  "\x5e\x5f\x70\x0e\x50\x1b\xca\x34"
+			  "\x5c\xa6\xd9\x05\x47\x0b\x6d\x74"
+			  "\x64\xa1\x83\x59\x73\xfa\x83\x1c"
+			  "\x35\x79\xa9\x9d\x2c\xaf\x54\x19"
+			  "\x03\xff\x66\xfb\xb5\x55\xe4\x2b"
+			  "\x7d\x93\x0e\x85\x62\x21\x20\xc0"
+			  "\xb9\x7c\xa9\xd2\xd7\x5c\x50\x9a",
+		.len	= 128,
+	},
+};
+
 /*
  * CTS (Cipher Text Stealing) mode tests
  */
-- 
2.18.0.597.ga71716f1ad-goog

