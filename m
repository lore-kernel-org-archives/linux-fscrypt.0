Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:58138 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727967AbfIDPz2 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 4 Sep 2019 11:55:28 -0400
Date: Wed, 4 Sep 2019 08:55:25 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v3] e2fsck: check for consistent encryption policies
Message-ID: <20190904155524.GA41757@gmail.com>
References: <20190823162339.186643-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190823162339.186643-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-ext4@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Aug 23, 2019 at 09:23:39AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> By design, the kernel enforces that all files in an encrypted directory
> use the same encryption policy as the directory.  It's not possible to
> violate this constraint using syscalls.  Lookups of files that violate
> this constraint also fail, in case the disk was manipulated.
> 
> But this constraint can also be violated by accidental filesystem
> corruption.  E.g., a power cut when using ext4 without a journal might
> leave new files without the encryption bit and/or xattr.  Thus, it's
> important that e2fsck correct this condition.
> 
> Therefore, this patch makes the following changes to e2fsck:
> 
> - During pass 1 (inode table scan), create a map from inode number to
>   encryption policy for all encrypted inodes.  But it's optimized so
>   that the full xattrs aren't saved but rather only 32-bit "policy IDs",
>   since usually many inodes share the same encryption policy.  Also, if
>   an encryption xattr is missing, offer to clear the encrypt flag.  If
>   an encryption xattr is clearly corrupt, offer to clear the inode.
> 
> - During pass 2 (directory structure check), use the map to verify that
>   all regular files, directories, and symlinks in encrypted directories
>   use the directory's encryption policy.  Offer to clear any directory
>   entries for which this isn't the case.
> 
> Add a new test "f_bad_encryption" to test the new behavior.
> 
> Due to the new checks, it was also necessary to update the existing test
> "f_short_encrypted_dirent" to add an encryption xattr to the test file,
> since it was missing one before, which is now considered invalid.
> 

Any comments on this patch?

- Eric
