Return-Path: <SRS0=xCEI=OV=thunk.org=tytso@kernel.org>
Date: Tue, 11 Dec 2018 23:07:03 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH 0/2] fs-verity: fix !CONFIG_FS_VERITY case
Message-ID: <20181212040703.GA21718@thunk.org>
References: <20181211224651.112510-1-ebiggers@kernel.org>
 <20181212023018.GD4464@thunk.org>
 <20181212024221.GA722@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212024221.GA722@sol.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Krzysztof Kozlowski <krzk@kernel.org>, linux-ext4@vger.kernel.org, Tony Lindgren <tony@atomide.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Dec 11, 2018 at 06:42:22PM -0800, Eric Biggers wrote:
> 
> Either works, but I slightly prefer my version since it minimizes the overhead
> on non-verity files when the kconfig option is enabled: it's just an i_flags
> check, rather than a function call plus an i_flags check.  The same approach is
> used in the fscrypt hooks.  Also shouldn't it be EOPNOTSUPP, not ENOTSUPP?

It's the same for both, since in the !CONFIG_FS_VERITY case the two
functions are inline functions.

There's actually a bigger issue that I've been meaning to raise, which
is that right now we'll set S_VERITY even if the VERITY feature flag
is not set.  What we should do, in my opinion, is to make ext4 fail a
r/w mount if it tries to mount the file system with the VERITY feature
flag set and the kernel is mounted with the VERITY flag set.

Also, if the kernel is compiled without CONFIG_FS_VERITY enabled,
IS_VERITY(inode) should be defined to 0, and if the an inode is found
with EXT4_VERITY_FL and the VERITY feature is not set, we should
declare the file system corrupted.

The problem is that f2fs doesn't check **any** file system features at
all.  If you mount a file system with f2fs features that the kernel
doesn't support, the f2fs file system doesn't say boo.  I suspect
hilarity would ensue if new f2fs file system with new features are
mounted on an older kernel, or a kernel where features like encryption
and verity are disabled.

So I could easily make these changes for ext4, but what we would do
for f2fs isn't clear.  I think f2fs is very broken here, but I
hesitate defining IS_VERITY(x) to 0 if !CONFIG_FS_VERITY might cause
f2fs to break even more than it does today.  I would prefer to do that
since it would remove dead code from ext4 and f2fs in the
!CONFIG_FS_VERITY case, but I think we clarify with the f2fs folks why
it is that they aren't checking the f2fs feature mask when mounting a
file system first.

       	    	      	       	    - Ted
