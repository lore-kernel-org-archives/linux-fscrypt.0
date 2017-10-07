Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:54175 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751466AbdJGHvn (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 7 Oct 2017 03:51:43 -0400
Received: by mail-oi0-f65.google.com with SMTP id j126so32854174oia.10
        for <linux-fscrypt@vger.kernel.org>; Sat, 07 Oct 2017 00:51:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171007030541.GA29421@gondor.apana.org.au>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
 <1504615144-29770-2-git-send-email-gilad@benyossef.com> <20171007030541.GA29421@gondor.apana.org.au>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Sat, 7 Oct 2017 10:51:42 +0300
Message-ID: <CAOtvUMd=vtju=VJkCYFRrvANbRRYj+95cdgDoMMfBvmPaPbsAA@mail.gmail.com>
Subject: Re: [PATCH v8 01/20] crypto: change transient busy return code to -EAGAIN
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Steffen Klassert <steffen.klassert@secunet.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, netdev@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Oct 7, 2017 at 6:05 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Sep 05, 2017 at 03:38:40PM +0300, Gilad Ben-Yossef wrote:
>>
>> diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
>> index 5e92bd2..3b3c154 100644
>> --- a/crypto/algif_hash.c
>> +++ b/crypto/algif_hash.c
>> @@ -39,6 +39,20 @@ struct algif_hash_tfm {
>>       bool has_key;
>>  };
>>
>> +/* Previous versions of crypto_* ops used to return -EBUSY
>> + * rather than -EAGAIN to indicate being tied up. The in
>> + * kernel API changed but we don't want to break the user
>> + * space API. As only the hash user interface exposed this
>> + * error ever to the user, do the translation here.
>> + */
>> +static inline int crypto_user_err(int err)
>> +{
>> +     if (err == -EAGAIN)
>> +             return -EBUSY;
>> +
>> +     return err;
>
> I don't see the need to carry along this baggage.  Does anyone
> in user-space actually rely on EBUSY?


I am not aware of anyone who does. I was just trying to avoid
changing the user ABI.

Shall I roll a new revision without this patch?

Thanks,
Gilad

>
> Cheers,
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
