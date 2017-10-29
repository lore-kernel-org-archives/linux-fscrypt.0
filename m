Return-Path: <tytso@thunk.org>
Date: Sun, 29 Oct 2017 06:23:05 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v2] fscrypt: fix dereference of NULL user_key_payload
Message-ID: <20171029102305.4ifapjehlrgwsqmu@thunk.org>
References: <20171009194618.67494-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009194618.67494-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, keyrings@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Oct 09, 2017 at 12:46:18PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> When an fscrypt-encrypted file is opened, we request the file's master
> key from the keyrings service as a logon key, then access its payload.
> However, a revoked key has a NULL payload, and we failed to check for
> this.  request_key() *does* skip revoked keys, but there is still a
> window where the key can be revoked before we acquire its semaphore.
> 
> Fix it by checking for a NULL payload, treating it like a key which was
> already revoked at the time it was requested.
> 
> Fixes: 88bd6ccdcdd6 ("ext4 crypto: add encryption key management facilities")
> Reviewed-by: James Morris <james.l.morris@oracle.com>
> Cc: <stable@vger.kernel.org>    [v4.1+]
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied, thanks.

					- Ted
