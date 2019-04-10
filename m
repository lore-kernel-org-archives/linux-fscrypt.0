Return-Path: <SRS0=NhUw=SM=ftp.linux.org.uk=viro@kernel.org>
Date: Wed, 10 Apr 2019 04:44:14 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH] fscrypt: cache decrypted symlink target in ->i_link
Message-ID: <20190410034414.GW2217@ZenIV.linux.org.uk>
References: <20190409233544.156665-1-ebiggers@kernel.org>
 <20190410003346.GT2217@ZenIV.linux.org.uk>
 <20190410004553.GA2454@sol.localdomain>
 <20190410010425.GU2217@ZenIV.linux.org.uk>
 <20190410012247.GB2454@sol.localdomain>
 <20190410013934.GV2217@ZenIV.linux.org.uk>
 <20190410025808.GA7140@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410025808.GA7140@sol.localdomain>
Sender: Al Viro <viro@ftp.linux.org.uk>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 09, 2019 at 07:58:08PM -0700, Eric Biggers wrote:

> It could check a flag IOP_GET_LINK in ->i_opflags instead, so it would be the
> same number of checks.  See patch below.

With that patch ->i_link is completely unused if ->get_link() is non-NULL,
so you get a method call on each traversal...

> Benefits are that we get code that isn't actively misleading (via
> simple_get_link() existing but actually never being called), and filesystems can
> cache a symlink target in ->i_link if it becomes available later, i.e. if it's
> not immediately available at iget() time.  Otherwise a filesystem-private field
> has to be used instead.  (For fscrypt, I'd probably use fscrypt_info::ci_link.)

What's to stop you from doing just that right now?  You'd need to take
care with barriers, but you'd need that anyway... As soon as ->i_link is set
you'll get no more ->get_link() on that sucker, using the cached value
from that point on.  IDGI...
