Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Wed, 29 May 2019 13:47:54 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190529204753.GB141639@gmail.com>
References: <20190520162952.156212-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190520162952.156212-1-ebiggers@kernel.org>
Subject: Re: [f2fs-dev] [PATCH v2 00/14] fscrypt,
 ext4: prepare for blocksize != PAGE_SIZE
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Chandan Rajendra <chandan@linux.ibm.com>, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 20, 2019 at 09:29:38AM -0700, Eric Biggers wrote:
> Hello,
> 
> This patchset prepares fs/crypto/, and partially ext4, for the
> 'blocksize != PAGE_SIZE' case.
> 
> This basically contains the encryption changes from Chandan Rajendra's
> patchset "[V2,00/13] Consolidate FS read I/O callbacks code"
> (https://patchwork.kernel.org/project/linux-fscrypt/list/?series=111039)
> that don't require introducing the read_callbacks and don't depend on
> fsverity stuff.  But they've been reworked to clean things up a lot.
> 
> I'd like to apply this patchset for 5.3 in order to make things forward
> for ext4 encryption with 'blocksize != PAGE_SIZE'.
> 
> AFAICT, after this patchset the only thing stopping ext4 encryption from
> working with blocksize != PAGE_SIZE is the lack of encryption support in
> block_read_full_page(), which the read_callbacks will address.
> 
> This patchset applies to v5.2-rc1, and it can also be retrieved from git
> at https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/linux.git
> branch "fscrypt-subpage-blocks-prep".
> 
> Changed since v1 (minor cleanups only):
> 
> - In "fscrypt: simplify bounce page handling", also remove
>   the definition of FS_CTX_HAS_BOUNCE_BUFFER_FL.
> 
> - In "ext4: decrypt only the needed blocks in ext4_block_write_begin()",
>   simplify the code slightly by moving the IS_ENCRYPTED() check.
> 
> - Change __fscrypt_decrypt_bio() in a separate patch rather than as part
>   of "fscrypt: support decrypting multiple filesystem blocks per page".
>   The resulting code is the same, so I kept Chandan's Reviewed-by.
> 
> - Improve the commit message of
>   "fscrypt: introduce fscrypt_decrypt_block_inplace()".
> 
> Chandan Rajendra (3):
>   ext4: clear BH_Uptodate flag on decryption error
>   ext4: decrypt only the needed blocks in ext4_block_write_begin()
>   ext4: decrypt only the needed block in __ext4_block_zero_page_range()
> 
> Eric Biggers (11):
>   fscrypt: simplify bounce page handling
>   fscrypt: remove the "write" part of struct fscrypt_ctx
>   fscrypt: rename fscrypt_do_page_crypto() to fscrypt_crypt_block()
>   fscrypt: clean up some BUG_ON()s in block encryption/decryption
>   fscrypt: introduce fscrypt_encrypt_block_inplace()
>   fscrypt: support encrypting multiple filesystem blocks per page
>   fscrypt: handle blocksize < PAGE_SIZE in fscrypt_zeroout_range()
>   fscrypt: introduce fscrypt_decrypt_block_inplace()
>   fscrypt: support decrypting multiple filesystem blocks per page
>   fscrypt: decrypt only the needed blocks in __fscrypt_decrypt_bio()
>   ext4: encrypt only up to last block in ext4_bio_write_page()
> 
>  fs/crypto/bio.c             |  73 +++------
>  fs/crypto/crypto.c          | 299 ++++++++++++++++++++----------------
>  fs/crypto/fscrypt_private.h |  15 +-
>  fs/ext4/inode.c             |  37 +++--
>  fs/ext4/page-io.c           |  44 +++---
>  fs/f2fs/data.c              |  17 +-
>  fs/ubifs/crypto.c           |  19 +--
>  include/linux/fscrypt.h     |  96 ++++++++----
>  8 files changed, 319 insertions(+), 281 deletions(-)
> 

I've applied this series to fscrypt.git for 5.3.

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
