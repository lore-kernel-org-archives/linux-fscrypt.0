Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:39710 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752314AbdHNPWk (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 14 Aug 2017 11:22:40 -0400
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v5 04/19] crypto: marvell/cesa: remove redundant backlog checks on EBUSY
Date: Mon, 14 Aug 2017 18:21:14 +0300
Message-Id: <1502724094-23305-5-git-send-email-gilad@benyossef.com>
In-Reply-To: <1502724094-23305-1-git-send-email-gilad@benyossef.com>
References: <1502724094-23305-1-git-send-email-gilad@benyossef.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
Cc: Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Now that -EBUSY return code only indicates backlog queueing
we can safely remove the now redundant check for the
CRYPTO_TFM_REQ_MAY_BACKLOG flag when -EBUSY is returned.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 drivers/crypto/marvell/cesa.c | 3 +--
 drivers/crypto/marvell/cesa.h | 2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/crypto/marvell/cesa.c b/drivers/crypto/marvell/cesa.c
index 6e7a5c7..269737f 100644
--- a/drivers/crypto/marvell/cesa.c
+++ b/drivers/crypto/marvell/cesa.c
@@ -183,8 +183,7 @@ int mv_cesa_queue_req(struct crypto_async_request *req,
 	spin_lock_bh(&engine->lock);
 	ret = crypto_enqueue_request(&engine->queue, req);
 	if ((mv_cesa_req_get_type(creq) == CESA_DMA_REQ) &&
-	    (ret == -EINPROGRESS ||
-	    (ret == -EBUSY && req->flags & CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	    (ret == -EINPROGRESS || ret == -EBUSY)
 		mv_cesa_tdma_chain(engine, creq);
 	spin_unlock_bh(&engine->lock);
 
diff --git a/drivers/crypto/marvell/cesa.h b/drivers/crypto/marvell/cesa.h
index b7872f6..63c8457 100644
--- a/drivers/crypto/marvell/cesa.h
+++ b/drivers/crypto/marvell/cesa.h
@@ -763,7 +763,7 @@ static inline int mv_cesa_req_needs_cleanup(struct crypto_async_request *req,
 	 * the backlog and will be processed later. There's no need to
 	 * clean it up.
 	 */
-	if (ret == -EBUSY && req->flags & CRYPTO_TFM_REQ_MAY_BACKLOG)
+	if (ret == -EBUSY)
 		return false;
 
 	/* Request wasn't queued, we need to clean it up */
-- 
2.1.4

