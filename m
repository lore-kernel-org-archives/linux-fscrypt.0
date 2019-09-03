Return-Path: <dm-devel-bounces@redhat.com>
Date: Tue, 3 Sep 2019 14:55:37 -0400
From: Mike Snitzer <snitzer@redhat.com>
Message-ID: <20190903185537.GC13472@redhat.com>
References: <20190819141738.1231-1-ard.biesheuvel@linaro.org>
	<20190819141738.1231-6-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190819141738.1231-6-ard.biesheuvel@linaro.org>
Subject: Re: [dm-devel] [PATCH v13 5/6] md: dm-crypt: switch to ESSIV crypto
	API template
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
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, Gilad Ben-Yossef <gilad@benyossef.com>, linux-fscrypt@vger.kernel.org, linux-crypto@vger.kernel.org, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 19 2019 at 10:17am -0400,
Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:

> Replace the explicit ESSIV handling in the dm-crypt driver with calls
> into the crypto API, which now possesses the capability to perform
> this processing within the crypto subsystem.
> 
> Note that we reorder the AEAD cipher_api string parsing with the TFM
> instantiation: this is needed because cipher_api is mangled by the
> ESSIV handling, and throws off the parsing of "authenc(" otherwise.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

I really like to see this type of factoring out to the crypto API;
nicely done.

Acked-by: Mike Snitzer <snitzer@redhat.com>

Herbert, please feel free to pull this, and the next 6/6 patch, into
your crypto tree for 5.4.  I see no need to complicate matters by me
having to rebase my dm-5.4 branch ontop of the crypto tree, etc.

Thanks,
Mike

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
