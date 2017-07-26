Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 6/7] fscrypt: cache the HMAC transform for each master key
Date: Wed, 26 Jul 2017 11:19:28 -0700
Message-Id: <20170726181929.99880-7-ebiggers3@gmail.com>
In-Reply-To: <20170726181929.99880-1-ebiggers3@gmail.com>
References: <20170726181929.99880-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Now that we have a key_hash field which securely identifies a master key
payload, introduce a cache of the HMAC transforms for the master keys
currently in use for inodes using v2+ encryption policies.  The entries
in this cache are called 'struct fscrypt_master_key' and are identified
by key_hash.  The cache is per-superblock.  (It could be global, but
making it per-superblock should reduce the lock contention a bit, and we
may need to keep track of keys on a per-superblock basis for other
reasons later, e.g. to implement an ioctl for evicting keys.)

This results in a large efficiency gain: we now only have to allocate
and key an "hmac(sha512)" transformation, execute HKDF-Extract, and
compute key_hash once per master key rather than once per inode.  Note
that this optimization can't easily be applied to the original AES-based
KDF because that uses a different AES key for each KDF execution.  In
practice, this difference makes the HKDF per-inode encryption key
derivation performance comparable to or even faster than the old KDF,
which typically spends more time allocating an "ecb(aes)" transformation
from the crypto API than doing actual crypto work.

Note that it would have been possible to make the mapping be from
raw_key => fscrypt_master_key (where raw_key denotes the actual bytes of
the master key) rather than from key_hash => fscrypt_master_key.
However, an advantage of doing lookups by key_hash is that it replaces
the keyring lookup in most cases, which opens up the future
possibilities of not even having the master key in memory following an
initial provisioning step (if the HMAC-SHA512 implementation is
hardware-backed), or of introducing an ioctl to provision a key to the
filesystem directly, avoiding keyrings and their visibility problems
entirely.  Also, because key_hash is public information while raw_key is
secret information, it would have been very difficult to use raw_key as
a map key in a way that would prevent timing attacks while still being
scalable to a large number of entries.

Reviewed-by: Michael Halcrow <mhalcrow@google.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fscrypt_private.h |  11 ++++
 fs/crypto/keyinfo.c         | 134 +++++++++++++++++++++++++++++++++++++++++++-
 fs/crypto/policy.c          |   5 +-
 fs/super.c                  |   4 ++
 include/linux/fs.h          |   5 ++
 5 files changed, 152 insertions(+), 7 deletions(-)

diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index f9469a71cc29..4221c5b23882 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -91,10 +91,21 @@ fscrypt_valid_context_format(const struct fscrypt_context *ctx, int size)
 
 /*
  * fscrypt_master_key - an in-use master key
+ *
+ * This is referenced from each in-core inode that has been "unlocked" using a
+ * particular master key.  It's primarily used to cache the HMAC transform so
+ * that the per-inode encryption keys can be derived efficiently with HKDF.  It
+ * is securely erased once all inodes referencing it have been evicted.
+ *
+ * If the same master key is used on different filesystems (unusual, but
+ * possible), we'll create one of these structs for each filesystem.
  */
 struct fscrypt_master_key {
 	struct crypto_shash	*mk_hmac;
 	u8			mk_hash[FSCRYPT_KEY_HASH_SIZE];
+	refcount_t		mk_refcount;
+	struct rb_node		mk_node;
+	struct super_block	*mk_sb;
 };
 
 /*
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index a9514078cf9d..2fca72826768 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -176,6 +176,14 @@ static void put_master_key(struct fscrypt_master_key *k)
 	if (!k)
 		return;
 
+	if (refcount_read(&k->mk_refcount) != 0) { /* in ->s_master_keys? */
+		if (!refcount_dec_and_lock(&k->mk_refcount,
+					   &k->mk_sb->s_master_keys_lock))
+			return;
+		rb_erase(&k->mk_node, &k->mk_sb->s_master_keys);
+		spin_unlock(&k->mk_sb->s_master_keys_lock);
+	}
+
 	crypto_free_shash(k->mk_hmac);
 	kzfree(k);
 }
@@ -230,6 +238,87 @@ alloc_master_key(const struct fscrypt_key *payload)
 	goto out;
 }
 
