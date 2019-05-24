Return-Path: <SRS0=XpvI=TY=mit.edu=tytso@kernel.org>
Date: Fri, 24 May 2019 12:52:13 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] mm/vmscan.c: drop all inode/dentry cache from LRU
Message-ID: <20190524165213.GB2765@mit.edu>
References: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Yafang Shao <laoar.shao@gmail.com>, Roman Gushchin <guro@fb.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, May 24, 2019 at 01:36:01PM +0530, Sahitya Tummala wrote:
> This is important for the scenario where FBE (file based encryption)
> is enabled. With FBE, the encryption context needed to en/decrypt a file
> will be stored in inode and any inode that is left in the cache after
> drop_caches is done will be a problem. For ex, in Android, drop_caches
> will be used when switching work profiles.
> 
> Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>

Instead of making a change to vmscan.c, it's probably better to
migrate to the new fscrypt key-management framework, which solves this
problem with an explicit FS_IOC_REMOVE_ENCRYPTION_KEY ioctl.  This
allows the system to remove all inodes that were made available via a
single key without having nuking all other inodes --- this would make
it much faster after a user logs out of ChromeOS, for example:

See:

	https://patchwork.kernel.org/patch/10952019/

							- Ted
