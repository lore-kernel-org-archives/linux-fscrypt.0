Return-Path: <ard.biesheuvel@linaro.org>
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu8Y_7GKnVnv+UgjP+K8MDXA7v72F8kCrUHt+t9_BRLn1A@mail.gmail.com>
References: <20171208013838.105034-1-ebiggers3@gmail.com> <CAKv+Gu8Y_7GKnVnv+UgjP+K8MDXA7v72F8kCrUHt+t9_BRLn1A@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 8 Dec 2017 09:11:57 +0000
Message-ID: <CAKv+Gu_7vMAOP371MJh+FoYb81gwF1y_zy+OES9q5eWTTdOBTg@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, Martin Willi <martin@strongswan.org>, David Gstir <david@sigma-star.at>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 8 December 2017 at 09:11, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> Hi Eric,
>
> On 8 December 2017 at 01:38, Eric Biggers <ebiggers3@gmail.com> wrote:
>> From: Eric Biggers <ebiggers@google.com>
>>
>> fscrypt currently only supports AES encryption.  However, many low-end
>> mobile devices still use older CPUs such as ARMv7, which do not support
>> the AES instructions (the ARMv8 Cryptography Extensions).  This results
>> in very poor AES performance, even if the NEON bit-sliced implementation
>> is used.  Roughly 20-40 MB/s is a typical number, in comparison to
>> 300-800 MB/s on CPUs that support the AES instructions.  Switching from
>> AES-256 to AES-128 only helps by about 30%.
>>
>> The result is that vendors don't enable encryption on these devices,
>> leaving users unprotected.
>>
>> A performance difference of similar magnitude can also be observed on
>> x86, between CPUs with and without the AES-NI instruction set.
>>
>> This patch provides an alternative to AES by updating fscrypt to support
>> the ChaCha20 stream cipher (RFC7539) for contents encryption.  ChaCha20
>> was designed to have a large security margin, to be efficient on
>> general-purpose CPUs without dedicated instructions, and to be
>> vectorizable.  It is already supported by the Linux crypto API,
>> including a vectorized implementation for ARM using NEON instructions,
>> and vectorized implementations for x86 using SSSE3 or AVX2 instructions.
>>
>> On 32-bit ARM processors with NEON support, ChaCha20 is about 3.2 times
>> faster than AES-128-XTS (chacha20-neon vs. xts-aes-neonbs).  Without
>> NEON support, ChaCha20 is about 1.5 times as fast (chacha20-generic vs.
>> xts(aes-asm)).  The improvement over AES-256-XTS is even greater.
>>
>> Note that stream ciphers are not an ideal choice for disk encryption,
>> since each data block has to be encrypted with the same IV each time it
>> is overwritten.  Consequently, an adversary who observes the ciphertext
>> both before and after a write can trivially recover the keystream if
>> they can guess one of the plaintexts.  Moreover, an adversary who can
>> write to the ciphertext can flip arbitrary bits in the plaintext, merely
>> by flipping the corresponding bits in the ciphertext.  A block cipher
>> operating in the XTS or CBC-ESSIV mode provides some protection against
>> these types of attacks -- albeit not full protection, which would at
>> minimum require the use an authenticated encryption mode with nonces.
>>
>> Unfortunately, we are unaware of any block cipher which performs as well
>> as ChaCha20, has a similar or greater security margin, and has been
>> subject to as much public security analysis.  We do not consider Speck
>> to be a viable alternative at this time.
>>
>> Still, a stream cipher is sufficient to protect data confidentiality in
>> the event of a single point-in-time permanent offline compromise of the
>> disk, which currently is the primary threat model for fscrypt.  Thus,
>> when the alternative is quite literally *no encryption*, we might as
>> well use a stream cipher.
>>
>> We offer ChaCha20 rather than the reduced-round variants ChaCha8 or
>> ChaCha12 because ChaCha20 has a much higher security margin, and we are
>> primarily targeting CPUs where ChaCha20 is fast enough, in particular
>> CPUs that have vector instructions such as NEON or SSSE3.  Also, the
>> crypto API currently only supports ChaCha20.  Still, if ChaCha8 and/or
>> ChaCha12 support were to be added to the crypto API, it would be
>> straightforward to support them in fscrypt too.
>>
>> Currently, stream ciphers cannot be used for filenames encryption with
>> fscrypt because all filenames in a directory have to be encrypted with
>> the same IV.  Therefore, we offer ChaCha20 for contents encryption only.
>> Filenames encryption still must use AES-256-CTS-CBC.  This is acceptable
>> because filenames encryption is not as performance-critical as contents
>> encryption.
>>
>> Reviewed-by: Michael Halcrow <mhalcrow@google.com>
>> Signed-off-by: Eric Biggers <ebiggers@google.com>
>> ---
>>  Documentation/filesystems/fscrypt.rst | 43 +++++++++++++++++++---
>>  fs/crypto/Kconfig                     |  1 +
>>  fs/crypto/crypto.c                    | 69 ++++++++++++++++++++++++++++-------
>>  fs/crypto/keyinfo.c                   |  2 +
>>  include/linux/fscrypt.h               |  6 ++-
>>  include/uapi/linux/fs.h               |  1 +
>>  6 files changed, 102 insertions(+), 20 deletions(-)
>>
>> diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
>> index 776ddc655f79..927d3c88816b 100644
>> --- a/Documentation/filesystems/fscrypt.rst
>> +++ b/Documentation/filesystems/fscrypt.rst
>> @@ -184,6 +184,9 @@ replaced with HKDF or another more standard KDF in the future.
>>  Encryption modes and usage
>>  ==========================
>>
>> +Available modes
>> +---------------
>> +
>>  fscrypt allows one encryption mode to be specified for file contents
>>  and one encryption mode to be specified for filenames.  Different
>>  directory trees are permitted to use different encryption modes.
>> @@ -191,24 +194,52 @@ Currently, the following pairs of encryption modes are supported:
>>
>>  - AES-256-XTS for contents and AES-256-CTS-CBC for filenames
>>  - AES-128-CBC for contents and AES-128-CTS-CBC for filenames
>> +- ChaCha20 for contents and AES-256-CTS-CBC for filenames
>>
>>  It is strongly recommended to use AES-256-XTS for contents encryption.
>>  AES-128-CBC was added only for low-powered embedded devices with
>>  crypto accelerators such as CAAM or CESA that do not support XTS.
>>
>> +Similarly, ChaCha20 was only added for low-end devices that have
>> +neither a CPU with AES instructions, nor a hardware crypto
>> +accelerator.  Note that since ChaCha20 is a stream cipher, it is
>> +easily broken if an attacker can view encrypted data both before and
>> +after it is overwritten.  Thus, even moreso than the other modes,
>> +ChaCha20 can protect data confidentiality *only* in the event of a
>> +single point-in-time, permanent offline compromise of the storage.
>> +Also, ChaCha20 is supported only for contents encryption, not
>> +filenames encryption, because all filenames in a directory have to be
>> +encrypted with the same IV, which would be especially inappropriate
>> +for a stream cipher.
>> +
>>  New encryption modes can be added relatively easily, without changes
>>  to individual filesystems.  However, authenticated encryption (AE)
>>  modes are not currently supported because of the difficulty of dealing
>>  with ciphertext expansion.
>>
>> +Contents encryption
>> +-------------------
>> +
>>  For file contents, each filesystem block is encrypted independently.
>>  Currently, only the case where the filesystem block size is equal to
>> -the system's page size (usually 4096 bytes) is supported.  With the
>> -XTS mode of operation (recommended), the logical block number within
>> -the file is used as the IV.  With the CBC mode of operation (not
>> -recommended), ESSIV is used; specifically, the IV for CBC is the
>> -logical block number encrypted with AES-256, where the AES-256 key is
>> -the SHA-256 hash of the inode's data encryption key.
>> +the system's page size (usually 4096 bytes) is supported.
>> +
>> +With the XTS mode of operation, the logical block number within the
>> +file is used as the IV.
>> +
>> +With the CBC mode of operation, ESSIV is used.  Specifically, the IV
>> +is the file logical block number encrypted with AES-256, where the
>> +AES-256 key is the SHA-256 hash of the inode's data encryption key.
>> +
>> +With ChaCha20, the file logical block number is also used as the IV,
>> +but it is formatted differently to ensure that it is copied into the
>> +"nonce" portion of the ChaCha20 initial state (words 14-15) rather
>> +than the "block counter" portion (words 12-13).  This detail is
>> +critical, since otherwise different portions of the file would be
>> +encrypted with the same keystream.
>> +
>> +Filenames encryption
>> +--------------------
>>
>>  For filenames, the full filename is encrypted at once.  Because of the
>>  requirements to retain support for efficient directory lookups and
>> diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
>> index 02b7d91c9231..44f052e9d842 100644
>> --- a/fs/crypto/Kconfig
>> +++ b/fs/crypto/Kconfig
>> @@ -3,6 +3,7 @@ config FS_ENCRYPTION
>>         select CRYPTO
>>         select CRYPTO_AES
>>         select CRYPTO_CBC
>> +       select CRYPTO_CHACHA20
>>         select CRYPTO_ECB
>>         select CRYPTO_XTS
>>         select CRYPTO_CTS
>> diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
>> index 732a786cce9d..d5c95a18db59 100644
>> --- a/fs/crypto/crypto.c
>> +++ b/fs/crypto/crypto.c
>> @@ -126,15 +126,66 @@ struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode, gfp_t gfp_flags)
>>  }
>>  EXPORT_SYMBOL(fscrypt_get_ctx);
>>
>> +struct fscrypt_iv {
>> +       __le64 first_half;
>> +       __le64 second_half;
>> +};
>> +
>> +/*
>> + * Generate the IV for encrypting/decrypting the block at the given logical
>> + * block number within a file.
>> + */
>> +static void fscrypt_generate_iv(struct fscrypt_iv *iv, u64 lblk_num,
>> +                               const struct fscrypt_info *ci)
>> +{
>> +       BUILD_BUG_ON(sizeof(*iv) != FS_IV_SIZE);
>> +
>> +       if (ci->ci_data_mode == FS_ENCRYPTION_MODE_CHACHA20) {
>> +               /*
>> +                * ChaCha20 interprets its IV as a block counter followed by a
>> +                * nonce.  We *MUST NOT* use the file logical block number as
>> +                * the Chacha block counter because the ChaCha block counter
>> +                * counts 64-byte ChaCha blocks, which are much smaller than
>> +                * file blocks.  If we did, then portions of the keystream would
>> +                * be repeated, which would be catastrophic.
>> +                *
>
> OK, so you are saying that LBA n + 1 will share its keystream with LBA
> n but shift by 64 blocks, right? Yeah, that's terrible.
>

shift-ed by 64 *bytes*
