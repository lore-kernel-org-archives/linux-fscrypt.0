Return-Path: <SRS0=NhUw=SM=ftp.linux.org.uk=viro@kernel.org>
Date: Wed, 10 Apr 2019 02:04:25 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH] fscrypt: cache decrypted symlink target in ->i_link
Message-ID: <20190410010425.GU2217@ZenIV.linux.org.uk>
References: <20190409233544.156665-1-ebiggers@kernel.org>
 <20190410003346.GT2217@ZenIV.linux.org.uk>
 <20190410004553.GA2454@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410004553.GA2454@sol.localdomain>
Sender: Al Viro <viro@ftp.linux.org.uk>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 09, 2019 at 05:45:54PM -0700, Eric Biggers wrote:
> On Wed, Apr 10, 2019 at 01:33:46AM +0100, Al Viro wrote:
> > On Tue, Apr 09, 2019 at 04:35:44PM -0700, Eric Biggers wrote:
> > > From: Eric Biggers <ebiggers@google.com>
> > > 
> > > Path lookups that traverse encrypted symlink(s) are very slow because
> > > each encrypted symlink needs to be decrypted each time it's followed.
> > > 
> > > Make encrypted symlinks faster by caching the decrypted symlink target
> > > in ->i_link.  The first call to ->get_link() sets it; later calls simply
> > > return it.  ->symlink() also sets it when the symlink is created.
> > > 
> > > When the inode's ->i_crypt_info is freed, ->i_link is freed too.
> > > 
> > > Note: RCU-delayed freeing of ->i_link is not yet implemented.
> > > Therefore, for now even when ->i_link is set, path lookups must continue
> > > to drop out of RCU-walk mode when following an encrypted symlink.
> > 
> > And how the devil would they continue to do that, if I might ask?
> > ->get_link() is *NOT* called if ->i_link is non-NULL, period.
> 
> You're right, I didn't notice that ->get_link() isn't called when
> ->i_link is non-NULL.
> 
> But that being the case, what's the point of simple_get_link()?

Non-NULL ->get_link() => DCACHE_SYMLINK_TYPE in ->d_flags =>
d_is_symlink() true => step_into() progresses to pick_link().

IOW, non-NULL ->get_link() is what tells you that we have
a symlink there.
