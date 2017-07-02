Return-Path: <keyrings-owner@vger.kernel.org>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v3 00/28] simplify crypto wait for async op
Date: Sun,  2 Jul 2017 17:41:42 +0300
Message-Id: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
Sender: keyrings-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
Cc: Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Many users of kernel async. crypto services have a pattern of
starting an async. crypto op and than using a completion
to wait for it to end.

This patch set simplifies this common use case in two ways:

First, by giving the case where a request was queued to the
backlog a separate return code (-EIOCBQUEUED) of its own
rather than sharing the -EBUSY return code with the fatal
error of a busy provider when backlog is not enabled.

Next, this change is than built on to create a generic way
to wait for a async. crypto operation to complete.

The end result is that after replacing all the call sites
I could find, the code is smaller by ~340 lines, a branch
is saved in some cases in run-time and the code is more
straightforward to follow.

Please note that patches 1-13 should be squashed together
when applied in order to function correctly. They are
only separated out to ease review.

The patch set was boot tested on x86_64 and arm64 which
at the very least tests the crypto users via testmgr and
tcrypt but I do note that I do not have access to some
of the HW whose drivers are modified nor do I claim I was
able to test all of the corner cases.

Last but not least, I do apologize for the size of this
patch set and number of recipients, but I did have to
touch every crypto async API user in the kernel. May the
340 deleted lines serve as penance for my sin :-)

Changes from v2:
- Patch title changed from "introduce crypto wait for
  async op" to better reflect the current state.
- Rebase on top of latest linux-next.
- Add a new return code of -EIOCBQUEUED for backlog
  queueing, as suggested by Herbert Xu.
- Transform more users to the new API.
- Update the drbg change to account for new init as
  indicated by Stephan Muller.

Changes from v1:
- Address review comments from Eric Biggers.
- Separated out bug fixes of existing code and rebase
  on top of that patch set.
- Rename 'ecr' to 'wait' in fscrypto code.
- Split patch introducing the new API from the change
  moving over the algif code which it originated from
  to the new API.
- Inline crypto_wait_req().
- Some code indentation fixes.

Gilad Ben-Yossef (28):
  crypto: change backlog return code to -EIOCBQUEUED
  crypto: atmel: use -EIOCBQUEUED for backlog indication
  crypto: ccm: use -EIOCBQUEUED for backlog indication
  crypto: marvell/cesa: use -EIOCBQUEUED for backlog indication
  crypto: mediatek: use -EIOCBQUEUED for backlog indication
  crypto: omap: use -EIOCBQUEUED for backlog indication
  crypto: qce: use -EIOCBQUEUED for backlog indication
  crypto: talitos: use -EIOCBQUEUED for backlog indication
  dm: verity: use -EIOCBQUEUED for backlog indication
  fscrypt: use -EIOCBQUEUED for backlog indication
  cifs: use -EIOCBQUEUED for backlog indication
  ima: use -EIOCBQUEUED for backlog indication
  crypto: adapt api sample to -EIOCBQUEUED as backlog indication
  crypto: introduce crypto wait for async op
  crypto: move algif to generic async completion
  crypto: move pub key to generic async completion
  crypto: move drbg to generic async completion
  crypto: move gcm to generic async completion
  crypto: move testmgr to generic async completion
  dm: move dm-verity to generic async completion
  fscrypt: move to generic async completion
  cifs: move to generic async completion
  ima: move to generic async completion
  crypto: tcrypt: move to generic async completion
  crypto: talitos: move to generic async completion
  crypto: qce: move to generic async completion
  crypto: mediatek: move to generic async completion
  crypto: adapt api sample to use async. op wait

 Documentation/crypto/api-samples.rst |  52 ++-------
 crypto/af_alg.c                      |  27 -----
 crypto/ahash.c                       |  12 +--
 crypto/algapi.c                      |   6 +-
 crypto/algif_aead.c                  |  14 +--
 crypto/algif_hash.c                  |  29 +++--
 crypto/algif_skcipher.c              |  15 ++-
 crypto/api.c                         |  13 +++
 crypto/asymmetric_keys/public_key.c  |  28 +----
 crypto/chacha20poly1305.c            |   2 +-
 crypto/cryptd.c                      |   4 +-
 crypto/cts.c                         |   6 +-
 crypto/drbg.c                        |  36 ++-----
 crypto/gcm.c                         |  32 ++----
 crypto/lrw.c                         |   8 +-
 crypto/rsa-pkcs1pad.c                |  16 +--
 crypto/tcrypt.c                      |  84 +++++----------
 crypto/testmgr.c                     | 204 ++++++++++++-----------------------
 crypto/xts.c                         |   8 +-
 drivers/crypto/atmel-sha.c           |   2 +-
 drivers/crypto/ccp/ccp-crypto-main.c |  10 +-
 drivers/crypto/ccp/ccp-dev.c         |   8 +-
 drivers/crypto/ccp/ccp-dmaengine.c   |   2 +-
 drivers/crypto/marvell/cesa.c        |   2 +-
 drivers/crypto/marvell/cesa.h        |   2 +-
 drivers/crypto/mediatek/mtk-aes.c    |  31 +-----
 drivers/crypto/mediatek/mtk-sha.c    |   2 +-
 drivers/crypto/omap-sham.c           |   2 +-
 drivers/crypto/qce/sha.c             |  30 +-----
 drivers/crypto/talitos.c             |  39 +------
 drivers/md/dm-verity-target.c        |  81 ++++----------
 drivers/md/dm-verity.h               |   5 -
 fs/cifs/smb2ops.c                    |  30 +-----
 fs/crypto/crypto.c                   |  29 +----
 fs/crypto/fname.c                    |  36 ++-----
 fs/crypto/fscrypt_private.h          |  10 --
 fs/crypto/keyinfo.c                  |  21 +---
 include/crypto/drbg.h                |   3 +-
 include/crypto/if_alg.h              |  14 ---
 include/linux/crypto.h               |  40 +++++++
 security/integrity/ima/ima_crypto.c  |  56 +++-------
 41 files changed, 305 insertions(+), 746 deletions(-)

-- 
2.1.4

