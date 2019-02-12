Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-eopbgr700130.outbound.protection.outlook.com ([40.107.70.130]:44746
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725778AbfBLFbb (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 12 Feb 2019 00:31:31 -0500
Date: Tue, 12 Feb 2019 00:31:23 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: Proposal: Yet another possible fs-verity interface
Message-ID: <20190212053123.GR23000@mit.edu>
References: <20190207031101.GA7387@mit.edu>
 <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
 <1549807615.12743.109.camel@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1549807615.12743.109.camel@linux.ibm.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Mimi Zohar <zohar@linux.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, James Bottomley <James.Bottomley@HansenPartnership.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Feb 10, 2019 at 09:06:55AM -0500, Mimi Zohar wrote:
> For which files will the Merkle tree be created?  Is this for all
> files on a per file system basis? �Or is there some sort of "flag" or
> policy?  The original design was based on an ioctl enabling/disabling
> a flag. In this new design, is there still an ioctl?

So for our first use case, it will be used for "privileged APK files"
in Android.  You can think of this as a "setuid binary", effectively.

The Merkle tree hash is digitally signed and provided by the App
Store.  It is *not* calculated on the android device.  So not all
files will have Merkle trees, because storing the android device won't
have access to the signing key.  The enforcement is done by the
userspace code which is loading the privileged APK (the application
loader).  If the APK is privileged, then it must have the Merkle tree,
with the root hash matching the digitally signed hash.  Otherwise, the
application loader will refuse to load it as a privileged "root"
application.

For Android, the policy enforcement is done in userspace (should the
APK be privileged), because userspace loads the APK.  We just let the
kernel take care of verifying the blocks as they are read, and that's
done by fsverity.

If we wanted to do something similar with all setuid executables, that
would have to be enforced via some kind of LSM (e.g., a SELinux
policy).

> The existing file hashes included in the measurement list and the
> audit log, are currently being used for remote attestation, forensics
> and security analytics.

IMA has a very different set primary use cases than fsverity.

As you have pointed out, forcibly dragging the entire file into the
page cache to measure it can sometimes result in performance
improvements.  So there may be system administrators that would prefer
having the entire file measured up front.  On the other hand, if the
binaries/APK's are gargantuan, and not all of the file will be used
(perhaps there are translation files, audio/video assets, etc., that
aren't used most of the time), then only verifying the blocks that are
used will be a better approach.

I've never thought that fsverity should replace IMA or vice versa;
they are optimized for different things.  If it makes sense in some
configuration for IMA to use the fsverity Merkle tree root hash as a
measurement, it's easy enough to set up the hooks so they can be
provided to IMA for its use.  This might be the easist way to
integrate with SELinux, for example.

Regards,
						- Ted
