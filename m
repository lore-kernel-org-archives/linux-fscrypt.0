Return-Path: <ebiggers3@gmail.com>
Date: Tue, 20 Feb 2018 16:48:21 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [RFC PATCH V2 00/11] Ext4 encryption support for blocksize <
 pagesize
Message-ID: <20180221004821.GA252219@gmail.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chandan,

On Mon, Feb 12, 2018 at 03:13:36PM +0530, Chandan Rajendra wrote:
> This patchset implements code to support encryption of Ext4 filesystem
> instances that have blocksize less than pagesize. The patchset has
> been tested on both ppc64 and x86_64 machines.
> 
> Eric, fscrypt_mpage_readpages() (originally, ext4_mpage_readpages())
> still retains the ability to read non-encrypted file data. Please let
> me know if the code has to be changed such that
> fscrypt_mpage_readpages() makes it mandatory for the file's data to be
> encrypted.
> 
> TODO:
> F2FS and UBIFS code needs to be updated to make use of the newly added
> fscrypt functions. I will do that in the next version of the patchset.
> 
> Changelog:
> "RFC V1" -> "RFC V2":
> 1. Ext4's "encryption aware" functionality in fs/ext4/readpage.c has
>    been moved to fs/crypto/.
> 2. fscrypt functions have now been renamed to indicate that they work
>    on blocks rather than pages.
>    Eric, I have renamed completion_pages() to fscrypt_complete_pages()
>    rather than to fscrypt_complete_blocks(). This is because we have a
>    new function fscrypt_complete_block() (which operates on a single
>    block) and IMHO having the identifier fscrypt_complete_blocks()
>    which differs from it by just one letter would confuse the reader.
> 3. ext4_block_write_begin() now clears BH_Uptodate flag when
>    decryption of boundary blocks fail.
> 4. fscrypt_encrypt_page() (now renamed to fscrypt_encrypt_block()) is
>    now split into two functions. fscrypt_prep_ciphertext_page()
>    allocates and initializes the fscrypt context and the bounce
>    page. fscrypt_encrypt_block() is limited to encrypting the
>    filesystem's block.
> 5. fscrypt_zeroout_range() has been updated to work on blocksize <
>    pagesize scenario.
> 6. Documentation/filesystems/fscrypt.rst has been updated to indicate
>    encryption support for blocksize < pagesize.
> 
> Thanks to Eric Biggers for providing review comments for "RFC V1".
> 

Thanks for the new version of the patchset.

I see you decided to move ext4's readpages to fs/crypto/.  Did you also consider
the other alternatives I had suggested, such as adding an encryption callback to
the generic mpage_readpages(), or making fscrypt non-modular and then calling it
directly from mpage_readpages()?  Maybe you did, but I don't see the tradeoffs
addressed in the patchset at all.  The patches need to explain *why* you're
doing what you're doing, not just *what* you're doing.

(Just a thought: if we did make fscrypt non-modular, we could potentially limit
what gets pulled in from the crypto API by dropping the 'selects' of the
specific crypto algorithms, since they aren't hard dependencies.  Also the
options like CRYPTO_AES and CRYPTO_XTS that are currently being selected
actually refer to the generic implementations of those algorithms, which usually
aren't the ones people want to be using since they can be very slow compared to
architecture-specific versions.)

It would also be easier to review the patch that moves ext4_mpage_readpages() to
fs/crypto/ if you split out the behavior change (allowing blocksize < pagesize)
into a separate patch.  Switching ext4 to use it can be separate from adding it
as well.  

Note that the situation with ext4_block_write_begin() vs __block_write_begin()
is very similar to ext4_mpage_readpages() vs mpage_readpages().  So I think
whatever you are doing with readpages (e.g. moving it to fs/crypto/, or adding a
callback to the generic version) should also be done with __block_write_begin().

In general, it would also be helpful if you kept comments up to date.  It makes
it difficult to read the code when I see fscrypt_encrypt_block(), but the
comment says fscrypt_encrypt_page() and the documented behavior is very
different from what it actually does.  fscrypt_prep_ciphertext_page() also
doesn't have a comment at all.

Updating f2fs and ubifs is important as well so that you can see whether the
changes actually work for them or not.

- Eric
