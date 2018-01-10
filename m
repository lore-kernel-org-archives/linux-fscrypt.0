Return-Path: <keyrings-owner@vger.kernel.org>
From: =?UTF-8?q?Andr=C3=A9=20Draszik?= <git@andred.net>
Subject: [PATCH 1/3] encrypted-keys: add fscrypt format support
Date: Wed, 10 Jan 2018 12:44:16 +0000
Message-Id: <20180110124418.24385-1-git@andred.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: keyrings-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This is heavily based on commit 79a73d188726
("encrypted-keys: add ecryptfs format support").

The 'encrypted' key type defines its own payload format which contains a
symmetric key randomly generated that cannot be used directly by the
fscrypt subsystem, because it instead expects an fscrypt_key structure.

This patch introduces the new format 'fscrypt' that allows to store an
fscrypt_key structure inside the encrypted key payload containing
a randomly generated symmetric key, as the same for the format 'default'
and 'ecryptfs'.

More details about the usage of encrypted keys with the fscrypt
subsystem can be found in the file 'Documentation/security/keys/fscrypt.rst'.

Signed-off-by: André Draszik <git@andred.net>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: David Howells <dhowells@redhat.com>
Cc: James Morris <james.l.morris@oracle.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: linux-integrity@vger.kernel.org
Cc: keyrings@vger.kernel.org
Cc: linux-security-module@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
---
 security/keys/encrypted-keys/Makefile         |  2 +-
 security/keys/encrypted-keys/encrypted.c      | 19 +++++++-
 security/keys/encrypted-keys/fscrypt_format.c | 70 +++++++++++++++++++++++++++
 security/keys/encrypted-keys/fscrypt_format.h | 20 ++++++++
 4 files changed, 108 insertions(+), 3 deletions(-)
 create mode 100644 security/keys/encrypted-keys/fscrypt_format.c
 create mode 100644 security/keys/encrypted-keys/fscrypt_format.h

diff --git a/security/keys/encrypted-keys/Makefile b/security/keys/encrypted-keys/Makefile
index 7a44dce6f69d..586702ce9622 100644
--- a/security/keys/encrypted-keys/Makefile
+++ b/security/keys/encrypted-keys/Makefile
@@ -5,7 +5,7 @@
 
 obj-$(CONFIG_ENCRYPTED_KEYS) += encrypted-keys.o
 
-encrypted-keys-y := encrypted.o ecryptfs_format.o
+encrypted-keys-y := encrypted.o ecryptfs_format.o fscrypt_format.o
 masterkey-$(CONFIG_TRUSTED_KEYS) := masterkey_trusted.o
 masterkey-$(CONFIG_TRUSTED_KEYS)-$(CONFIG_ENCRYPTED_KEYS) := masterkey_trusted.o
 encrypted-keys-y += $(masterkey-y) $(masterkey-m-m)
diff --git a/security/keys/encrypted-keys/encrypted.c b/security/keys/encrypted-keys/encrypted.c
index d92cbf9687c3..b570a930583a 100644
--- a/security/keys/encrypted-keys/encrypted.c
+++ b/security/keys/encrypted-keys/encrypted.c
@@ -37,6 +37,7 @@
 
 #include "encrypted.h"
 #include "ecryptfs_format.h"
+#include "fscrypt_format.h"
 
 static const char KEY_TRUSTED_PREFIX[] = "trusted:";
 static const char KEY_USER_PREFIX[] = "user:";
@@ -45,6 +46,7 @@ static const char hmac_alg[] = "hmac(sha256)";
 static const char blkcipher_alg[] = "cbc(aes)";
 static const char key_format_default[] = "default";
 static const char key_format_ecryptfs[] = "ecryptfs";
+static const char key_format_fscrypt[] = "fscrypt";
 static unsigned int ivsize;
 static int blksize;
 
@@ -62,12 +64,13 @@ enum {
 };
 
 enum {
-	Opt_error = -1, Opt_default, Opt_ecryptfs
+	Opt_error = -1, Opt_default, Opt_ecryptfs, Opt_fscrypt
 };
 
 static const match_table_t key_format_tokens = {
 	{Opt_default, "default"},
 	{Opt_ecryptfs, "ecryptfs"},
+	{Opt_fscrypt, "fscrypt"},
 	{Opt_error, NULL}
 };
 
@@ -185,7 +188,7 @@ static int datablob_parse(char *datablob, const char **format,
 	}
 	key_cmd = match_token(keyword, key_tokens, args);
 
