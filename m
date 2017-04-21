Return-Path: <ebiggers3@gmail.com>
Date: Fri, 21 Apr 2017 00:44:02 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: use 32 bytes of encrypted filename
Message-ID: <20170421074402.GA7459@zzz>
References: <20170418210642.6039-1-gwendal@chromium.org>
 <20170418230136.GA96152@gmail.com>
 <20170419001005.GA143911@gmail.com>
 <20170419014209.GB12215@jaegeuk.local>
 <20170419040138.GA563@zzz>
 <20170419204448.GA1021@jaegeuk.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419204448.GA1021@jaegeuk.local>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, ebiggers@google.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-mtd@lists.infradead.org, tytso@mit.edu, linux-ext4@vger.kernel.org, kinaba@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jaegeuk,

On Wed, Apr 19, 2017 at 01:44:48PM -0700, Jaegeuk Kim wrote:
> 
> Thank you for sharing more details. I could reproduce this issue and reach out
> to what you mentioned. In order to resolve this, I wrote a patch for f2fs first
> to act like ext4 for easy backports. Then, I expect a global fscrypt function
> is easily able to clean them up.
[...]
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

I agree with this approach, but I don't think it's ever the case that
fname->usr_fname->name[0] != '_'.  (Yes, ext4 checks it, but I think it's
unneeded there too.)  And if it was, it doesn't make sense to modify the 'name'
that is passed in.

In any case, I guess that unless there are other ideas we can do these patches:

1.) f2fs patch to start checking the name, as above
2.) patch to start encoding last 32 bytes of the name (or second-to-last CTS
    block, I haven't decided yet) rather than last 16 bytes, changing
    fs/crypto/, fs/ext4/, and fs/f2fs/
3.) cleanup patches to introduce helper function and switch ext4 and f2fs to it

(1) and (2) will be backported.

UBIFS can be changed to use the helper function later if needed.  It's not as
important for it to be backported there since UBIFS does the "double hashing",
and UBIFS encryption was just added in 4.10 anyway.

I can try to put together the full series when I have time.  It probably would
make sense for it to go through the fscrypt tree, given the dependencies.

Eric
