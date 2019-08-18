Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Sun, 18 Aug 2019 13:23:24 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190818202324.GA1824@zzz.localdomain>
References: <20190811213557.1970-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190811213557.1970-1-ebiggers@kernel.org>
Subject: Re: [f2fs-dev] [PATCH 0/6] fs-verity fixups
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Aug 11, 2019 at 02:35:51PM -0700, Eric Biggers wrote:
> A few fixes and cleanups for fs-verity.
> 
> If there are no objections, I'll fold these into the original patches.
> 
> Eric Biggers (6):
>   fs-verity: fix crash on read error in build_merkle_tree_level()
>   ext4: skip truncate when verity in progress in ->write_begin()
>   f2fs: skip truncate when verity in progress in ->write_begin()
>   ext4: remove ext4_bio_encrypted()
>   ext4: fix comment in ext4_end_enable_verity()
>   f2fs: use EFSCORRUPTED in f2fs_get_verity_descriptor()
> 
>  fs/ext4/inode.c    |  7 +++++--
>  fs/ext4/readpage.c |  9 ---------
>  fs/ext4/verity.c   |  2 +-
>  fs/f2fs/data.c     |  2 +-
>  fs/f2fs/verity.c   |  2 +-
>  fs/verity/enable.c | 24 ++++++++++++++++--------
>  6 files changed, 24 insertions(+), 22 deletions(-)
> 
> -- 
> 2.22.0
> 

I've gone ahead and folded in these fixes.

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
