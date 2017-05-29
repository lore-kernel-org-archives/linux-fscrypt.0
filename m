Return-Path: <gilad@benyossef.com>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v2 05/11] crypto: move gcm to generic async completion
Date: Mon, 29 May 2017 11:22:52 +0300
Message-Id: <1496046180-21962-6-git-send-email-gilad@benyossef.com>
In-Reply-To: <1496046180-21962-1-git-send-email-gilad@benyossef.com>
References: <1496046180-21962-1-git-send-email-gilad@benyossef.com>
To: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, Ofir Drang <ofir.drang@arm.com>, Pavel Shilovsky <pshilov@microsoft.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

gcm is starting an async. crypto op and waiting for it complete.
Move it over to generic code doing the same.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 crypto/gcm.c | 32 ++++++--------------------------
 1 file changed, 6 insertions(+), 26 deletions(-)

diff --git a/crypto/gcm.c b/crypto/gcm.c
index 3841b5e..fb923a5 100644
--- a/crypto/gcm.c
+++ b/crypto/gcm.c
@@ -16,7 +16,6 @@
 #include <crypto/scatterwalk.h>
 #include <crypto/hash.h>
 #include "internal.h"
-#include <linux/completion.h>
 #include <linux/err.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
@@ -78,11 +77,6 @@ struct crypto_gcm_req_priv_ctx {
 	} u;
 };
 
-struct crypto_gcm_setkey_result {
-	int err;
-	struct completion completion;
-};
-
 static struct {
 	u8 buf[16];
 	struct scatterlist sg;
@@ -98,17 +92,6 @@ static inline struct crypto_gcm_req_priv_ctx *crypto_gcm_reqctx(
 	return (void *)PTR_ALIGN((u8 *)aead_request_ctx(req), align + 1);
 }
 
-static void crypto_gcm_setkey_done(struct crypto_async_request *req, int err)
-{
-	struct crypto_gcm_setkey_result *result = req->data;
-
-	if (err == -EINPROGRESS)
-		return;
-
-	result->err = err;
-	complete(&result->completion);
-}
-
 static int crypto_gcm_setkey(struct crypto_aead *aead, const u8 *key,
 			     unsigned int keylen)
 {
@@ -119,7 +102,7 @@ static int crypto_gcm_setkey(struct crypto_aead *aead, const u8 *key,
 		be128 hash;
 		u8 iv[16];
 
-		struct crypto_gcm_setkey_result result;
+		struct crypto_wait wait;
 
 		struct scatterlist sg[1];
 		struct skcipher_request req;
@@ -140,21 +123,18 @@ static int crypto_gcm_setkey(struct crypto_aead *aead, const u8 *key,
 	if (!data)
 		return -ENOMEM;
 
-	init_completion(&data->result.completion);
+	crypto_init_wait(&data->wait);
 	sg_init_one(data->sg, &data->hash, sizeof(data->hash));
 	skcipher_request_set_tfm(&data->req, ctr);
 	skcipher_request_set_callback(&data->req, CRYPTO_TFM_REQ_MAY_SLEEP |
 						  CRYPTO_TFM_REQ_MAY_BACKLOG,
-				      crypto_gcm_setkey_done,
-				      &data->result);
+				      crypto_req_done,
+				      &data->wait);
 	skcipher_request_set_crypt(&data->req, data->sg, data->sg,
 				   sizeof(data->hash), data->iv);
 
-	err = crypto_skcipher_encrypt(&data->req);
-	if (err == -EINPROGRESS || err == -EBUSY) {
-		wait_for_completion(&data->result.completion);
-		err = data->result.err;
-	}
+	err = crypto_wait_req(crypto_skcipher_encrypt(&data->req),
+							&data->wait);
 
 	if (err)
 		goto out;
-- 
2.1.4
