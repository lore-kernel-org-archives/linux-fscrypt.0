Return-Path: <tytso@thunk.org>
Date: Thu, 1 Jun 2017 10:25:30 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v4] fscrypt: Add support for AES-128-CBC
Message-ID: <20170601142530.n6rfwuwwdzmkzyfp@thunk.org>
References: <20170517180850.GA91213@gmail.com>
 <20170523051120.15698-1-david@sigma-star.at>
 <20170523190041.GA132828@gmail.com>
 <54DA453A-BC92-466E-B3D2-6C67D7D32A90@sigma-star.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54DA453A-BC92-466E-B3D2-6C67D7D32A90@sigma-star.at>
To: David Gstir <david@sigma-star.at>
Cc: Eric Biggers <ebiggers3@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@sigma-star.at>, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Daniel Walter <dwalter@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, May 31, 2017 at 05:57:22PM +0200, David Gstir wrote:
> > The 'keysize > sizeof(salt)' check is now pointless and should be removed, since
> > we decided not to key the ESSIV cipher with 'keysize' bytes, but rather with
> > sizeof(salt) bytes.  So this function is compatible with any 'keysize', not just
> > keysize <= sizeof(salt).
> 
> You're right. Just let me know if I should send a new version of this patch with these minor issues fixed.

Please do, thanks!

					- Ted