-	/* Get optional format: default | ecryptfs */
+	/* Get optional format: default | ecryptfs | fscrypt */
 	p = strsep(&datablob, " \t");
 	if (!p) {
 		pr_err("encrypted_key: insufficient parameters specified\n");
@@ -194,6 +197,7 @@ static int datablob_parse(char *datablob, const char **format,
 
 	key_format = match_token(p, key_format_tokens, args);
 	switch (key_format) {
+	case Opt_fscrypt:
 	case Opt_ecryptfs:
 	case Opt_default:
 		*format = p;
@@ -634,6 +638,11 @@ static struct encrypted_key_payload *encrypted_key_alloc(struct key *key,
 		}
 		decrypted_datalen = ECRYPTFS_MAX_KEY_BYTES;
 		payload_datalen = sizeof(struct ecryptfs_auth_tok);
+	} else if (format && !strcmp(format, key_format_fscrypt)) {
+		ret = fscrypt_encrypted_key_reserve_payload(decrypted_datalen,
+							    &payload_datalen);
+		if (ret < 0)
+			return ERR_PTR(ret);
 	}
 
 	encrypted_datalen = roundup(decrypted_datalen, blksize);
@@ -734,6 +743,8 @@ static void __ekey_init(struct encrypted_key_payload *epayload,
 		if (!strcmp(format, key_format_ecryptfs))
 			epayload->decrypted_data =
 				ecryptfs_get_auth_tok_key((struct ecryptfs_auth_tok *)epayload->payload_data);
+		else if (!strcmp(format, key_format_fscrypt))
+			fscrypt__ekey_init(epayload);
 
 		memcpy(epayload->format, format, format_len);
 	}
@@ -762,6 +773,10 @@ static int encrypted_init(struct encrypted_key_payload *epayload,
 
 		ecryptfs_fill_auth_tok((struct ecryptfs_auth_tok *)epayload->payload_data,
 				       key_desc);
+	} else if (format && !strcmp(format, key_format_fscrypt)) {
+		ret = fscrypt_valid_desc(key_desc);
+		if (ret < 0)
+			return ret;
 	}
 
 	__ekey_init(epayload, format, master_desc, datalen);
diff --git a/security/keys/encrypted-keys/fscrypt_format.c b/security/keys/encrypted-keys/fscrypt_format.c
new file mode 100644
index 000000000000..7620c0fa3ff9
--- /dev/null
+++ b/security/keys/encrypted-keys/fscrypt_format.c
@@ -0,0 +1,70 @@
+/*
+ * fscrypt_format.c: helper functions for the encrypted key type
+ *
+ * Copyright (C) 2006 International Business Machines Corp.
+ * Copyright (C) 2010 Politecnico di Torino, Italy
+ *                    TORSEC group -- http://security.polito.it
+ *
+ * Authors:
+ * André Draszik <git@andred.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, version 2 of the License.
+ */
+
+#include <linux/ctype.h>
+#define __FS_HAS_ENCRYPTION 0
+#include <linux/fscrypt.h>
+#include <keys/encrypted-type.h>
+#include <crypto/aes.h>
+#include "fscrypt_format.h"
+
+
+#define FS_KEY_DESCRIPTOR_HEX_SIZE (FS_KEY_DESCRIPTOR_SIZE*2)
+
+int fscrypt_encrypted_key_reserve_payload(unsigned short decrypted_datalen,
+					  unsigned short *payload_datalen)
+{
+	if (decrypted_datalen < AES_BLOCK_SIZE /* FS_AES_128_CBC_KEY_SIZE */
+	    || decrypted_datalen > FS_MAX_KEY_SIZE
+	    || decrypted_datalen % AES_BLOCK_SIZE != 0) {
+		pr_err("encrypted_key: fscrypt keylen must be a multiple of %d up to %d bytes\n",
+		       AES_BLOCK_SIZE, FS_MAX_KEY_SIZE);
+		return -EINVAL;
+	}
+	*payload_datalen = sizeof(struct fscrypt_key);
+	return 0;
+}
+
+void fscrypt__ekey_init(struct encrypted_key_payload *epayload)
+{
+	struct fscrypt_key *fk = (struct fscrypt_key *)epayload->payload_data;
+
+	epayload->decrypted_data = fk->raw;
+
+	fk->mode = 0;
+	fk->size = epayload->decrypted_datalen;
+}
+
+int fscrypt_valid_desc(const char *desc)
+{
+	int i;
+
+	if (strlen(desc) != (FS_KEY_DESC_PREFIX_SIZE
+			     + FS_KEY_DESCRIPTOR_HEX_SIZE))
+		goto error;
+	if (memcmp(desc, FS_KEY_DESC_PREFIX, FS_KEY_DESC_PREFIX_SIZE))
+		goto error;
+	desc += FS_KEY_DESC_PREFIX_SIZE;
+	for (i = 0; i < FS_KEY_DESCRIPTOR_HEX_SIZE; i++)
+		if (!isxdigit(desc[i]))
+			goto error;
+
+	return 0;
+
+error:
+	pr_err("encrypted_key: key description must be 'fscrypt:<policy>'\n");
+	return -EINVAL;
+}
+
diff --git a/security/keys/encrypted-keys/fscrypt_format.h b/security/keys/encrypted-keys/fscrypt_format.h
new file mode 100644
index 000000000000..c6d7da1a2113
--- /dev/null
+++ b/security/keys/encrypted-keys/fscrypt_format.h
@@ -0,0 +1,20 @@
+/*
+ * fscrypt_format.h: helper functions for the encrypted key type
+ *
+ * Copyright (C) 2006 International Business Machines Corp.
+ * Copyright (C) 2010 Politecnico di Torino, Italy
+ *                    TORSEC group -- http://security.polito.it
+ *
+ * Authors:
+ * André Draszik <git@andred.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, version 2 of the License.
+ */
+#pragma once
+
+int fscrypt_encrypted_key_reserve_payload(unsigned short decrypted_datalen,
+					  unsigned short *payload_datalen);
+void fscrypt__ekey_init(struct encrypted_key_payload *epayload);
+int fscrypt_valid_desc(const char *desc);
-- 
2.15.1

