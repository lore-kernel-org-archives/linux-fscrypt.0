Return-Path: <ebiggers3@gmail.com>
Date: Thu, 25 Jan 2018 16:36:48 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v3] fscrypt: add support for the encrypted key type
Message-ID: <20180126003648.jtmiznczkinla353@gmail.com>
References: <20180118131359.8365-1-git@andred.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180118131359.8365-1-git@andred.net>
To: =?iso-8859-1?Q?Andr=E9?= Draszik <git@andred.net>
Cc: linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Kees Cook <keescook@chromium.org>, Eric Biggers <ebiggers@google.com>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jan 18, 2018 at 01:13:59PM +0000, Andr� Draszik wrote:
> fscrypt uses a master key for each directory policy from
> which all further keys for that policy are derived, and
> at the moment such a master key has to be inserted into
> a kernel keyring as a 'logon' key by user-space.
> 
> While 'logon' keys have the nice property of not being
> readable by user-space (keyctl dump etc.), the fscrypt

There is no 'keyctl dump' command.  Probably you meant 'keyctl read'.

> master key still needs to be generated initially, in a
> secure way, and it needs to be saved somewhere for
> subsequent reboots, and hence also needs securing itself.
> 
> Usage of the 'logon' key means that it is up to user-space
> to do all that, opening up the possibility of creating
> cryptographically non-sound master keys, or not storing
> the master key securely across reboots.
> 
> One approach for securing the master key would be to do
> that using a TPM and while one could manually do so e.g.
> using tpm-tools, that still leaves creation and actual
> correct usage of tpm-tools up to user-space, though. As an
> aside, tpm-tools needs the tcsd daemon running, which makes
> it awkward to use from within an initramfs, and while other
> libraries for interfacing with a TPM do exist, there
> appears to be a better way:
> 
> The kernel already has a concept of trusted as well as
> encrypted keys. Trusted keys are TPM backed keys, which can
> be sealed to PCRs and also easily be re-sealed against new
> future PCRs, and encrypted keys are keys that are encrypted
> using another key, e.g. a trusted key. All are generated
> automatically by the kernel using the RNG and never leave
> kernel memory space (bar any kernel or hardware bugs).

Saying "the RNG" is unclear, since "encrypted" keys are generated using the
kernel's RNG whereas "trusted" keys are generated using the TPM's RNG.

> 
> So it seems reasonable to allow the fscrypt subsystem to
> work with encrypted keys as well. This is what this change
> here does.
> 
> We can utilise keys that never ever exist in user-space,
> not even at initial creation time, as well as simplifying
> usage / configuration. Something very very similar exists
> for eCrypts already.

typo: eCrypts => eCryptfs

[...]
> diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
> index 776ddc655f79..852ac2900b66 100644
> --- a/Documentation/filesystems/fscrypt.rst
> +++ b/Documentation/filesystems/fscrypt.rst
> @@ -368,11 +368,19 @@ Adding keys
>  To provide a master key, userspace must add it to an appropriate
>  keyring using the add_key() system call (see:
>  ``Documentation/security/keys/core.rst``).  The key type must be
> -"logon"; keys of this type are kept in kernel memory and cannot be
> -read back by userspace.  The key description must be "fscrypt:"
> -followed by the 16-character lower case hex representation of the
> -``master_key_descriptor`` that was set in the encryption policy.  The
> -key payload must conform to the following structure::
> +either "logon" or "encrypted"; "logon" keys are kept in kernel
> +memory and cannot be read back by userspace while "encrypted"
> +keys can be rooted in a "trusted" key and thus are protected by
> +a TPM and cannot be read by userspace in unencrypted form. Note
> +that while an "encrypted" key can also be rooted in a "user" key,
> +any "encrypted" key rooted in a "user" key can effectively be
> +retrieved in the clear, hence only rooting the key in a "trusted"
> +key has any useful security properties!
> +
> +The key description must be "fscrypt:" followed by the 16-character
> +lower case hex representation of the ``master_key_descriptor`` that
> +was set in the encryption policy.  For a "logon" key, key payload
> +must conform to the following structure::
>  
>      #define FS_MAX_KEY_SIZE 64
>  
> @@ -386,6 +394,17 @@ key payload must conform to the following structure::
>  ``raw`` with ``size`` indicating its size in bytes.  That is, the
>  bytes ``raw[0..size-1]`` (inclusive) are the actual key.
>  
> +When using an "encrypted" key, only the actual ``raw`` key from above
> +fscrypt_key structure is needed::
> +
> +    keyctl add encrypted "fscrypt:``master_key_descriptor``" "new default trusted:``master-key-name`` ``size``" ``ring``
> +    keyctl add encrypted "fscrypt:``master_key_descriptor``" "load ``hex_blob``" ``ring``
> +
> +Where::
> +
> +    master-key-name:= name of the trusted key this fscrypt master key
> +                      shall be rooted in
> +

