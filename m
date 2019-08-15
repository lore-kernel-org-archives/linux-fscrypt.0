Return-Path: <dm-devel-bounces@redhat.com>
MIME-Version: 1.0
References: <20190814163746.3525-1-ard.biesheuvel@linaro.org>
	<20190814163746.3525-2-ard.biesheuvel@linaro.org>
	<20190815023734.GB23782@gondor.apana.org.au>
	<CAKv+Gu_maif=kZk-HRMx7pP=ths1vuTgcu4kFpzz0tCkO2+DFA@mail.gmail.com>
	<20190815051320.GA24982@gondor.apana.org.au>
In-Reply-To: <20190815051320.GA24982@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 15 Aug 2019 08:15:29 +0300
Message-ID: <CAKv+Gu_OVUfXW6t+j1RHA4_Uc43o50Sspke2KkVw9djbFDd04g@mail.gmail.com>
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
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, device-mapper development <dm-devel@redhat.com>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, 15 Aug 2019 at 08:13, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Thu, Aug 15, 2019 at 07:59:34AM +0300, Ard Biesheuvel wrote:
> >
> > So how do I ensure that the cipher and shash are actually loaded at
> > create() time, and that they are still loaded at TFM init time?
>
> If they're not available at TFM init then you just fail the init
> and therefore the TFM allocation.  What is the problem?
>
> IOW the presence of the block cipher and unkeyed hash does not
> affect the creation of the instance object.
>

Right.

So what about checking that the cipher key size matches the shash
digest size, or that the cipher block size matches the skcipher IV
size? This all moves to the TFM init function?

Are there any existing templates that use this approach?

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
