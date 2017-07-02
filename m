Return-Path: <linux-crypto-owner@vger.kernel.org>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v3 15/28] crypto: move algif to generic async completion
Date: Sun,  2 Jul 2017 17:41:57 +0300
Message-Id: <1499006535-19760-16-git-send-email-gilad@benyossef.com>
In-Reply-To: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
References: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
Cc: Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

algif starts several async crypto ops and waits for their completion.
Move it over to generic code doing the same.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 crypto/af_alg.c         | 27 ---------------------------
 crypto/algif_aead.c     | 14 +++++++-------
 crypto/algif_hash.c     | 29 +++++++++++++----------------
 crypto/algif_skcipher.c | 15 +++++++--------
 include/crypto/if_alg.h | 14 --------------
 5 files changed, 27 insertions(+), 72 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index c67daba..bf4acaf 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -480,33 +480,6 @@ int af_alg_cmsg_send(struct msghdr *msg, struct af_alg_control *con)
 }
 EXPORT_SYMBOL_GPL(af_alg_cmsg_send);
 
-int af_alg_wait_for_completion(int err, struct af_alg_completion *completion)
-{
-	switch (err) {
-	case -EINPROGRESS:
-	case -EIOCBQUEUED:
-		wait_for_completion(&completion->completion);
-		reinit_completion(&completion->completion);
-		err = completion->err;
-		break;
-	};
-
-	return err;
-}
-EXPORT_SYMBOL_GPL(af_alg_wait_for_completion);
-
-void af_alg_complete(struct crypto_async_request *req, int err)
-{
-	struct af_alg_completion *completion = req->data;
-
-	if (err == -EINPROGRESS)
-		return;
-
-	completion->err = err;
-	complete(&completion->completion);
-}
-EXPORT_SYMBOL_GPL(af_alg_complete);
-
 static int __init af_alg_init(void)
 {
 	int err = proto_register(&alg_proto, 0);
diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index 8af664f..4881cb1 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -57,7 +57,7 @@ struct aead_ctx {
 
 	void *iv;
 
-	struct af_alg_completion completion;
+	struct crypto_wait wait;
 
 	unsigned long used;
 
@@ -648,10 +648,10 @@ static int aead_recvmsg_sync(struct socket *sock, struct msghdr *msg, int flags)
 			       used, ctx->iv);
 	aead_request_set_ad(&ctx->aead_req, ctx->aead_assoclen);
 
-	err = af_alg_wait_for_completion(ctx->enc ?
-					 crypto_aead_encrypt(&ctx->aead_req) :
-					 crypto_aead_decrypt(&ctx->aead_req),
-					 &ctx->completion);
+	err = crypto_wait_req(ctx->enc ?
+			      crypto_aead_encrypt(&ctx->aead_req) :
+			      crypto_aead_decrypt(&ctx->aead_req),
+			      &ctx->wait);
 
 	if (err) {
 		/* EBADMSG implies a valid cipher operation took place */
@@ -912,7 +912,7 @@ static int aead_accept_parent_nokey(void *private, struct sock *sk)
 	ctx->enc = 0;
 	ctx->tsgl.cur = 0;
 	ctx->aead_assoclen = 0;
-	af_alg_init_completion(&ctx->completion);
+	crypto_init_wait(&ctx->wait);
 	sg_init_table(ctx->tsgl.sg, ALG_MAX_PAGES);
 	INIT_LIST_HEAD(&ctx->list);
 
@@ -920,7 +920,7 @@ static int aead_accept_parent_nokey(void *private, struct sock *sk)
 
 	aead_request_set_tfm(&ctx->aead_req, aead);
 	aead_request_set_callback(&ctx->aead_req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				  af_alg_complete, &ctx->completion);
+				  crypto_req_done, &ctx->wait);
 
 	sk->sk_destruct = aead_sock_destruct;
 
diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 5e92bd2..6a6739a 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -26,7 +26,7 @@ struct hash_ctx {
 
 	u8 *result;
 
-	struct af_alg_completion completion;
+	struct crypto_wait wait;
 
 	unsigned int len;
 	bool more;
@@ -88,8 +88,7 @@ static int hash_sendmsg(struct socket *sock, struct msghdr *msg,
 		if ((msg->msg_flags & MSG_MORE))
 			hash_free_result(sk, ctx);
 
-		err = af_alg_wait_for_completion(crypto_ahash_init(&ctx->req),
-						&ctx->completion);
+		err = crypto_wait_req(crypto_ahash_init(&ctx->req), &ctx->wait);
 		if (err)
 			goto unlock;
 	}
@@ -110,8 +109,8 @@ static int hash_sendmsg(struct socket *sock, struct msghdr *msg,
 
 		ahash_request_set_crypt(&ctx->req, ctx->sgl.sg, NULL, len);
 
-		err = af_alg_wait_for_completion(crypto_ahash_update(&ctx->req),
-						 &ctx->completion);
+		err = crypto_wait_req(crypto_ahash_update(&ctx->req),
+				      &ctx->wait);
 		af_alg_free_sg(&ctx->sgl);
 		if (err)
 			goto unlock;
@@ -129,8 +128,8 @@ static int hash_sendmsg(struct socket *sock, struct msghdr *msg,
 			goto unlock;
 
 		ahash_request_set_crypt(&ctx->req, NULL, ctx->result, 0);
-		err = af_alg_wait_for_completion(crypto_ahash_final(&ctx->req),
-						 &ctx->completion);
+		err = crypto_wait_req(crypto_ahash_final(&ctx->req),
+				      &ctx->wait);
 	}
 
 unlock:
@@ -171,7 +170,7 @@ static ssize_t hash_sendpage(struct socket *sock, struct page *page,
 	} else {
 		if (!ctx->more) {
 			err = crypto_ahash_init(&ctx->req);
-			err = af_alg_wait_for_completion(err, &ctx->completion);
+			err = crypto_wait_req(err, &ctx->wait);
 			if (err)
 				goto unlock;
 		}
@@ -179,7 +178,7 @@ static ssize_t hash_sendpage(struct socket *sock, struct page *page,
 		err = crypto_ahash_update(&ctx->req);
 	}
 
-	err = af_alg_wait_for_completion(err, &ctx->completion);
+	err = crypto_wait_req(err, &ctx->wait);
 	if (err)
 		goto unlock;
 
@@ -215,17 +214,15 @@ static int hash_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	ahash_request_set_crypt(&ctx->req, NULL, ctx->result, 0);
 
 	if (!result && !ctx->more) {
-		err = af_alg_wait_for_completion(
-				crypto_ahash_init(&ctx->req),
-				&ctx->completion);
+		err = crypto_wait_req(crypto_ahash_init(&ctx->req), &ctx->wait);
 		if (err)
 			goto unlock;
 	}
 
 	if (!result || ctx->more) {
 		ctx->more = 0;
-		err = af_alg_wait_for_completion(crypto_ahash_final(&ctx->req),
-						 &ctx->completion);
+		err = crypto_wait_req(crypto_ahash_final(&ctx->req),
+				      &ctx->wait);
 		if (err)
 			goto unlock;
 	}
@@ -476,13 +473,13 @@ static int hash_accept_parent_nokey(void *private, struct sock *sk)
 	ctx->result = NULL;
 	ctx->len = len;
 	ctx->more = 0;
-	af_alg_init_completion(&ctx->completion);
+	crypto_init_wait(&ctx->wait);
 
 	ask->private = ctx;
 
 	ahash_request_set_tfm(&ctx->req, hash);
 	ahash_request_set_callback(&ctx->req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				   af_alg_complete, &ctx->completion);
+				   crypto_req_done, &ctx->wait);
 
 	sk->sk_destruct = hash_sock_destruct;
 
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 43839b0..75fa9a5 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -43,7 +43,7 @@ struct skcipher_ctx {
 
 	void *iv;
 
-	struct af_alg_completion completion;
+	struct crypto_wait wait;
 
 	atomic_t inflight;
 	size_t used;
@@ -684,11 +684,10 @@ static int skcipher_recvmsg_sync(struct socket *sock, struct msghdr *msg,
 		skcipher_request_set_crypt(&ctx->req, sg, ctx->rsgl.sg, used,
 					   ctx->iv);
 
-		err = af_alg_wait_for_completion(
-				ctx->enc ?
-					crypto_skcipher_encrypt(&ctx->req) :
-					crypto_skcipher_decrypt(&ctx->req),
-				&ctx->completion);
+		err = crypto_wait_req(ctx->enc ?
+				      crypto_skcipher_encrypt(&ctx->req) :
+				      crypto_skcipher_decrypt(&ctx->req),
+				      &ctx->wait);
 
 free:
 		af_alg_free_sg(&ctx->rsgl);
@@ -948,14 +947,14 @@ static int skcipher_accept_parent_nokey(void *private, struct sock *sk)
 	ctx->merge = 0;
 	ctx->enc = 0;
 	atomic_set(&ctx->inflight, 0);
-	af_alg_init_completion(&ctx->completion);
+	crypto_init_wait(&ctx->wait);
 
 	ask->private = ctx;
 
 	skcipher_request_set_tfm(&ctx->req, skcipher);
 	skcipher_request_set_callback(&ctx->req, CRYPTO_TFM_REQ_MAY_SLEEP |
 						 CRYPTO_TFM_REQ_MAY_BACKLOG,
-				      af_alg_complete, &ctx->completion);
+				      crypto_req_done, &ctx->wait);
 
 	sk->sk_destruct = skcipher_sock_destruct;
 
diff --git a/include/crypto/if_alg.h b/include/crypto/if_alg.h
index e2b9c6f..86764fb 100644
--- a/include/crypto/if_alg.h
+++ b/include/crypto/if_alg.h
@@ -14,7 +14,6 @@
 #define _CRYPTO_IF_ALG_H
 
 #include <linux/compiler.h>
-#include <linux/completion.h>
 #include <linux/if_alg.h>
 #include <linux/scatterlist.h>
 #include <linux/types.h>
@@ -37,11 +36,6 @@ struct alg_sock {
 	void *private;
 };
 
-struct af_alg_completion {
-	struct completion completion;
-	int err;
-};
-
 struct af_alg_control {
 	struct af_alg_iv *iv;
 	int op;
@@ -81,17 +75,9 @@ void af_alg_link_sg(struct af_alg_sgl *sgl_prev, struct af_alg_sgl *sgl_new);
 
 int af_alg_cmsg_send(struct msghdr *msg, struct af_alg_control *con);
 
-int af_alg_wait_for_completion(int err, struct af_alg_completion *completion);
-void af_alg_complete(struct crypto_async_request *req, int err);
-
 static inline struct alg_sock *alg_sk(struct sock *sk)
 {
 	return (struct alg_sock *)sk;
 }
 
-static inline void af_alg_init_completion(struct af_alg_completion *completion)
-{
-	init_completion(&completion->completion);
-}
-
 #endif	/* _CRYPTO_IF_ALG_H */
-- 
2.1.4
