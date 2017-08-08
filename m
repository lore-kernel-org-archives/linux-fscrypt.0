Return-Path: <keyrings-owner@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <8585274.Umn6qnzcUd@tauon.chronox.de>
References: <1502193834-11289-1-git-send-email-gilad@benyossef.com>
 <1502193834-11289-7-git-send-email-gilad@benyossef.com> <8585274.Umn6qnzcUd@tauon.chronox.de>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Tue, 8 Aug 2017 16:45:36 +0300
Message-ID: <CAOtvUMfp7Hie_RA8XNmWS084PvyO_xB0VAf2Vt9nR68cQhz3=g@mail.gmail.com>
Subject: Re: [PATCH v4 06/19] crypto: move algif to generic async completion
Content-Type: text/plain; charset="UTF-8"
Sender: keyrings-owner@vger.kernel.org
To: Stephan Mueller <smueller@chronox.de>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba <-technical@lists.samba.org>, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Aug 8, 2017 at 4:10 PM, Stephan Mueller <smueller@chronox.de> wrote:
> Am Dienstag, 8. August 2017, 14:03:37 CEST schrieb Gilad Ben-Yossef:
>
> Hi Gilad,
>
>> algif starts several async crypto ops and waits for their completion.
>> Move it over to generic code doing the same.
>
> Just FYI: your patch set and my patch [1] will clash.
>
> [1] https://patchwork.kernel.org/patch/9875959/

I'll try to rebase on linux-next + your patch than.

Thanks for letting me know.

Gilad




-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
