Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AC981A6820;
	Sat, 15 Aug 2026 18:31:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786818674; cv=none; b=MVCF+41gOSq9b+MKO/umA/CRqoeplV3cCzymC62VXbNItFtWCwNv3nHic3sN+4UsT3XYy+I85nSqLizc0PrbEUZmVqUtBNw/pP/OiudKvoHG2CIUb3XNQGNDGkFJ8doWorhJCCMYzs32bdyiwPxJZOKah5N4GFENNELCRusoW8w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786818674; c=relaxed/simple;
	bh=wsImOMeIighCx5MVYwoD26poss2Q4Zj9u5G0yR8awA0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=b8P6E7TpckMDxjEVyGjbDQ7VZoYxlDPsQDrPCSWw/EDGkXcTg8jskKDpPt7x9uP5VzImC4stnM2qjOxnZ7vKpMJzXmvq4zQZuJxKpo9BLumxusBACTtaloRnYQP/PRmXE20F5WaIMrj2SgB05Aqq4VtcXO7HTp54oSfDXQ8Ww0A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SzCP7yJa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SzCP7yJa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E465A1F000E9;
	Sat, 15 Aug 2026 18:31:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786818672;
	bh=yss4NKTcidIsJLxylzz8PPnXCt/m0PDvpVMO4RaufRA=;
	h=From:To:Cc:Subject:Date;
	b=SzCP7yJa0bihJco5GZbEv4kw4Z/ggT7qhFy485A9MTS+ft2MaGTKhvbsqM3NvZM0x
	 xjsk1fTVULB5R0i2jcyQrLhueCSpIErNoRkbqhJQzNdYHYsE+l6OwXOPXUnVc+ALrP
	 22UTfYT9vUSA/klW28cGOWH40QXS/HszgnBkXu4+sJf/vIJt3sjT5UyRrzy6uYkRbx
	 oseEC/G0LmYU3xMycGvHxYD9JR3/Cu8kjF6fpya09Pgb0R3x1p/sfKdqq6FpaTAM92
	 Zu5N3D+rP5GxbSpTKna5t5q9qygEKLm4zW+nlO3Gsfucn15k8n1dLkuwHA+znFbGfy
	 koalpRo3CQWjw==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com,
	Mohammed EL Kadiri <med08elkadiri@gmail.com>
Subject: [PATCH 6.1] fscrypt: Replace mk_users keyring with simple list
Date: Sat, 15 Aug 2026 11:30:57 -0700
Message-ID: <20260815183057.101594-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

commit 696c030e1e3438955aba443b308ee8b6faa3983e upstream.

Change mk_users (the set of user claims to an fscrypt master key) from a
'struct key' keyring to a simple linked list.

It's still a collection of 'struct key' for quota tracking.  It was
originally thought to be natural that a collection of 'struct key'
should be held in a 'struct key' keyring.  In reality, it's just been
causing problems, similar to how using 'struct key' for the filesystem
keyring caused problems and was removed in commit d7e7b9af104c
("fscrypt: stop using keyrings subsystem for fscrypt_master_key").

Commit d3a7bd420076 ("fscrypt: clear keyring before calling key_put()")
fixed mk_users cleanup to be synchronous.  But that apparently wasn't
enough: the keyring subsystem's redundant locking is still generating
lockdep false positives due to the interaction with filesystem reclaim.

With the simple list, the redundant locking and lockdep issue goes away.

Of course, searching a linked list is linear-time whereas the
'struct key' keyring used a fancy constant-time associative array.  But
that's fine here, since in practice there's just one entry in the list.
In fact the new code is much faster in practice, since it's much smaller
and doesn't have to convert the kuid_t into a string to search for it.

Reported-by: syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=f55b043dacf43776b50c
Reported-by: Mohammed EL Kadiri <med08elkadiri@gmail.com>
Closes: https://lore.kernel.org/keyrings/20260614150041.21172-1-med08elkadiri@gmail.com/
Fixes: 23c688b54016 ("fscrypt: allow unprivileged users to add/remove keys for v2 policies")
Cc: stable@vger.kernel.org
Link: https://patch.msgid.link/20260618221921.87896-1-ebiggers@kernel.org
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/fscrypt_private.h |  32 ++++--
 fs/crypto/keyring.c         | 212 ++++++++++++++++--------------------
 2 files changed, 113 insertions(+), 131 deletions(-)

diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 88414cbd97ae..aabc3a4751df 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -423,6 +423,19 @@ fscrypt_is_key_prepared(struct fscrypt_prepared_key *prep_key,
 
 /* keyring.c */
 
+/*
+ * fscrypt_master_key_user - a user's claim to a master key
+ */
+struct fscrypt_master_key_user {
+	struct list_head link;
+	kuid_t uid;
+	/*
+	 * This 'struct key' contains no secret.  It exists solely to charge the
+	 * appropriate user's key quota.
+	 */
+	struct key *quota_key;
+};
+
 /*
  * fscrypt_master_key_secret - secret key material of an in-use master key
  */
@@ -513,19 +526,18 @@ struct fscrypt_master_key {
 	struct fscrypt_key_specifier		mk_spec;
 
 	/*
-	 * Keyring which contains a key of type 'key_type_fscrypt_user' for each
-	 * user who has added this key.  Normally each key will be added by just
-	 * one user, but it's possible that multiple users share a key, and in
-	 * that case we need to keep track of those users so that one user can't
-	 * remove the key before the others want it removed too.
+	 * List of user claims to this key (struct fscrypt_master_key_user).
+	 * Normally each key will be added by just one user, but it's possible
+	 * that multiple users share a key, and in that case we need to keep
+	 * track of those users so that one user can't remove the key before the
+	 * others want it removed too.
 	 *
-	 * This is NULL for v1 policy keys; those can only be added by root.
+	 * Used only for v2 policy keys.  v1 policy keys can be added only by
+	 * root, so user tracking doesn't apply to them.
 	 *
-	 * Locking: protected by ->mk_sem.  (We don't just rely on the keyrings
-	 * subsystem semaphore ->mk_users->sem, as we need support for atomic
-	 * search+insert along with proper synchronization with ->mk_secret.)
+	 * Locking: protected by ->mk_sem.
 	 */
-	struct key		*mk_users;
+	struct list_head	mk_users;
 
 	/*
 	 * List of inodes that were unlocked using this key.  This allows the
diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index 2a24b1f0ae68..e1cce06f4343 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -64,18 +64,19 @@ static void fscrypt_free_master_key(struct rcu_head *head)
 	kfree_sensitive(mk);
 }
 
+static void clear_mk_users(struct fscrypt_master_key *mk);
+
 void fscrypt_put_master_key(struct fscrypt_master_key *mk)
 {
 	if (!refcount_dec_and_test(&mk->mk_struct_refs))
 		return;
 	/*
-	 * No structural references left, so free ->mk_users, and also free the
+	 * No structural references left, so clear ->mk_users, and also free the
 	 * fscrypt_master_key struct itself after an RCU grace period ensures
 	 * that concurrent keyring lookups can no longer find it.
 	 */
 	WARN_ON(refcount_read(&mk->mk_active_refs) != 0);
-	key_put(mk->mk_users);
-	mk->mk_users = NULL;
+	clear_mk_users(mk);
 	call_rcu(&mk->mk_rcu_head, fscrypt_free_master_key);
 }
 
@@ -144,8 +145,8 @@ static void fscrypt_user_key_describe(const struct key *key, struct seq_file *m)
 }
 
 /*
- * Type of key in ->mk_users.  Each key of this type represents a particular
- * user who has added a particular master key.
+ * Type of fscrypt_master_key_user::quota_key.  This contains no secret; it
+ * exists solely to charge a user's key quota.
  *
  * Note that the name of this key type really should be something like
  * ".fscrypt-user" instead of simply ".fscrypt".  But the shorter name is chosen
@@ -159,30 +160,9 @@ static struct key_type key_type_fscrypt_user = {
 	.describe		= fscrypt_user_key_describe,
 };
 
-#define FSCRYPT_MK_USERS_DESCRIPTION_SIZE	\
-	(CONST_STRLEN("fscrypt-") + 2 * FSCRYPT_KEY_IDENTIFIER_SIZE + \
-	 CONST_STRLEN("-users") + 1)
-
 #define FSCRYPT_MK_USER_DESCRIPTION_SIZE	\
 	(2 * FSCRYPT_KEY_IDENTIFIER_SIZE + CONST_STRLEN(".uid.") + 10 + 1)
 
-static void format_mk_users_keyring_description(
-			char description[FSCRYPT_MK_USERS_DESCRIPTION_SIZE],
-			const u8 mk_identifier[FSCRYPT_KEY_IDENTIFIER_SIZE])
-{
-	sprintf(description, "fscrypt-%*phN-users",
-		FSCRYPT_KEY_IDENTIFIER_SIZE, mk_identifier);
-}
-
-static void format_mk_user_description(
-			char description[FSCRYPT_MK_USER_DESCRIPTION_SIZE],
-			const u8 mk_identifier[FSCRYPT_KEY_IDENTIFIER_SIZE])
-{
-
-	sprintf(description, "%*phN.uid.%u", FSCRYPT_KEY_IDENTIFIER_SIZE,
-		mk_identifier, __kuid_val(current_fsuid()));
-}
-
 /* Create ->s_master_keys if needed.  Synchronized by fscrypt_add_key_mutex. */
 static int allocate_filesystem_keyring(struct super_block *sb)
 {
@@ -321,91 +301,94 @@ fscrypt_find_master_key(struct super_block *sb,
 	return mk;
 }
 
-static int allocate_master_key_users_keyring(struct fscrypt_master_key *mk)
+/* Find the current user's claim in ->mk_users.  ->mk_sem must be held. */
+static struct fscrypt_master_key_user *
+find_master_key_user(struct fscrypt_master_key *mk)
 {
-	char description[FSCRYPT_MK_USERS_DESCRIPTION_SIZE];
-	struct key *keyring;
-
-	format_mk_users_keyring_description(description,
-					    mk->mk_spec.u.identifier);
-	keyring = keyring_alloc(description, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
-				current_cred(), KEY_POS_SEARCH |
-				  KEY_USR_SEARCH | KEY_USR_READ | KEY_USR_VIEW,
-				KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
-	if (IS_ERR(keyring))
-		return PTR_ERR(keyring);
-
-	mk->mk_users = keyring;
-	return 0;
-}
+	struct fscrypt_master_key_user *mk_user;
+	kuid_t uid = current_fsuid();
 
-/*
- * Find the current user's "key" in the master key's ->mk_users.
- * Returns ERR_PTR(-ENOKEY) if not found.
- */
-static struct key *find_master_key_user(struct fscrypt_master_key *mk)
-{
-	char description[FSCRYPT_MK_USER_DESCRIPTION_SIZE];
-	key_ref_t keyref;
-
-	format_mk_user_description(description, mk->mk_spec.u.identifier);
-
-	/*
-	 * We need to mark the keyring reference as "possessed" so that we
-	 * acquire permission to search it, via the KEY_POS_SEARCH permission.
-	 */
-	keyref = keyring_search(make_key_ref(mk->mk_users, true /*possessed*/),
-				&key_type_fscrypt_user, description, false);
-	if (IS_ERR(keyref)) {
-		if (PTR_ERR(keyref) == -EAGAIN || /* not found */
-		    PTR_ERR(keyref) == -EKEYREVOKED) /* recently invalidated */
-			keyref = ERR_PTR(-ENOKEY);
-		return ERR_CAST(keyref);
+	list_for_each_entry(mk_user, &mk->mk_users, link) {
+		if (uid_eq(mk_user->uid, uid))
+			return mk_user;
 	}
-	return key_ref_to_ptr(keyref);
+	return NULL;
 }
 
 /*
- * Give the current user a "key" in ->mk_users.  This charges the user's quota
+ * Give the current user a claim in ->mk_users.  This charges the user's quota
  * and marks the master key as added by the current user, so that it cannot be
  * removed by another user with the key.  Either ->mk_sem must be held for
  * write, or the master key must be still undergoing initialization.
  */
 static int add_master_key_user(struct fscrypt_master_key *mk)
 {
+	kuid_t uid = current_fsuid();
 	char description[FSCRYPT_MK_USER_DESCRIPTION_SIZE];
-	struct key *mk_user;
+	struct key *quota_key;
+	struct fscrypt_master_key_user *mk_user;
 	int err;
 
-	format_mk_user_description(description, mk->mk_spec.u.identifier);
-	mk_user = key_alloc(&key_type_fscrypt_user, description,
-			    current_fsuid(), current_gid(), current_cred(),
-			    KEY_POS_SEARCH | KEY_USR_VIEW, 0, NULL);
-	if (IS_ERR(mk_user))
-		return PTR_ERR(mk_user);
+	snprintf(description, sizeof(description), "%*phN.uid.%u",
+		 FSCRYPT_KEY_IDENTIFIER_SIZE, mk->mk_spec.u.identifier,
+		 __kuid_val(uid));
+	quota_key = key_alloc(&key_type_fscrypt_user, description, uid,
+			      current_gid(), current_cred(),
+			      KEY_POS_SEARCH | KEY_USR_VIEW, 0, NULL);
+	if (IS_ERR(quota_key))
+		return PTR_ERR(quota_key);
+
+	err = key_instantiate_and_link(quota_key, NULL, 0, NULL, NULL);
+	if (err) {
+		key_put(quota_key);
+		return err;
+	}
 
-	err = key_instantiate_and_link(mk_user, NULL, 0, mk->mk_users, NULL);
-	key_put(mk_user);
-	return err;
+	mk_user = kzalloc(sizeof(*mk_user), GFP_KERNEL);
+	if (!mk_user) {
+		key_put(quota_key);
+		return -ENOMEM;
+	}
+	mk_user->uid = uid;
+	mk_user->quota_key = quota_key;
+	list_add(&mk_user->link, &mk->mk_users);
+	return 0;
+}
+
+static void unlink_and_free_mk_user(struct fscrypt_master_key_user *mk_user)
+{
+	list_del(&mk_user->link);
+	key_put(mk_user->quota_key);
+	kfree(mk_user);
 }
 
 /*
- * Remove the current user's "key" from ->mk_users.
+ * Remove the current user's claim from ->mk_users.
  * ->mk_sem must be held for write.
  *
- * Returns 0 if removed, -ENOKEY if not found, or another -errno code.
+ * Returns 0 if removed or -ENOKEY if not found.
  */
 static int remove_master_key_user(struct fscrypt_master_key *mk)
 {
-	struct key *mk_user;
-	int err;
+	struct fscrypt_master_key_user *mk_user;
 
 	mk_user = find_master_key_user(mk);
-	if (IS_ERR(mk_user))
-		return PTR_ERR(mk_user);
-	err = key_unlink(mk->mk_users, mk_user);
-	key_put(mk_user);
-	return err;
+	if (!mk_user)
+		return -ENOKEY;
+	unlink_and_free_mk_user(mk_user);
+	return 0;
+}
+
+/*
+ * Clear ->mk_users.  Either ->mk_sem must be held for write, or 'mk' must have
+ * no structural references left.
+ */
+static void clear_mk_users(struct fscrypt_master_key *mk)
+{
+	struct fscrypt_master_key_user *mk_user, *tmp;
+
+	list_for_each_entry_safe(mk_user, tmp, &mk->mk_users, link)
+		unlink_and_free_mk_user(mk_user);
 }
 
 /*
@@ -429,13 +412,12 @@ static int add_new_master_key(struct super_block *sb,
 	refcount_set(&mk->mk_struct_refs, 1);
 	mk->mk_spec = *mk_spec;
 
+	INIT_LIST_HEAD(&mk->mk_users);
+
 	INIT_LIST_HEAD(&mk->mk_decrypted_inodes);
 	spin_lock_init(&mk->mk_decrypted_inodes_lock);
 
 	if (mk_spec->type == FSCRYPT_KEY_SPEC_TYPE_IDENTIFIER) {
-		err = allocate_master_key_users_keyring(mk);
-		if (err)
-			goto out_put;
 		err = add_master_key_user(mk);
 		if (err)
 			goto out_put;
@@ -463,19 +445,13 @@ static int add_existing_master_key(struct fscrypt_master_key *mk,
 	int err;
 
 	/*
-	 * If the current user is already in ->mk_users, then there's nothing to
-	 * do.  Otherwise, we need to add the user to ->mk_users.  (Neither is
-	 * applicable for v1 policy keys, which have NULL ->mk_users.)
+	 * For v2 policy keys (FSCRYPT_KEY_SPEC_TYPE_IDENTIFIER): If the current
+	 * user is already in ->mk_users, then there's nothing to do.
+	 * Otherwise, add the user to ->mk_users.
 	 */
-	if (mk->mk_users) {
-		struct key *mk_user = find_master_key_user(mk);
-
-		if (mk_user != ERR_PTR(-ENOKEY)) {
-			if (IS_ERR(mk_user))
-				return PTR_ERR(mk_user);
-			key_put(mk_user);
+	if (mk->mk_spec.type == FSCRYPT_KEY_SPEC_TYPE_IDENTIFIER) {
+		if (find_master_key_user(mk) != NULL)
 			return 0;
-		}
 		err = add_master_key_user(mk);
 		if (err)
 			return err;
@@ -830,7 +806,6 @@ int fscrypt_verify_key_added(struct super_block *sb,
 {
 	struct fscrypt_key_specifier mk_spec;
 	struct fscrypt_master_key *mk;
-	struct key *mk_user;
 	int err;
 
 	mk_spec.type = FSCRYPT_KEY_SPEC_TYPE_IDENTIFIER;
@@ -842,13 +817,10 @@ int fscrypt_verify_key_added(struct super_block *sb,
 		goto out;
 	}
 	down_read(&mk->mk_sem);
-	mk_user = find_master_key_user(mk);
-	if (IS_ERR(mk_user)) {
-		err = PTR_ERR(mk_user);
-	} else {
-		key_put(mk_user);
+	if (find_master_key_user(mk) != NULL)
 		err = 0;
-	}
+	else
+		err = -ENOKEY;
 	up_read(&mk->mk_sem);
 	fscrypt_put_master_key(mk);
 out:
@@ -1041,16 +1013,18 @@ static int do_remove_key(struct file *filp, void __user *_uarg, bool all_users)
 	down_write(&mk->mk_sem);
 
 	/* If relevant, remove current user's (or all users) claim to the key */
-	if (mk->mk_users && mk->mk_users->keys.nr_leaves_on_tree != 0) {
-		if (all_users)
-			err = keyring_clear(mk->mk_users);
-		else
+	if (!list_empty(&mk->mk_users)) {
+		if (all_users) {
+			clear_mk_users(mk);
+			err = 0;
+		} else {
 			err = remove_master_key_user(mk);
+		}
 		if (err) {
 			up_write(&mk->mk_sem);
 			goto out_put_key;
 		}
-		if (mk->mk_users->keys.nr_leaves_on_tree != 0) {
+		if (!list_empty(&mk->mk_users)) {
 			/*
 			 * Other users have still added the key too.  We removed
 			 * the current user's claim to the key, but we still
@@ -1138,6 +1112,8 @@ int fscrypt_ioctl_get_key_status(struct file *filp, void __user *uarg)
 	struct super_block *sb = file_inode(filp)->i_sb;
 	struct fscrypt_get_key_status_arg arg;
 	struct fscrypt_master_key *mk;
+	kuid_t uid;
+	const struct fscrypt_master_key_user *mk_user;
 	int err;
 
 	if (copy_from_user(&arg, uarg, sizeof(arg)))
@@ -1170,19 +1146,13 @@ int fscrypt_ioctl_get_key_status(struct file *filp, void __user *uarg)
 	}
 
 	arg.status = FSCRYPT_KEY_STATUS_PRESENT;
-	if (mk->mk_users) {
-		struct key *mk_user;
 
-		arg.user_count = mk->mk_users->keys.nr_leaves_on_tree;
-		mk_user = find_master_key_user(mk);
-		if (!IS_ERR(mk_user)) {
+	uid = current_fsuid();
+	list_for_each_entry(mk_user, &mk->mk_users, link) {
+		arg.user_count++;
+		if (uid_eq(mk_user->uid, uid))
 			arg.status_flags |=
 				FSCRYPT_KEY_STATUS_FLAG_ADDED_BY_SELF;
-			key_put(mk_user);
-		} else if (mk_user != ERR_PTR(-ENOKEY)) {
-			err = PTR_ERR(mk_user);
-			goto out_release_key;
-		}
 	}
 	err = 0;
 out_release_key:

base-commit: e4f7d8be268ecf717f94ee2e242afa79ddeacaed
-- 
2.55.0

