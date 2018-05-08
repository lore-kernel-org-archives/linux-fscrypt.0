Return-Path: <linux-ext4-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH v2] fscrypt: add Speck128/256 support
Date: Mon,  7 May 2018 17:22:08 -0700
Message-Id: <20180508002208.7072-1-ebiggers@google.com>
Sender: linux-ext4-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>
Cc: linux-crypto@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Jeffrey Walton <noloader@gmail.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

fscrypt currently only supports AES encryption.  However, many low-end
mobile devices have older CPUs that don't have AES instructions, e.g.
the ARMv8 Cryptography Extensions.  Currently, user data on such devices
is not encrypted at rest because AES is too slow, even when the NEON
bit-sliced implementation of AES is used.  Unfortunately, it is
infeasible to encrypt these devices at all when AES is the only option.

Therefore, this patch updates fscrypt to support the Speck block cipher,
which was recently added to the crypto API.  The C implementation of
Speck is not especially fast, but Speck can be implemented very
efficiently with general-purpose vector instructions, e.g. ARM NEON.
For example, on an ARMv7 processor, we measured the NEON-accelerated
Speck128/256-XTS at 69 MB/s for both encryption and decryption, while
AES-256-XTS with the NEON bit-sliced implementation was only 22 MB/s
encryption and 19 MB/s decryption.

There are multiple variants of Speck.  This patch only adds support for
Speck128/256, which is the variant with a 128-bit block size and 256-bit
key size -- the same as AES-256.  This is believed to be the most secure
variant of Speck, and it's only about 6% slower than Speck128/128.
Speck64/128 would be at least 20% faster because it has 20% rounds, and
it can be even faster on CPUs that can't efficiently do the 64-bit
operations needed for Speck128.  However, Speck64's 64-bit block size is
not preferred security-wise.  ARM NEON also supports the needed 64-bit
operations even on 32-bit CPUs, resulting in Speck128 being fast enough
for our targeted use cases so far.

The chosen modes of operation are XTS for contents and CTS-CBC for
filenames.  These are the same modes of operation that fscrypt defaults
to for AES.  Note that as with the other fscrypt modes, Speck will not
be used unless userspace chooses to use it.  Nor are any of the existing
modes (which are all AES-based) being removed, of course.

We intentionally don't make CONFIG_FS_ENCRYPTION select
CONFIG_CRYPTO_SPECK, so people will have to enable Speck support
themselves if they need it.  This is because we shouldn't bloat the
FS_ENCRYPTION dependencies with every new cipher, especially ones that
aren't recommended for most users.  Moreover, CRYPTO_SPECK is just the
generic implementation, which won't be fast enough for many users; in
practice, they'll need to enable CRYPTO_SPECK_NEON to get acceptable
performance.

More details about our choice of Speck can be found in our patches that
added Speck to the crypto API, and the follow-on discussion threads.
We're planning a publication that explains the choice in more detail.
But briefly, we can't use ChaCha20 as we previously proposed, since it
would be insecure to use a stream cipher in this context, with potential
IV reuse during writes on f2fs and/or on wear-leveling flash storage.

We also evaluated many other lightweight and/or ARX-based block ciphers
such as Chaskey-LTS, RC5, LEA, CHAM, Threefish, RC6, NOEKEON, SPARX, and
XTEA.  However, all had disadvantages vs. Speck, such as insufficient
performance with NEON, much less published cryptanalysis, or an
insufficient security level.  Various design choices in Speck make it
perform better with NEON than competing ciphers while still having a
security margin similar to AES, and in the case of Speck128 also the
same available security levels.  Unfortunately, Speck does have some
political baggage attached -- it's an NSA designed cipher, and was
rejected from an ISO standard (though for context, as far as I know none
of the above-mentioned alternatives are ISO standards either).
Nevertheless, we believe it is a good solution to the problem from a
technical perspective.

Certain algorithms constructed from ChaCha or the ChaCha permutation,
such as MEM (Masked Even-Mansour) or HPolyC, may also meet our
performance requirements.  However, these are new constructions that
need more time to receive the cryptographic review and acceptance needed
to be confident in their security.  HPolyC hasn't been published yet,
and we are concerned that MEM makes stronger assumptions about the
underlying permutation than the ChaCha stream cipher does.  In contrast,
the XTS mode of operation is relatively well accepted, and Speck has
over 70 cryptanalysis papers.  Of course, these ChaCha-based algorithms
can still be added later if they become ready.

The best known attack on Speck128/256 is a differential cryptanalysis
attack on 25 of 34 rounds with 2^253 time complexity and 2^125 chosen
plaintexts, i.e. only marginally faster than brute force.  There is no
known attack on the full 34 rounds.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---

Changed since v1:
    - Improved commit message and documentation.

 Documentation/filesystems/fscrypt.rst | 10 ++++++++++
 fs/crypto/fscrypt_private.h           |  4 ++++
 fs/crypto/keyinfo.c                   |  2 ++
 include/uapi/linux/fs.h               |  2 ++
 4 files changed, 18 insertions(+)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index cfbc18f0d9c9..48b424de85bb 100644
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
+NEON instructions but not the Cryptography Extensions -- and for which
+it would not otherwise be feasible to use encryption at all.  It is
+not recommended to use Speck on CPUs that have AES instructions.
+Speck support is only available if it has been enabled in the crypto
+API via CONFIG_CRYPTO_SPECK.  Also, on ARM platforms, to get
+acceptable performance CONFIG_CRYPTO_SPECK_NEON must be enabled.
+
 New encryption modes can be added relatively easily, without changes
 to individual filesystems.  However, authenticated encryption (AE)
 modes are not currently supported because of the difficulty of dealing
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index ad6722bae8b7..bceb737d4694 100644
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
2.17.0.441.gb46fe60e1d-goog