We need to be very careful with the wording.  For example it's implied that
encrypted keys cannot be read by userspace because they are protected by a TPM,
but that's not true.  They can be *wrapped* by a key which in turn can be
TPM-sealed, but once unwrapped they are present in the clear in kernel memory,
and it's only the policy of the kernel code that they can't be read back in the
clear.

Also the "logon" and "encrypted" key types should probably be in their own
subsections, so that there is space to explain them properly.

I've tried reorganizing the section a bit and this is what I came up with:

Adding keys
-----------

To provide a master key, userspace must add it to an appropriate
keyring using the add_key() system call (see:
``Documentation/security/keys/core.rst``).

The key description must be "fscrypt:" followed by the 16-character
lower case hex representation of the ``master_key_descriptor`` that
was set in the encryption policy.  The "fscrypt:" prefix can
alternatively be replaced with a filesystem-specific prefix such as
"ext4:".  However, the filesystem-specific prefixes are deprecated and
should not be used in new programs.

The key type must be "logon" or "encrypted", as described below.
Support for the "logon" key type will always be available when any
filesystem has fscrypt support enabled, whereas support for the
"encrypted" key type additionally requires CONFIG_ENCRYPTED_KEYS=y.

Logon key type
~~~~~~~~~~~~~~

With the "logon" type, userspace is responsible for generating or
unwrapping the master key, then passing it to the kernel in the
following format:

    #define FS_MAX_KEY_SIZE 64

    struct fscrypt_key {
            u32 mode;
            u8 raw[FS_MAX_KEY_SIZE];
            u32 size;
    };

``mode`` is ignored; just set it to 0.  The actual key is provided in
``raw`` with ``size`` indicating its size in bytes.  That is, the
bytes ``raw[0..size-1]`` (inclusive) are the actual key.

The "logon" key will then be stored in kernel memory for the
filesystem to use.  There is no API for userspace to read it back.

Encrypted key type
~~~~~~~~~~~~~~~~~~

With the "encrypted" key type, the key is initially randomly generated
by the kernel.  Then, userspace can read it back as a blob wrapped by
another key.  In particular, it can be wrapped by a "trusted" key,
which can be sealed to a TPM in a certain state, with only the
TPM-sealed blob being made available to userspace.  Then, userspace
can later re-instantiate the "encrypted" key by first re-instantiating
the needed "trusted" key, then providing the encrypted-key blob to be
unwrapped by the kernel.  For example:

    # create a new encrypted-key
    keyctl add encrypted "fscrypt:``master_key_descriptor``" "new default trusted:``master-key-desc`` ``size``" ``ring``

    # unwrap an existing encrypted-key blob
    keyctl add encrypted "fscrypt:``master_key_descriptor``" "load ``hex_blob``" ``ring``

Where::

    master-key-desc:= description of the trusted key this fscrypt master key
                      shall be wrapped by

    size := desired size of the fscrypt master key in bytes

    ring := keyring to add the key to

The "encrypted" key must be instantiated using the "default" format,
since its decrypted payload is treated as the raw master key; that is,
the ``fscrypt_key`` structure is not used.

Note that just like "logon" keys, "encrypted" keys are actually
present in kernel memory in the clear after being added.  Thus, they
are not safe from attacks that compromise kernel memory.  However,
they cannot be read back in the clear using the system call interface.

Choice of keyring
~~~~~~~~~~~~~~~~~

There are several different types of keyrings in which fscrypt master
keys may be placed, such as a session keyring, a user session keyring,
or a user keyring.  Each key must be placed in a keyring that is
"attached" to all processes that might need to access files encrypted
with it, in the sense that request_key() will find the key.
Generally, if only processes belonging to a specific user need to
access a given encrypted directory and no session keyring has been
installed, then that directory's key should be placed in that user's
user session keyring or user keyring.  Otherwise, a session keyring
should be installed if needed, and the key should be linked into that
session keyring, or in a keyring linked into that session keyring.

Note: introducing the complex visibility semantics of keyrings here
was arguably a mistake --- especially given that by design, after any
process successfully opens an encrypted file (thereby setting up the
per-file key), possessing the keyring key is not actually required for
any process to read/write the file until its in-memory inode is
evicted.  In the future there probably should be a way to provide keys
directly to the filesystem instead, which would make the intended
semantics clearer.
