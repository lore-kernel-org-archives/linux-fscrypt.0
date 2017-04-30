Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:17:25 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [1/4] fscrypt: fix context consistency check when key(s)
 unavailable
Message-ID: <20170430061725.wgdhived7oqvzqso@thunk.org>
References: <20170407175840.95740-2-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170407175840.95740-2-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Apr 07, 2017 at 10:58:37AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> To mitigate some types of offline attacks, filesystem encryption is
> designed to enforce that all files in an encrypted directory tree use
> the same encryption policy (i.e. the same encryption context excluding
> the nonce).  However, the fscrypt_has_permitted_context() function which
> enforces this relies on comparing struct fscrypt_info's, which are only
> available when we have the encryption keys.  This can cause two
> incorrect behaviors:
> 
> 1. If we have the parent directory's key but not the child's key, or
>    vice versa, then fscrypt_has_permitted_context() returned false,
>    causing applications to see EPERM or ENOKEY.  This is incorrect if
>    the encryption contexts are in fact consistent.  Although we'd
>    normally have either both keys or neither key in that case since the
>    master_key_descriptors would be the same, this is not guaranteed
>    because keys can be added or removed from keyrings at any time.
> 
> 2. If we have neither the parent's key nor the child's key, then
>    fscrypt_has_permitted_context() returned true, causing applications
>    to see no error (or else an error for some other reason).  This is
>    incorrect if the encryption contexts are in fact inconsistent, since
>    in that case we should deny access.
> 
> To fix this, retrieve and compare the fscrypt_contexts if we are unable
> to set up both fscrypt_infos.
> 
> While this slightly hurts performance when accessing an encrypted
> directory tree without the key, this isn't a case we really need to be
> optimizing for; access *with* the key is much more important.
> Furthermore, the performance hit is barely noticeable given that we are
> already retrieving the fscrypt_context and doing two keyring searches in
> fscrypt_get_encryption_info().  If we ever actually wanted to optimize
> this case we might start by caching the fscrypt_contexts.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
