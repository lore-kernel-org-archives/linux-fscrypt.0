Return-Path: <dm-devel-bounces@redhat.com>
Date: Thu, 15 Aug 2019 21:35:48 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Message-ID: <20190815113548.GA27723@gondor.apana.org.au>
References: <20190814163746.3525-1-ard.biesheuvel@linaro.org>
	<20190814163746.3525-2-ard.biesheuvel@linaro.org>
	<20190815023734.GB23782@gondor.apana.org.au>
	<CAKv+Gu_maif=kZk-HRMx7pP=ths1vuTgcu4kFpzz0tCkO2+DFA@mail.gmail.com>
	<20190815051320.GA24982@gondor.apana.org.au>
	<CAKv+Gu_OVUfXW6t+j1RHA4_Uc43o50Sspke2KkVw9djbFDd04g@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAKv+Gu_OVUfXW6t+j1RHA4_Uc43o50Sspke2KkVw9djbFDd04g@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH v11 1/4] crypto: essiv - create wrapper
 template for ESSIV generation
List-Unsubscribe: <https://www.redhat.com/mailman/options/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, device-mapper development <dm-devel@redhat.com>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Aug 15, 2019 at 08:15:29AM +0300, Ard Biesheuvel wrote:
> 
> So what about checking that the cipher key size matches the shash
> digest size, or that the cipher block size matches the skcipher IV
> size? This all moves to the TFM init function?

I don't think you need to check those things.  If the shash produces
an incorrect key size the setkey will just fail naturally.  As to
the block size matching the IV size, in the kernel it's not actually
possible to get an underlying cipher with different block size
than the cbc mode that you used to derive it.

The size checks that we have in general are to stop people from
making crazy combinations such as lrw(des3_ede), it's not there
to test the correctness of a given implementation.  That is,
we assume that whoever provides "aes" will give it the correct
geometry for it.

Sure we haven't made it explicit (which we should at some point)
but as it stands, it can only occur if we have a bug or someone
loads a malicious kernel module in which case none of this matters.

> Are there any existing templates that use this approach?

I'm not sure of templates doing this but this is similar to fallbacks.
In fact we don't check any gemoetry on the fallbacks at all.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
