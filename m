Return-Path: <keyrings-owner@vger.kernel.org>
Date: Thu, 15 Aug 2019 09:24:58 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: Merge resolution for fscrypt and keyrings trees
Message-ID: <20190815162456.GA121345@gmail.com>
References: <20190814222822.GA101319@gmail.com>
 <12089.1565876240@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12089.1565876240@warthog.procyon.org.uk>
Sender: keyrings-owner@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-fscrypt@vger.kernel.org, linux-next@vger.kernel.org, keyrings@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi David,

On Thu, Aug 15, 2019 at 02:37:20PM +0100, David Howells wrote:
> Eric Biggers <ebiggers@kernel.org> wrote:
> 
> > +static struct key_acl fscrypt_keyring_acl = {
> > +	.usage = REFCOUNT_INIT(1),
> > +	.nr_ace	= 2,
> > +	.aces = {
> > +		KEY_POSSESSOR_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL |
> > +				  KEY_ACE_JOIN),
> > +		KEY_OWNER_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL | KEY_ACE_JOIN |
> > +			      KEY_ACE_READ | KEY_ACE_VIEW),
> > +	}
> > +};
> 
> Does you really want JOIN permission for these keyrings?  Are you permitting
> them to be used with KEYCTL_JOIN_SESSION_KEYRING?  Do you also want INVAL for
> the keyring rather than just the keys it contains?  Would CLEAR be more
> appropriate?

I don't actually want any of JOIN, INVAL, or CLEAR on any of these keys or
keyrings.  But it's not really appropriate to make semantic changes in a merge
resolution; remember that pre-merge, SEARCH implied INVAL and JOIN.  Instead
I'll remove the unneeded permissions in a separate patch later.

> 
> > +static struct key_acl fscrypt_key_acl = {
> > +	.usage = REFCOUNT_INIT(1),
> > +	.nr_ace	= 2,
> > +	.aces = {
> > +		KEY_POSSESSOR_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL |
> > +				  KEY_ACE_JOIN),
> > +		KEY_OWNER_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL | KEY_ACE_JOIN |
> > +			      KEY_ACE_VIEW),
> > +	}
> > +};
> 
> JOIN permission is useless here.  This is only used for keys of type
> key_type_fscrypt that I can see - and those aren't keyrings and so aren't
> joinable.
> 

Okay, let's remove JOIN from the non-keyrings now then.  So now it's:

diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index c34fa7c61b43b0..fb4f6a44ffcd09 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -127,6 +127,35 @@ static struct key_type key_type_fscrypt_user = {
 	.describe		= fscrypt_user_key_describe,
 };
 
+static struct key_acl fscrypt_keyring_acl = {
+	.usage = REFCOUNT_INIT(1),
+	.nr_ace	= 2,
+	.aces = {
+		KEY_POSSESSOR_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL |
+				  KEY_ACE_JOIN),
+		KEY_OWNER_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL | KEY_ACE_JOIN |
+			      KEY_ACE_READ | KEY_ACE_VIEW),
+	}
+};
+
+static struct key_acl fscrypt_key_acl = {
+	.usage = REFCOUNT_INIT(1),
+	.nr_ace	= 2,
+	.aces = {
+		KEY_POSSESSOR_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL),
+		KEY_OWNER_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL | KEY_ACE_VIEW),
+	}
+};
+
+static struct key_acl fscrypt_user_key_acl = {
+	.usage = REFCOUNT_INIT(1),
+	.nr_ace	= 2,
+	.aces = {
+		KEY_POSSESSOR_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL),
+		KEY_OWNER_ACE(KEY_ACE_VIEW),
+	}
+};
+
 /* Search ->s_master_keys or ->mk_users */
 static struct key *search_fscrypt_keyring(struct key *keyring,
 					  struct key_type *type,
@@ -203,8 +232,7 @@ static int allocate_filesystem_keyring(struct super_block *sb)
 
 	format_fs_keyring_description(description, sb);
 	keyring = keyring_alloc(description, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
-				current_cred(), KEY_POS_SEARCH |
-				  KEY_USR_SEARCH | KEY_USR_READ | KEY_USR_VIEW,
+				current_cred(), &fscrypt_keyring_acl,
 				KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
 	if (IS_ERR(keyring))
 		return PTR_ERR(keyring);
@@ -247,8 +275,7 @@ static int allocate_master_key_users_keyring(struct fscrypt_master_key *mk)
 	format_mk_users_keyring_description(description,
 					    mk->mk_spec.u.identifier);
 	keyring = keyring_alloc(description, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
-				current_cred(), KEY_POS_SEARCH |
-				  KEY_USR_SEARCH | KEY_USR_READ | KEY_USR_VIEW,
+				current_cred(), &fscrypt_keyring_acl,
 				KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
 	if (IS_ERR(keyring))
 		return PTR_ERR(keyring);
@@ -285,7 +312,7 @@ static int add_master_key_user(struct fscrypt_master_key *mk)
 	format_mk_user_description(description, mk->mk_spec.u.identifier);
 	mk_user = key_alloc(&key_type_fscrypt_user, description,
 			    current_fsuid(), current_gid(), current_cred(),
-			    KEY_POS_SEARCH | KEY_USR_VIEW, 0, NULL);
+			    &fscrypt_user_key_acl, 0, NULL);
 	if (IS_ERR(mk_user))
 		return PTR_ERR(mk_user);
 
@@ -357,8 +384,7 @@ static int add_new_master_key(struct fscrypt_master_key_secret *secret,
 	format_mk_description(description, mk_spec);
 	key = key_alloc(&key_type_fscrypt, description,
 			GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, current_cred(),
-			KEY_POS_SEARCH | KEY_USR_SEARCH | KEY_USR_VIEW,
-			KEY_ALLOC_NOT_IN_QUOTA, NULL);
+			&fscrypt_key_acl, KEY_ALLOC_NOT_IN_QUOTA, NULL);
 	if (IS_ERR(key)) {
 		err = PTR_ERR(key);
 		goto out_free_mk;
diff --git a/fs/crypto/keysetup_v1.c b/fs/crypto/keysetup_v1.c
index ad1a36c370c3fb..0727251be865b7 100644
--- a/fs/crypto/keysetup_v1.c
+++ b/fs/crypto/keysetup_v1.c
@@ -104,7 +104,7 @@ find_and_lock_process_key(const char *prefix,
 	if (!description)
 		return ERR_PTR(-ENOMEM);
 
-	key = request_key(&key_type_logon, description, NULL);
+	key = request_key(&key_type_logon, description, NULL, NULL);
 	kfree(description);
 	if (IS_ERR(key))
 		return key;
