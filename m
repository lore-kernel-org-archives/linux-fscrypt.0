Return-Path: <tytso@thunk.org>
Date: Mon, 28 May 2018 15:34:37 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH V3 07/12] mpage_readpage[s]: Introduce post process
 callback parameters
Message-ID: <20180528193437.GC3572@thunk.org>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
 <20180522160110.1161-8-chandan@linux.vnet.ibm.com>
 <20180525200121.GA4613@thunk.org>
 <4837046.FSMeUsGny4@dhcp-9-109-247-5>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4837046.FSMeUsGny4@dhcp-9-109-247-5>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-fscrypt@vger.kernel.org, ebiggers3@gmail.com, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 28, 2018 at 11:05:52AM +0530, Chandan Rajendra wrote:
> > Can you describe more of what you are doing here; specifically, you
> > deleted all of fs/ext4/readpage.c --- was this because you moved
> > functionality back into fs/mpage.c?  Did you make sure all of the
> > local changes in fs/ext4/readpage was moved back to fs/mpage.c?
> > 
> > If the goal is to refactor code to remove the need for
> > fs/ext4/readpage.c, you should probably make that be the first patch
> > as a prerequisite patch.  And we then need to make sure we don't
> > accidentally break anyone else who might be using fs/mpage.c.  Saying
> > a bit more about why you think the refactor is a good thing would also
> > be useful.
> 
> I will split this patch into two as suggested by you. Also, I will update 
> the commit messages.

Note that I was planning on making changes to fs/ext4/readpage.c as
part of integrating fsverity[1][2] support into ext4.  Basically, I
need to do something like [3] to fs/ext4/readpage.c.

[1] https://www.spinics.net/lists/linux-fsdevel/msg121182.html
[2] https://www.youtube.com/watch?v=GlEWcVuRbNA
[3] https://git.kernel.org/pub/scm/linux/kernel/git/mhalcrow/linux.git/commit/?h=fs-verity-dev&id=827faba05972517f49fa2f2aaf272150f5766af2

Which is why I'm really interested in your reasoning for why you
propose to drop fs/ext4/readpage.c.  :-)

						- Ted
