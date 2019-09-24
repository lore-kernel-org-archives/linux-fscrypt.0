Return-Path: <SRS0=cHzQ=XT=oracle.com=darrick.wong@kernel.org>
Date: Tue, 24 Sep 2019 15:47:44 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 3/8] xfs_io/encrypt: add new encryption modes
Message-ID: <20190924224744.GD2229799@magnolia>
References: <20190812175635.34186-1-ebiggers@kernel.org>
 <20190812175635.34186-4-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812175635.34186-4-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-xfs@vger.kernel.org, fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 12, 2019 at 10:56:29AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add new encryption modes: AES-128-CBC and AES-128-CTS (supported since
> Linux v4.11), and Adiantum (supported since Linux v5.0).
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  io/encrypt.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/io/encrypt.c b/io/encrypt.c
> index ac473ed7..11eb4a3e 100644
> --- a/io/encrypt.c
> +++ b/io/encrypt.c
> @@ -156,7 +156,7 @@ set_encpolicy_help(void)
>  " -v VERSION -- version of policy structure\n"
>  "\n"
>  " MODE can be numeric or one of the following predefined values:\n"
> -"    AES-256-XTS, AES-256-CTS\n"
> +"    AES-256-XTS, AES-256-CTS, AES-128-CBC, AES-128-CTS, Adiantum\n"

What do you think of generating the list of predefined values from
the available_modes[] array?  Then you wouldn't have to keep the help
text in sync with the C definitions, since it's not like there's a
meaningful translation for them anyway.

--D

>  " FLAGS and VERSION must be numeric.\n"
>  "\n"
>  " Note that it's only possible to set an encryption policy on an empty\n"
> @@ -170,6 +170,9 @@ static const struct {
>  } available_modes[] = {
>  	{FSCRYPT_MODE_AES_256_XTS, "AES-256-XTS"},
>  	{FSCRYPT_MODE_AES_256_CTS, "AES-256-CTS"},
> +	{FSCRYPT_MODE_AES_128_CBC, "AES-128-CBC"},
> +	{FSCRYPT_MODE_AES_128_CTS, "AES-128-CTS"},
> +	{FSCRYPT_MODE_ADIANTUM, "Adiantum"},
>  };
>  
>  static bool
> -- 
> 2.23.0.rc1.153.gdeed80330f-goog
> 
