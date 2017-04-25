Return-Path: <jaegeuk@kernel.org>
Date: Mon, 24 Apr 2017 17:16:31 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH 5/6] f2fs: switch to using fscrypt_match_name()
Message-ID: <20170425001631.GB4983@jaegeuk.local>
References: <20170424170013.85175-1-ebiggers3@gmail.com>
 <20170424170013.85175-6-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424170013.85175-6-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 04/24, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Switch f2fs directory searches to use the fscrypt_match_name() helper
> function.  There should be no functional change.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Jaegeuk Kim <jaegeuk@kernel.org>

> ---
>  fs/f2fs/dir.c | 28 ++++------------------------
>  1 file changed, 4 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
> index 5df3596a667a..c7ed25fb3003 100644
> --- a/fs/f2fs/dir.c
> +++ b/fs/f2fs/dir.c
> @@ -111,8 +111,6 @@ struct f2fs_dir_entry *find_target_dentry(struct fscrypt_name *fname,
>  	struct f2fs_dir_entry *de;
>  	unsigned long bit_pos = 0;
>  	int max_len = 0;
> -	struct fscrypt_str de_name = FSTR_INIT(NULL, 0);
> -	struct fscrypt_str *name = &fname->disk_name;
>  
>  	if (max_slots)
>  		*max_slots = 0;
> @@ -130,29 +128,11 @@ struct f2fs_dir_entry *find_target_dentry(struct fscrypt_name *fname,
>  			continue;
>  		}
>  
> -		if (de->hash_code != namehash)
> -			goto not_match;
> -
> -		de_name.name = d->filename[bit_pos];
> -		de_name.len = le16_to_cpu(de->name_len);
> -
> -#ifdef CONFIG_F2FS_FS_ENCRYPTION
> -		if (unlikely(!name->name)) {
> -			if (fname->usr_fname->name[0] == '_') {
> -				if (de_name.len > 32 &&
> -					!memcmp(de_name.name + ((de_name.len - 17) & ~15),
> -						fname->crypto_buf.name + 8, 16))
> -					goto found;
> -				goto not_match;
> -			}
> -			name->name = fname->crypto_buf.name;
> -			name->len = fname->crypto_buf.len;
> -		}
> -#endif
> -		if (de_name.len == name->len &&
> -				!memcmp(de_name.name, name->name, name->len))
> +		if (de->hash_code == namehash &&
> +		    fscrypt_match_name(fname, d->filename[bit_pos],
> +				       le16_to_cpu(de->name_len)))
>  			goto found;
> -not_match:
> +
>  		if (max_slots && max_len > *max_slots)
>  			*max_slots = max_len;
>  		max_len = 0;
> -- 
> 2.12.2.816.g2cccc81164-goog
