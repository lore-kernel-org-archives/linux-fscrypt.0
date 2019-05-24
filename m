Return-Path: <SRS0=ZLyM=TY=gmail.com=laoar.shao@kernel.org>
MIME-Version: 1.0
References: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
In-Reply-To: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 24 May 2019 22:15:18 +0800
Message-ID: <CALOAHbCGhRymJhKLbSXzwHszUtBexE9iD=MuywEEdROvXCrh+Q@mail.gmail.com>
Subject: Re: [PATCH] mm/vmscan.c: drop all inode/dentry cache from LRU
Content-Type: text/plain; charset="UTF-8"
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, May 24, 2019 at 4:06 PM Sahitya Tummala <stummala@codeaurora.org> wrote:
>
> This is important for the scenario where FBE (file based encryption)
> is enabled. With FBE, the encryption context needed to en/decrypt a file
> will be stored in inode and any inode that is left in the cache after
> drop_caches is done will be a problem. For ex, in Android, drop_caches
> will be used when switching work profiles.
>
> Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d96c547..b48926f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -730,7 +730,7 @@ void drop_slab_node(int nid)
>                 do {
>                         freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
>                 } while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
> -       } while (freed > 10);
> +       } while (freed != 0);
>  }

Perhaps that is not enough, because the shrink may stop when scan
count is less than SHRINK_BATCH.
Pls. see do_shrink_slab.

What about set shrinker->batch to 1 in this case ?

Thanks
Yafang
