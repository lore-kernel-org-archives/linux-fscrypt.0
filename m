Return-Path: <jaegeuk@kernel.org>
Date: Tue, 18 Apr 2017 18:42:09 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: use 32 bytes of encrypted filename
Message-ID: <20170419014209.GB12215@jaegeuk.local>
References: <20170418210642.6039-1-gwendal@chromium.org>
 <20170418230136.GA96152@gmail.com>
 <20170419001005.GA143911@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419001005.GA143911@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, ebiggers@google.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-mtd@lists.infradead.org, tytso@mit.edu, linux-ext4@vger.kernel.org, kinaba@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On 04/18, Eric Biggers wrote:
> On Tue, Apr 18, 2017 at 04:01:36PM -0700, Eric Biggers wrote:
> > 
> > Strangely, f2fs and ubifs do not use the bytes from the filename at all when
> > trying to find a specific directory entry in this case.  So this patch doesn't
> > really affect them.  This seems unreliable; perhaps we should introduce a
> > function like "fscrypt_name_matches()" which all the filesystems could call?
> > Can any of the f2fs and ubifs developers explain why they don't look at any
> > bytes from the filename?
> > 

The fscrypt_setup_filename sets fname->hash in the bigname case, but doesn't
give fname->disk_name. If it's not such the bigname case, we check its name
since fname->hash is zero.

> Just to give some ideas, here's an untested patch which does this and also
> updates F2FS to start checking the filename.  UBIFS seemed more difficult so I
> didn't touch it yet.
> 
> Of course, this would need to be split into a few different patches if we
> actually wanted to go with it.
> 
> ---

...

> diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
> index 8d5c62b07b28..07b80d78a9f6 100644
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
> @@ -130,17 +128,10 @@ struct f2fs_dir_entry *find_target_dentry(struct fscrypt_name *fname,
>  			continue;
>  		}
>  
> -		/* encrypted case */
> -		de_name.name = d->filename[bit_pos];
> -		de_name.len = le16_to_cpu(de->name_len);
> -
> -		/* show encrypted name */
> -		if (fname->hash) {
> -			if (de->hash_code == cpu_to_le32(fname->hash))
> -				goto found;
> -		} else if (de_name.len == name->len &&
> -			de->hash_code == namehash &&
> -			!memcmp(de_name.name, name->name, name->len))
> +		if ((fname->hash == 0 ||
> +		     fname->hash == le32_to_cpu(de->hash_code)) &&
> +		    fscrypt_name_matches(fname, d->filename[bit_pos],
> +					 le16_to_cpu(de->name_len)))

BTW, this slips checking namehash?

Thanks,

>  			goto found;
>  
>  		if (max_slots && max_len > *max_slots)
> diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
> index 3511ca798804..4034976bea93 100644
> --- a/include/linux/fscrypt_notsupp.h
> +++ b/include/linux/fscrypt_notsupp.h
> @@ -147,6 +147,24 @@ static inline int fscrypt_fname_usr_to_disk(struct inode *inode,
>  	return -EOPNOTSUPP;
>  }
>  
> +static inline bool fscrypt_match_dirent(const struct qstr *usr_fname,
> +					const struct fscrypt_str *disk_name,
> +					const struct fscrypt_str *crypto_buf,
> +					const char *de_name, u32 de_name_len)
> +{
> +	/* Encryption support disabled; use standard comparison. */
> +	if (de_name_len != disk_name->len)
> +		return false;
> +	return !memcmp(de_name, disk_name->name, disk_name->len);
> +}
> +
> +static inline bool fscrypt_name_matches(const struct fscrypt_name *fname,
> +					const char *de_name, u32 de_name_len)
> +{
> +	return fscrypt_match_dirent(fname->usr_fname, &fname->disk_name,
> +				    &fname->crypto_buf, de_name, de_name_len);
> +}
> +
>  /* bio.c */
>  static inline void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *ctx,
>  					     struct bio *bio)
> diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
> index a140f47e9b27..e3c9aa7209a1 100644
> --- a/include/linux/fscrypt_supp.h
> +++ b/include/linux/fscrypt_supp.h
> @@ -57,6 +57,63 @@ extern int fscrypt_fname_disk_to_usr(struct inode *, u32, u32,
>  extern int fscrypt_fname_usr_to_disk(struct inode *, const struct qstr *,
>  			struct fscrypt_str *);
>  
> +/*
> + * Number of bytes of ciphertext from the end of the filename which the
> + * filesystem includes when encoding long encrypted filenames for presentation
> + * to userspace without the key.
> + */
> +#define FS_FNAME_CRYPTO_DIGEST_SIZE	(2 * FS_CRYPTO_BLOCK_SIZE)
> +
> +/**
> + * fscrypt_match_dirent() - does the directory entry match the name being looked up?
> + *
> + * This is like fscrypt_name_matches(), but for filesystems which don't use the
> + * fscrypt_name structure.  (We probably should make all filesystems do the same
> + * thing...)
> + */
> +static inline bool fscrypt_match_dirent(const struct qstr *usr_fname,
> +					const struct fscrypt_str *disk_name,
> +					const struct fscrypt_str *crypto_buf,
> +					const char *de_name, u32 de_name_len)
> +{
> +	if (unlikely(!disk_name->name)) {
> +		if (WARN_ON_ONCE(usr_fname->name[0] != '_'))
> +			return false;
> +		if (de_name_len < FS_FNAME_CRYPTO_DIGEST_SIZE)
> +			return false;
> +		return !memcmp(de_name + de_name_len - FS_FNAME_CRYPTO_DIGEST_SIZE,
> +			       crypto_buf->name + 8,
> +			       FS_FNAME_CRYPTO_DIGEST_SIZE);
> +	}
> +
> +	if (de_name_len != disk_name->len)
> +		return false;
> +	return !memcmp(de_name, disk_name->name, disk_name->len);
> +}
> +
> +/**
> + * fscrypt_name_matches() - does the directory entry match the name being looked up?
> + * @fname: the name being looked up
> + * @de_name: the name from the directory entry
> + * @de_name_len: the length of @de_name in bytes
> + *
> + * Normally @fname->disk_name will be set, and in that case we simply compare
> + * that to the directory entry.  The only exception is that if we don't have the
> + * key for an encrypted directory and a filename in it is very long, then the
> + * filename presented to userspace will only have the last
> + * FS_FNAME_CRYPTO_DIGEST_SIZE bytes of ciphertext encoded in it, so we can only
> + * compare that portion.  Note that despite this limit, due to the use of
> + * CBC-CTS encryption there should not be any collisions.
> + *
> + * Return: true if the name matches, otherwise false.
> + */
> +static inline bool fscrypt_name_matches(const struct fscrypt_name *fname,
> +					const char *de_name, u32 de_name_len)
> +{
> +	return fscrypt_match_dirent(fname->usr_fname, &fname->disk_name,
> +				    &fname->crypto_buf, de_name, de_name_len);
> +}
> +
>  /* bio.c */
>  extern void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *, struct bio *);
>  extern void fscrypt_pullback_bio_page(struct page **, bool);
> 
> ------------------------------------------------------------------------------
> Check out the vibrant tech community on one of the world's most
> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
> _______________________________________________
> Linux-f2fs-devel mailing list
> Linux-f2fs-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