+/*
+ * ->s_master_keys is a map of master keys currently in use by in-core inodes on
+ * a given filesystem, identified by key_hash which is a cryptographically
+ * secure identifier for an actual key payload.
+ *
+ * Note that master_key_descriptor cannot be used to identify the keys because
+ * master_key_descriptor only identifies the "location" of a key in the keyring,
+ * not the actual key payload --- i.e., buggy or malicious userspace may provide
+ * different keys with the same master_key_descriptor.
+ */
+
+/*
+ * Search ->s_master_keys for the fscrypt_master_key having the specified hash.
+ * If found return it with a reference taken, otherwise return NULL.
+ */
+static struct fscrypt_master_key *
+get_cached_master_key(struct super_block *sb,
+		      const u8 hash[FSCRYPT_KEY_HASH_SIZE])
+{
+	struct rb_node *node;
+	struct fscrypt_master_key *k;
+	int res;
+
+	spin_lock(&sb->s_master_keys_lock);
+	node = sb->s_master_keys.rb_node;
+	while (node) {
+		k = rb_entry(node, struct fscrypt_master_key, mk_node);
+		res = memcmp(hash, k->mk_hash, FSCRYPT_KEY_HASH_SIZE);
+		if (res < 0)
+			node = node->rb_left;
+		else if (res > 0)
+			node = node->rb_right;
+		else {
+			refcount_inc(&k->mk_refcount);
+			goto out;
+		}
+	}
+	k = NULL;
+out:
+	spin_unlock(&sb->s_master_keys_lock);
+	return k;
+}
+
+/*
+ * Try to insert the specified fscrypt_master_key into ->s_master_keys.  If it
+ * already exists, then drop the key being inserted and take a reference to the
+ * existing one instead.
+ */
+static struct fscrypt_master_key *
+insert_master_key(struct super_block *sb, struct fscrypt_master_key *new)
+{
+	struct fscrypt_master_key *k;
+	struct rb_node *parent = NULL, **p;
+	int res;
+
+	spin_lock(&sb->s_master_keys_lock);
+	p = &sb->s_master_keys.rb_node;
+	while (*p) {
+		parent = *p;
+		k = rb_entry(parent, struct fscrypt_master_key, mk_node);
+		res = memcmp(new->mk_hash, k->mk_hash, FSCRYPT_KEY_HASH_SIZE);
+		if (res < 0)
+			p = &parent->rb_left;
+		else if (res > 0)
+			p = &parent->rb_right;
+		else {
+			refcount_inc(&k->mk_refcount);
+			spin_unlock(&sb->s_master_keys_lock);
+			put_master_key(new);
+			return k;
+		}
+	}
+
+	rb_link_node(&new->mk_node, parent, p);
+	rb_insert_color(&new->mk_node, &sb->s_master_keys);
+	refcount_set(&new->mk_refcount, 1);
+	new->mk_sb = sb;
+	spin_unlock(&sb->s_master_keys_lock);
+	return new;
+}
+
 static void release_keyring_key(struct key *keyring_key)
 {
 	up_read(&keyring_key->sem);
@@ -320,6 +409,47 @@ load_master_key_from_keyring(const struct inode *inode,
 	return master_key;
 }
 
+/*
+ * Get the fscrypt_master_key identified by the specified v2+ encryption
+ * context, or create it if not found.
+ *
+ * Returns the fscrypt_master_key with a reference taken, or an ERR_PTR().
+ */
+static struct fscrypt_master_key *
+find_or_create_master_key(const struct inode *inode,
+			  const struct fscrypt_context *ctx,
+			  unsigned int min_keysize)
+{
+	struct fscrypt_master_key *master_key;
+
+	if (WARN_ON(ctx->version < FSCRYPT_CONTEXT_V2))
+		return ERR_PTR(-EINVAL);
+
+	/*
+	 * First try looking up the master key by its cryptographically secure
+	 * key_hash.  If it's already in memory, there's no need to do a keyring
+	 * search.  (Note that we don't enforce access control based on which
+	 * processes "have the key" and which don't, as encryption is meant to
+	 * be orthogonal to operating-system level access control.  Hence, it's
+	 * sufficient for anyone on the system to have added the needed key.)
+	 */
+	master_key = get_cached_master_key(inode->i_sb, ctx->key_hash);
+	if (master_key)
+		return master_key;
+
+	/*
+	 * The needed master key isn't in memory yet.  Load it from the keyring.
+	 */
+	master_key = load_master_key_from_keyring(inode,
+						  ctx->master_key_descriptor,
+						  min_keysize);
+	if (IS_ERR(master_key))
+		return master_key;
+
+	/* Cache the key for later */
+	return insert_master_key(inode->i_sb, master_key);
+}
+
 static void derive_crypt_complete(struct crypto_async_request *req, int rc)
 {
 	struct fscrypt_completion_result *ecr = req->data;
@@ -637,9 +767,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 					     derived_keysize);
 	} else {
 		crypt_info->ci_master_key =
-			load_master_key_from_keyring(inode,
-						     ctx.master_key_descriptor,
-						     derived_keysize);
+			find_or_create_master_key(inode, &ctx, derived_keysize);
 		if (IS_ERR(crypt_info->ci_master_key)) {
 			res = PTR_ERR(crypt_info->ci_master_key);
 			crypt_info->ci_master_key = NULL;
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index c0a047559736..ece55350cee8 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -261,10 +261,7 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
 			(parent_ci->ci_filename_mode ==
 			 child_ci->ci_filename_mode) &&
 			(parent_ci->ci_flags == child_ci->ci_flags) &&
-			(parent_ci->ci_context_version == FSCRYPT_CONTEXT_V1 ||
-			 (memcmp(parent_ci->ci_master_key->mk_hash,
-				 child_ci->ci_master_key->mk_hash,
-				 FSCRYPT_KEY_HASH_SIZE) == 0));
+			(parent_ci->ci_master_key == child_ci->ci_master_key);
 	}
 
 	res = cops->get_context(parent, &parent_ctx, sizeof(parent_ctx));
diff --git a/fs/super.c b/fs/super.c
index 6bc3352adcf3..de9be131b5ee 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -214,6 +214,10 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	spin_lock_init(&s->s_inode_list_lock);
 	INIT_LIST_HEAD(&s->s_inodes_wb);
 	spin_lock_init(&s->s_inode_wblist_lock);
+#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
+	s->s_master_keys = RB_ROOT;
+	spin_lock_init(&s->s_master_keys_lock);
+#endif
 
 	if (list_lru_init_memcg(&s->s_dentry_lru))
 		goto fail;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6e1fd5d21248..e6e494e6ef10 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1413,6 +1413,11 @@ struct super_block {
 
 	spinlock_t		s_inode_wblist_lock;
 	struct list_head	s_inodes_wb;	/* writeback inodes */
+
+#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
+	spinlock_t		s_master_keys_lock;
+	struct rb_root		s_master_keys;	/* master crypto keys in use */
+#endif
 } __randomize_layout;
 
 /* Helper functions so that in most cases filesystems will
-- 
2.14.0.rc0.400.g1c36432dff-goog
