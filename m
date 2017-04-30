Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:18:21 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [4/4] ubifs: check for consistent encryption contexts in
 ubifs_lookup()
Message-ID: <20170430061821.2vzsfs4y6f6tavro@thunk.org>
References: <20170407175840.95740-5-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170407175840.95740-5-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Apr 07, 2017 at 10:58:40AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> As ext4 and f2fs do, ubifs should check for consistent encryption
> contexts during ->lookup() in an encrypted directory.  This protects
> certain users of filesystem encryption against certain types of offline
> attacks.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

						- Ted
