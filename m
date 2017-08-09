Return-Path: <keyrings-owner@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <4600c898-a2f2-f95f-15b4-0adcc6acc0b5@amd.com>
References: <1502193834-11289-1-git-send-email-gilad@benyossef.com>
 <1502193834-11289-3-git-send-email-gilad@benyossef.com> <4600c898-a2f2-f95f-15b4-0adcc6acc0b5@amd.com>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Wed, 9 Aug 2017 08:18:03 +0300
Message-ID: <CAOtvUMeUHk9KxQumhuvJ52dp-_-LFOD8XGvCWvhU6LjEZhEF7A@mail.gmail.com>
Subject: Re: [PATCH v4 02/19] crypto: ccm: use -EAGAIN for transient busy indication
Content-Type: text/plain; charset="UTF-8"
Sender: keyrings-owner@vger.kernel.org
To: Gary R Hook <gary.hook@amd.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, "Lendacky, Thomas" <Thomas.Lendacky@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mediatek@lists.infradead.org" <linux-mediatek@lists.infradead.org>, "linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>, "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>, "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>, "linux-fscrypt@vger.kernel.org" <linux-fscrypt@vger.kernel.org>, "linux-ima-devel@lists.sourceforge.net" <linux-ima-devel@lists.sourceforge.net>, "linux-ima-user@lists.sourceforge.net" <linux-ima-user@lists.sourceforge.net>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Aug 8, 2017 at 6:24 PM, Gary R Hook <gary.hook@amd.com> wrote:
> On 08/08/2017 07:03 AM, Gilad Ben-Yossef wrote:
>>
>> Replace -EBUSY with -EAGAIN when reporting transient busy
>> indication in the absence of backlog.
>>
>> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
>
>
> Could we use "ccp" in the subject line, please?

Of course, sorry about the the typo.

Gilad

-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
