Return-Path: <SRS0=mLUp=WJ=mit.edu=tytso@kernel.org>
Date: Mon, 12 Aug 2019 20:15:55 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v8 15/20] fscrypt: add
 FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS ioctl
Message-ID: <20190813001555.GJ28705@mit.edu>
References: <20190805162521.90882-1-ebiggers@kernel.org>
 <20190805162521.90882-16-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805162521.90882-16-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, linux-api@vger.kernel.org, Satya Tangirala <satyat@google.com>, Paul Crowley <paulcrowley@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 05, 2019 at 09:25:16AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add a root-only variant of the FS_IOC_REMOVE_ENCRYPTION_KEY ioctl which
> removes all users' claims of the key, not just the current user's claim.
> I.e., it always removes the key itself, no matter how many users have
> added it.
> 
> This is useful for forcing a directory to be locked, without having to
> figure out which user ID(s) the key was added under.  This is planned to
> be used by a command like 'sudo fscrypt lock DIR --all-users' in the
> fscrypt userspace tool (http://github.com/google/fscrypt).
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, thanks.   Feel free to add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>
