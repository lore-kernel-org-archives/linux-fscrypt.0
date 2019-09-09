Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:54066 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726836AbfIIReW (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 9 Sep 2019 13:34:22 -0400
Date: Mon, 9 Sep 2019 10:34:20 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v3] e2fsck: check for consistent encryption policies
Message-ID: <20190909173418.GA12329@gmail.com>
References: <20190823162339.186643-1-ebiggers@kernel.org>
 <20190904155524.GA41757@gmail.com>
 <28D1848F-B84A-4D2A-880E-F0C8E8FD36C7@dilger.ca>
 <20190907100640.GA6778@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190907100640.GA6778@mit.edu>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger@dilger.ca>, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Sep 07, 2019 at 06:06:40AM -0400, Theodore Y. Ts'o wrote:
> On Fri, Sep 06, 2019 at 10:23:03PM -0600, Andreas Dilger wrote:
> > If the number of files in the array get very large, then doubling the
> > array size at the end may consume a *lot* of memory.  It would be
> > somewhat better to cap new_capacity by the number of inodes in the
> > filesystem, and better yet scale the array size by a fraction of the
> > total number of inodes that have already been processed, but this array
> > might still be several GB of RAM.
> > 
> > What about using run-length encoding for this?  It is unlikely that many
> > different encryption policies are in a filesystem, and inodes tend to be
> > allocated in groups by users, so it is likely that you will get large runs
> > of inodes with the same policy_id, and this could save considerable space.
> 
> One approach that we could use is to allocate a separate bitmap for
> each policy.  EXT2FS_BMAP_RBTREE effectively will use RLE.  The
> downside is that if the inodes are not sparse, it will be quite
> heavyweight; each extent costs 40 bytes.
> 
> So for file system with a very large number of policies (as opposed
> less than two or three, which will be the case with the vast majority
> of Android devices) this could be quite expensive.
> 
> Of course, we don't have to use an rbtree; the bitarray will be
> created sequentially, so in theory we could create a new bitmap
> backend which uses a sorted list, which is O(1) for ordered insert and
> o(log n) for lookups.  That could be about 12 bytes per extent.  And
> of course, we don't have to implement the sorted list back end right
> away, switching it is just a matter of changing a parameter to
> ext2fs_alloc_generic_bitmap().
> 

I don't think a bitmap per policy is a good idea, even if it was actually
represented as an rbtree or a sorted list.  The problem is that to look up an
inode's encryption policy ID that way, you'd have to iterate through every
encryption policy, of which there could be a huge number.

Instead I'll try just changing:

	struct encrypted_file {
		ext2_ino_t              ino;
		__u32                   policy_id;
	};

to the following:

	struct encrypted_file_range {
		ext2_ino_t              first_ino;
		ext2_ino_t              last_ino;
		__u32                   policy_id;
	};

- Eric
