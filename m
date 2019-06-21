Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Fri, 21 Jun 2019 15:00:08 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190621220007.GE167064@gmail.com>
References: <20190616160813.24464-1-chandan@linux.ibm.com>
 <20190616160813.24464-4-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190616160813.24464-4-chandan@linux.ibm.com>
Subject: Re: [f2fs-dev] [PATCH V3 3/7] fscrypt: remove struct fscrypt_ctx
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Chandan Rajendra <chandan@linux.ibm.com>
Cc: tytso@mit.edu, linux-f2fs-devel@lists.sourceforge.net, hch@infradead.org, linux-fscrypt@vger.kernel.org, adilger.kernel@dilger.ca, linux-fsdevel@vger.kernel.org, jaegeuk@kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Jun 16, 2019 at 09:38:09PM +0530, Chandan Rajendra wrote:
> -/**
> - * fscrypt_get_ctx() - Get a decryption context
> - * @gfp_flags:   The gfp flag for memory allocation
> - *
> - * Allocate and initialize a decryption context.
> - *
> - * Return: A new decryption context on success; an ERR_PTR() otherwise.
> - */
> -struct fscrypt_ctx *fscrypt_get_ctx(gfp_t gfp_flags)
> -{
> -	struct fscrypt_ctx *ctx;
> -	unsigned long flags;
> -
> -	/*
> -	 * First try getting a ctx from the free list so that we don't have to
> -	 * call into the slab allocator.
> -	 */
> -	spin_lock_irqsave(&fscrypt_ctx_lock, flags);
> -	ctx = list_first_entry_or_null(&fscrypt_free_ctxs,
> -					struct fscrypt_ctx, free_list);
> -	if (ctx)
> -		list_del(&ctx->free_list);
> -	spin_unlock_irqrestore(&fscrypt_ctx_lock, flags);
> -	if (!ctx) {
> -		ctx = kmem_cache_zalloc(fscrypt_ctx_cachep, gfp_flags);
> -		if (!ctx)
> -			return ERR_PTR(-ENOMEM);
> -		ctx->flags |= FS_CTX_REQUIRES_FREE_ENCRYPT_FL;
> -	} else {
> -		ctx->flags &= ~FS_CTX_REQUIRES_FREE_ENCRYPT_FL;
> -	}
> -	return ctx;
> -}
> -EXPORT_SYMBOL(fscrypt_get_ctx);

FS_CTX_REQUIRES_FREE_ENCRYPT_FL is no longer used, so should be removed.

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
