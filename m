Return-Path: <ebiggers3@gmail.com>
Date: Mon, 29 Jan 2018 10:19:35 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v3] fscrypt: add support for the encrypted key type
Message-ID: <20180129181935.qaec5n7w6jsk6gso@gmail.com>
References: <20180118131359.8365-1-git@andred.net>
 <20180126003748.f2uhgwhulcltyok6@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180126003748.f2uhgwhulcltyok6@gmail.com>
To: =?iso-8859-1?Q?Andr=E9?= Draszik <git@andred.net>
Cc: linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Kees Cook <keescook@chromium.org>, Eric Biggers <ebiggers@google.com>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jan 25, 2018 at 04:37:48PM -0800, Eric Biggers wrote:
> On Thu, Jan 18, 2018 at 01:13:59PM +0000, Andr� Draszik wrote:
> > -static int validate_user_key(struct fscrypt_info *crypt_info,
> > +static inline struct key *fscrypt_get_encrypted_key(const char *description)
> > +{
> > +	if (IS_ENABLED(CONFIG_ENCRYPTED_KEYS))
> > +		return request_key(&key_type_encrypted, description, NULL);
> > +	return ERR_PTR(-ENOKEY);
> > +}
> > +
> > +static int validate_keyring_key(struct fscrypt_info *crypt_info,
> >  			struct fscrypt_context *ctx, u8 *raw_key,
> >  			const char *prefix, int min_keysize)
> >  {
> >  	char *description;
> >  	struct key *keyring_key;
> > -	struct fscrypt_key *master_key;
> > -	const struct user_key_payload *ukp;
> > +	const u8 *master_key;
> > +	u32 master_key_len;
> >  	int res;
> >  
> >  	description = kasprintf(GFP_NOFS, "%s%*phN", prefix,
> > @@ -83,39 +93,55 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
> >  		return -ENOMEM;
> >  
> >  	keyring_key = request_key(&key_type_logon, description, NULL);
> > +	if (keyring_key == ERR_PTR(-ENOKEY))
> > +		keyring_key = fscrypt_get_encrypted_key(description);
> >  	kfree(description);
> >  	if (IS_ERR(keyring_key))
> >  		return PTR_ERR(keyring_key);
> >  	down_read(&keyring_key->sem);
> >  
> > -	if (keyring_key->type != &key_type_logon) {
> > +	if (keyring_key->type == &key_type_logon) {
> > +		const struct user_key_payload *ukp;
> > +		const struct fscrypt_key *fk;
> > +
> > +		ukp = user_key_payload_locked(keyring_key);
> > +		if (!ukp) {
> > +			/* key was revoked before we acquired its semaphore */
> > +			res = -EKEYREVOKED;
> > +			goto out;
> > +		}
> > +		if (ukp->datalen != sizeof(struct fscrypt_key)) {
> > +			res = -EINVAL;
> > +			goto out;
> > +		}
> > +		fk = (struct fscrypt_key *)ukp->data;
> > +		master_key = fk->raw;
> > +		master_key_len = fk->size;
> > +	} else if (keyring_key->type == &key_type_encrypted) {
> > +		const struct encrypted_key_payload *ekp;
> > +
> > +		ekp = keyring_key->payload.data[0];
> > +		master_key = ekp->decrypted_data;
> > +		master_key_len = ekp->decrypted_datalen;
> > +	} else {
> >  		printk_once(KERN_WARNING
> > -				"%s: key type must be logon\n", __func__);
> > +				"%s: key type must be logon or encrypted\n",
> > +				__func__);
> >  		res = -ENOKEY;
> >  		goto out;
> >  	}
> > -	ukp = user_key_payload_locked(keyring_key);
> > -	if (!ukp) {
> > -		/* key was revoked before we acquired its semaphore */
> > -		res = -EKEYREVOKED;
> > -		goto out;
> > -	}
> > -	if (ukp->datalen != sizeof(struct fscrypt_key)) {
> > -		res = -EINVAL;
> > -		goto out;
> > -	}
> > -	master_key = (struct fscrypt_key *)ukp->data;
> >  	BUILD_BUG_ON(FS_AES_128_ECB_KEY_SIZE != FS_KEY_DERIVATION_NONCE_SIZE);
> >  
> > -	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
> > -	    || master_key->size % AES_BLOCK_SIZE != 0) {
> > +	if (master_key_len < min_keysize || master_key_len > FS_MAX_KEY_SIZE
> > +	    || master_key_len % AES_BLOCK_SIZE != 0) {
> >  		printk_once(KERN_WARNING
> > -				"%s: key size incorrect: %d\n",
> > -				__func__, master_key->size);
> > +				"%s: key size incorrect: %u\n",
> > +				__func__, master_key_len);
> >  		res = -ENOKEY;
> >  		goto out;
> >  	}
> 
> The code changes here look fine, but unfortunately there is a lock ordering
> problem exposed by using a key type that implements the key_type ->read()
> method.  The problem is that encrypted_read() can take a page fault during
> copy_to_user() while holding the key semaphore, which then (with ext4) can
> trigger the start of a jbd2 transaction.  Meanwhile
> fscrypt_get_encryption_info() can be called from within a jbd2 transaction via
> fscrypt_inherit_context(), which results in a different locking order.  We
> probably will need to fix this by removing the call to
> fscrypt_get_encryption_info() from fscrypt_inherit_context().
> 

Actually, a better idea might be to access the key payload under rcu_read_lock()
rather than the key semaphore.  It looks like that's possible with both the
"logon" and "encrypted" key types.

Note that derive_key_aes() can sleep, so the part under the rcu_read_lock()
would have to just copy the payload to a temporary buffer, and derive_key_aes()
would be done after rcu_read_unlock(), using the temporary buffer.  But I think
you can just reuse the 'raw_key' buffer, so that the encryption operation in
derive_key_aes() is done in-place.

Eric
