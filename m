Return-Path: <SRS0=TTB/=VZ=mit.edu=tytso@kernel.org>
Date: Sun, 28 Jul 2019 15:30:12 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v7 08/16] fscrypt: add FS_IOC_GET_ENCRYPTION_KEY_STATUS
 ioctl
Message-ID: <20190728193012.GH6088@mit.edu>
References: <20190726224141.14044-1-ebiggers@kernel.org>
 <20190726224141.14044-9-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726224141.14044-9-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-api@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Satya Tangirala <satyat@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jul 26, 2019 at 03:41:33PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add a new fscrypt ioctl, FS_IOC_GET_ENCRYPTION_KEY_STATUS.  Given a key
> specified by 'struct fscrypt_key_specifier' (the same way a key is
> specified for the other fscrypt key management ioctls), it returns
> status information in a 'struct fscrypt_get_key_status_arg'.
> 
> The main motivation for this is that applications need to be able to
> check whether an encrypted directory is "unlocked" or not, so that they
> can add the key if it is not, and avoid adding the key (which may
> involve prompting the user for a passphrase) if it already is.
> 
> It's possible to use some workarounds such as checking whether opening a
> regular file fails with ENOKEY, or checking whether the filenames "look
> like gibberish" or not.  However, no workaround is usable in all cases.
> 
> Like the other key management ioctls, the keyrings syscalls may seem at
> first to be a good fit for this.  Unfortunately, they are not.  Even if
> we exposed the keyring ID of the ->s_master_keys keyring and gave
> everyone Search permission on it (note: currently the keyrings
> permission system would also allow everyone to "invalidate" the keyring
> too), the fscrypt keys have an additional state that doesn't map cleanly
> to the keyrings API: the secret can be removed, but we can be still
> tracking the files that were using the key, and the removal can be
> re-attempted or the secret added again.
> 
> After later patches, some applications will also need a way to determine
> whether a key was added by the current user vs. by some other user.
> Reserved fields are included in fscrypt_get_key_status_arg for this and
> other future extensions.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, feel free to add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>
