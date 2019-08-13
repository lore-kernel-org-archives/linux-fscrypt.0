Return-Path: <SRS0=mLUp=WJ=mit.edu=tytso@kernel.org>
Date: Mon, 12 Aug 2019 20:06:44 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v8 10/20] fscrypt: add FS_IOC_REMOVE_ENCRYPTION_KEY ioctl
Message-ID: <20190813000644.GH28705@mit.edu>
References: <20190805162521.90882-1-ebiggers@kernel.org>
 <20190805162521.90882-11-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805162521.90882-11-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, linux-api@vger.kernel.org, Satya Tangirala <satyat@google.com>, Paul Crowley <paulcrowley@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

> +		/* Some inodes still reference this key; try to evict them. */
> +		if (try_to_lock_encrypted_files(sb, mk) != 0)
> +			status_flags |=
> +				FSCRYPT_KEY_REMOVAL_STATUS_FLAG_FILES_BUSY;
> +	}

try_to_lock_encrypted_files() can return other errors besides -EBUSY;
in particular sync_filesystem() can return other errors, such as -EIO
or -EFSCORUPTED.  In that case, I think we're better off returning the
relevant status code back to the user.  We will have already wiped the
master key, but this situation will only happen in exceptional
conditions (e.g., user has ejected the sdcard, etc.), so it's not
worth it to try to undo the master key wipe to try to restore things
to the pre-ioctl execution state.

So I think we should capture the return code from
try_to_lock_encrypted_files, and if it is EBUSY, we can set FILES_BUSY
flag and return success.  Otherwise, we should return the error.

If you agree, please fix that up and then feel free to add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>

						- Ted
