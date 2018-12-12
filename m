Return-Path: <SRS0=xCEI=OV=thunk.org=tytso@kernel.org>
Date: Tue, 11 Dec 2018 21:30:18 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH 0/2] fs-verity: fix !CONFIG_FS_VERITY case
Message-ID: <20181212023018.GD4464@thunk.org>
References: <20181211224651.112510-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211224651.112510-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Krzysztof Kozlowski <krzk@kernel.org>, linux-ext4@vger.kernel.org, Tony Lindgren <tony@atomide.com>, Kirill Tkhai <ktkhai@virtuozzo.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Dec 11, 2018 at 02:46:49PM -0800, Eric Biggers wrote:
> Replace the two patches that broken the !CONFIG_FS_VERITY case with
> fixed verisons.

I had fixed this by simply adding the conditional to the
!CONFIG_FS_VERITY versions of fsverity_file_open() and
fsverity_prepare_setattr(), before I found your patch in my inbox.  I
think my version is simpler (and results in a fewer lines of code :-),
so I think I'm going to stick with it.

The net diff of my changes from the previous version was:

diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
index ea8c418bd7d5..6684bb72bbfc 100644
--- a/include/linux/fsverity.h
+++ b/include/linux/fsverity.h
@@ -60,13 +60,13 @@ static inline int fsverity_ioctl_measure(struct file *filp, void __user *arg)
 
 static inline int fsverity_file_open(struct inode *inode, struct file *filp)
 {
-	return -EOPNOTSUPP;
+	return IS_VERITY(inode) ? -ENOTSUPP : 0;
 }
 
 static inline int fsverity_prepare_setattr(struct dentry *dentry,
 					   struct iattr *attr)
 {
-	return -EOPNOTSUPP;
+	return IS_VERITY(d_inode(dentry)) ? -ENOTSUPP : 0;
 }
 
 static inline int fsverity_prepare_getattr(struct inode *inode)

       	   				   	 - Ted
