Return-Path: <ebiggers3@gmail.com>
Date: Fri, 5 Jan 2018 13:18:39 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v2 05/11] fscrypt: split fscrypt_dummy_context_enabled()
 into supp/notsupp versions
Message-ID: <20180105211839.GB44929@gmail.com>
References: <20180105184502.48473-1-ebiggers3@gmail.com>
 <20180105184502.48473-6-ebiggers3@gmail.com>
 <20180105204009.GA72343@jaegeuk-macbookpro.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180105204009.GA72343@jaegeuk-macbookpro.roam.corp.google.com>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jan 05, 2018 at 12:40:09PM -0800, Jaegeuk Kim wrote:
> On 01/05, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > fscrypt_dummy_context_enabled() accesses ->s_cop, which now is only set
> > when the filesystem is built with encryption support.  This didn't
> > actually matter because no filesystems called it.  However, it will
> > start being used soon, so fix it by moving it from fscrypt.h to
> > fscrypt_supp.h and stubbing it out in fscrypt_notsupp.h.
> 
> Ted, do we have a chance to get rid of this dummy_context? If there exists
> backward compatibility issue, please never mind tho.
> 

It's used to implement the test_dummy_encryption mount option for ext4, which is
used by the 'ext4/encrypt' config for gce-xfstests.  Its purpose is to cause all
new files (directories, regular files, and symlinks) to be automatically
encrypted with a default key, so that the encrypted I/O paths are tested more
thoroughly than by just running the 'encrypt' group tests.

There are no backward compatibility concerns with changing or removing the
test_dummy_encryption mount option; we just don't have a better solution yet.

Ideally, instead of using test_dummy_encryption we would encrypt the root
directory of the filesystem immediately after it is formatted.  However, that
doesn't work for ext4 because the lost+found directory has to be located in the
root directory, and must be unencrypted, and the lost+found directory entry must
be unencrypted.

So I think getting rid of test_dummy_encryption depends on a solution to the
lost+found problem.

An alternative would be to add support for "inherit-only" encryption policies,
then set such a policy on the root directory of the filesystem.  But, there
haven't been any requests for such a feature yet outside of this specific
testing-only use case, so I've been hesitant to add it.

Eric
