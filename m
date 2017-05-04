Return-Path: <tytso@thunk.org>
Date: Thu, 4 May 2017 11:49:40 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [1/4] fscrypt: fix context consistency check when key(s)
 unavailable
Message-ID: <20170504154940.6kof2mn3p4oo6vnj@thunk.org>
References: <20170407175840.95740-2-ebiggers3@gmail.com>
 <20170430061725.wgdhived7oqvzqso@thunk.org>
 <20170502173601.GA75651@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170502173601.GA75651@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, May 02, 2017 at 10:36:01AM -0700, Eric Biggers wrote:
> Ted, can you add Cc stable to this commit?  (Just this one; the others in the
> series aren't as important.)  I think this fix is more important than I
> originally thought, because it's actually pretty easy to end up in a situation
> where a directory has its key but a file in it does not, due to the file's inode
> having been evicted from the inode cache but not the directory's inode.  This
> makes the file undeletable.

Done.  This meant I had to do a rewind on the fscrypt tree, so if
someone has built something on top of fscrypt since Sunday you may
need to take special precautions.  This was just a change to the
commit description so git rebase should take of the problem relatively
easily.

					- Ted
