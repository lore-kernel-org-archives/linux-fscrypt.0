Return-Path: <smueller@chronox.de>
From: Stephan =?ISO-8859-1?Q?M=FCller?= <smueller@chronox.de>
Subject: Re: [PATCH v2 04/11] crypto: move drbg to generic async completion
Date: Mon, 29 May 2017 11:04:01 +0200
Message-ID: <1638335.mkZCLTBCSi@tauon.chronox.de>
In-Reply-To: <1496046180-21962-5-git-send-email-gilad@benyossef.com>
References: <1496046180-21962-1-git-send-email-gilad@benyossef.com> <1496046180-21962-5-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Eric Biggers <ebiggers3@gmail.com>, Ofir Drang <ofir.drang@arm.com>, Pavel Shilovsky <pshilov@microsoft.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Am Montag, 29. Mai 2017, 10:22:51 CEST schrieb Gilad Ben-Yossef:

Hi Gilad,

> DRBG is starting an async. crypto op and waiting for it complete.
> Move it over to generic code doing the same.
>=20
> The code now also passes CRYPTO_TFM_REQ_MAY_SLEEP flag indicating
> crypto request memory allocation may use GFP_KERNEL which should
> be perfectly fine as the code is obviously sleeping for the
> completion of the request any way.
>=20
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>

Acked-by: Stephan M=FCller <smueller@chronox.de>

However, please note that there is a patch "crypto:drbg- Fixes panic in=20
wait_for_completion call." which adds another init_completion. I guess that=
=20
needs conversion to crypto_init_wait as well, once this patch set is accept=
ed.


Ciao
Stephan
