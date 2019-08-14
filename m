Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Wed, 14 Aug 2019 15:35:43 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190814223542.GE101319@gmail.com>
References: <20190805162521.90882-1-ebiggers@kernel.org>
 <20190805162521.90882-11-ebiggers@kernel.org>
 <20190813000644.GH28705@mit.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190813000644.GH28705@mit.edu>
Subject: Re: [f2fs-dev] [PATCH v8 10/20] fscrypt: add
 FS_IOC_REMOVE_ENCRYPTION_KEY ioctl
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
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Satya Tangirala <satyat@google.com>, linux-api@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, keyrings@vger.kernel.org, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 12, 2019 at 08:06:44PM -0400, Theodore Y. Ts'o wrote:
> > +		/* Some inodes still reference this key; try to evict them. */
> > +		if (try_to_lock_encrypted_files(sb, mk) != 0)
> > +			status_flags |=
> > +				FSCRYPT_KEY_REMOVAL_STATUS_FLAG_FILES_BUSY;
> > +	}
> 
> try_to_lock_encrypted_files() can return other errors besides -EBUSY;
> in particular sync_filesystem() can return other errors, such as -EIO
> or -EFSCORUPTED.  In that case, I think we're better off returning the
> relevant status code back to the user.  We will have already wiped the
> master key, but this situation will only happen in exceptional
> conditions (e.g., user has ejected the sdcard, etc.), so it's not
> worth it to try to undo the master key wipe to try to restore things
> to the pre-ioctl execution state.
> 
> So I think we should capture the return code from
> try_to_lock_encrypted_files, and if it is EBUSY, we can set FILES_BUSY
> flag and return success.  Otherwise, we should return the error.
> 
> If you agree, please fix that up and then feel free to add:
> 
> Reviewed-by: Theodore Ts'o <tytso@mit.edu>
> 
> 						- Ted

Yes, that makes sense.  I've made the following change to this patch:

diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index 9901593051424b..c3423f0edc7014 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -479,6 +479,7 @@ int fscrypt_ioctl_remove_key(struct file *filp, void __user *_uarg)
 	struct key *key;
 	struct fscrypt_master_key *mk;
 	u32 status_flags = 0;
+	int err;
 	bool dead;
 
 	if (copy_from_user(&arg, uarg, sizeof(arg)))
@@ -514,11 +515,15 @@ int fscrypt_ioctl_remove_key(struct file *filp, void __user *_uarg)
 		 * key object is free to be removed from the keyring.
 		 */
 		key_invalidate(key);
+		err = 0;
 	} else {
 		/* Some inodes still reference this key; try to evict them. */
-		if (try_to_lock_encrypted_files(sb, mk) != 0)
+		err = try_to_lock_encrypted_files(sb, mk);
+		if (err == -EBUSY) {
 			status_flags |=
 				FSCRYPT_KEY_REMOVAL_STATUS_FLAG_FILES_BUSY;
+			err = 0;
+		}
 	}
 	/*
 	 * We return 0 if we successfully did something: wiped the secret, or
@@ -527,7 +532,9 @@ int fscrypt_ioctl_remove_key(struct file *filp, void __user *_uarg)
 	 * including all files locked.
 	 */
 	key_put(key);
-	return put_user(status_flags, &uarg->removal_status_flags);
+	if (err == 0)
+		err = put_user(status_flags, &uarg->removal_status_flags);
+	return err;
 }
 EXPORT_SYMBOL_GPL(fscrypt_ioctl_remove_key);
 


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
