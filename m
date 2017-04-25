Return-Path: <jaegeuk@kernel.org>
Date: Mon, 24 Apr 2017 17:10:23 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH 1/6] f2fs: check entire encrypted bigname when finding a
 dentry
Message-ID: <20170425001023.GA4983@jaegeuk.local>
References: <20170424170013.85175-1-ebiggers3@gmail.com>
 <20170424170013.85175-2-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424170013.85175-2-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

This looks good to me.
I'll drop it from my tree, so please move forward through fscrypt.

Thanks,

On 04/24, Eric Biggers wrote:
> From: Jaegeuk Kim <jaegeuk@kernel.org>
> 
> If user has no key under an encrypted dir, fscrypt gives digested dentries.
> Previously, when looking up a dentry, f2fs only checks its hash value with
> first 4 bytes of the digested dentry, which didn't handle hash collisions fully.
> This patch enhances to check entire dentry bytes likewise ext4.
> 
> Eric reported how to reproduce this issue by:
> 
>  # seq -f "edir/abcdefghijklmnopqrstuvwxyz012345%.0f" 100000 | xargs touch
>  # find edir -type f | xargs stat -c %i | sort | uniq | wc -l
> 100000
>  # sync
>  # echo 3 > /proc/sys/vm/drop_caches
>  # keyctl new_session
>  # find edir -type f | xargs stat -c %i | sort | uniq | wc -l
> 99999
> 
> Cc: <stable@vger.kernel.org>
> Reported-by: Eric Biggers <ebiggers@google.com>
> Signed-off-by: Jaegeuk Kim <jaegeuk@kernel.org>
> (fixed f2fs_dentry_hash() to work even when the hash is 0)
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/f2fs/dir.c    | 37 +++++++++++++++++++++----------------
>  fs/f2fs/f2fs.h   |  3 ++-
>  fs/f2fs/hash.c   |  7 ++++++-
>  fs/f2fs/inline.c |  4 ++--
>  4 files changed, 31 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
> index c143dffcae6e..374e4b8f9b70 100644
> --- a/fs/f2fs/dir.c
> +++ b/fs/f2fs/dir.c
> @@ -130,19 +130,29 @@ struct f2fs_dir_entry *find_target_dentry(struct fscrypt_name *fname,
>  			continue;
>  		}
>  
> -		/* encrypted case */
> +		if (de->hash_code != namehash)
> +			goto not_match;
> +
>  		de_name.name = d->filename[bit_pos];
>  		de_name.len = le16_to_cpu(de->name_len);
>  
> -		/* show encrypted name */
> -		if (fname->hash) {
> -			if (de->hash_code == cpu_to_le32(fname->hash))
> -				goto found;
> -		} else if (de_name.len == name->len &&
> -			de->hash_code == namehash &&
> -			!memcmp(de_name.name, name->name, name->len))
> +#ifdef CONFIG_F2FS_FS_ENCRYPTION
> +		if (unlikely(!name->name)) {
> +			if (fname->usr_fname->name[0] == '_') {
> +				if (de_name.len >= 16 &&
> +					!memcmp(de_name.name + de_name.len - 16,
> +						fname->crypto_buf.name + 8, 16))
> +					goto found;
> +				goto not_match;
> +			}
> +			name->name = fname->crypto_buf.name;
> +			name->len = fname->crypto_buf.len;
> +		}
> +#endif
> +		if (de_name.len == name->len &&
> +				!memcmp(de_name.name, name->name, name->len))
>  			goto found;
> -
> +not_match:
>  		if (max_slots && max_len > *max_slots)
>  			*max_slots = max_len;
>  		max_len = 0;
> @@ -170,12 +180,7 @@ static struct f2fs_dir_entry *find_in_level(struct inode *dir,
>  	struct f2fs_dir_entry *de = NULL;
>  	bool room = false;
>  	int max_slots;
> -	f2fs_hash_t namehash;
> -
> -	if(fname->hash)
> -		namehash = cpu_to_le32(fname->hash);
> -	else
> -		namehash = f2fs_dentry_hash(&name);
> +	f2fs_hash_t namehash = f2fs_dentry_hash(&name, fname);
>  
>  	nbucket = dir_buckets(level, F2FS_I(dir)->i_dir_level);
>  	nblock = bucket_blocks(level);
> @@ -527,7 +532,7 @@ int f2fs_add_regular_entry(struct inode *dir, const struct qstr *new_name,
>  
>  	level = 0;
>  	slots = GET_DENTRY_SLOTS(new_name->len);
> -	dentry_hash = f2fs_dentry_hash(new_name);
> +	dentry_hash = f2fs_dentry_hash(new_name, NULL);
>  
>  	current_depth = F2FS_I(dir)->i_current_depth;
>  	if (F2FS_I(dir)->chash == dentry_hash) {
> diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
> index 562db8989a4e..5bc232e21a6e 100644
> --- a/fs/f2fs/f2fs.h
> +++ b/fs/f2fs/f2fs.h
> @@ -2145,7 +2145,8 @@ int sanity_check_ckpt(struct f2fs_sb_info *sbi);
>  /*
>   * hash.c
>   */
> -f2fs_hash_t f2fs_dentry_hash(const struct qstr *name_info);
> +f2fs_hash_t f2fs_dentry_hash(const struct qstr *name_info,
> +				struct fscrypt_name *fname);
>  
>  /*
>   * node.c
> diff --git a/fs/f2fs/hash.c b/fs/f2fs/hash.c
> index 71b7206c431e..eb2e031ea887 100644
> --- a/fs/f2fs/hash.c
> +++ b/fs/f2fs/hash.c
> @@ -70,7 +70,8 @@ static void str2hashbuf(const unsigned char *msg, size_t len,
>  		*buf++ = pad;
>  }
>  
> -f2fs_hash_t f2fs_dentry_hash(const struct qstr *name_info)
> +f2fs_hash_t f2fs_dentry_hash(const struct qstr *name_info,
> +				struct fscrypt_name *fname)
>  {
>  	__u32 hash;
>  	f2fs_hash_t f2fs_hash;
> @@ -79,6 +80,10 @@ f2fs_hash_t f2fs_dentry_hash(const struct qstr *name_info)
>  	const unsigned char *name = name_info->name;
>  	size_t len = name_info->len;
>  
> +	/* encrypted bigname case */
> +	if (fname && !fname->disk_name.name)
> +		return cpu_to_le32(fname->hash);
> +
>  	if (is_dot_dotdot(name_info))
>  		return 0;
>  
> diff --git a/fs/f2fs/inline.c b/fs/f2fs/inline.c
> index 0ccdefe9fdba..e4c527c4e7d0 100644
> --- a/fs/f2fs/inline.c
> +++ b/fs/f2fs/inline.c
> @@ -298,7 +298,7 @@ struct f2fs_dir_entry *find_in_inline_dir(struct inode *dir,
>  		return NULL;
>  	}
>  
> -	namehash = f2fs_dentry_hash(&name);
> +	namehash = f2fs_dentry_hash(&name, fname);
>  
>  	inline_dentry = inline_data_addr(ipage);
>  
> @@ -533,7 +533,7 @@ int f2fs_add_inline_entry(struct inode *dir, const struct qstr *new_name,
>  
>  	f2fs_wait_on_page_writeback(ipage, NODE, true);
>  
> -	name_hash = f2fs_dentry_hash(new_name);
> +	name_hash = f2fs_dentry_hash(new_name, NULL);
>  	make_dentry_ptr_inline(NULL, &d, dentry_blk);
>  	f2fs_update_dentry(ino, mode, &d, new_name, name_hash, bit_pos);
>  
> -- 
> 2.12.2.816.g2cccc81164-goog
