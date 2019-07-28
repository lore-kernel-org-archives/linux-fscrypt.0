Return-Path: <SRS0=TTB/=VZ=mit.edu=tytso@kernel.org>
Date: Sun, 28 Jul 2019 17:22:26 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v7 11/16] fscrypt: allow unprivileged users to add/remove
 keys for v2 policies
Message-ID: <20190728212226.GL6088@mit.edu>
References: <20190726224141.14044-1-ebiggers@kernel.org>
 <20190726224141.14044-12-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726224141.14044-12-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-api@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Satya Tangirala <satyat@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jul 26, 2019 at 03:41:36PM -0700, Eric Biggers wrote:
> diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
> index 56e085c2ed8c6..307533d4d7c51 100644
> --- a/fs/crypto/keyring.c
> +++ b/fs/crypto/keyring.c
> +		if (mk->mk_users->keys.nr_leaves_on_tree != 0) {
> +			/*
> +			 * Other users have still added the key too.  We removed
> +			 * the current user's usage of the key if there was one,
> +			 * but we still can't remove the key itself.
> +			 */
> +			err = -EUSERS;
> +			up_write(&key->sem);
> +			goto out_put_key;

I commented about this on an earlier patch, but I'm not convinced we
should be returning EUSERS here.  Returning success might be a better
choice.

					- Ted
