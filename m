Return-Path: <tytso@thunk.org>
Date: Thu, 4 May 2017 10:55:16 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: correct collision claim for digested names
Message-ID: <20170504145516.7vwyb3f44iz7njly@thunk.org>
References: <20170501184332.37532-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170501184332.37532-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 01, 2017 at 11:43:32AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> As I noted on the mailing list, it's easier than I originally thought to
> create intentional collisions in the digested names.  Unfortunately it's
> not too easy to solve this, so for now just fix the comment to not lie.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied, thanks.

					- Ted
