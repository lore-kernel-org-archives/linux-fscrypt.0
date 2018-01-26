Return-Path: <ebiggers3@gmail.com>
Date: Thu, 25 Jan 2018 16:37:48 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v3] fscrypt: add support for the encrypted key type
Message-ID: <20180126003748.f2uhgwhulcltyok6@gmail.com>
References: <20180118131359.8365-1-git@andred.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180118131359.8365-1-git@andred.net>
To: =?iso-8859-1?Q?Andr=E9?= Draszik <git@andred.net>
Cc: linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Kees Cook <keescook@chromium.org>, Eric Biggers <ebiggers@google.com>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jan 18, 2018 at 01:13:59PM +0000, Andr� Draszik wrote:
> -static int validate_user_key(struct fscrypt_info *crypt_info,
> +static inline struct key *fscrypt_get_encrypted_key(const char *description)
> +{
> +	if (IS_ENABLED(CONFIG_ENCRYPTED_KEYS))
> +		return request_key(&key_type_encrypted, description, NULL);
> +	return ERR_PTR(-ENOKEY);
> +}
> +
> +static int validate_keyring_key(struct fscrypt_info *crypt_info,
>  			struct fscrypt_context *ctx, u8 *raw_key,
>  			const char *prefix, int min_keysize)
>  {
>  	char *description;
>  	struct key *keyring_key;
> -	struct fscrypt_key *master_key;
> -	const struct user_key_payload *ukp;
> +	const u8 *master_key;
> +	u32 master_key_len;
>  	int res;
>  
>  	description = kasprintf(GFP_NOFS, "%s%*phN", prefix,
> @@ -83,39 +93,55 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
>  		return -ENOMEM;
>  
>  	keyring_key = request_key(&key_type_logon, description, NULL);
> +	if (keyring_key == ERR_PTR(-ENOKEY))
> +		keyring_key = fscrypt_get_encrypted_key(description);
>  	kfree(description);
>  	if (IS_ERR(keyring_key))
>  		return PTR_ERR(keyring_key);
>  	down_read(&keyring_key->sem);
>  
> -	if (keyring_key->type != &key_type_logon) {
> +	if (keyring_key->type == &key_type_logon) {
> +		const struct user_key_payload *ukp;
> +		const struct fscrypt_key *fk;
> +
> +		ukp = user_key_payload_locked(keyring_key);
> +		if (!ukp) {
> +			/* key was revoked before we acquired its semaphore */
> +			res = -EKEYREVOKED;
> +			goto out;
> +		}
> +		if (ukp->datalen != sizeof(struct fscrypt_key)) {
> +			res = -EINVAL;
> +			goto out;
> +		}
> +		fk = (struct fscrypt_key *)ukp->data;
> +		master_key = fk->raw;
> +		master_key_len = fk->size;
> +	} else if (keyring_key->type == &key_type_encrypted) {
> +		const struct encrypted_key_payload *ekp;
> +
> +		ekp = keyring_key->payload.data[0];
> +		master_key = ekp->decrypted_data;
> +		master_key_len = ekp->decrypted_datalen;
> +	} else {
>  		printk_once(KERN_WARNING
> -				"%s: key type must be logon\n", __func__);
> +				"%s: key type must be logon or encrypted\n",
> +				__func__);
>  		res = -ENOKEY;
>  		goto out;
>  	}
> -	ukp = user_key_payload_locked(keyring_key);
> -	if (!ukp) {
> -		/* key was revoked before we acquired its semaphore */
> -		res = -EKEYREVOKED;
> -		goto out;
> -	}
> -	if (ukp->datalen != sizeof(struct fscrypt_key)) {
> -		res = -EINVAL;
> -		goto out;
> -	}
> -	master_key = (struct fscrypt_key *)ukp->data;
>  	BUILD_BUG_ON(FS_AES_128_ECB_KEY_SIZE != FS_KEY_DERIVATION_NONCE_SIZE);
>  
> -	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
> -	    || master_key->size % AES_BLOCK_SIZE != 0) {
> +	if (master_key_len < min_keysize || master_key_len > FS_MAX_KEY_SIZE
> +	    || master_key_len % AES_BLOCK_SIZE != 0) {
>  		printk_once(KERN_WARNING
> -				"%s: key size incorrect: %d\n",
> -				__func__, master_key->size);
> +				"%s: key size incorrect: %u\n",
> +				__func__, master_key_len);
>  		res = -ENOKEY;
>  		goto out;
>  	}
> -	res = derive_key_aes(ctx->nonce, master_key, raw_key);
> +	res = derive_key_aes(ctx->nonce, master_key, master_key_len, raw_key);
> +
>  out:
>  	up_read(&keyring_key->sem);
>  	key_put(keyring_key);
> @@ -302,12 +328,12 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  	if (!raw_key)
>  		goto out;
>  
> -	res = validate_user_key(crypt_info, &ctx, raw_key, FS_KEY_DESC_PREFIX,
> -				keysize);
> +	res = validate_keyring_key(crypt_info, &ctx, raw_key,
> +				   FS_KEY_DESC_PREFIX, keysize);
>  	if (res && inode->i_sb->s_cop->key_prefix) {
> -		int res2 = validate_user_key(crypt_info, &ctx, raw_key,
> -					     inode->i_sb->s_cop->key_prefix,
> -					     keysize);
> +		int res2 = validate_keyring_key(crypt_info, &ctx, raw_key,
> +						inode->i_sb->s_cop->key_prefix,
> +						keysize);
>  		if (res2) {
>  			if (res2 == -ENOKEY)
>  				res = -ENOKEY;
> -- 
> 2.15.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe keyrings" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The code changes here look fine, but unfortunately there is a lock ordering
problem exposed by using a key type that implements the key_type ->read()
method.  The problem is that encrypted_read() can take a page fault during
copy_to_user() while holding the key semaphore, which then (with ext4) can
trigger the start of a jbd2 transaction.  Meanwhile
fscrypt_get_encryption_info() can be called from within a jbd2 transaction via
fscrypt_inherit_context(), which results in a different locking order.  We
probably will need to fix this by removing the call to
fscrypt_get_encryption_info() from fscrypt_inherit_context().

I've pasted the lockdep report I got below:

[  432.705339] 
[  432.705681] ======================================================
[  432.707015] WARNING: possible circular locking dependency detected
[  432.708155] 4.15.0-rc8-next-20180119-00019-gab7ec46b6936 #31 Not tainted
[  432.709365] ------------------------------------------------------
[  432.710482] keyctl/877 is trying to acquire lock:
[  432.711286]  (&mm->mmap_sem){++++}, at: [<00000000e8bba1c7>] __might_fault+0xce/0x1a0
[  432.712688] 
[  432.712688] but task is already holding lock:
[  432.713684]  (&type->lock_class#2){++++}, at: [<000000008ccfa156>] keyctl_read_key+0x174/0x240
[  432.715176] 
[  432.715176] which lock already depends on the new lock.
[  432.715176] 
[  432.716601] 
[  432.716601] the existing dependency chain (in reverse order) is:
[  432.717901] 
[  432.717901] -> #3 (&type->lock_class#2){++++}:
[  432.718924]        lock_acquire+0xaa/0x170
[  432.719632]        down_read+0x37/0xa0
[  432.720298]        validate_keyring_key.isra.1+0x97/0x410
[  432.721218]        fscrypt_get_encryption_info+0x724/0x1200
[  432.722233]        fscrypt_inherit_context+0x2c1/0x330
[  432.723067]        __ext4_new_inode+0x34f5/0x44d0
[  432.723830]        ext4_create+0x195/0x4a0
[  432.724499]        lookup_open+0xbe2/0x1400
[  432.725185]        path_openat+0xb31/0x1e50
[  432.725876]        do_filp_open+0x175/0x250
[  432.726572]        do_sys_open+0x219/0x3f0
[  432.727312]        entry_SYSCALL_64_fastpath+0x1e/0x8b
[  432.728153] 
[  432.728153] -> #2 (jbd2_handle){.+.+}:
[  432.729008]        lock_acquire+0xaa/0x170
[  432.729680]        start_this_handle+0x47b/0x1020
[  432.730463]        jbd2__journal_start+0x32e/0x5c0
[  432.731276]        __ext4_journal_start_sb+0xa8/0x190
[  432.732183]        ext4_truncate+0x4dd/0xd00
[  432.732868]        ext4_setattr+0xa62/0x1ac0
[  432.733528]        notify_change+0x672/0xdb0
[  432.734198]        do_truncate+0x111/0x1c0
[  432.734831]        path_openat+0xee6/0x1e50
[  432.735476]        do_filp_open+0x175/0x250
[  432.736149]        do_sys_open+0x219/0x3f0
[  432.736785]        entry_SYSCALL_64_fastpath+0x1e/0x8b
[  432.737576] 
[  432.737576] -> #1 (&ei->i_mmap_sem){++++}:
[  432.738508]        lock_acquire+0xaa/0x170
[  432.739148]        down_read+0x37/0xa0
[  432.739735]        ext4_filemap_fault+0x7b/0xb0
[  432.740446]        __do_fault+0x7a/0x200
[  432.741060]        __handle_mm_fault+0x6e0/0x2040
[  432.741801]        handle_mm_fault+0x194/0x320
[  432.742494]        __do_page_fault+0x4e1/0xa70
[  432.743184]        page_fault+0x2c/0x60
[  432.743784]        __clear_user+0x3d/0x60
[  432.744409]        clear_user+0x76/0xa0
[  432.745009]        load_elf_binary+0x2bf6/0x2f10
[  432.745753]        search_binary_handler+0x136/0x450
[  432.746522]        do_execveat_common.isra.12+0x1241/0x19c0
[  432.747339]        do_execve+0x2c/0x40
[  432.747881]        try_to_run_init_process+0x12/0x40
[  432.748611]        kernel_init+0xf2/0x180
[  432.749190]        ret_from_fork+0x3a/0x50
[  432.749785] 
[  432.749785] -> #0 (&mm->mmap_sem){++++}:
[  432.750576]        __lock_acquire+0x8d1/0x12d0
[  432.751232]        lock_acquire+0xaa/0x170
[  432.751848]        __might_fault+0x12b/0x1a0
[  432.752478]        _copy_to_user+0x27/0xc0
[  432.753080]        encrypted_read+0x54d/0x7b0
[  432.753734]        keyctl_read_key+0x1f2/0x240
[  432.754396]        SyS_keyctl+0x184/0x2a0
[  432.754995]        entry_SYSCALL_64_fastpath+0x1e/0x8b
[  432.755778] 
[  432.755778] other info that might help us debug this:
[  432.755778] 
[  432.756972] Chain exists of:
[  432.756972]   &mm->mmap_sem --> jbd2_handle --> &type->lock_class#2
[  432.756972] 
[  432.758498]  Possible unsafe locking scenario:
[  432.758498] 
[  432.759302]        CPU0                    CPU1
[  432.759919]        ----                    ----
[  432.760536]   lock(&type->lock_class#2);
[  432.761100]                                lock(jbd2_handle);
[  432.761926]                                lock(&type->lock_class#2);
[  432.762836]   lock(&mm->mmap_sem);
[  432.763348] 
[  432.763348]  *** DEADLOCK ***
[  432.763348] 
[  432.764209] 1 lock held by keyctl/877:
[  432.764765]  #0:  (&type->lock_class#2){++++}, at: [<000000008ccfa156>] keyctl_read_key+0x174/0x240
[  432.766045] 
[  432.766045] stack backtrace:
[  432.766671] CPU: 1 PID: 877 Comm: keyctl Not tainted 4.15.0-rc8-next-20180119-00019-gab7ec46b6936 #31
[  432.768021] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[  432.769211] Call Trace:
[  432.769559]  dump_stack+0x8d/0xd5
[  432.770041]  print_circular_bug.isra.20+0x321/0x5e0
[  432.770712]  ? save_trace+0xd6/0x250
[  432.771185]  check_prev_add.constprop.27+0xa2a/0x1670
[  432.771867]  ? depot_save_stack+0x2d5/0x490
[  432.772504]  ? check_usage+0x13c0/0x13c0
[  432.773047]  ? trace_hardirqs_on_caller+0x3dc/0x550
[  432.773712]  ? _raw_spin_unlock_irqrestore+0x39/0x60
[  432.774401]  ? depot_save_stack+0x2d5/0x490
[  432.774979]  ? kasan_kmalloc+0x13a/0x170
[  432.775522]  ? validate_chain.isra.24+0x13ee/0x2410
[  432.776187]  validate_chain.isra.24+0x13ee/0x2410
[  432.776831]  ? check_prev_add.constprop.27+0x1670/0x1670
[  432.777546]  __lock_acquire+0x8d1/0x12d0
[  432.778088]  lock_acquire+0xaa/0x170
[  432.778576]  ? __might_fault+0xce/0x1a0
[  432.779096]  __might_fault+0x12b/0x1a0
[  432.779608]  ? __might_fault+0xce/0x1a0
[  432.780029]  _copy_to_user+0x27/0xc0
[  432.780438]  encrypted_read+0x54d/0x7b0
[  432.780858]  ? key_task_permission+0x16e/0x3b0
[  432.781340]  ? encrypted_instantiate+0x8b0/0x8b0
[  432.781851]  ? creds_are_invalid+0x9/0x50
[  432.782287]  ? lookup_user_key+0x19a/0xf50
[  432.782736]  ? __lock_acquire+0x8d1/0x12d0
[  432.783182]  ? key_validate+0xb0/0xb0
[  432.783602]  ? keyctl_read_key+0x174/0x240
[  432.784058]  keyctl_read_key+0x1f2/0x240
[  432.784486]  SyS_keyctl+0x184/0x2a0
[  432.784875]  entry_SYSCALL_64_fastpath+0x1e/0x8b
[  432.785374] RIP: 0033:0x7f812b6c8259
