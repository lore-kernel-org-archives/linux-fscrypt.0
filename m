Return-Path: <linux-ext4-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH] fscrypt: add Speck128/256 support
Date: Fri,  2 Mar 2018 11:56:10 -0800
Message-Id: <20180302195610.153581-1-ebiggers@google.com>
Sender: linux-ext4-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>
Cc: linux-crypto@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Richard Weinberger <richard@nod.at>, David Gstir <david@sigma-star.at>, Jaegeuk Kim <jaegeuk@kernel.org>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hello, here's a patch which adds Speck128/256 support to fscrypt, for
ext4/f2fs/ubifs encryption.  Note that this can be applied independently
of the patches that added Speck to the crypto API since there is no hard
dependency, but the crypto API support is needed for Speck-encrypted
files to work.  The crypto API patches can be found in linux-next via
cryptodev/master.  Commit da7a0ab5b4ba ("crypto: speck - add support for
the Speck block cipher") with CONFIG_CRYPTO_SPECK enabled is sufficient
for basic testing, but for testing on ARM the NEON-accelerated version
should be applied and enabled as well.

-----8<-----

fscrypt currently only supports AES encryption.  However, many low-end
mobile devices have older CPUs that don't have AES instructions, e.g.
the ARMv8 Cryptography Extensions.  Currently, user data on such devices
is not being encrypted because AES is not fast enough, even when the
NEON bit-sliced implementation of AES is used.

Therefore, this patch provides an alternative to AES by updating fscrypt
to support the Speck block cipher.

Separate patches added Speck to the crypto API; more details about the
choice of Speck can be found in those patches.  Note in particular that
we can't use ChaCha20 as previously proposed, since it would, in
general, be insecure to use a stream cipher in this context.

The generic Speck implementation is not especially fast, but Speck can
be greatly accelerated using general-purpose vector instructions, e.g.
ARM NEON.  As an example, on a device with an ARMv7 processor, the
NEON-accelerated Speck128/256-XTS was 108 MB/s for both encryption and
decryption, while AES-256-XTS (with the NEON bit-sliced implementation)
was only 41 MB/s encryption and 37 MB/s decryption.

There are multiple variants of Speck.  This patch only adds support for
Speck128/256, which is the variant with a 128-bit block size and 256-bit
key size -- the same as AES-256.  This is believed to be the most secure
variant of Speck, and it's only about 6% slower than Speck128/128.

Speck64/128 is also a contender, since it's at least 20% faster than
Speck128/256 (having 20% fewer rounds), and can be even faster on CPUs
that can't efficiently do the 64-bit operations needed for Speck128.
But, ARM NEON supports the needed 64-bit operations even on 32-bit CPUs,
and Speck128/256 appears to be fast enough for our targeted use cases.
So, it makes sense to support Speck128/256 in fscrypt anyway, even if
there's a possibility that Speck64/128 support would be added later.

The chosen modes of operation are XTS for contents and CTS-CBC for
filenames.  These are the same modes recommended for AES currently.

This patch intentionally does *not* make CONFIG_FS_ENCRYPTION select
CONFIG_CRYPTO_SPECK.  Thus, people will have to enable Speck support
themselves if needed.  This is firstly because we shouldn't bloat the
FS_ENCRYPTION dependencies with every new cipher, especially ones that
aren't recommended for most users.  It's also because CRYPTO_SPECK just
refers to the generic implementation, which won't be fast enough for
many users; in practice, they'll need to enable a vectorized
implementation such as CRYPTO_SPECK_NEON to get acceptable performance.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 Documentation/filesystems/fscrypt.rst | 10 ++++++++++
 fs/crypto/fscrypt_private.h           |  4 ++++
 fs/crypto/keyinfo.c                   |  2 ++
 include/uapi/linux/fs.h               |  2 ++
 4 files changed, 18 insertions(+)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index cfbc18f0d9c9..c99465965512 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -191,11 +191,21 @@ Currently, the following pairs of encryption modes are supported:
 
 - AES-256-XTS for contents and AES-256-CTS-CBC for filenames
 - AES-128-CBC for contents and AES-128-CTS-CBC for filenames
+- Speck128/256-XTS for contents and Speck128/256-CTS-CBC for filenames
 
 It is strongly recommended to use AES-256-XTS for contents encryption.
 AES-128-CBC was added only for low-powered embedded devices with
 crypto accelerators such as CAAM or CESA that do not support XTS.
 
+Similarly, Speck128/256 support was only added for older or low-end
+CPUs which cannot do AES fast enough -- especially ARM CPUs which have
+NEON instructions but not the Cryptography Extensions.  It is not
+recommended to use Speck on CPUs that have AES instructions.
+Nevertheless, to use Speck, CONFIG_CRYPTO_SPECK must be enabled.  It
+is strongly recommended to enable any available architecture-specific
+implementations of Speck as well, e.g. CONFIG_CRYPTO_SPECK_NEON for
+ARM, since they can be much faster than the generic implementation.
+
 New encryption modes can be added relatively easily, without changes
 to individual filesystems.  However, authenticated encryption (AE)
 modes are not currently supported because of the difficulty of dealing
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index fb96e493167b..bf0bbba783f8 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -91,6 +91,10 @@ static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
 	    filenames_mode == FS_ENCRYPTION_MODE_AES_256_CTS)
 		return true;
 
+	if (contents_mode == FS_ENCRYPTION_MODE_SPECK128_256_XTS &&
+	    filenames_mode == FS_ENCRYPTION_MODE_SPECK128_256_CTS)
+		return true;
+
 	return false;
 }
 
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 05f5ee1f0705..96a1eae9e51d 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -135,6 +135,8 @@ static const struct {
 					     FS_AES_128_CBC_KEY_SIZE },
 	[FS_ENCRYPTION_MODE_AES_128_CTS] = { "cts(cbc(aes))",
 					     FS_AES_128_CTS_KEY_SIZE },
+	[FS_ENCRYPTION_MODE_SPECK128_256_XTS] = { "xts(speck128)", 64 },
+	[FS_ENCRYPTION_MODE_SPECK128_256_CTS] = { "cts(cbc(speck128))", 32 },
 };
 
 static int determine_cipher_type(struct fscrypt_info *ci, struct inode *inode,
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index d2a8313fabd7..0b6e07ee63a6 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -275,6 +275,8 @@ struct fsxattr {
 #define FS_ENCRYPTION_MODE_AES_256_CTS		4
 #define FS_ENCRYPTION_MODE_AES_128_CBC		5
 #define FS_ENCRYPTION_MODE_AES_128_CTS		6
+#define FS_ENCRYPTION_MODE_SPECK128_256_XTS	7
+#define FS_ENCRYPTION_MODE_SPECK128_256_CTS	8
 
 struct fscrypt_policy {
 	__u8 version;
-- 
2.16.2.395.g2e18187dfd-goog
