Return-Path: <dm-devel-bounces@redhat.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu,  4 Jul 2019 20:30:13 +0200
Message-Id: <20190704183017.31570-4-ard.biesheuvel@linaro.org>
In-Reply-To: <20190704183017.31570-1-ard.biesheuvel@linaro.org>
References: <20190704183017.31570-1-ard.biesheuvel@linaro.org>
Subject: [dm-devel] [PATCH v8 3/7] md: dm-crypt: infer ESSIV block cipher
	from cipher string directly
List-Unsubscribe: <https://www.redhat.com/mailman/options/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
To: linux-crypto@vger.kernel.org
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, dm-devel@redhat.com, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Instead of allocating a crypto skcipher tfm 'foo' and attempting to
infer the encapsulated block cipher from the driver's 'name' field,
directly parse the string that we used to allocated the tfm. These
are always identical (unless the allocation failed, in which case
we bail anyway), but using the string allows us to use it in the
allocation, which is something we will need when switching to the
'essiv' crypto API template.

Reviewed-by: Milan Broz <gmazyland@gmail.com>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 drivers/md/dm-crypt.c | 41 +++++++++-----------
 1 file changed, 18 insertions(+), 23 deletions(-)

diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 1b16d34bb785..3c17d588f6db 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -2321,25 +2321,17 @@ static int crypt_ctr_ivmode(struct dm_target *ti, const char *ivmode)
  * The cc->cipher is currently used only in ESSIV.
  * This should be probably done by crypto-api calls (once available...)
  */
-static int crypt_ctr_blkdev_cipher(struct crypt_config *cc)
+static int crypt_ctr_blkdev_cipher(struct crypt_config *cc, char *alg_name)
 {
-	const char *alg_name = NULL;
 	char *start, *end;
 
 	if (crypt_integrity_aead(cc)) {
-		alg_name = crypto_tfm_alg_name(crypto_aead_tfm(any_tfm_aead(cc)));
-		if (!alg_name)
-			return -EINVAL;
 		if (crypt_integrity_hmac(cc)) {
 			alg_name = strchr(alg_name, ',');
 			if (!alg_name)
 				return -EINVAL;
 		}
 		alg_name++;
-	} else {
-		alg_name = crypto_tfm_alg_name(crypto_skcipher_tfm(any_tfm(cc)));
-		if (!alg_name)
-			return -EINVAL;
 	}
 
 	start = strchr(alg_name, '(');
@@ -2434,32 +2426,35 @@ static int crypt_ctr_cipher_new(struct dm_target *ti, char *cipher_in, char *key
 	if (*ivmode && !strcmp(*ivmode, "lmk"))
 		cc->tfms_count = 64;
 
-	cc->key_parts = cc->tfms_count;
-
-	/* Allocate cipher */
-	ret = crypt_alloc_tfms(cc, cipher_api);
-	if (ret < 0) {
-		ti->error = "Error allocating crypto tfm";
-		return ret;
-	}
-
 	/* Alloc AEAD, can be used only in new format. */
 	if (crypt_integrity_aead(cc)) {
 		ret = crypt_ctr_auth_cipher(cc, cipher_api);
 		if (ret < 0) {
 			ti->error = "Invalid AEAD cipher spec";
 			return -ENOMEM;
-		}
-		cc->iv_size = crypto_aead_ivsize(any_tfm_aead(cc));
-	} else
-		cc->iv_size = crypto_skcipher_ivsize(any_tfm(cc));
+	       }
+	}
 
-	ret = crypt_ctr_blkdev_cipher(cc);
+	ret = crypt_ctr_blkdev_cipher(cc, cipher_api);
 	if (ret < 0) {
 		ti->error = "Cannot allocate cipher string";
 		return -ENOMEM;
 	}
 
+	cc->key_parts = cc->tfms_count;
+
+	/* Allocate cipher */
+	ret = crypt_alloc_tfms(cc, cipher_api);
+	if (ret < 0) {
+		ti->error = "Error allocating crypto tfm";
+		return ret;
+	}
+
+	if (crypt_integrity_aead(cc))
+		cc->iv_size = crypto_aead_ivsize(any_tfm_aead(cc));
+	else
+		cc->iv_size = crypto_skcipher_ivsize(any_tfm(cc));
+
 	return 0;
 }
 
-- 
2.17.1

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
