Return-Path: <ebiggers3@gmail.com>
Date: Wed, 8 Mar 2017 14:18:00 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: Why does keyctl_invalidate() only require Search permission?
Message-ID: <20170308221800.GA90803@gmail.com>
References: <20170222011657.GC101993@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222011657.GC101993@gmail.com>
To: keyrings@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, linux-fscrypt@vger.kernel.org, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Feb 21, 2017 at 05:16:57PM -0800, Eric Biggers wrote:
> Hi David (or anyone else experienced with Linux keyrings),
> 
> I was surprised to discover that the keyctl_invalidate() operation, as added by
> commit fd75815f727f1 ("KEYS: Add invalidation support") only requires Search
> permission.
> 
> AFAICS, this means that any process which has permission to find a key in
> searches can also "invalidate" it, which deletes it from all keyrings
> system-wide.  This cannot even be forbidden by SELinux, which likewise is only
> asked for "Search" permission on the key.
> 
> This is very problematic on systems that want to have a privileged process like
> 'init' set up a keyring, then give less privileged processes read-only access.
> 
> What is the motivation behind only requiring Search permission, and how should
> this be fixed?  Perhaps "invalidation" should require write access to all the
> keyrings the key is in, since it's similar to unlinking it from all of them?  Or
> am I missing something about why it was designed the way it is?
> 
> Thanks!
> 
> Eric
> 

David, do you have any comments on this?  This seems to be a pretty serious flaw
because it makes it impossible to give processes read-only access to keys.

What would you say about solving this by making keyctl_invalidate() require both
Setattr and Search permission?

- Eric
