Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:17:49 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [2/4] ext4: remove "nokey" check from ext4_lookup()
Message-ID: <20170430061749.tk4zaoatjqqt2avf@thunk.org>
References: <20170407175840.95740-3-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170407175840.95740-3-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Apr 07, 2017 at 10:58:38AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Now that fscrypt_has_permitted_context() correctly handles the case
> where we have the key for the parent directory but not the child, we
> don't need to try to work around this in ext4_lookup().
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
