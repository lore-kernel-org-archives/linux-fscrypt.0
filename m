Return-Path: <mhalcrow@google.com>
Return-Path: <mhalcrow@google.com>
Date: Fri, 14 Jul 2017 09:40:54 -0700
From: Michael Halcrow <mhalcrow@google.com>
Subject: Re: [PATCH 4/6] fscrypt: verify that the correct master key was
 supplied
Message-ID: <20170714164054.GC25453@google.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-5-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170712210035.51534-5-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jul 12, 2017 at 02:00:33PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Currently, while a fscrypt master key is required to have a certain
> description in the keyring, its payload is never verified to be correct.
> While sufficient for well-behaved userspace, this is insecure in a
> multi-user system where a user has been given only read-only access to
> an encrypted file or directory.  Specifically, if an encrypted file or
> directory does not yet have its key cached by the kernel, the first user
> who accesses it can provide an arbitrary key in their own keyring, which
> the kernel will then associate with the inode and use for read(),
> write(), readdir(), etc. by other users as well.
> 
> Consequently, it's trivial for a user with *read-only* access to an
> encrypted file or directory to make it appear as garbage to everyone.
> Creative users might be able to accomplish more sophisticated attacks by
> careful choice of the key, e.g. choosing a key causes certain bytes of
> file contents to have certain values or that causes filenames containing
> the '/' character to appear.
> 
> Solve the problem for v2 encryption policies by storing a "hash" of the
> master encryption key in the encryption xattr and verifying it before
> accepting the user-provided key.  We generate the "hash" using
> HKDF-SHA512 by passing a distinct application-specific info string.
> This produces a value which is cryptographically isolated and can be
> stored in the clear without leaking any information about the master key
> or any other derived keys (in a computational sense).  Reusing HKDF is
> better than doing e.g. SHA-512(master_key) because it avoids passing the
> same key into different cryptographic primitives.
> 
> We make the hash field 16 bytes long, as this should provide sufficient
> collision and preimage resistance while not wasting too much space for
> the encryption xattr.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Michael Halcrow <mhalcrow@google.com>

