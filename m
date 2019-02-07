Return-Path: <keyrings-owner@vger.kernel.org>
Date: Thu, 7 Feb 2019 15:35:10 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] KEYS: user: Align the payload buffer
Message-ID: <20190207233509.GA125156@gmail.com>
References: <20190115033716.18380-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115033716.18380-1-ebiggers@kernel.org>
Sender: keyrings-owner@vger.kernel.org
To: keyrings@vger.kernel.org, David Howells <dhowells@redhat.com>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jan 14, 2019 at 07:37:16PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Align the payload of "user" and "logon" keys so that users of the
> keyrings service can access it as a struct that requires more than
> 2-byte alignment.  fscrypt currently does this which results in the read
> of fscrypt_key::size being misaligned as it needs 4-byte alignment.
> 
> Align to __alignof__(u64) rather than __alignof__(long) since in the
> future it's conceivable that people would use structs beginning with
> u64, which on some platforms would require more than 'long' alignment.
> 
> Reported-by: Aaro Koskinen <aaro.koskinen@iki.fi>
> Fixes: 2aa349f6e37c ("[PATCH] Keys: Export user-defined keyring operations")
> Fixes: 88bd6ccdcdd6 ("ext4 crypto: add encryption key management facilities")
> Cc: stable@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  include/keys/user-type.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/keys/user-type.h b/include/keys/user-type.h
> index e098cbe27db54..12babe9915944 100644
> --- a/include/keys/user-type.h
> +++ b/include/keys/user-type.h
> @@ -31,7 +31,7 @@
>  struct user_key_payload {
>  	struct rcu_head	rcu;		/* RCU destructor */
>  	unsigned short	datalen;	/* length of this data */
> -	char		data[0];	/* actual data */
> +	char		data[0] __aligned(__alignof__(u64)); /* actual data */
>  };
>  
>  extern struct key_type key_type_user;
> -- 
> 2.20.1
> 

Ping.  David, are you planning to apply this?

- Eric
