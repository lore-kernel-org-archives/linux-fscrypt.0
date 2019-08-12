Return-Path: <dm-devel-bounces@redhat.com>
Date: Mon, 12 Aug 2019 12:47:48 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190812194747.GB131059@gmail.com>
References: <20190812145324.27090-1-ard.biesheuvel@linaro.org>
	<20190812145324.27090-3-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190812145324.27090-3-ard.biesheuvel@linaro.org>
Subject: Re: [dm-devel] [PATCH v10 2/7] fs: crypto: invoke crypto API for
	ESSIV handling
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
Cc: Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, dm-devel@redhat.com, linux-crypto@vger.kernel.org, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 12, 2019 at 05:53:19PM +0300, Ard Biesheuvel wrote:
> Instead of open coding the calculations for ESSIV handling, use a
> ESSIV skcipher which does all of this under the hood.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

This looks fine (except for one comment below), but this heavily conflicts with
the fscrypt patches planned for v5.4.  So I suggest moving this to the end of
the series and having Herbert take only 1-6, and I'll apply this one to the
fscrypt tree later.

Thanks!

> ---
>  fs/crypto/Kconfig           |  1 +
>  fs/crypto/crypto.c          |  5 --
>  fs/crypto/fscrypt_private.h |  9 --
>  fs/crypto/keyinfo.c         | 92 +-------------------
>  4 files changed, 4 insertions(+), 103 deletions(-)
> 
> diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
> index 5fdf24877c17..6f3d59b880b7 100644
> --- a/fs/crypto/Kconfig
> +++ b/fs/crypto/Kconfig
> @@ -5,6 +5,7 @@ config FS_ENCRYPTION
>  	select CRYPTO_AES
>  	select CRYPTO_CBC
>  	select CRYPTO_ECB
> +	select CRYPTO_ESSIV
>  	select CRYPTO_XTS
>  	select CRYPTO_CTS
>  	select KEYS

In v5.3 I removed the 'select CRYPTO_SHA256', so now ESSIV shouldn't be selected
here either.  Instead we should just update the documentation:

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 82efa41b0e6c02..a1e2ab12a99943 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -193,7 +193,8 @@ If unsure, you should use the (AES-256-XTS, AES-256-CTS-CBC) pair.
 AES-128-CBC was added only for low-powered embedded devices with
 crypto accelerators such as CAAM or CESA that do not support XTS.  To
 use AES-128-CBC, CONFIG_CRYPTO_SHA256 (or another SHA-256
-implementation) must be enabled so that ESSIV can be used.
+implementation) and CONFIG_CRYPTO_ESSIV must be enabled so that ESSIV
+can be used.
 
 Adiantum is a (primarily) stream cipher-based mode that is fast even
 on CPUs without dedicated crypto instructions.  It's also a true

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
