Return-Path: <keyrings-owner@vger.kernel.org>
Date: Mon, 3 Jul 2017 20:35:15 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3 01/28] crypto: change backlog return code to
 -EIOCBQUEUED
Message-ID: <20170703123515.GC30067@gondor.apana.org.au>
References: <1499006535-19760-1-git-send-email-gilad@benyossef.com>
 <1499006535-19760-2-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499006535-19760-2-git-send-email-gilad@benyossef.com>
Sender: keyrings-owner@vger.kernel.org
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Jul 02, 2017 at 05:41:43PM +0300, Gilad Ben-Yossef wrote:
> The crypto API was using the -EBUSY return value to indicate
> both a hard failure to submit a crypto operation into a
> transformation provider when the latter was busy and the backlog
> mechanism was not enabled as well as a notification that the operation
> was queued into the backlog when the backlog mechanism was enabled.
> 
> Having the same return code indicate two very different conditions
> depending on a flag is both error prone and requires extra runtime
> check like the following to discern between the cases:
> 
> 	if (err == -EINPROGRESS ||
> 	    (err == -EBUSY && (ahash_request_flags(req) &
> 			       CRYPTO_TFM_REQ_MAY_BACKLOG)))
> 
> This patch changes the return code used to indicate a crypto op
> was queued in the backlog to -EIOCBQUEUED, thus resolving both
> issues.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>

So you're changing the success case from EBUSY to EIOCBQUEUED.
This results in a lot of churn as you have to change every single
driver and caller.

How about changing the error case to use something other than
EBUSY instead?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
