Return-Path: <SRS0=Z4Px=NM=linux.vnet.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/2] fscrypt: Remove filesystem specific build config option
Date: Thu, 01 Nov 2018 19:12:13 +0530
In-Reply-To: <20181031234319.GA202657@gmail.com>
References: <20181031050005.17770-1-chandan@linux.vnet.ibm.com> <20181031234319.GA202657@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <1668493.xrQW3tLzlS@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: tytso@mit.edu, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, November 1, 2018 5:13:20 AM IST Eric Biggers wrote:
> Hi Chandan, a couple questions:
> 
> On Wed, Oct 31, 2018 at 10:30:04AM +0530, Chandan Rajendra wrote:
> > As a first step to avoid copy-pasting common code across filesystems
> > which implement fscrypt, this commit removes filesystem specific build
> > config option (e.g. CONFIG_EXT4_FS_ENCRYPTION) and replaces it with a
> > build option (i.e. CONFIG_FS_ENCRYPTION) whose value affects all the
> > filesystems making use of fscrypt.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
> 
> Can you be more explicit about the goal here?  It's mostly about implementing
> ->readpages() when the filesystem may support both fscrypt and fs-verity, right?

You are right. I will add that to the commit message.

> 
> > diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
> > index 02b7d91..6e9ae56 100644
> > --- a/fs/crypto/Kconfig
> > +++ b/fs/crypto/Kconfig
> > @@ -1,5 +1,5 @@
> >  config FS_ENCRYPTION
> > -	tristate "FS Encryption (Per-file encryption)"
> > +	bool "FS Encryption (Per-file encryption)"
> >  	select CRYPTO
> >  	select CRYPTO_AES
> >  	select CRYPTO_CBC
> 
> Is it possible to keep this as a module, rather than requiring that fs/crypto/
> always be built-in?  Making this a 'bool' will require all the selected crypto
> algorithms to be built-in too.

This could cause a scenario where any of the filesystems using
CONFIG_FS_ENCRYPTION might be built into the kernel and
CONFIG_FS_ENCRYPTION itself is marked as a module. This will cause the kernel
build to end up with linker errors.

To solve this we would need to have dependency for CONFIG_FS_ENCRYPTION
mentioned in individual filesystem's Kconfig i.e. We would be going back to
the earlier per-filesystem encryption configuration.

> 
> > -	if (ext4_encrypted_inode(inode)) {
> > +	if (IS_ENCRYPTED(inode)) {
> 
> I suggest doing the replacements of ext4_encrypted_inode() with IS_ENCRYPTED()
> as a standalone patch, so it's easier to review.

Ok. I will do this. I will also have to add something equivalent to 
ext4_verity_inode().

> 
> Also I suggest sending this patch to the ext4 and f2fs mailing lists too.

Sure. I will send the next version of this patch to the above mentioned
mailing lists.

-- 
chandan
