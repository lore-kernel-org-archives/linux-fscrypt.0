Return-Path: <dm-devel-bounces@redhat.com>
Date: Fri, 26 Jul 2019 14:31:17 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Message-ID: <20190726043117.GA654@gondor.apana.org.au>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190704183017.31570-2-ard.biesheuvel@linaro.org>
Subject: Re: [dm-devel] [PATCH v8 1/7] crypto: essiv - create wrapper
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
Cc: ebiggers@google.com, linux-fscrypt@vger.kernel.org, gilad@benyossef.com, dm-devel@redhat.com, linux-crypto@vger.kernel.org, gmazyland@gmail.com
List-ID: <linux-fscrypt@vger.kernel.org>

Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>
> + * The typical use of this template is to instantiate the skcipher
> + * 'essiv(cbc(aes),aes,sha256)', which is the only instantiation used by
> + * fscrypt, and the most relevant one for dm-crypt. However, dm-crypt
> + * also permits ESSIV to be used in combination with the authenc template,
> + * e.g., 'essiv(authenc(hmac(sha256),cbc(aes)),aes,sha256)', in which case
> + * we need to instantiate an aead that accepts the same special key format
> + * as the authenc template, and deals with the way the encrypted IV is
> + * embedded into the AAD area of the aead request. This means the AEAD
> + * flavor produced by this template is tightly coupled to the way dm-crypt
> + * happens to use it.

IIRC only authenc is allowed in dm-crypt currently in conjunction
with ESSIV.  Does it ever allow a different hash algorithm in
authenc compared to the one used for ESSIV? IOW given

	essiv(authenc(hmac(X),cbc(Y)),Z,U)

is it currently possible for X != U or Y != Z? If not then let's
just make the algorithm name be essiv(Y,X).

Because this is legacy stuff, I don't want it to support any more
than what is currently being supported by dm-crypt.

Similary for the skcipher case, given

	essiv(cbc(X),Y,Z)

is it ever possible for X != Y? If not then we should just make the
algorithm name essiv(X,Z).

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
