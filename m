Return-Path: <keyrings-owner@vger.kernel.org>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v3 10/28] fscrypt: use -EIOCBQUEUED for backlog indication
Date: Sun,  2 Jul 2017 17:41:52 +0300
Message-Id: <1499006535-19760-11-git-send-email-gilad@benyossef.com>
In-Reply-To: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
References: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
Sender: keyrings-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
Cc: Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Replace -EBUSY with -EIOCBQUEUED for backlog queueing indication
as part of new API.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---

This patch should be squashed with the first patch in the series
when applied.

 fs/crypto/crypto.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index c7835df..c5c89ed 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -190,7 +190,7 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 		res = crypto_skcipher_decrypt(req);
 	else
 		res = crypto_skcipher_encrypt(req);
-	if (res == -EINPROGRESS || res == -EBUSY) {
+	if (res == -EINPROGRESS || res == -EIOCBQUEUED) {
 		BUG_ON(req->base.data != &ecr);
 		wait_for_completion(&ecr.completion);
 		res = ecr.res;
-- 
2.1.4

