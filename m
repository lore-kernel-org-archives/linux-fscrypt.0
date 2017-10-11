Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:33248 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755552AbdJKG3I (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 11 Oct 2017 02:29:08 -0400
Date: Wed, 11 Oct 2017 14:26:51 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v8 01/20] crypto: change transient busy return code to
 -EAGAIN
Message-ID: <20171011062651.GA18664@gondor.apana.org.au>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
 <1504615144-29770-2-git-send-email-gilad@benyossef.com>
 <20171007030541.GA29421@gondor.apana.org.au>
 <CAOtvUMd=vtju=VJkCYFRrvANbRRYj+95cdgDoMMfBvmPaPbsAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOtvUMd=vtju=VJkCYFRrvANbRRYj+95cdgDoMMfBvmPaPbsAA@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Steffen Klassert <steffen.klassert@secunet.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, netdev@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Oct 07, 2017 at 10:51:42AM +0300, Gilad Ben-Yossef wrote:
> On Sat, Oct 7, 2017 at 6:05 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > On Tue, Sep 05, 2017 at 03:38:40PM +0300, Gilad Ben-Yossef wrote:
> >>
> >> diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
> >> index 5e92bd2..3b3c154 100644
> >> --- a/crypto/algif_hash.c
> >> +++ b/crypto/algif_hash.c
> >> @@ -39,6 +39,20 @@ struct algif_hash_tfm {
> >>       bool has_key;
> >>  };
> >>
> >> +/* Previous versions of crypto_* ops used to return -EBUSY
> >> + * rather than -EAGAIN to indicate being tied up. The in
> >> + * kernel API changed but we don't want to break the user
> >> + * space API. As only the hash user interface exposed this
> >> + * error ever to the user, do the translation here.
> >> + */
> >> +static inline int crypto_user_err(int err)
> >> +{
> >> +     if (err == -EAGAIN)
> >> +             return -EBUSY;
> >> +
> >> +     return err;
> >
> > I don't see the need to carry along this baggage.  Does anyone
> > in user-space actually rely on EBUSY?
> 
> 
> I am not aware of anyone who does. I was just trying to avoid
> changing the user ABI.
> 
> Shall I roll a new revision without this patch?

Yes please.  I'd rather not carry this around for eternity unless
it was actually required.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
