Return-Path: <SRS0=5Bo/=LJ=vger.kernel.org=linux-integrity-owner@kernel.org>
Date: Sun, 26 Aug 2018 10:04:34 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 02/10] fs-verity: add data verification hooks for
 ->readpages()
Message-ID: <20180826170433.GA728@sol.localdomain>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-3-ebiggers@kernel.org>
 <C86750D6-CA95-4A7F-9204-51345C497EC2@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C86750D6-CA95-4A7F-9204-51345C497EC2@gmail.com>
Sender: linux-integrity-owner@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chuck,

On Sun, Aug 26, 2018 at 11:55:57AM -0400, Chuck Lever wrote:
> > +
> > +/**
> > + * fsverity_verify_page - verify a data page
> > + *
> > + * Verify a page that has just been read from a file against that file's Merkle
> > + * tree.  The page is assumed to be a pagecache page.
> > + *
> > + * Return: true if the page is valid, else false.
> > + */
> > +bool fsverity_verify_page(struct page *data_page)
> > +{
> > +	struct inode *inode = data_page->mapping->host;
> > +	const struct fsverity_info *vi = get_fsverity_info(inode);
> > +	struct ahash_request *req;
> > +	bool valid;
> > +
> > +	req = ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
> > +	if (unlikely(!req))
> > +		return false;
> > +
> > +	valid = verify_page(inode, vi, req, data_page);
> > +
> > +	ahash_request_free(req);
> > +
> > +	return valid;
> > +}
> > +EXPORT_SYMBOL_GPL(fsverity_verify_page);
> > +
> > +/**
> > + * fsverity_verify_bio - verify a 'read' bio that has just completed
> > + *
> > + * Verify a set of pages that have just been read from a file against that
> > + * file's Merkle tree.  The pages are assumed to be pagecache pages.  Pages that
> > + * fail verification are set to the Error state.  Verification is skipped for
> > + * pages already in the Error state, e.g. due to fscrypt decryption failure.
> > + */
> > +void fsverity_verify_bio(struct bio *bio)
> 
> Hi Eric-
> 
> This kind of API won't work for remote filesystems, which do not use
> "struct bio" to do their I/O. Could a remote filesystem solely use
> fsverity_verify_page instead?
> 

Yes, filesystems don't have to use fsverity_verify_bio().  They can call
fsverity_verify_page() on each page instead.  I will clarify this in the next
revision of the patchset.

- Eric
