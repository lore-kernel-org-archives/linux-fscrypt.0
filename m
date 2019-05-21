Return-Path: <keyrings-owner@vger.kernel.org>
Date: Mon, 20 May 2019 17:41:20 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v6 00/16] fscrypt: key management improvements
Message-ID: <20190521004119.GA647@sol.localdomain>
References: <20190520172552.217253-1-ebiggers@kernel.org>
 <20190521001636.GA2369@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521001636.GA2369@mit.edu>
Sender: keyrings-owner@vger.kernel.org
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>, linux-api@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, keyrings@vger.kernel.org, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 20, 2019 at 08:16:36PM -0400, Theodore Ts'o wrote:
> On Mon, May 20, 2019 at 10:25:36AM -0700, Eric Biggers wrote:
> > 
> > This patchset makes major improvements to how keys are added, removed,
> > and derived in fscrypt, aka ext4/f2fs/ubifs encryption.  It does this by
> > adding new ioctls that add and remove encryption keys directly to/from
> > the filesystem, and by adding a new encryption policy version ("v2")
> > where the user-provided keys are only used as input to HKDF-SHA512 and
> > are identified by their cryptographic hash.
> 
> Do you have userspace programs which use these new ioctl's?  What's
> are testing strategy for these new ioctls?
> 
> Thanks,
> 
> 						- Ted

This was answered in the cover letter, quoted below:

I've written xfstests for the new APIs.  They test the APIs themselves
as well as verify the correctness of the ciphertext stored on-disk for
v2 encryption policies.  The tests can be found at:

	Repository:   https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/xfstests-dev.git
	Branch:       fscrypt-key-mgmt-improvements

The xfstests depend on new xfs_io commands which can be found at:

	Repository:   https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/xfsprogs-dev.git
	Branch:       fscrypt-key-mgmt-improvements

I've also made proof-of-concept changes to the 'fscrypt' userspace
program (https://github.com/google/fscrypt) to make it support v2
encryption policies.  You can find these changes in git at:

	Repository:   https://github.com/ebiggers/fscrypt.git
	Branch:       fscrypt-key-mgmt-improvements

To make the 'fscrypt' userspace program experimentally use v2 encryption
policies on new encrypted directories, add the following to
/etc/fscrypt.conf within the "options" section:

	"policy_version": "2"

Finally, it's also planned for Android and Chromium OS to switch to the
new ioctls and eventually to v2 encryption policies.  Work-in-progress,
proof-of-concept changes by Satya Tangirala for AOSP can be found at
https://android-review.googlesource.com/q/topic:fscrypt-key-mgmt-improvements

- Eric
