Return-Path: <ebiggers3@gmail.com>
Date: Thu, 30 Mar 2017 23:36:01 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: Add support for AES-128-CBC
Message-ID: <20170331063601.GB32409@zzz>
References: <20170330173840.72909-1-david@sigma-star.at>
 <20170331062149.GA32409@zzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170331062149.GA32409@zzz>
To: David Gstir <david@sigma-star.at>
Cc: tytso@mit.edu, jaegeuk@kernel.org, dwalter@sigma-star.at, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Mar 30, 2017 at 11:21:49PM -0700, Eric Biggers wrote:
> 
> Something else to consider (probably for the future; this doesn't necessarily
> have to be done yet) is that you really only need one essiv_tfm per *key*, not
> one per inode.  To deduplicate them you'd need a hash table or LRU queue or
> something to keep track of the keys in use.
> 

Sorry, I screwed this up.  This wouldn't work because the ESSIV key is being
derived from the per-file key, not the master key.

- Eric
