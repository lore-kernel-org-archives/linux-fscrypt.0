Return-Path: <ebiggers3@gmail.com>
Date: Tue, 13 Jun 2017 20:12:45 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 1/3] ext4: require key for truncate(2) of encrypted file
Message-ID: <20170614031245.GA605@zzz>
References: <20170613234755.111167-1-ebiggers3@gmail.com>
 <20170613234755.111167-2-ebiggers3@gmail.com>
 <72134F72-718F-4B14-891D-20F2CF781A16@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <72134F72-718F-4B14-891D-20F2CF781A16@dilger.ca>
To: Andreas Dilger <adilger@dilger.ca>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Andreas,

On Tue, Jun 13, 2017 at 06:14:53PM -0600, Andreas Dilger wrote:
> On Jun 13, 2017, at 5:47 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> > 
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Currently, filesystems allow truncate(2) on an encrypted file without
> > the encryption key.  However, it's impossible to correctly handle the
> > case where the size being truncated to is not a multiple of the
> > filesystem block size, because that would require decrypting the final
> > block, zeroing the part beyond i_size, then encrypting the block.
> > 
> > As other modifications to encrypted file contents are prohibited without
> > the key, just prohibit truncate(2) as well, making it fail with ENOKEY.
> 
> Out of curiosity, if an encrypted block is zero-filled at the end when
> the key is unavailable, what would happen?  At worst this would result
> in garbage at the end of the file when the zeroes are "decrypted"?

Currently ext4 just skips zeroing the final block entirely, which is perhaps the
most reasonable behavior, but it's wrong because it breaks truncate() semantics.
If it did zero the final block on-disk, yes it wouldn't actually be zeroes after
being decrypted, so if the file were to be extended later the extended portion
wouldn't be filled with zeroes, and more importantly even without extending, up
to the last 15 bytes of the file would be corrupted since AES-XTS encryption
operates on 16 byte blocks.  Also, the ciphertext page would likely end up in
the pagecache, which is supposed to contain the plaintext.  So if the file were
read later (which requires the key), up to the last PAGE_SIZE bytes of the file
would appear as garbage.

> 
> Is it possible to unlink files if they are encrypted without the key (if
> the user has permission to write to the directory)?
> 

Yes, that's supported.

> Does file unlink result in the per-file crypto key being erased in the
> inode, or is the inode just marked unused but not overwritten?  One of
> the desirable features of per-file crypto is "secure erase" so that once
> the inode is unlinked the crypto key is gone and there is no way to decrypt
> the data after the fact, even if the filesystem/user key is later recovered.
> If the per-file key is still sitting in the inode, then it may be possible
> to decrypt the data long after the file was deleted if the key is later
> compromised and the inode+data blocks were not re-used.

I assume you're talking about the key derivation nonce in the encryption xattr
(which is stored on-disk and is not really a "key"; although it's used as an
AES-ECB key in derive_key_aes(), that's really an implementation detail, and the
key derivation algorithm could/should be replaced with something less
idiosyncratic like an HKDF).  This is a completely separate issue, but no, as
far as I know we aren't securely erasing the nonce following a file deletion so
that someone with access to both the raw disk and the master key can no longer
derive the per-file key.  It's a good idea, though, and I think it should be
done if practical.  Note, though, that the xattr may be stored in an external
xattr block, and it also may have moved around over time --- so it may be
necessary to zero the whole inode and xattr block.

Eric