> ---
>  fs/crypto/fscrypt_private.h |  4 ++++
>  fs/crypto/keyinfo.c         | 46 +++++++++++++++++++++++++++++++++++++
>  fs/crypto/policy.c          | 55 ++++++++++++++++++++++++++++++++++++---------
>  3 files changed, 95 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
> index 095e7c16483a..a7baeac92575 100644
> --- a/fs/crypto/fscrypt_private.h
> +++ b/fs/crypto/fscrypt_private.h
> @@ -92,6 +92,7 @@ fscrypt_valid_context_format(const struct fscrypt_context *ctx, int size)
>  struct fscrypt_master_key {
>  	struct crypto_shash	*mk_hmac;
>  	unsigned int		mk_size;
> +	u8			mk_hash[FSCRYPT_KEY_HASH_SIZE];
>  };
>  
>  /*
> @@ -155,6 +156,9 @@ extern struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
>  					      gfp_t gfp_flags);
>  
>  /* keyinfo.c */
> +extern int fscrypt_compute_key_hash(const struct inode *inode,
> +				    const struct fscrypt_policy *policy,
> +				    u8 hash[FSCRYPT_KEY_HASH_SIZE]);
>  extern void __exit fscrypt_essiv_cleanup(void);
>  
>  #endif /* _FSCRYPT_PRIVATE_H */
> diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
> index 7ed1a7fb1308..12a60eacf819 100644
> --- a/fs/crypto/keyinfo.c
> +++ b/fs/crypto/keyinfo.c
> @@ -39,8 +39,11 @@ static struct crypto_shash *essiv_hash_tfm;
>   *
>   * Keys derived with different info strings are cryptographically isolated from
>   * each other --- knowledge of one derived key doesn't reveal any others.
> + * (This property is particularly important for the derived key used as the
> + * "key hash", as that is stored in the clear.)
>   */
>  #define HKDF_CONTEXT_PER_FILE_KEY	1
> +#define HKDF_CONTEXT_KEY_HASH		2
>  
>  /*
>   * HKDF consists of two steps:
> @@ -212,6 +215,12 @@ alloc_master_key(const struct fscrypt_key *payload)
>  	err = crypto_shash_setkey(k->mk_hmac, prk, sizeof(prk));
>  	if (err)
>  		goto fail;
> +
> +	/* Calculate the "key hash" */
> +	err = hkdf_expand(k->mk_hmac, HKDF_CONTEXT_KEY_HASH, NULL, 0,
> +			  k->mk_hash, FSCRYPT_KEY_HASH_SIZE);
> +	if (err)
> +		goto fail;
>  out:
>  	memzero_explicit(prk, sizeof(prk));
>  	return k;
> @@ -537,6 +546,31 @@ void __exit fscrypt_essiv_cleanup(void)
>  	crypto_free_shash(essiv_hash_tfm);
>  }
>  
> +int fscrypt_compute_key_hash(const struct inode *inode,
> +			     const struct fscrypt_policy *policy,
> +			     u8 hash[FSCRYPT_KEY_HASH_SIZE])
> +{
> +	struct fscrypt_master_key *k;
> +	unsigned int min_keysize;
> +
> +	/*
> +	 * Require that the master key be long enough for both the
> +	 * contents and filenames encryption modes.
> +	 */
> +	min_keysize =
> +		max(available_modes[policy->contents_encryption_mode].keysize,
> +		    available_modes[policy->filenames_encryption_mode].keysize);
> +
> +	k = load_master_key_from_keyring(inode, policy->master_key_descriptor,
> +					 min_keysize);
> +	if (IS_ERR(k))
> +		return PTR_ERR(k);
> +
> +	memcpy(hash, k->mk_hash, FSCRYPT_KEY_HASH_SIZE);
> +	put_master_key(k);
> +	return 0;
> +}
> +
>  int fscrypt_get_encryption_info(struct inode *inode)
>  {
>  	struct fscrypt_info *crypt_info;
> @@ -613,6 +647,18 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  			goto out;
>  		}
>  
> +		/*
> +		 * Make sure the master key we found has the correct hash.
> +		 * Buggy or malicious userspace may provide the wrong key.
> +		 */
> +		if (memcmp(crypt_info->ci_master_key->mk_hash, ctx.key_hash,
> +			   FSCRYPT_KEY_HASH_SIZE)) {
> +			pr_warn_ratelimited("fscrypt: wrong encryption key supplied for inode %lu\n",
> +					    inode->i_ino);
> +			res = -ENOKEY;
> +			goto out;
> +		}
> +
>  		res = derive_key_hkdf(crypt_info->ci_master_key, &ctx,
>  				      derived_key, derived_keysize);
>  	}
> diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
> index 81c59f8e45c0..2934bc2bff4b 100644
> --- a/fs/crypto/policy.c
> +++ b/fs/crypto/policy.c
> @@ -40,7 +40,8 @@ static u8 context_version_for_policy(const struct fscrypt_policy *policy)
>   */
>  static bool is_encryption_context_consistent_with_policy(
>  				const struct fscrypt_context *ctx,
> -				const struct fscrypt_policy *policy)
> +				const struct fscrypt_policy *policy,
> +				const u8 key_hash[FSCRYPT_KEY_HASH_SIZE])
>  {
>  	return (ctx->version == context_version_for_policy(policy)) &&
>  		(memcmp(ctx->master_key_descriptor,
> @@ -50,11 +51,14 @@ static bool is_encryption_context_consistent_with_policy(
>  		(ctx->contents_encryption_mode ==
>  		 policy->contents_encryption_mode) &&
>  		(ctx->filenames_encryption_mode ==
> -		 policy->filenames_encryption_mode);
> +		 policy->filenames_encryption_mode) &&
> +		(ctx->version == FSCRYPT_CONTEXT_V1 ||
> +		 (memcmp(ctx->key_hash, key_hash, FSCRYPT_KEY_HASH_SIZE) == 0));
>  }
>  
>  static int create_encryption_context_from_policy(struct inode *inode,
> -				const struct fscrypt_policy *policy)
> +				const struct fscrypt_policy *policy,
> +				const u8 key_hash[FSCRYPT_KEY_HASH_SIZE])
>  {
>  	struct fscrypt_context ctx;
>  
> @@ -74,7 +78,7 @@ static int create_encryption_context_from_policy(struct inode *inode,
>  	BUILD_BUG_ON(sizeof(ctx.nonce) != FS_KEY_DERIVATION_NONCE_SIZE);
>  	get_random_bytes(ctx.nonce, FS_KEY_DERIVATION_NONCE_SIZE);
>  	if (ctx.version != FSCRYPT_CONTEXT_V1)
> -		memset(ctx.key_hash, 0, FSCRYPT_KEY_HASH_SIZE);
> +		memcpy(ctx.key_hash, key_hash, FSCRYPT_KEY_HASH_SIZE);
>  
>  	return inode->i_sb->s_cop->set_context(inode, &ctx,
>  					       fscrypt_context_size(&ctx),
> @@ -87,6 +91,7 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
>  	struct inode *inode = file_inode(filp);
>  	int ret;
>  	struct fscrypt_context ctx;
> +	u8 key_hash[FSCRYPT_KEY_HASH_SIZE];
>  
>  	if (copy_from_user(&policy, arg, sizeof(policy)))
>  		return -EFAULT;
> @@ -98,6 +103,25 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
>  	    policy.version != FS_POLICY_VERSION_HKDF)
>  		return -EINVAL;
>  
> +	if (policy.version == FS_POLICY_VERSION_ORIGINAL) {
> +		/*
> +		 * Originally no key verification was implemented, which was
> +		 * insufficient for scenarios where multiple users share
> +		 * encrypted files.  The new encryption policy version fixes
> +		 * this and also implements an improved key derivation function.
> +		 * So as long as the key can be in the keyring at the time the
> +		 * policy is set and compatibility with old kernels isn't
> +		 * required, it's recommended to use the new policy version
> +		 * (fscrypt_policy.version = 2).
> +		 */
> +		pr_warn_once("%s (pid %d) is setting less secure v0 encryption policy; recommend upgrading to v2.\n",
> +			     current->comm, current->pid);
> +	} else {
> +		ret = fscrypt_compute_key_hash(inode, &policy, key_hash);
> +		if (ret)
> +			return ret;
> +	}
> +
>  	ret = mnt_want_write_file(filp);
>  	if (ret)
>  		return ret;
> @@ -112,10 +136,12 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
>  			ret = -ENOTEMPTY;
>  		else
>  			ret = create_encryption_context_from_policy(inode,
> -								    &policy);
> +								    &policy,
> +								    key_hash);
>  	} else if (ret >= 0 && fscrypt_valid_context_format(&ctx, ret) &&
>  		   is_encryption_context_consistent_with_policy(&ctx,
> -								&policy)) {
> +								&policy,
> +								key_hash)) {
>  		/* The file already uses the same encryption policy. */
>  		ret = 0;
>  	} else if (ret >= 0 || ret == -ERANGE) {
> @@ -232,7 +258,11 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
>  			(parent_ci->ci_data_mode == child_ci->ci_data_mode) &&
>  			(parent_ci->ci_filename_mode ==
>  			 child_ci->ci_filename_mode) &&
> -			(parent_ci->ci_flags == child_ci->ci_flags);
> +			(parent_ci->ci_flags == child_ci->ci_flags) &&
> +			(parent_ci->ci_context_version == FSCRYPT_CONTEXT_V1 ||
> +			 (memcmp(parent_ci->ci_master_key->mk_hash,
> +				 child_ci->ci_master_key->mk_hash,
> +				 FSCRYPT_KEY_HASH_SIZE) == 0));
>  	}
>  
>  	res = cops->get_context(parent, &parent_ctx, sizeof(parent_ctx));
> @@ -251,7 +281,10 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
>  		 child_ctx.contents_encryption_mode) &&
>  		(parent_ctx.filenames_encryption_mode ==
>  		 child_ctx.filenames_encryption_mode) &&
> -		(parent_ctx.flags == child_ctx.flags);
> +		(parent_ctx.flags == child_ctx.flags) &&
> +		(parent_ctx.version == FSCRYPT_CONTEXT_V1 ||
> +		 (memcmp(parent_ctx.key_hash, child_ctx.key_hash,
> +			 FSCRYPT_KEY_HASH_SIZE) == 0));
>  }
>  EXPORT_SYMBOL(fscrypt_has_permitted_context);
>  
> @@ -286,8 +319,10 @@ int fscrypt_inherit_context(struct inode *parent, struct inode *child,
>  	memcpy(ctx.master_key_descriptor, ci->ci_master_key_descriptor,
>  	       FS_KEY_DESCRIPTOR_SIZE);
>  	get_random_bytes(ctx.nonce, FS_KEY_DERIVATION_NONCE_SIZE);
> -	if (ctx.version != FSCRYPT_CONTEXT_V1)
> -		memset(ctx.key_hash, 0, FSCRYPT_KEY_HASH_SIZE);
> +	if (ctx.version != FSCRYPT_CONTEXT_V1) {
> +		memcpy(ctx.key_hash, ci->ci_master_key->mk_hash,
> +		       FSCRYPT_KEY_HASH_SIZE);
> +	}
>  
>  	BUILD_BUG_ON(sizeof(ctx) != FSCRYPT_SET_CONTEXT_MAX_SIZE);
>  	res = parent->i_sb->s_cop->set_context(child, &ctx,
> -- 
> 2.13.2.932.g7449e964c-goog
> 
