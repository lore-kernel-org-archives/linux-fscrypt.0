Return-Path: <tytso@thunk.org>
Date: Fri, 25 May 2018 16:01:21 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH V3 07/12] mpage_readpage[s]: Introduce post process
 callback parameters
Message-ID: <20180525200121.GA4613@thunk.org>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
 <20180522160110.1161-8-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522160110.1161-8-chandan@linux.vnet.ibm.com>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-fscrypt@vger.kernel.org, ebiggers3@gmail.com, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, May 22, 2018 at 09:31:05PM +0530, Chandan Rajendra wrote:
> This commit introduces a new parameter to mpage_readpage[s]()
> functions. This parameter contains pointers to functions that can be
> used to decrypt data read from the backing device. These are stored in
> the fscrypt_ctx structure and one of these functions is invoked after
> the read operation is completed.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>

Can you describe more of what you are doing here; specifically, you
deleted all of fs/ext4/readpage.c --- was this because you moved
functionality back into fs/mpage.c?  Did you make sure all of the
local changes in fs/ext4/readpage was moved back to fs/mpage.c?

If the goal is to refactor code to remove the need for
fs/ext4/readpage.c, you should probably make that be the first patch
as a prerequisite patch.  And we then need to make sure we don't
accidentally break anyone else who might be using fs/mpage.c.  Saying
a bit more about why you think the refactor is a good thing would also
be useful.

	     	   	       	   	    	  - Ted

P.S.  What version of the kernel was these patches against?  I noticed
the patches weren't applying cleanly to the ext4 git tree.  Given how
invasive these patches are, it's not surprising that they are very
version-sensitive.
