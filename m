Return-Path: <keyrings-owner@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <20171015153831.GA22867@gondor.apana.org.au>
References: <1508059209-25529-1-git-send-email-gilad@benyossef.com> <20171015153831.GA22867@gondor.apana.org.au>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Tue, 17 Oct 2017 14:55:21 +0300
Message-ID: <CAOtvUMeESbKKaEvpW_MKrRaCxwQWnBa00m4v4F1jNZ_+Xq7pWA@mail.gmail.com>
Subject: Re: [PATCH v9 00/20] simplify crypto wait for async op
Content-Type: text/plain; charset="UTF-8"
Sender: keyrings-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Steffen Klassert <steffen.klassert@secunet.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Ofir Drang <ofir.drang@arm.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, netdev@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Oct 15, 2017 at 6:38 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Sun, Oct 15, 2017 at 10:19:45AM +0100, Gilad Ben-Yossef wrote:
> >
> > Changes from v8:
> > - Remove the translation of EAGAIN return code to the
> >   previous return code of EBUSY for the user space
> >   interface of algif as no one seems to rely on it as
> >   requested by Herbert Xu.
>
> Sorry, but I forgot to mention that EAGAIN is not a good value
> to use because it's used by the network system calls for other
> meanings (interrupted by a signal).
>
> So if we stop doing the translation then we also need to pick
> a different value, perhaps E2BIG or something similar that have
> no current use within the crypto API or network API.

Yes, I see what you mean. With a netlink based interface this can
be confusing to debug.

Would you mind if we used ENOSPC instead of E2BIG?

"No space left on device" seems more appropriate than
"Argument list too long".

Thanks,
Gilad




-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
