Return-Path: <SRS0=psIF=OF=thunk.org=tytso@kernel.org>
Date: Mon, 26 Nov 2018 12:36:15 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH 5/7] ext4: use IS_VERITY() to check inode's fsverity
 status
Message-ID: <20181126173615.GB22888@thunk.org>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
 <20181119052324.31456-6-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119052324.31456-6-chandan@linux.vnet.ibm.com>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, ebiggers@kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Nov 19, 2018 at 10:53:22AM +0530, Chandan Rajendra wrote:
> This commit now uses IS_VERITY() macro to check if fsverity is
> enabled on an inode.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>

This patch causes a massive number of fsverity tests.  I suspect it's
due to a mismatch between the ext4's inode flags as opposed to the VFS
inode's flags.  I'll take a closer look in the next day or two.

Cheers,

						- Ted
