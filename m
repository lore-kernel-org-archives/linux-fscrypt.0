Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33384 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdICGRT (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 3 Sep 2017 02:17:19 -0400
Received: by mail-oi0-f65.google.com with SMTP id x133so595176oif.0
        for <linux-fscrypt@vger.kernel.org>; Sat, 02 Sep 2017 23:17:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFXBA=n6W_n1P=NKHEUAgpaDDrdmh4QwB4aYma9xyio7UFP3Vw@mail.gmail.com>
References: <1503584350-7831-1-git-send-email-gilad@benyossef.com> <CAFXBA=n6W_n1P=NKHEUAgpaDDrdmh4QwB4aYma9xyio7UFP3Vw@mail.gmail.com>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Sun, 3 Sep 2017 09:17:18 +0300
Message-ID: <CAOtvUMcjtEMj4eoCG_Rpp-8CmJP+Yu0dPDN3PyOTWjHapf_y1g@mail.gmail.com>
Subject: Re: [PATCH v7 00/19] simplify crypto wait for async op
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Harsh Jain <harshjain.prof@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Aug 31, 2017 at 3:31 PM, Harsh Jain <harshjain.prof@gmail.com> wrote:
> HI Gilad,
>
> I think we need an update in ESP also. Now EBUSY return means driver
> has accepted, Packet should not be dropped in
>
> esp_output_tail() function.

Good catch. You are right and the same holds true for ah_output() in ah4.c.

But I do wonder, the code there now treats -EBUSY as a special case
and returns NET_XMIT_DROP
but if an AEAD or AHASH transformation return some other error, like
-ENOMEM or -EINVAL shouldn't
we return NET_XMIT_DROP in that case too?

Any ideas?

Gilad

>
>
> On Thu, Aug 24, 2017 at 7:48 PM, Gilad Ben-Yossef <gilad@benyossef.com> wrote:
>> Many users of kernel async. crypto services have a pattern of
>> starting an async. crypto op and than using a completion
>> to wait for it to end.
>>
>> This patch set simplifies this common use case in two ways:
>>
>> First, by separating the return codes of the case where a
>> request is queued to a backlog due to the provider being
>> busy (-EBUSY) from the case the request has failed due
>> to the provider being busy and backlogging is not enabled
>> (-EAGAIN).
>>
>> Next, this change is than built on to create a generic API
>> to wait for a async. crypto operation to complete.
>>
>> The end result is a smaller code base and an API that is
>> easier to use and more difficult to get wrong.
>>
>> The patch set was boot tested on x86_64 and arm64 which
>> at the very least tests the crypto users via testmgr and
>> tcrypt but I do note that I do not have access to some
>> of the HW whose drivers are modified nor do I claim I was
>> able to test all of the corner cases.
>>
>> The patch set is based upon linux-next release tagged
>> next-20170824.
>>
>> Changes from v6:
>> - Fix brown paper bag compile error on marvell/cesa
>>   code.
>>
>> Changes from v5:
>> - Remove redundant new line as spotted by Jonathan
>>   Cameron.
>> - Reworded dm-verity change commit message to better
>>   clarify potential issue averted by change as
>>   pointed out by Mikulas Patocka.
>>
>> Changes from v4:
>> - Rebase on top of latest algif changes from Stephan
>>   Mueller.
>> - Fix typo in ccp patch title.
>>
>> Changes from v3:
>> - Instead of changing the return code to indicate
>>   backlog queueing, change the return code to indicate
>>   transient busy state, as suggested by Herbert Xu.
>>
>> Changes from v2:
>> - Patch title changed from "introduce crypto wait for
>>   async op" to better reflect the current state.
>> - Rebase on top of latest linux-next.
>> - Add a new return code of -EIOCBQUEUED for backlog
>>   queueing, as suggested by Herbert Xu.
>> - Transform more users to the new API.
>> - Update the drbg change to account for new init as
>>   indicated by Stephan Muller.
>>
>> Changes from v1:
>> - Address review comments from Eric Biggers.
>> - Separated out bug fixes of existing code and rebase
>>   on top of that patch set.
>> - Rename 'ecr' to 'wait' in fscrypto code.
>> - Split patch introducing the new API from the change
>>   moving over the algif code which it originated from
>>   to the new API.
>> - Inline crypto_wait_req().
>> - Some code indentation fixes.
>>
>> Gilad Ben-Yossef (19):
>>   crypto: change transient busy return code to -EAGAIN
>>   crypto: ccp: use -EAGAIN for transient busy indication
>>   crypto: remove redundant backlog checks on EBUSY
>>   crypto: marvell/cesa: remove redundant backlog checks on EBUSY
>>   crypto: introduce crypto wait for async op
>>   crypto: move algif to generic async completion
>>   crypto: move pub key to generic async completion
>>   crypto: move drbg to generic async completion
>>   crypto: move gcm to generic async completion
>>   crypto: move testmgr to generic async completion
>>   fscrypt: move to generic async completion
>>   dm: move dm-verity to generic async completion
>>   cifs: move to generic async completion
>>   ima: move to generic async completion
>>   crypto: tcrypt: move to generic async completion
>>   crypto: talitos: move to generic async completion
>>   crypto: qce: move to generic async completion
>>   crypto: mediatek: move to generic async completion
>>   crypto: adapt api sample to use async. op wait
>>
>>  Documentation/crypto/api-samples.rst |  52 ++-------
>>  crypto/af_alg.c                      |  27 -----
>>  crypto/ahash.c                       |  12 +--
>>  crypto/algapi.c                      |   6 +-
>>  crypto/algif_aead.c                  |   8 +-
>>  crypto/algif_hash.c                  |  50 +++++----
>>  crypto/algif_skcipher.c              |   9 +-
>>  crypto/api.c                         |  13 +++
>>  crypto/asymmetric_keys/public_key.c  |  28 +----
>>  crypto/cryptd.c                      |   4 +-
>>  crypto/cts.c                         |   6 +-
>>  crypto/drbg.c                        |  36 ++-----
>>  crypto/gcm.c                         |  32 ++----
>>  crypto/lrw.c                         |   8 +-
>>  crypto/rsa-pkcs1pad.c                |  16 +--
>>  crypto/tcrypt.c                      |  84 +++++----------
>>  crypto/testmgr.c                     | 204 ++++++++++++-----------------------
>>  crypto/xts.c                         |   8 +-
>>  drivers/crypto/ccp/ccp-crypto-main.c |   8 +-
>>  drivers/crypto/ccp/ccp-dev.c         |   7 +-
>>  drivers/crypto/marvell/cesa.c        |   3 +-
>>  drivers/crypto/marvell/cesa.h        |   2 +-
>>  drivers/crypto/mediatek/mtk-aes.c    |  31 +-----
>>  drivers/crypto/qce/sha.c             |  30 +-----
>>  drivers/crypto/talitos.c             |  38 +------
>>  drivers/md/dm-verity-target.c        |  81 ++++----------
>>  drivers/md/dm-verity.h               |   5 -
>>  fs/cifs/smb2ops.c                    |  30 +-----
>>  fs/crypto/crypto.c                   |  28 +----
>>  fs/crypto/fname.c                    |  36 ++-----
>>  fs/crypto/fscrypt_private.h          |  10 --
>>  fs/crypto/keyinfo.c                  |  21 +---
>>  include/crypto/drbg.h                |   3 +-
>>  include/crypto/if_alg.h              |  15 +--
>>  include/linux/crypto.h               |  40 +++++++
>>  security/integrity/ima/ima_crypto.c  |  56 +++-------
>>  36 files changed, 310 insertions(+), 737 deletions(-)
>>
>> --
>> 2.1.4
>>



-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
