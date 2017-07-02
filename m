Return-Path: <keyrings-owner@vger.kernel.org>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v3 03/28] crypto: ccm: use -EIOCBQUEUED for backlog indication
Date: Sun,  2 Jul 2017 17:41:45 +0300
Message-Id: <1499006535-19760-4-git-send-email-gilad@benyossef.com>
In-Reply-To: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
References: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
Sender: keyrings-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
Cc: Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Replace -EBUSY with -EIOCBQUEUED for backlog queueing indication
as part of new API

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---

This patch should be squashed with the first patch in the series
when applied.

 drivers/crypto/ccp/ccp-crypto-main.c | 10 +++++-----
 drivers/crypto/ccp/ccp-dev.c         |  8 +++++---
 drivers/crypto/ccp/ccp-dmaengine.c   |  2 +-
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/crypto/ccp/ccp-crypto-main.c b/drivers/crypto/ccp/ccp-crypto-main.c
index 8dccbdd..dff1998 100644
--- a/drivers/crypto/ccp/ccp-crypto-main.c
+++ b/drivers/crypto/ccp/ccp-crypto-main.c
@@ -84,7 +84,7 @@ struct ccp_crypto_cpu {
 
 static inline bool ccp_crypto_success(int err)
 {
-	if (err && (err != -EINPROGRESS) && (err != -EBUSY))
+	if (err && (err != -EINPROGRESS) && (err != -EIOCBQUEUED))
 		return false;
 
 	return true;
@@ -148,7 +148,7 @@ static void ccp_crypto_complete(void *data, int err)
 
 	if (err == -EINPROGRESS) {
 		/* Only propagate the -EINPROGRESS if necessary */
-		if (crypto_cmd->ret == -EBUSY) {
+		if (crypto_cmd->ret == -EIOCBQUEUED) {
 			crypto_cmd->ret = -EINPROGRESS;
 			req->complete(req, -EINPROGRESS);
 		}
@@ -166,8 +166,8 @@ static void ccp_crypto_complete(void *data, int err)
 		backlog->req->complete(backlog->req, -EINPROGRESS);
 	}
 
-	/* Transition the state from -EBUSY to -EINPROGRESS first */
-	if (crypto_cmd->ret == -EBUSY)
+	/* Transition the state from -EIOCBQUEUED to -EINPROGRESS first */
+	if (crypto_cmd->ret == -EIOCBQUEUED)
 		req->complete(req, -EINPROGRESS);
 
 	/* Completion callbacks */
@@ -243,7 +243,7 @@ static int ccp_crypto_enqueue_cmd(struct ccp_crypto_cmd *crypto_cmd)
 	}
 
 	if (req_queue.cmd_count >= CCP_CRYPTO_MAX_QLEN) {
-		ret = -EBUSY;
+		ret = -EIOCBQUEUED;
 		if (req_queue.backlog == &req_queue.cmds)
 			req_queue.backlog = &crypto_cmd->entry;
 	}
diff --git a/drivers/crypto/ccp/ccp-dev.c b/drivers/crypto/ccp/ccp-dev.c
index 2506b50..b7006d7 100644
--- a/drivers/crypto/ccp/ccp-dev.c
+++ b/drivers/crypto/ccp/ccp-dev.c
@@ -269,7 +269,7 @@ EXPORT_SYMBOL_GPL(ccp_version);
  * Queue a cmd to be processed by the CCP. If queueing the cmd
  * would exceed the defined length of the cmd queue the cmd will
  * only be queued if the CCP_CMD_MAY_BACKLOG flag is set and will
- * result in a return code of -EBUSY.
+ * result in a return code of -EIOCBQUEUED;
  *
  * The callback routine specified in the ccp_cmd struct will be
  * called to notify the caller of completion (if the cmd was not
@@ -280,7 +280,7 @@ EXPORT_SYMBOL_GPL(ccp_version);
  *
  * The cmd has been successfully queued if:
  *   the return code is -EINPROGRESS or
- *   the return code is -EBUSY and CCP_CMD_MAY_BACKLOG flag is set
+ *   the return code is -EIOCBQUEUED
  */
 int ccp_enqueue_cmd(struct ccp_cmd *cmd)
 {
@@ -307,8 +307,10 @@ int ccp_enqueue_cmd(struct ccp_cmd *cmd)
 
 	if (ccp->cmd_count >= MAX_CMD_QLEN) {
 		ret = -EBUSY;
-		if (cmd->flags & CCP_CMD_MAY_BACKLOG)
+		if (cmd->flags & CCP_CMD_MAY_BACKLOG) {
 			list_add_tail(&cmd->entry, &ccp->backlog);
+			ret = -EIOCBQUEUED;
+		}
 	} else {
 		ret = -EINPROGRESS;
 		ccp->cmd_count++;
diff --git a/drivers/crypto/ccp/ccp-dmaengine.c b/drivers/crypto/ccp/ccp-dmaengine.c
index e00be01..ab67304 100644
--- a/drivers/crypto/ccp/ccp-dmaengine.c
+++ b/drivers/crypto/ccp/ccp-dmaengine.c
@@ -146,7 +146,7 @@ static int ccp_issue_next_cmd(struct ccp_dma_desc *desc)
 		desc->tx_desc.cookie, cmd);
 
 	ret = ccp_enqueue_cmd(&cmd->ccp_cmd);
-	if (!ret || (ret == -EINPROGRESS) || (ret == -EBUSY))
+	if (!ret || (ret == -EINPROGRESS) || (ret == -EIOCBQUEUED))
 		return 0;
 
 	dev_dbg(desc->ccp->dev, "%s - error: ret=%d, tx %d, cmd=%p\n", __func__,
-- 
2.1.4

