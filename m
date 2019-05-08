Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57764 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726276AbfEHBT3 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 7 May 2019 21:19:29 -0400
Date: Tue, 7 May 2019 18:19:26 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [GIT PULL] fscrypt updates for 5.2
Message-ID: <20190508011925.GB7528@sol.localdomain>
References: <20190507233042.GA28476@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507233042.GA28476@mit.edu>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Theodore Ts'o <tytso@mit.edu>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, May 07, 2019 at 07:30:42PM -0400, Theodore Ts'o wrote:
> The following changes since commit dc4060a5dc2557e6b5aa813bf5b73677299d62d2:
> 
>   Linux 5.1-rc5 (2019-04-14 15:17:41 -0700)
> 
> are available in the Git repository at:
> 
>   git://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fscrypt_for_linus
> 
> for you to fetch changes up to 2c58d548f5706d085c4b009f6abb945220460632:
> 
>   fscrypt: cache decrypted symlink target in ->i_link (2019-04-17 12:43:29 -0400)
> 
> ----------------------------------------------------------------
> Clean up fscrypt's dcache revalidation support, and other
> miscellaneous cleanups.
> 
> ----------------------------------------------------------------
> Eric Biggers (10):
>       fscrypt: drop inode argument from fscrypt_get_ctx()
>       fscrypt: remove WARN_ON_ONCE() when decryption fails
>       fscrypt: use READ_ONCE() to access ->i_crypt_info
>       fscrypt: clean up and improve dentry revalidation
>       fscrypt: fix race allowing rename() and link() of ciphertext dentries
>       fs, fscrypt: clear DCACHE_ENCRYPTED_NAME when unaliasing directory
>       fscrypt: only set dentry_operations on ciphertext dentries
>       fscrypt: fix race where ->lookup() marks plaintext dentry as ciphertext
>       vfs: use READ_ONCE() to access ->i_link
>       fscrypt: cache decrypted symlink target in ->i_link
> 

There will be a merge conflict between "fscrypt: cache decrypted symlink target
in ->i_link", and "ext4: make use of ->free_inode()" and "f2fs: switch to
->free_inode()".  The correct resolutions should be fairly straightforward:

	static void ext4_free_in_core_inode(struct inode *inode)
	{
		fscrypt_free_inode(inode);
		kmem_cache_free(ext4_inode_cachep, EXT4_I(inode));
	}

and

	static void f2fs_free_inode(struct inode *inode)
	{
		fscrypt_free_inode(inode);
		kmem_cache_free(f2fs_inode_cachep, F2FS_I(inode));
	}

- Eric
