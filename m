Return-Path: <ebiggers3@gmail.com>
Date: Wed, 21 Feb 2018 11:06:55 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [RFC PATCH V2 00/11] Ext4 encryption support for blocksize <
 pagesize
Message-ID: <20180221190655.GB114620@gmail.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
 <20180221004821.GA252219@gmail.com>
 <3754767.QgBE46qNIq@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3754767.QgBE46qNIq@localhost.localdomain>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chandan,

On Wed, Feb 21, 2018 at 03:27:34PM +0530, Chandan Rajendra wrote:
> On Wednesday, February 21, 2018 6:18:21 AM IST Eric Biggers wrote:
> > Hi Chandan,
> > 
> > On Mon, Feb 12, 2018 at 03:13:36PM +0530, Chandan Rajendra wrote:
> > > This patchset implements code to support encryption of Ext4 filesystem
> > > instances that have blocksize less than pagesize. The patchset has
> > > been tested on both ppc64 and x86_64 machines.
> > > 
> > > Eric, fscrypt_mpage_readpages() (originally, ext4_mpage_readpages())
> > > still retains the ability to read non-encrypted file data. Please let
> > > me know if the code has to be changed such that
> > > fscrypt_mpage_readpages() makes it mandatory for the file's data to be
> > > encrypted.
> > > 
> > > TODO:
> > > F2FS and UBIFS code needs to be updated to make use of the newly added
> > > fscrypt functions. I will do that in the next version of the patchset.
> > > 
> > > Changelog:
> > > "RFC V1" -> "RFC V2":
> > > 1. Ext4's "encryption aware" functionality in fs/ext4/readpage.c has
> > >    been moved to fs/crypto/.
> > > 2. fscrypt functions have now been renamed to indicate that they work
> > >    on blocks rather than pages.
> > >    Eric, I have renamed completion_pages() to fscrypt_complete_pages()
> > >    rather than to fscrypt_complete_blocks(). This is because we have a
> > >    new function fscrypt_complete_block() (which operates on a single
> > >    block) and IMHO having the identifier fscrypt_complete_blocks()
> > >    which differs from it by just one letter would confuse the reader.
> > > 3. ext4_block_write_begin() now clears BH_Uptodate flag when
> > >    decryption of boundary blocks fail.
> > > 4. fscrypt_encrypt_page() (now renamed to fscrypt_encrypt_block()) is
> > >    now split into two functions. fscrypt_prep_ciphertext_page()
> > >    allocates and initializes the fscrypt context and the bounce
> > >    page. fscrypt_encrypt_block() is limited to encrypting the
> > >    filesystem's block.
> > > 5. fscrypt_zeroout_range() has been updated to work on blocksize <
> > >    pagesize scenario.
> > > 6. Documentation/filesystems/fscrypt.rst has been updated to indicate
> > >    encryption support for blocksize < pagesize.
> > > 
> > > Thanks to Eric Biggers for providing review comments for "RFC V1".
> > > 
> > 
> > Thanks for the new version of the patchset.
> > 
> > I see you decided to move ext4's readpages to fs/crypto/.  Did you also consider
> > the other alternatives I had suggested, such as adding an encryption callback to
> > the generic mpage_readpages(), or making fscrypt non-modular and then calling it
> > directly from mpage_readpages()?  Maybe you did, but I don't see the tradeoffs
> > addressed in the patchset at all.  The patches need to explain *why* you're
> > doing what you're doing, not just *what* you're doing.
> 
> I had glanced through F2FS and UBIFS source code. F2FS has its own version of
> mpage_readpage[s] and UBIFS does not use mpage_readpage[s]
> functionality. This was the major reason for deciding to not go with the
> approach of having a decryption call back passed to mpage_readpage[s].
> 
> Apart from the reason of memory being wasted on systems which do not require
> files to be encrypted, the previously listed reason of mpage_readpage[s] not
> being used by F2FS and UBIFS also played a role is deciding against invoking
> fscrypt_decrypt_bio_blocks() from within mpage_readpages().
> 

Sure, F2FS and UBIFS don't use mpage_readpages(), block_write_full_page(), or
__block_write_begin().  But that doesn't mean it's a good idea to copy and paste
all of those functions from generic code to fs/crypto or to fs/ext4 just to add
encryption support.  It will be difficult to maintain two copies of the code.

The other option I suggested, which I think you still haven't addressed at all,
is adding an encryption/decryption callback to those functions, which would be
provided by the filesystem.  See for example how __block_write_begin_int() takes
in an optional 'struct iomap *' pointer; maybe we could do something similar
with crypto?  Note, that approach would have the advantage of not requiring that
fscrypt be built-in.  Just a thought, I haven't tried writing the code yet to
see how difficult/ugly it would be...

Eric
