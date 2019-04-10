Return-Path: <SRS0=NhUw=SM=ftp.linux.org.uk=viro@kernel.org>
Date: Wed, 10 Apr 2019 02:39:34 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH] fscrypt: cache decrypted symlink target in ->i_link
Message-ID: <20190410013934.GV2217@ZenIV.linux.org.uk>
References: <20190409233544.156665-1-ebiggers@kernel.org>
 <20190410003346.GT2217@ZenIV.linux.org.uk>
 <20190410004553.GA2454@sol.localdomain>
 <20190410010425.GU2217@ZenIV.linux.org.uk>
 <20190410012247.GB2454@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410012247.GB2454@sol.localdomain>
Sender: Al Viro <viro@ftp.linux.org.uk>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 09, 2019 at 06:22:49PM -0700, Eric Biggers wrote:

> > Non-NULL ->get_link() => DCACHE_SYMLINK_TYPE in ->d_flags =>
> > d_is_symlink() true => step_into() progresses to pick_link().
> > 
> > IOW, non-NULL ->get_link() is what tells you that we have
> > a symlink there.
> 
> I think that's pretty unintuitive.  The fact that multiple filesystems including
> ext4 set ->i_link on fast symlinks, then set ->get_link() to a function that
> returns ->i_link, made me assume that's the mechanism by which such symlink
> targets are returned to the VFS.  When in fact fs/namei.c just uses ->i_link,
> and never calls ->get_link().
> 
> Is there any reason why d_flags_for_inode() doesn't check S_ISLNK() instead, and
> then fs/namei.c would call ->get_link() if non-NULL, otherwise use ->i_link?

Extra check and dereference on hot path with no visible benefits of doing it
that way, for starters.  Really, what _is_ the benefit of pessimizing that?  
Most of the symlinks we run into will have ->i_link set; checking ->i_op->get_link
first is extra work for no good reason...

What's more, ->get_link is visible in inode_operations; ->i_link (let alone ->i_mode)
isn't.  As it is, we can easily tell symlink inode_operations from everything else
on the source level.  With your scheme we won't.
