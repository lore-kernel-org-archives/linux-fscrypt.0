Return-Path: <keyrings-owner@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <20170703123515.GC30067@gondor.apana.org.au>
References: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
 <1499006535-19760-2-git-send-email-gilad@benyossef.com> <20170703123515.GC30067@gondor.apana.org.au>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Mon, 3 Jul 2017 16:23:18 +0300
Message-ID: <CAOtvUMdoMfrpZPuRfD_cQo4=FDp5Vn4uv51Vzc-0Gitmvr2V6g@mail.gmail.com>
Subject: Re: [PATCH v3 01/28] crypto: change backlog return code to -EIOCBQUEUED
Content-Type: text/plain; charset="UTF-8"
Sender: keyrings-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jul 3, 2017 at 3:35 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Sun, Jul 02, 2017 at 05:41:43PM +0300, Gilad Ben-Yossef wrote:
>> The crypto API was using the -EBUSY return value to indicate
>> both a hard failure to submit a crypto operation into a
>> transformation provider when the latter was busy and the backlog
>> mechanism was not enabled as well as a notification that the operation
>> was queued into the backlog when the backlog mechanism was enabled.
>>
>> Having the same return code indicate two very different conditions
>> depending on a flag is both error prone and requires extra runtime
>> check like the following to discern between the cases:
>>
>>       if (err == -EINPROGRESS ||
>>           (err == -EBUSY && (ahash_request_flags(req) &
>>                              CRYPTO_TFM_REQ_MAY_BACKLOG)))
>>
>> This patch changes the return code used to indicate a crypto op
>> was queued in the backlog to -EIOCBQUEUED, thus resolving both
>> issues.
>>
>> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
>
> So you're changing the success case from EBUSY to EIOCBQUEUED.
> This results in a lot of churn as you have to change every single
> driver and caller.
>
> How about changing the error case to use something other than
> EBUSY instead?

That was indeed my first thought - I wanted to change EBUSY to EAGAIN.
It might even be a more descriptive error message since the failure is
transient.

What stopped me was that I saw the algif interface passes this EBUSY value
to user space. I don't know of any software that depends on this value but
I'm really averse to changing user space API.

Of course, we can just plant a (ret != AGAIN : ? EBUSY) in the algif interface
return to user space code path but that felt like a kludge to me.

And it doesn't really save any churn, I think - I'd still have to
visit all the places that
use the flags value to distinguish between the two EBUSY use cases and  I need
to visit most places that check for EBUSY as backlog indication because I'm
replacing the check with the generic replacement, so it doesn't look
like in the end
it will be a smaller change.

Having said that, if you prefer me to replace the error case I'd
happily do that.

Thanks,
Gilad


-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
