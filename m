Return-Path: <linux-crypto-owner@vger.kernel.org>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v4 06/19] crypto: move algif to generic async completion
Date: Tue,  8 Aug 2017 15:03:37 +0300
Message-Id: <1502193834-11289-7-git-send-email-gilad@benyossef.com>
In-Reply-To: <1502193834-11289-1-git-send-email-gilad@benyossef.com>
References: <1502193834-11289-1-git-send-email-gilad@benyossef.com>
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
 crypto/algif_hash.c     | 30 ++++++++++++++----------------
 crypto/algif_skcipher.c | 15 +++++++--------
 include/crypto/if_alg.h | 13 -------------
 5 files changed, 28 insertions(+), 71 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 92a3d54..887f75c 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -480,33 +480,6 @@ int af_alg_cmsg_send(struct msghdr *msg, struct af_alg_control *con)
 }
 EXPORT_SYMBOL_GPL(af_alg_cmsg_send);
 
-int af_alg_wait_for_completion(int err, struct af_alg_completion *completion)
-{
-	switch (err) {
-	case -EINPROGRESS:
-	case -EBUSY:
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
index 9755aac..36be369 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -78,7 +78,7 @@ struct aead_ctx {
 	void *iv;
 	size_t aead_assoclen;
 
-	struct af_alg_completion completion;	/* sync work queue */
+	struct crypto_wait wait;
 
 	size_t used;		/* TX bytes sent to kernel */
 	size_t rcvused;		/* total RX bytes to be processed by kernel */
@@ -751,11 +751,11 @@ static int _aead_recvmsg(struct socket *sock, struct msghdr *msg,
 		/* Synchronous operation */
 		aead_request_set_callback(&areq->aead_req,
 					  CRYPTO_TFM_REQ_MAY_BACKLOG,
-					  af_alg_complete, &ctx->completion);
-		err = af_alg_wait_for_completion(ctx->enc ?
-					 crypto_aead_encrypt(&areq->aead_req) :
-					 crypto_aead_decrypt(&areq->aead_req),
-					 &ctx->completion);
+					  crypto_req_done, &ctx->wait);
+		err = crypto_wait_req(ctx->enc ?
+				      crypto_aead_encrypt(&areq->aead_req) :
+				      crypto_aead_decrypt(&areq->aead_req),
+				      &ctx->wait);
 	}
 
 	/* AIO operation in progress */
@@ -1036,7 +1036,7 @@ static int aead_accept_parent_nokey(void *private, struct sock *sk)
 	ctx->merge = 0;
 	ctx->enc = 0;
 	ctx->aead_assoclen = 0;
-	af_alg_init_completion(&ctx->completion);
+	crypto_init_wait(&ctx->wait);
 
 	ask->private = ctx;
 
diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 3b3c154..d2ab8de 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -26,7 +26,7 @@ struct hash_ctx {
 
 	u8 *result;
 
-	struct af_alg_completion completion;
+	struct crypto_wait wait;
 
 	unsigned int len;
 	bool more;
@@ -102,8 +102,7 @@ static int hash_sendmsg(struct socket *sock, struct msghdr *msg,
 		if ((msg->msg_flags & MSG_MORE))
 			hash_free_result(sk, ctx);
 
-		err = af_alg_wait_for_completion(crypto_ahash_init(&ctx->req),
-						&ctx->completion);
+		err = crypto_wait_req(crypto_ahash_init(&ctx->req), &ctx->wait);
 		if (err)
 			goto unlock;
 	}
@@ -124,8 +123,8 @@ static int hash_sendmsg(struct socket *sock, struct msghdr *msg,
 
 		ahash_request_set_crypt(&ctx->req, ctx->sgl.sg, NULL, len);
 
-		err = af_alg_wait_for_completion(crypto_ahash_update(&ctx->req),
-						 &ctx->completion);
+		err = crypto_wait_req(crypto_ahash_update(&ctx->req),
+				      &ctx->wait);
 		af_alg_free_sg(&ctx->sgl);
 		if (err)
 			goto unlock;
@@ -143,8 +142,8 @@ static int hash_sendmsg(struct socket *sock, struct msghdr *msg,
 			goto unlock;
 
 		ahash_request_set_crypt(&ctx->req, NULL, ctx->result, 0);
-		err = af_alg_wait_for_completion(crypto_ahash_final(&ctx->req),
-						 &ctx->completion);
+		err = crypto_wait_req(crypto_ahash_final(&ctx->req),
+				      &ctx->wait);
 	}
 
 unlock:
@@ -185,7 +184,7 @@ static ssize_t hash_sendpage(struct socket *sock, struct page *page,
 	} else {
 		if (!ctx->more) {
 			err = crypto_ahash_init(&ctx->req);
-			err = af_alg_wait_for_completion(err, &ctx->completion);
+			err = crypto_wait_req(err, &ctx->wait);
 			if (err)
 				goto unlock;
 		}
@@ -193,7 +192,7 @@ static ssize_t hash_sendpage(struct socket *sock, struct page *page,
 		err = crypto_ahash_update(&ctx->req);
 	}
 
-	err = af_alg_wait_for_completion(err, &ctx->completion);
+	err = crypto_wait_req(err, &ctx->wait);
 	if (err)
 		goto unlock;
 
@@ -229,17 +228,16 @@ static int hash_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	ahash_request_set_crypt(&ctx->req, NULL, ctx->result, 0);
 
 	if (!result && !ctx->more) {
-		err = af_alg_wait_for_completion(
-				crypto_ahash_init(&ctx->req),
-				&ctx->completion);
+		err = crypto_wait_req(crypto_ahash_init(&ctx->req),
+				      &ctx->wait);
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
@@ -490,13 +488,13 @@ static int hash_accept_parent_nokey(void *private, struct sock *sk)
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
index 968d094..ebbd433 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -75,7 +75,7 @@ struct skcipher_ctx {
 
 	void *iv;
 
-	struct af_alg_completion completion;
+	struct crypto_wait wait;
 
 	size_t used;
 	size_t rcvused;
@@ -677,12 +677,11 @@ static int _skcipher_recvmsg(struct socket *sock, struct msghdr *msg,
 		skcipher_request_set_callback(&areq->req,
 					      CRYPTO_TFM_REQ_MAY_SLEEP |
 					      CRYPTO_TFM_REQ_MAY_BACKLOG,
-					      af_alg_complete,
-					      &ctx->completion);
-		err = af_alg_wait_for_completion(ctx->enc ?
-					crypto_skcipher_encrypt(&areq->req) :
-					crypto_skcipher_decrypt(&areq->req),
-						 &ctx->completion);
+					      crypto_req_done, &ctx->wait);
+		err = crypto_wait_req(ctx->enc ?
+				      crypto_skcipher_encrypt(&areq->req) :
+				      crypto_skcipher_decrypt(&areq->req),
+				      &ctx->wait);
 	}
 
 	/* AIO operation in progress */
@@ -950,7 +949,7 @@ static int skcipher_accept_parent_nokey(void *private, struct sock *sk)
 	ctx->more = 0;
 	ctx->merge = 0;
 	ctx->enc = 0;
-	af_alg_init_completion(&ctx->completion);
+	crypto_init_wait(&ctx->wait);
 
 	ask->private = ctx;
 
diff --git a/include/crypto/if_alg.h b/include/crypto/if_alg.h
index e2b9c6f..14b79e5 100644
--- a/include/crypto/if_alg.h
+++ b/include/crypto/if_alg.h
@@ -37,11 +37,6 @@ struct alg_sock {
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
@@ -81,17 +76,9 @@ void af_alg_link_sg(struct af_alg_sgl *sgl_prev, struct af_alg_sgl *sgl_new);
 
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
