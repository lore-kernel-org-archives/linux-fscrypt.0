Return-Path: <dm-devel-bounces@redhat.com>
Date: Thu, 15 Aug 2019 15:13:20 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Message-ID: <20190815051320.GA24982@gondor.apana.org.au>
References: <20190814163746.3525-1-ard.biesheuvel@linaro.org>
	<20190814163746.3525-2-ard.biesheuvel@linaro.org>
	<20190815023734.GB23782@gondor.apana.org.au>
	<CAKv+Gu_maif=kZk-HRMx7pP=ths1vuTgcu4kFpzz0tCkO2+DFA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAKv+Gu_maif=kZk-HRMx7pP=ths1vuTgcu4kFpzz0tCkO2+DFA@mail.gmail.com>
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

On Thu, Aug 15, 2019 at 07:59:34AM +0300, Ard Biesheuvel wrote:
>
> So how do I ensure that the cipher and shash are actually loaded at
> create() time, and that they are still loaded at TFM init time?

If they're not available at TFM init then you just fail the init
and therefore the TFM allocation.  What is the problem?

IOW the presence of the block cipher and unkeyed hash does not
affect the creation of the instance object.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
