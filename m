Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Wed, 24 Jul 2019 09:07:11 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fs: crypto: keyinfo: Fix a possible null-pointer
 dereference in derive_key_aes()
Message-ID: <20190724160711.GB673@sol.localdomain>
References: <20190724100204.2009-1-baijiaju1990@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724100204.2009-1-baijiaju1990@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: tytso@mit.edu, jaegeuk@kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

[+Cc linux-crypto]

On Wed, Jul 24, 2019 at 06:02:04PM +0800, Jia-Ju Bai wrote:
> In derive_key_aes(), tfm is assigned to NULL on line 46, and then
> crypto_free_skcipher(tfm) is executed.
> 
> crypto_free_skcipher(tfm)
>     crypto_skcipher_tfm(tfm)
>         return &tfm->base;
> 
> Thus, a possible null-pointer dereference may occur.

This analysis is incorrect because only the address &tfm->base is taken.
There's no pointer dereference.

In fact all the crypto_free_*() functions are no-ops on NULL pointers, and many
other callers rely on it.  So there's no bug here.

It appears you've sent the same patch for some of these other callers
(https://lore.kernel.org/lkml/?q=%22fix+a+possible+null-pointer%22), but none
are Cc'ed to linux-crypto or another mailing list I'm subscribed to, so I can't
respond to them.  But this feedback applies equally to them too.

Note also that if there actually were a bug here (which again, there doesn't
appear to be), we'd need to fix it in crypto_free_*(), not in the callers.

- Eric
