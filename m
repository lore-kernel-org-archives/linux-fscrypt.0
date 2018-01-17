Return-Path: <linux-kernel-owner@vger.kernel.org>
From: =?UTF-8?q?Andr=C3=A9=20Draszik?= <git@andred.net>
Subject: [PATCH v2 2/2] fscrypt: update documentation for encrypted key support
Date: Wed, 17 Jan 2018 14:13:19 +0000
Message-Id: <20180117141319.8060-2-git@andred.net>
In-Reply-To: <20180117141319.8060-1-git@andred.net>
References: <20180111040022.GA943@zzz.localdomain>
 <20180117141319.8060-1-git@andred.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?Andr=C3=A9=20Draszik?= <git@andred.net>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Jonathan Corbet <corbet@lwn.net>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, linux-doc@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Signed-off-by: André Draszik <git@andred.net>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Eric Biggers <ebiggers@google.com>
Cc: linux-doc@vger.kernel.org
---
 Documentation/filesystems/fscrypt.rst | 56 +++++++++++++++++++++++++++++++----
 1 file changed, 51 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 776ddc655f79..852ac2900b66 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -368,11 +368,19 @@ Adding keys
 To provide a master key, userspace must add it to an appropriate
 keyring using the add_key() system call (see:
 ``Documentation/security/keys/core.rst``).  The key type must be
-"logon"; keys of this type are kept in kernel memory and cannot be
-read back by userspace.  The key description must be "fscrypt:"
-followed by the 16-character lower case hex representation of the
-``master_key_descriptor`` that was set in the encryption policy.  The
-key payload must conform to the following structure::
+either "logon" or "encrypted"; "logon" keys are kept in kernel
+memory and cannot be read back by userspace while "encrypted"
+keys can be rooted in a "trusted" key and thus are protected by
+a TPM and cannot be read by userspace in unencrypted form. Note
+that while an "encrypted" key can also be rooted in a "user" key,
+any "encrypted" key rooted in a "user" key can effectively be
+retrieved in the clear, hence only rooting the key in a "trusted"
+key has any useful security properties!
+
+The key description must be "fscrypt:" followed by the 16-character
+lower case hex representation of the ``master_key_descriptor`` that
+was set in the encryption policy.  For a "logon" key, key payload
+must conform to the following structure::
 
     #define FS_MAX_KEY_SIZE 64
 
@@ -386,6 +394,17 @@ key payload must conform to the following structure::
 ``raw`` with ``size`` indicating its size in bytes.  That is, the
 bytes ``raw[0..size-1]`` (inclusive) are the actual key.
 
+When using an "encrypted" key, only the actual ``raw`` key from above
+fscrypt_key structure is needed::
+
+    keyctl add encrypted "fscrypt:``master_key_descriptor``" "new default trusted:``master-key-name`` ``size``" ``ring``
+    keyctl add encrypted "fscrypt:``master_key_descriptor``" "load ``hex_blob``" ``ring``
+
+Where::
+
+    master-key-name:= name of the trusted key this fscrypt master key
+                      shall be rooted in
+
 The key description prefix "fscrypt:" may alternatively be replaced
 with a filesystem-specific prefix such as "ext4:".  However, the
 filesystem-specific prefixes are deprecated and should not be used in
@@ -412,6 +431,33 @@ evicted.  In the future there probably should be a way to provide keys
 directly to the filesystem instead, which would make the intended
 semantics clearer.
 
+Complete Examples
+------------------
+
+Set fscrypt policy on an (empty) encrypted directory, /encrypted::
+
+    $ fscryptctl set_policy 1234567890123456 /encrypted
+
+Create an encrypted key "1234567890123456" of length 64 bytes with format
+'fscrypt' and root it in a previously loaded trusted "kmk"::
+
+    $ keyctl add encrypted "fscrypt:1234567890123456" "new default trusted:kmk 64" @u
+    839715473
+
+    $ keyctl print 839715473
+    default trusted:kmk 64 e98a49dc11eb9312f46530879aac869300ee734035100f4ee
+    5441279369a4c9d83d6e59b8158d0a3de01790c0bb99af82e9603cb6977c7d1229338cda
+    80375aaf034678405a00c19806d6fb12490e39b1d7ca603c491b58a962345160e344ae51
+    83483e066692d05f5ab3d8b9ea39cab0e
+
+    $ keyctl pipe 839715473 > fscrypt.blob
+
+The directory policy will remain across reboots, so after a reboot the key
+generated earlier will simply have to be loaded into the kernel keyring
+again::
+
+    $ keyctl add encrypted fscrypt:1234567890123456 "load $(cat fscrypt.blob)" @u
+
 Access semantics
 ================
 
-- 
2.15.1
