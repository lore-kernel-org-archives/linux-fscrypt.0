Return-Path: <SRS0=J7B4=LI=huawei.com=gaoxiang25@kernel.org>
Subject: Re: [f2fs-dev] [RFC PATCH 02/10] fs-verity: add data verification
 hooks for ->readpages()
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-3-ebiggers@kernel.org>
From: Gao Xiang <gaoxiang25@huawei.com>
Message-ID: <2f2382c3-e5e9-f0da-dc89-42dfc7b2b636@huawei.com>
Date: Sat, 25 Aug 2018 10:29:26 +0800
MIME-Version: 1.0
In-Reply-To: <20180824161642.1144-3-ebiggers@kernel.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

On 2018/8/25 0:16, Eric Biggers wrote:
> +/**
> + * fsverity_verify_page - verify a data page
> + *
> + * Verify a page that has just been read from a file against that file's Merkle
> + * tree.  The page is assumed to be a pagecache page.
> + *
> + * Return: true if the page is valid, else false.
> + */
> +bool fsverity_verify_page(struct page *data_page)
> +{
> +	struct inode *inode = data_page->mapping->host;
> +	const struct fsverity_info *vi = get_fsverity_info(inode);
> +	struct ahash_request *req;
> +	bool valid;
> +
> +	req = ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
> +	if (unlikely(!req))
> +		return false;
> +
> +	valid = verify_page(inode, vi, req, data_page);
> +
> +	ahash_request_free(req);
> +
> +	return valid;
> +}
> +EXPORT_SYMBOL_GPL(fsverity_verify_page);
> +
> +/**
> + * fsverity_verify_bio - verify a 'read' bio that has just completed
> + *
> + * Verify a set of pages that have just been read from a file against that
> + * file's Merkle tree.  The pages are assumed to be pagecache pages.  Pages that
> + * fail verification are set to the Error state.  Verification is skipped for
> + * pages already in the Error state, e.g. due to fscrypt decryption failure.
> + */
> +void fsverity_verify_bio(struct bio *bio)
> +{
> +	struct inode *inode = bio_first_page_all(bio)->mapping->host;
> +	const struct fsverity_info *vi = get_fsverity_info(inode);
> +	struct ahash_request *req;
> +	struct bio_vec *bv;
> +	int i;
> +
> +	req = ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
> +	if (unlikely(!req)) {
> +		bio_for_each_segment_all(bv, bio, i)
> +			SetPageError(bv->bv_page);
> +		return;
> +	}
> +
> +	bio_for_each_segment_all(bv, bio, i) {
> +		struct page *page = bv->bv_page;
> +
> +		if (!PageError(page) && !verify_page(inode, vi, req, page))
> +			SetPageError(page);
> +	}
> +
> +	ahash_request_free(req);
> +}
> +EXPORT_SYMBOL_GPL(fsverity_verify_bio);

Out of curiosity, I quickly scanned the fs-verity source code and some minor question out there....

If something is wrong, please point out, thanks in advance...

My first question is that 'Is there any way to skip to verify pages in a bio?'
I am thinking about
If metadata and data page are mixed in a filesystem of such kind, they could submit together in a bio, but metadata could be unsuitable for such kind of verification.

The second question is related to the first question --- 'Is there any way to verify a partial page?'
Take scalability into consideration, some files could be totally inlined or partially inlined in metadata.
Is there any way to deal with them in per-file approach? at least --- support for the interface?

At last, I hope filesystems could select the on-disk position of hash tree and 'struct fsverity_descriptor'
rather than fixed in the end of verity files...I think if fs-verity preparing such support and interfaces could be better.....hmmm... :(

Thanks,
Gao Xiang
