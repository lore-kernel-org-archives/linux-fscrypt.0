Return-Path: <gilad@benyossef.com>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v2 10/11] ima: move to generic async completion
Date: Mon, 29 May 2017 11:22:57 +0300
Message-Id: <1496046180-21962-11-git-send-email-gilad@benyossef.com>
In-Reply-To: <1496046180-21962-1-git-send-email-gilad@benyossef.com>
References: <1496046180-21962-1-git-send-email-gilad@benyossef.com>
To: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, Ofir Drang <ofir.drang@arm.com>, Pavel Shilovsky <pshilov@microsoft.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

ima starts several async crypto ops and  waits for their completions.
Move it over to generic code doing the same.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Mimi Zohar <zohar@linux.vnet.ibm.com>
---
 security/integrity/ima/ima_crypto.c | 56 +++++++++++--------------------------
 1 file changed, 17 insertions(+), 39 deletions(-)

diff --git a/security/integrity/ima/ima_crypto.c b/security/integrity/ima/ima_crypto.c
index 802d5d2..0e4db1fe 100644
--- a/security/integrity/ima/ima_crypto.c
+++ b/security/integrity/ima/ima_crypto.c
@@ -27,11 +27,6 @@
 
 #include "ima.h"
 
-struct ahash_completion {
-	struct completion completion;
-	int err;
-};
-
 /* minimum file size for ahash use */
 static unsigned long ima_ahash_minsize;
 module_param_named(ahash_minsize, ima_ahash_minsize, ulong, 0644);
@@ -196,30 +191,13 @@ static void ima_free_atfm(struct crypto_ahash *tfm)
 		crypto_free_ahash(tfm);
 }
 
-static void ahash_complete(struct crypto_async_request *req, int err)
+static inline int ahash_wait(int err, struct crypto_wait *wait)
 {
-	struct ahash_completion *res = req->data;
 
-	if (err == -EINPROGRESS)
-		return;
-	res->err = err;
-	complete(&res->completion);
-}
+	err = crypto_wait_req(err, wait);
 
-static int ahash_wait(int err, struct ahash_completion *res)
-{
-	switch (err) {
-	case 0:
-		break;
-	case -EINPROGRESS:
-	case -EBUSY:
-		wait_for_completion(&res->completion);
-		reinit_completion(&res->completion);
-		err = res->err;
-		/* fall through */
-	default:
+	if (err)
 		pr_crit_ratelimited("ahash calculation failed: err: %d\n", err);
-	}
 
 	return err;
 }
@@ -233,7 +211,7 @@ static int ima_calc_file_hash_atfm(struct file *file,
 	int rc, read = 0, rbuf_len, active = 0, ahash_rc = 0;
 	struct ahash_request *req;
 	struct scatterlist sg[1];
-	struct ahash_completion res;
+	struct crypto_wait wait;
 	size_t rbuf_size[2];
 
 	hash->length = crypto_ahash_digestsize(tfm);
@@ -242,12 +220,12 @@ static int ima_calc_file_hash_atfm(struct file *file,
 	if (!req)
 		return -ENOMEM;
 
-	init_completion(&res.completion);
+	crypto_init_wait(&wait);
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG |
 				   CRYPTO_TFM_REQ_MAY_SLEEP,
-				   ahash_complete, &res);
+				   crypto_req_done, &wait);
 
-	rc = ahash_wait(crypto_ahash_init(req), &res);
+	rc = ahash_wait(crypto_ahash_init(req), &wait);
 	if (rc)
 		goto out1;
 
@@ -288,7 +266,7 @@ static int ima_calc_file_hash_atfm(struct file *file,
 			 * read/request, wait for the completion of the
 			 * previous ahash_update() request.
 			 */
-			rc = ahash_wait(ahash_rc, &res);
+			rc = ahash_wait(ahash_rc, &wait);
 			if (rc)
 				goto out3;
 		}
@@ -304,7 +282,7 @@ static int ima_calc_file_hash_atfm(struct file *file,
 			 * read/request, wait for the completion of the
 			 * previous ahash_update() request.
 			 */
-			rc = ahash_wait(ahash_rc, &res);
+			rc = ahash_wait(ahash_rc, &wait);
 			if (rc)
 				goto out3;
 		}
@@ -318,7 +296,7 @@ static int ima_calc_file_hash_atfm(struct file *file,
 			active = !active; /* swap buffers, if we use two */
 	}
 	/* wait for the last update request to complete */
-	rc = ahash_wait(ahash_rc, &res);
+	rc = ahash_wait(ahash_rc, &wait);
 out3:
 	if (read)
 		file->f_mode &= ~FMODE_READ;
@@ -327,7 +305,7 @@ static int ima_calc_file_hash_atfm(struct file *file,
 out2:
 	if (!rc) {
 		ahash_request_set_crypt(req, NULL, hash->digest, 0);
-		rc = ahash_wait(crypto_ahash_final(req), &res);
+		rc = ahash_wait(crypto_ahash_final(req), &wait);
 	}
 out1:
 	ahash_request_free(req);
@@ -527,7 +505,7 @@ static int calc_buffer_ahash_atfm(const void *buf, loff_t len,
 {
 	struct ahash_request *req;
 	struct scatterlist sg;
-	struct ahash_completion res;
+	struct crypto_wait wait;
 	int rc, ahash_rc = 0;
 
 	hash->length = crypto_ahash_digestsize(tfm);
@@ -536,12 +514,12 @@ static int calc_buffer_ahash_atfm(const void *buf, loff_t len,
 	if (!req)
 		return -ENOMEM;
 
-	init_completion(&res.completion);
+	crypto_init_wait(&wait);
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG |
 				   CRYPTO_TFM_REQ_MAY_SLEEP,
-				   ahash_complete, &res);
+				   crypto_req_done, &wait);
 
-	rc = ahash_wait(crypto_ahash_init(req), &res);
+	rc = ahash_wait(crypto_ahash_init(req), &wait);
 	if (rc)
 		goto out;
 
@@ -551,10 +529,10 @@ static int calc_buffer_ahash_atfm(const void *buf, loff_t len,
 	ahash_rc = crypto_ahash_update(req);
 
 	/* wait for the update request to complete */
-	rc = ahash_wait(ahash_rc, &res);
+	rc = ahash_wait(ahash_rc, &wait);
 	if (!rc) {
 		ahash_request_set_crypt(req, NULL, hash->digest, 0);
-		rc = ahash_wait(crypto_ahash_final(req), &res);
+		rc = ahash_wait(crypto_ahash_final(req), &wait);
 	}
 out:
 	ahash_request_free(req);
-- 
2.1.4
