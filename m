Return-Path: <jaegeuk@kernel.org>
Date: Fri, 5 Jan 2018 16:39:50 -0800
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH v2 05/11] fscrypt: split fscrypt_dummy_context_enabled()
 into supp/notsupp versions
Message-ID: <20180106003950.GC72343@jaegeuk-macbookpro.roam.corp.google.com>
References: <20180105184502.48473-1-ebiggers3@gmail.com>
 <20180105184502.48473-6-ebiggers3@gmail.com>
 <20180105204009.GA72343@jaegeuk-macbookpro.roam.corp.google.com>
 <20180105211839.GB44929@gmail.com>
 <20180105213608.GB72343@jaegeuk-macbookpro.roam.corp.google.com>
 <20180105220149.GD44929@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180105220149.GD44929@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 01/05, Eric Biggers wrote:
> On Fri, Jan 05, 2018 at 01:36:08PM -0800, Jaegeuk Kim wrote:
> > On 01/05, Eric Biggers wrote:
> > > On Fri, Jan 05, 2018 at 12:40:09PM -0800, Jaegeuk Kim wrote:
> > > > On 01/05, Eric Biggers wrote:
> > > > > From: Eric Biggers <ebiggers@google.com>
> > > > > 
> > > > > fscrypt_dummy_context_enabled() accesses ->s_cop, which now is only set
> > > > > when the filesystem is built with encryption support.  This didn't
> > > > > actually matter because no filesystems called it.  However, it will
> > > > > start being used soon, so fix it by moving it from fscrypt.h to
> > > > > fscrypt_supp.h and stubbing it out in fscrypt_notsupp.h.
> > > > 
> > > > Ted, do we have a chance to get rid of this dummy_context? If there exists
> > > > backward compatibility issue, please never mind tho.
> > > > 
> > > 
> > > It's used to implement the test_dummy_encryption mount option for ext4, which is
> > > used by the 'ext4/encrypt' config for gce-xfstests.  Its purpose is to cause all
> > > new files (directories, regular files, and symlinks) to be automatically
> > > encrypted with a default key, so that the encrypted I/O paths are tested more
> > > thoroughly than by just running the 'encrypt' group tests.
> > > 
> > > There are no backward compatibility concerns with changing or removing the
> > > test_dummy_encryption mount option; we just don't have a better solution yet.
> > > 
> > > Ideally, instead of using test_dummy_encryption we would encrypt the root
> > > directory of the filesystem immediately after it is formatted.  However, that
> > > doesn't work for ext4 because the lost+found directory has to be located in the
> > > root directory, and must be unencrypted, and the lost+found directory entry must
> > > be unencrypted.
> > > 
> > > So I think getting rid of test_dummy_encryption depends on a solution to the
> > > lost+found problem.
> > 
> > Thank you for the explanation. Actually, I've got used to encrypt the root dir
> > in f2fs for such the testing purpose, since it's indeed empty. If it's the only
> > matter of lost_found in ext4, how about setting the encryption bit and dummy
> > context in root inode by mke2fs or tune2fs?
> > 
> 
> You can't mark a nonempty directory as encrypted.  First, you can't have an
> unencrypted file *name* in an encrypted directory, because then all the
> operations on that filename won't work, because the filesystem will think it is
> encrypted.  Second, you cannot have an unencrypted file in an encrypted
> directory because that violates the constraint that all files in an encrypted
> directory are encrypted -- and by design that is verified on ->lookup().
> 
> So to get it to actually work in ext4 we'd need to add extra special-case logic
> around the lost+found directory -- probably allowing both the directory entry
> and directory itself to be unencrypted, despite existing in an encrypted
> directory.  And I think that solution would be more complicated than the
> test_dummy_encryption mount option we have now.

Agreed that dummy'd be easy to go for now tho, doesn't it give any security
concern at all, even only for ext4 testing purpose? Is there a chance to hack
the mount option in runtime? BTW, it may be doable to build an encrypt root
inode having encrypted dentry of lost_found, given dummy_context in mke2fs.
I'm just curious whether or not it'd be worth to do.

Thanks,

> 
> It may be worth reconsidering if people start asking for the ability to encrypt
> the root directory for other reasons, though.  (Although, that use case is
> largely redundant with dm-crypt.)
> 
> Eric
