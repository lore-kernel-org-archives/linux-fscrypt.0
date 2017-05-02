Return-Path: <tytso@thunk.org>
Date: Tue, 2 May 2017 01:28:11 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] ext4: inherit encryption xattr before other xattrs
Message-ID: <20170502052811.vvynumo5s7egy7q5@thunk.org>
References: <20170217233321.108637-1-ebiggers3@gmail.com>
 <2F4F7FA9-37C2-4FF1-9365-EF38D57FE7CA@dilger.ca>
 <20170227213637.GA123733@gmail.com>
 <20170501185228.GA30027@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170501185228.GA30027@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Ext4 Developers List <linux-ext4@vger.kernel.org>, Andreas Dilger <adilger@dilger.ca>, linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 01, 2017 at 11:52:28AM -0700, Eric Biggers wrote:
> 
> Ted, this patch seems to have gotten missed; are you planning to apply it?  Next
> cycle is fine too, but I'd like to get it in sometime.

Yes, I had missed it.  Since it's simple and low-risk, I'll include it
this cycle; it's in the dev branch now.  Thanks for reminding me!

						- Ted
