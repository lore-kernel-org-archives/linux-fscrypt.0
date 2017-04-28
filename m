Return-Path: <ebiggers3@gmail.com>
Date: Fri, 28 Apr 2017 14:18:45 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 3/6] fscrypt: introduce helper function for filename
 matching
Message-ID: <20170428211845.GA62395@gmail.com>
References: <20170424170013.85175-1-ebiggers3@gmail.com>
 <20170424170013.85175-4-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424170013.85175-4-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Apr 24, 2017 at 10:00:10AM -0700, Eric Biggers wrote:
> +/**
> + * fscrypt_digested_name - alternate identifier for an on-disk filename
> + *
> + * When userspace lists an encrypted directory without access to the key,
> + * filenames whose ciphertext is longer than FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE
> + * bytes are shown in this abbreviated form (base64-encoded) rather than as the
> + * full ciphertext (base64-encoded).  This is necessary to allow supporting
> + * filenames up to NAME_MAX bytes, since base64 encoding expands the length.
> + *
> + * To make it possible for filesystems to still find the correct directory entry
> + * despite not knowing the full on-disk name, we encode any filesystem-specific
> + * 'hash' and/or 'minor_hash' which the filesystem may need for its lookups,
> + * followed by the second-to-last ciphertext block of the filename.  Due to the
> + * use of the CBC-CTS encryption mode, the second-to-last ciphertext block
> + * depends on the full plaintext.  (Note that ciphertext stealing causes the
> + * last two blocks to appear "flipped".)  This makes collisions very unlikely:
> + * just a 1 in 2^128 chance for two filenames to collide even if they share the
> + * same filesystem-specific hashes.
> + *
> + * This scheme isn't strictly immune to intentional collisions because it's
> + * basically like a CBC-MAC, which isn't secure on variable-length inputs.
> + * However, generating a CBC-MAC collision requires the ability to choose
> + * arbitrary ciphertext, which won't normally be possible with filename
> + * encryption since it would require write access to the raw disk.
> + *
> + * Taking a real cryptographic hash like SHA-256 over the full ciphertext would
> + * be better in theory but would be less efficient and more complicated to
> + * implement, especially since the filesystem would need to calculate it for
> + * each directory entry examined during a search.
> + */

Hmm, after thinking about it more, my claim that creating intentional collisions
in digested names requires write access to the raw disk is incorrect.  Actually
it's pretty easy to create intentional collisions; it's sufficient to be able to
create filenames and view their corresponding ciphertexts.  So someone could
create undeletable files --- not necessarily the end of the world, but still
annoying.

Unfortunately, the same problem exists regardless of whether we use the
second-to-last ciphertext block, the last block, or the last two blocks; and
regardless of whether the length is encoded in the digested names.

My patches are still an improvement, of course, and for now I'll probably just
tweak the comment.  But to solve this for real I think we'd need to do one of
the following:

- Use a real cryptographic hash like SHA-256 of the ciphertext (which I think
  was actually the original design)
- Switch to an encryption mode like HEH (Hash-Encrypt-Hash) which is a
  pseudorandom permutation over the whole input
- Take some number (maybe 8 or 12) of bytes of ciphertext from each block;
  definitely a hack cryptographically, but it *might* be good enough
- Limit filenames in encrypted directories to (3*255)/4 bytes, so we can avoid
  this mess entirely

Another hack we maybe could do is remove the following sanity check in
ext4_unlink(), and in other filesystems if needed, which requires that the inode
number in a dir_entry being removed is as expected:

	retval = -EFSCORRUPTED;
	if (le32_to_cpu(de->inode) != inode->i_ino)
		goto end_unlink;

Then I think any colliding files could still be deleted; it just wouldn't happen
in the right order...

Eric
