Return-Path: <gilad@benyossef.com>
MIME-Version: 1.0
In-Reply-To: <20170610034336.GB14206@gondor.apana.org.au>
References: <1496046180-21962-1-git-send-email-gilad@benyossef.com>
 <1496046180-21962-2-git-send-email-gilad@benyossef.com> <20170610034336.GB14206@gondor.apana.org.au>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Sat, 10 Jun 2017 11:05:39 +0300
Message-ID: <CAOtvUMeRtcVcp8HE9oJAkJO35yF9XBsry3tdNQYj-e31DnDFQQ@mail.gmail.com>
Subject: Re: [PATCH v2 01/11] crypto: introduce crypto wait for async op
Content-Type: text/plain; charset="UTF-8"
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Eric Biggers <ebiggers3@gmail.com>, Ofir Drang <ofir.drang@arm.com>, Pavel Shilovsky <pshilov@microsoft.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Jun 10, 2017 at 6:43 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, May 29, 2017 at 11:22:48AM +0300, Gilad Ben-Yossef wrote:
>>
>> +static inline int crypto_wait_req(int err, struct crypto_wait *wait)
>> +{
>> +     switch (err) {
>> +     case -EINPROGRESS:
>> +     case -EBUSY:
>> +             wait_for_completion(&wait->completion);
>> +             reinit_completion(&wait->completion);
>> +             err = wait->err;
>> +             break;
>> +     };
>> +
>> +     return err;
>> +}
>
> This assumes that the request is used with backlog.  For non-backlog
> requests this would result in a memory leak as EBUSY in that case is
> a fatal error.
>
> So this API can't be used without backlog.

You are right, of course. I did not take that into account.

>
> We could introduce a flag to indicate whether we want backlog or not,
> or maybe we should change our API so that in the non-backlog case we
> return something other than EBUSY.
>
> Opinions?

I guess there is a question if it really is important to know that
your request ended up
on the backlog, rather than being handled.I can imagine it can be used
as back pressure
indication but I wonder if someone is using that.

If not, maybe we can simplify things and use EINPROGRESS asindication
of a request
being accepted by the next layer (either being processed or queued in
the back log), whereas
EBUSY would indicate failure.

It does have a potential to make things simpler, I think.

Gilad

>
> Thanks,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt



-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
