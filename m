Return-Path: <krzk@kernel.org>
MIME-Version: 1.0
References: <CGME20190821064211epcas2p43ed73f4fd126bcc5b470c9136db6aabc@epcas2p4.samsung.com>
 <003d01d557eb$8f6ca210$ae45e630$@samsung.com>
In-Reply-To: <003d01d557eb$8f6ca210$ae45e630$@samsung.com>
From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Thu, 22 Aug 2019 10:37:26 +0200
Message-ID: <CAJKOXPdK3ZzQXjzPZLzu5q0HZsL1vohQ4UxYTONcWdtDbEe2ng@mail.gmail.com>
Subject: Re: [PATCH 1/9] crypt: Add diskcipher
Content-Type: text/plain; charset="UTF-8"
To: "boojin.kim" <boojin.kim@samsung.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Biggers <ebiggers@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Chao Yu <chao@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Andreas Dilger <adilger.kernel@dilger.ca>, dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, Jens Axboe <axboe@kernel.dk>, Kukjin Kim <kgene@kernel.org>, Jaehoon Chung <jh80.chung@samsung.com>, Ulf Hansson <ulf.hansson@linaro.org>, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, 21 Aug 2019 at 08:42, boojin.kim <boojin.kim@samsung.com> wrote:
>
> Diskcipher supports cryptographic operations of inline crypto engines like
> FMP. Inline crypto engine refers to hardware and solutions implemented
> to encrypt data stored in storage device.
>
> When encrypting using the FMP, Additional control is required
> to carry and maintain the crypto information between
> the encryption user(fscrypt, DM-crypt) and FMP driver.
> Diskcipher provides this control.
>
> Diskcipher is a symmetric key cipher in linux crypto API to support FMP.
> FMP are registered with the cihper algorithm that uses diskcipher.
>
> Diskcipher has three major steps.
> The first step is to assign a cipher and set the key.
> The second step is to pass the cipher through the BIO to the storage
> driver.
> The third step is to get the cipher from BIO and request a crypt
> to FMP algorithm.
>
> In the first step, encryption users such as fscrypt or dm-crypt
> allocate/release a diskcipher and set key into the diskcipher.
> Diskcipher provides allocate(), free(), and setkey() that are similar
> to existing ciphers.
>
> In the second step, BIO is used to pass the diskcipher to the storage
> driver.
> The BIO submitters such as ext4, f2fs and DM-crypt set diskcipher to BIO.
> Diskcipher provides the set () API for this.
>
> In the third step, the storage driver extracts the diskcipher from the BIO
> and requests the actual encryption behavior to inline crypto engine driver.
> Diskcipher provides get() and crypt() APIs for this.
>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Boojin Kim <boojin.kim@samsung.com>
> ---
>  crypto/Kconfig              |   9 ++
>  crypto/Makefile             |   1 +
>  crypto/diskcipher.c         | 349
> ++++++++++++++++++++++++++++++++++++++++++++
>  crypto/testmgr.c            | 157 ++++++++++++++++++++
>  include/crypto/diskcipher.h | 245 +++++++++++++++++++++++++++++++
>  include/linux/crypto.h      |   1 +
>  6 files changed, 762 insertions(+)
>  create mode 100644 crypto/diskcipher.c
>  create mode 100644 include/crypto/diskcipher.h
>
> diff --git a/crypto/Kconfig b/crypto/Kconfig
> index 455a335..382d43a 100644
> --- a/crypto/Kconfig
> +++ b/crypto/Kconfig
> @@ -1636,6 +1636,15 @@ config CRYPTO_TWOFISH_AVX_X86_64
>           See also:
>           <http://www.schneier.com/twofish.html>
>
> +config CRYPTO_DISKCIPHER
> +       bool "Diskcipher support"
> +       default n
> +       help
> +         Disk cipher algorithm
> +
> +         This cipher supports the crypt operation of the block host device
> +         that has inline crypto engine.
> +
>  comment "Compression"
>
>  config CRYPTO_DEFLATE
> diff --git a/crypto/Makefile b/crypto/Makefile
> index 0d2cdd5..71df76a 100644
> --- a/crypto/Makefile
> +++ b/crypto/Makefile
> @@ -165,6 +165,7 @@ obj-$(CONFIG_CRYPTO_USER_API_AEAD) += algif_aead.o
>  obj-$(CONFIG_CRYPTO_ZSTD) += zstd.o
>  obj-$(CONFIG_CRYPTO_OFB) += ofb.o
>  obj-$(CONFIG_CRYPTO_ECC) += ecc.o
> +obj-$(CONFIG_CRYPTO_DISKCIPHER) += diskcipher.o
>
>  ecdh_generic-y += ecdh.o
>  ecdh_generic-y += ecdh_helper.o
> diff --git a/crypto/diskcipher.c b/crypto/diskcipher.c
> new file mode 100644
> index 0000000..ffe95a5
> --- /dev/null
> +++ b/crypto/diskcipher.c
> @@ -0,0 +1,349 @@
> +// SPDX-License-Identifier: GPL-2.0-or-later
> +/*
> + * Copyright (C) 2017 Samsung Electronics Co., Ltd.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/blkdev.h>
> +#include <linux/errno.h>
> +#include <linux/module.h>
> +#include <linux/seq_file.h>
> +#include <linux/string.h>
> +#include <linux/crypto.h>
> +#include <crypto/algapi.h>
> +#include <crypto/diskcipher.h>
> +#include <linux/delay.h>
> +#include <linux/mm_types.h>
> +#include <linux/fs.h>
> +#include <linux/fscrypt.h>
> +
> +#include "internal.h"
> +
> +static int crypto_diskcipher_check(struct bio *bio)
> +{
> +       struct crypto_diskcipher *ci = NULL;
> +       struct inode *inode = NULL;
> +       struct page *page = NULL;
> +
> +       if (!bio) {
> +               pr_err("%s: doesn't exist bio\n", __func__);
> +               return 0;
> +       }
> +
> +       /* enc without fscrypt */
> +       ci = bio->bi_aux_private;
> +       if (!ci->inode)
> +               return 0;
> +       if (ci->algo == 0)
> +               return 0;
> +
> +       page = bio->bi_io_vec[0].bv_page;
> +       if (!page || PageAnon(page) || !page->mapping ||
> !page->mapping->host)

Your patch looks corrupted - wrapped by mailer. The easiest way
usually is to use git format-patch and git send-email - then you do
not have to worry about formatting etc.

Best regards,
Krzysztof
