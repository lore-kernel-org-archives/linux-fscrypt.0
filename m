Return-Path: <dm-devel-bounces@redhat.com>
MIME-Version: 1.0
References: <20190819141738.1231-1-ard.biesheuvel@linaro.org>
In-Reply-To: <20190819141738.1231-1-ard.biesheuvel@linaro.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 20 Aug 2019 14:03:02 +0300
Message-ID: <CAKv+Gu_ZoQ+mfchJMigoy32DtAMbzRU3fOZS4YjBMS-2ZMvebg@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH v13 0/6] crypto: switch to crypto API for
	ESSIV generation
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
To: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, device-mapper development <dm-devel@redhat.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, 19 Aug 2019 at 17:17, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>
> This series creates an ESSIV template that produces a skcipher or AEAD
> transform based on a tuple of the form '<skcipher>,<shash>' (or '<aead>,<shash>'
> for the AEAD case). It exposes the encapsulated sync or async skcipher/aead by
> passing through all operations, while using the cipher/shash pair to transform
> the input IV into an ESSIV output IV.
>
> Changes since v12:
> - don't use a per-instance shash but only record the cra_driver_name of the
>   shash when instantiating the template, and allocate the shash for each
>   allocated transform instead
> - add back the dm-crypt patch -> as Milan has indicated, his preference would
>   be to queue these changes for v5.4 (with the first patch shared between the
>   cryptodev and md trees on a stable branch based on v5.3-rc1 - if needed,
>   I can provide a signed tag)
>

Actually, since Eric has indicated that he does not want to take the
associated fscrypt change for v5.4 anyway, patch #1 could simply be
routed through the md tree instead, while the others are taken through
cryptodev.

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
