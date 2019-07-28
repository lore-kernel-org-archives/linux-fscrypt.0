Return-Path: <SRS0=TTB/=VZ=mit.edu=tytso@kernel.org>
Date: Sun, 28 Jul 2019 17:24:02 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v7 12/16] fscrypt: require that key be added when setting
 a v2 encryption policy
Message-ID: <20190728212402.GM6088@mit.edu>
References: <20190726224141.14044-1-ebiggers@kernel.org>
 <20190726224141.14044-13-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726224141.14044-13-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-api@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Satya Tangirala <satyat@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jul 26, 2019 at 03:41:37PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> By looking up the master keys in a filesystem-level keyring rather than
> in the calling processes' key hierarchy, it becomes possible for a user
> to set an encryption policy which refers to some key they don't actually
> know, then encrypt their files using that key.  Cryptographically this
> isn't much of a problem, but the semantics of this would be a bit weird.
> Thus, enforce that a v2 encryption policy can only be set if the user
> has previously added the key, or has capable(CAP_FOWNER).
> 
> We tolerate that this problem will continue to exist for v1 encryption
> policies, however; there is no way around that.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, feel free to add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>

					- Ted
