Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-eopbgr680102.outbound.protection.outlook.com ([40.107.68.102]:21472
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725795AbfA2PuZ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 29 Jan 2019 10:50:25 -0500
Date: Tue, 29 Jan 2019 10:48:39 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: Proposal: A new fs-verity interface
Message-ID: <20190129154839.GA4421@mit.edu>
References: <20190110051500.GA32361@mit.edu>
 <20190114234101.GQ27534@dastard>
 <20190123051017.GA8785@mit.edu>
 <20190124212544.GS6173@dastard>
 <CAHk-=wh7jq6U3+ou_FDujB-ipg9JcJAGSjEQ_niCwLG313x6UA@mail.gmail.com>
 <20190124232237.GH8785@mit.edu>
 <CAHk-=wjw+tAKu7fM3GwUX9i7LBFuvB=ohqXj+KgQQaW3pCzfxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAHk-=wjw+tAKu7fM3GwUX9i7LBFuvB=ohqXj+KgQQaW3pCzfxg@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jan 25, 2019 at 01:35:05PM +1300, Linus Torvalds wrote:
> But that's the whole hiding thing. Why do you feel you need to do
> that? Why not just leave it alone, and leave it visible, and say "hey,
> the merkle data for file X comes from here".

There are a number of downsides:

*) It's ugly that files that have to live somewhere (e.g., a dot file,
   some other directory, etc.) in the directory hierarchy, when theyt
   are fundamentally part of the file that is being protected --- that
   is, it is file metadata.

*) We don't want to allow the files to be deted, since it breaks the
   protection; that either has to make the original file useful, since
   the security policy is we can't trust the file --- which might be a
   privileged APK (think setuid binary), or we have to make the file
   immutable and it from being deleted.

*) When we delete the original file, userspace now has to manually
   clean up the Merkle data for the file.

So keeping it hidden is just cleaner.

You're right that making the Merkle data explicit available in some
form (either via an xattr or a separate file) would make it easier to
copy the file, but that's not something that is needed in practice.
So it's an advantage, but it wasn't one that we had considered
important.  For example for most executables on a desktop, they are
installed via a package manager, and they are deleted when the package
is updated.  Or in the case of an Android APK, copying it is not
something that is done once it is downloaded to the device.

> In fact, if you want to have merkle data for small files (where the
> merkle data itself is just a  few words), then having it in a separate
> file and as part of the inode inline data doesn't seem like it's
> likely any worse (and might be *better*) than having it at some block
> boundary due to alignment...
> 
> Hmm?

The default inode size is 256; and in that case "small files" is less
than 12k.  With an ext4 inode size of 1024 bytes "small files" would
be 108k --- and this is ignoring the size of the fsverity header.
With the header these numbers would be even smaller --- and given that
the most common use of this will be for APK and executables, using the
inline data (or inline xattrs) is really not practical.

       	    	       	       	  - Ted
