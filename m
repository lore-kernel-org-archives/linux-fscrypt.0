Return-Path: <linux-crypto-owner@vger.kernel.org>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v3 01/28] crypto: change backlog return code to -EIOCBQUEUED
Date: Sun,  2 Jul 2017 17:41:43 +0300
Message-Id: <1499006535-19760-2-git-send-email-gilad@benyossef.com>
In-Reply-To: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
References: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
Cc: Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

The crypto API was using the -EBUSY return value to indicate
both a hard failure to submit a crypto operation into a
transformation provider when the latter was busy and the backlog
mechanism was not enabled as well as a notification that the operation
was queued into the backlog when the backlog mechanism was enabled.

Having the same return code indicate two very different conditions
depending on a flag is both error prone and requires extra runtime
check like the following to discern between the cases:

	if (err == -EINPROGRESS ||
	    (err == -EBUSY && (ahash_request_flags(req) &
			       CRYPTO_TFM_REQ_MAY_BACKLOG)))

This patch changes the return code used to indicate a crypto op
was queued in the backlog to -EIOCBQUEUED, thus resolving both
issues.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 crypto/af_alg.c                     |  2 +-
 crypto/ahash.c                      | 12 +++---------
 crypto/algapi.c                     |  6 ++++--
 crypto/asymmetric_keys/public_key.c |  2 +-
 crypto/chacha20poly1305.c           |  2 +-
 crypto/cryptd.c                     |  4 +---
 crypto/cts.c                        |  6 ++----
 crypto/drbg.c                       |  2 +-
 crypto/gcm.c                        |  2 +-
 crypto/lrw.c                        |  8 ++------
 crypto/rsa-pkcs1pad.c               | 16 ++++------------
 crypto/tcrypt.c                     |  6 +++---
 crypto/testmgr.c                    | 12 ++++++------
 crypto/xts.c                        |  8 ++------
 14 files changed, 32 insertions(+), 56 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 3556d8e..c67daba 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -484,7 +484,7 @@ int af_alg_wait_for_completion(int err, struct af_alg_completion *completion)
 {
 	switch (err) {
 	case -EINPROGRESS:
-	case -EBUSY:
+	case -EIOCBQUEUED:
 		wait_for_completion(&completion->completion);
 		reinit_completion(&completion->completion);
 		err = completion->err;
diff --git a/crypto/ahash.c b/crypto/ahash.c
index 826cd7a..65d08db 100644
--- a/crypto/ahash.c
+++ b/crypto/ahash.c
@@ -334,9 +334,7 @@ static int ahash_op_unaligned(struct ahash_request *req,
 		return err;
 
 	err = op(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && (ahash_request_flags(req) &
-			       CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err == -EINPROGRESS || err == -EIOCBQUEUED)
 		return err;
 
 	ahash_restore_req(req, err);
@@ -394,9 +392,7 @@ static int ahash_def_finup_finish1(struct ahash_request *req, int err)
 	req->base.complete = ahash_def_finup_done2;
 
 	err = crypto_ahash_reqtfm(req)->final(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && (ahash_request_flags(req) &
-			       CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err == -EINPROGRESS || err == -EIOCBQUEUED)
 		return err;
 
 out:
@@ -432,9 +428,7 @@ static int ahash_def_finup(struct ahash_request *req)
 		return err;
 
 	err = tfm->update(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && (ahash_request_flags(req) &
-			       CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err == -EINPROGRESS || err == -EIOCBQUEUED)
 		return err;
 
 	return ahash_def_finup_finish1(req, err);
diff --git a/crypto/algapi.c b/crypto/algapi.c
index e4cc761..3bfd1fa 100644
--- a/crypto/algapi.c
+++ b/crypto/algapi.c
@@ -897,9 +897,11 @@ int crypto_enqueue_request(struct crypto_queue *queue,
 	int err = -EINPROGRESS;
 
 	if (unlikely(queue->qlen >= queue->max_qlen)) {
-		err = -EBUSY;
-		if (!(request->flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (!(request->flags & CRYPTO_TFM_REQ_MAY_BACKLOG)) {
+			err = -EBUSY;
 			goto out;
+		}
+		err = -EIOCBQUEUED;
 		if (queue->backlog == &queue->list)
 			queue->backlog = &request->list;
 	}
diff --git a/crypto/asymmetric_keys/public_key.c b/crypto/asymmetric_keys/public_key.c
index 3cd6e12..3fad1fd 100644
--- a/crypto/asymmetric_keys/public_key.c
+++ b/crypto/asymmetric_keys/public_key.c
@@ -141,7 +141,7 @@ int public_key_verify_signature(const struct public_key *pkey,
 	 * signature and returns that to us.
 	 */
 	ret = crypto_akcipher_verify(req);
-	if ((ret == -EINPROGRESS) || (ret == -EBUSY)) {
+	if ((ret == -EINPROGRESS) || (ret == -EIOCBQUEUED)) {
 		wait_for_completion(&compl.completion);
 		ret = compl.err;
 	}
diff --git a/crypto/chacha20poly1305.c b/crypto/chacha20poly1305.c
index db1bc31..e0e2785 100644
--- a/crypto/chacha20poly1305.c
+++ b/crypto/chacha20poly1305.c
@@ -79,7 +79,7 @@ static inline void async_done_continue(struct aead_request *req, int err,
 	if (!err)
 		err = cont(req);
 
-	if (err != -EINPROGRESS && err != -EBUSY)
+	if (err != -EINPROGRESS && err != -EIOCBQUEUED)
 		aead_request_complete(req, err);
 }
 
diff --git a/crypto/cryptd.c b/crypto/cryptd.c
index 0508c48..5daca13 100644
--- a/crypto/cryptd.c
+++ b/crypto/cryptd.c
@@ -137,16 +137,14 @@ static int cryptd_enqueue_request(struct cryptd_queue *queue,
 	int cpu, err;
 	struct cryptd_cpu_queue *cpu_queue;
 	atomic_t *refcnt;
-	bool may_backlog;
 
 	cpu = get_cpu();
 	cpu_queue = this_cpu_ptr(queue->cpu_queue);
 	err = crypto_enqueue_request(&cpu_queue->queue, request);
 
 	refcnt = crypto_tfm_ctx(request->tfm);
-	may_backlog = request->flags & CRYPTO_TFM_REQ_MAY_BACKLOG;
 
-	if (err == -EBUSY && !may_backlog)
+	if (err == -EBUSY)
 		goto out_put_cpu;
 
 	queue_work_on(cpu, kcrypto_wq, &cpu_queue->work);
diff --git a/crypto/cts.c b/crypto/cts.c
index 243f591..e2068dc 100644
--- a/crypto/cts.c
+++ b/crypto/cts.c
@@ -136,8 +136,7 @@ static void crypto_cts_encrypt_done(struct crypto_async_request *areq, int err)
 		goto out;
 
 	err = cts_cbc_encrypt(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+	if (err == -EINPROGRESS || err == -EIOCBQUEUED)
 		return;
 
 out:
@@ -229,8 +228,7 @@ static void crypto_cts_decrypt_done(struct crypto_async_request *areq, int err)
 		goto out;
 
 	err = cts_cbc_decrypt(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+	if (err == -EINPROGRESS || err == -EIOCBQUEUED)
 		return;
 
 out:
diff --git a/crypto/drbg.c b/crypto/drbg.c
index 633a88e..850b451 100644
--- a/crypto/drbg.c
+++ b/crypto/drbg.c
@@ -1767,7 +1767,7 @@ static int drbg_kcapi_sym_ctr(struct drbg_state *drbg,
 		case 0:
 			break;
 		case -EINPROGRESS:
-		case -EBUSY:
+		case -EIOCBQUEUED:
 			wait_for_completion(&drbg->ctr_completion);
 			if (!drbg->ctr_async_err) {
 				reinit_completion(&drbg->ctr_completion);
diff --git a/crypto/gcm.c b/crypto/gcm.c
index 3841b5e..ffac821 100644
--- a/crypto/gcm.c
+++ b/crypto/gcm.c
@@ -151,7 +151,7 @@ static int crypto_gcm_setkey(struct crypto_aead *aead, const u8 *key,
 				   sizeof(data->hash), data->iv);
 
 	err = crypto_skcipher_encrypt(&data->req);
-	if (err == -EINPROGRESS || err == -EBUSY) {
+	if (err == -EINPROGRESS || err == -EIOCBQUEUED) {
 		wait_for_completion(&data->result.completion);
 		err = data->result.err;
 	}
diff --git a/crypto/lrw.c b/crypto/lrw.c
index a8bfae4..e2b1378 100644
--- a/crypto/lrw.c
+++ b/crypto/lrw.c
@@ -328,9 +328,7 @@ static int do_encrypt(struct skcipher_request *req, int err)
 		      crypto_skcipher_encrypt(subreq) ?:
 		      post_crypt(req);
 
-		if (err == -EINPROGRESS ||
-		    (err == -EBUSY &&
-		     req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (err == -EINPROGRESS || err == -EIOCBQUEUED)
 			return err;
 	}
 
@@ -380,9 +378,7 @@ static int do_decrypt(struct skcipher_request *req, int err)
 		      crypto_skcipher_decrypt(subreq) ?:
 		      post_crypt(req);
 
-		if (err == -EINPROGRESS ||
-		    (err == -EBUSY &&
-		     req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (err == -EINPROGRESS || err == -EIOCBQUEUED)
 			return err;
 	}
 
diff --git a/crypto/rsa-pkcs1pad.c b/crypto/rsa-pkcs1pad.c
index 407c64b..3c82542 100644
--- a/crypto/rsa-pkcs1pad.c
+++ b/crypto/rsa-pkcs1pad.c
@@ -279,9 +279,7 @@ static int pkcs1pad_encrypt(struct akcipher_request *req)
 				   req->dst, ctx->key_size - 1, req->dst_len);
 
 	err = crypto_akcipher_encrypt(&req_ctx->child_req);
-	if (err != -EINPROGRESS &&
-			(err != -EBUSY ||
-			 !(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err != -EINPROGRESS && err != -EIOCBQUEUED)
 		return pkcs1pad_encrypt_sign_complete(req, err);
 
 	return err;
@@ -383,9 +381,7 @@ static int pkcs1pad_decrypt(struct akcipher_request *req)
 				   ctx->key_size);
 
 	err = crypto_akcipher_decrypt(&req_ctx->child_req);
-	if (err != -EINPROGRESS &&
-			(err != -EBUSY ||
-			 !(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err != -EINPROGRESS && err != -EIOCBQUEUED)
 		return pkcs1pad_decrypt_complete(req, err);
 
 	return err;
@@ -440,9 +436,7 @@ static int pkcs1pad_sign(struct akcipher_request *req)
 				   req->dst, ctx->key_size - 1, req->dst_len);
 
 	err = crypto_akcipher_sign(&req_ctx->child_req);
-	if (err != -EINPROGRESS &&
-			(err != -EBUSY ||
-			 !(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err != -EINPROGRESS && err != -EIOCBQUEUED)
 		return pkcs1pad_encrypt_sign_complete(req, err);
 
 	return err;
@@ -561,9 +555,7 @@ static int pkcs1pad_verify(struct akcipher_request *req)
 				   ctx->key_size);
 
 	err = crypto_akcipher_verify(&req_ctx->child_req);
-	if (err != -EINPROGRESS &&
-			(err != -EBUSY ||
-			 !(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err != -EINPROGRESS && err != -EIOCBQUEUED)
 		return pkcs1pad_verify_complete(req, err);
 
 	return err;
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 0dd6a43..57f7ac4 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -97,7 +97,7 @@ static void tcrypt_complete(struct crypto_async_request *req, int err)
 
 static inline int do_one_aead_op(struct aead_request *req, int ret)
 {
-	if (ret == -EINPROGRESS || ret == -EBUSY) {
+	if (ret == -EINPROGRESS || ret == -EIOCBQUEUED) {
 		struct tcrypt_result *tr = req->base.data;
 
 		ret = wait_for_completion_interruptible(&tr->completion);
@@ -397,7 +397,7 @@ static void test_hash_sg_init(struct scatterlist *sg)
 
 static inline int do_one_ahash_op(struct ahash_request *req, int ret)
 {
-	if (ret == -EINPROGRESS || ret == -EBUSY) {
+	if (ret == -EINPROGRESS || ret == -EIOCBQUEUED) {
 		struct tcrypt_result *tr = req->base.data;
 
 		wait_for_completion(&tr->completion);
@@ -765,7 +765,7 @@ static void test_hash_speed(const char *algo, unsigned int secs,
 
 static inline int do_one_acipher_op(struct skcipher_request *req, int ret)
 {
-	if (ret == -EINPROGRESS || ret == -EBUSY) {
+	if (ret == -EINPROGRESS || ret == -EIOCBQUEUED) {
 		struct tcrypt_result *tr = req->base.data;
 
 		wait_for_completion(&tr->completion);
diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index 7125ba3..fb5418f 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -195,7 +195,7 @@ static void testmgr_free_buf(char *buf[XBUFSIZE])
 
 static int wait_async_op(struct tcrypt_result *tr, int ret)
 {
-	if (ret == -EINPROGRESS || ret == -EBUSY) {
+	if (ret == -EINPROGRESS || ret == -EIOCBQUEUED) {
 		wait_for_completion(&tr->completion);
 		reinit_completion(&tr->completion);
 		ret = tr->err;
@@ -425,7 +425,7 @@ static int __test_hash(struct crypto_ahash *tfm,
 		case 0:
 			break;
 		case -EINPROGRESS:
-		case -EBUSY:
+		case -EIOCBQUEUED:
 			wait_for_completion(&tresult.completion);
 			reinit_completion(&tresult.completion);
 			ret = tresult.err;
@@ -723,7 +723,7 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 			}
 			break;
 		case -EINPROGRESS:
-		case -EBUSY:
+		case -EIOCBQUEUED:
 			wait_for_completion(&result.completion);
 			reinit_completion(&result.completion);
 			ret = result.err;
@@ -880,7 +880,7 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 			}
 			break;
 		case -EINPROGRESS:
-		case -EBUSY:
+		case -EIOCBQUEUED:
 			wait_for_completion(&result.completion);
 			reinit_completion(&result.completion);
 			ret = result.err;
@@ -1171,7 +1171,7 @@ static int __test_skcipher(struct crypto_skcipher *tfm, int enc,
 		case 0:
 			break;
 		case -EINPROGRESS:
-		case -EBUSY:
+		case -EIOCBQUEUED:
 			wait_for_completion(&result.completion);
 			reinit_completion(&result.completion);
 			ret = result.err;
@@ -1279,7 +1279,7 @@ static int __test_skcipher(struct crypto_skcipher *tfm, int enc,
 		case 0:
 			break;
 		case -EINPROGRESS:
-		case -EBUSY:
+		case -EIOCBQUEUED:
 			wait_for_completion(&result.completion);
 			reinit_completion(&result.completion);
 			ret = result.err;
diff --git a/crypto/xts.c b/crypto/xts.c
index d86c11a..b4b90cc 100644
--- a/crypto/xts.c
+++ b/crypto/xts.c
@@ -269,9 +269,7 @@ static int do_encrypt(struct skcipher_request *req, int err)
 		      crypto_skcipher_encrypt(subreq) ?:
 		      post_crypt(req);
 
-		if (err == -EINPROGRESS ||
-		    (err == -EBUSY &&
-		     req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (err == -EINPROGRESS || err == -EIOCBQUEUED)
 			return err;
 	}
 
@@ -321,9 +319,7 @@ static int do_decrypt(struct skcipher_request *req, int err)
 		      crypto_skcipher_decrypt(subreq) ?:
 		      post_crypt(req);
 
-		if (err == -EINPROGRESS ||
-		    (err == -EBUSY &&
-		     req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (err == -EINPROGRESS || err == -EIOCBQUEUED)
 			return err;
 	}
 
-- 
2.1.4
