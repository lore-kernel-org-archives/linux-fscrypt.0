Return-Path: <SRS0=JOCC=TY=codeaurora.org=stummala@kernel.org>
From: Sahitya Tummala <stummala@codeaurora.org>
Subject: [PATCH] mm/vmscan.c: drop all inode/dentry cache from LRU
Date: Fri, 24 May 2019 13:36:01 +0530
Message-Id: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Yafang Shao <laoar.shao@gmail.com>, Roman Gushchin <guro@fb.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Sahitya Tummala <stummala@codeaurora.org>
List-ID: <linux-fscrypt@vger.kernel.org>

This is important for the scenario where FBE (file based encryption)
is enabled. With FBE, the encryption context needed to en/decrypt a file
will be stored in inode and any inode that is left in the cache after
drop_caches is done will be a problem. For ex, in Android, drop_caches
will be used when switching work profiles.

Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d96c547..b48926f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -730,7 +730,7 @@ void drop_slab_node(int nid)
 		do {
 			freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
-	} while (freed > 10);
+	} while (freed != 0);
 }
 
 void drop_slab(void)
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project.
