Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:60293 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1728247AbfGSXsG (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 19 Jul 2019 19:48:06 -0400
Date: Fri, 19 Jul 2019 19:47:59 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] e2fsck: check for consistent encryption policies
Message-ID: <20190719234759.GC8149@mit.edu>
References: <20190718011325.19516-1-ebiggers@kernel.org>
 <621FA6A1-745D-43BA-A52A-4229902737BF@dilger.ca>
 <20190719231843.GH1422@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190719231843.GH1422@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Andreas Dilger <adilger@dilger.ca>, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jul 19, 2019 at 04:18:44PM -0700, Eric Biggers wrote:
> 
> That's correct.  I wanted to propose something simpler first to see what people
> thought, but yes if this is really a concern, what we should do is assign a u32
> id to each new encryption policy that is seen, and store just that id per inode.
> 
> To do that we need a proper map data structure for the policy => ID mapping,
> which as usual is nontrivial to do in C.  lib/ext2fs/rbtree.h could do, though.
> There's also lib/ext2fs/hashmap.c, but it doesn't implement resizing.

The fscrypt policy is only 12 bytes, so overhead of using an rbtree
(two 8 byte pointers) is about the same as its payload.  The number of
policies in a file system will typically be quite small (at most a few
dozen), usually under a dozen, and so it might be the simplest thing
to do is to keep a sorted list (in memcmp order), and then use a
binary search to do the lookups.

OTOH, since normally there will only be a small handful of policies in
use, we don't really care about the rbtree overhead, so if we just use
an rbtree to avoid open-coding another data structure (like we do in
lib/ext2fs/icount.c, et.al.), that's also find.

The other thing I'll note is that we only need the map in pass 1.
Once we've assigned a policy ID number to each encrypted inode, we
don't need it any more, since the only thing we really care about is
enforcing the parent::child relationship vis-a-vis fscrypt policies.

      		    		 	   	   - Ted
