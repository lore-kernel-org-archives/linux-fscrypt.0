Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57220 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725925AbfG3DrH (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 29 Jul 2019 23:47:07 -0400
Date: Mon, 29 Jul 2019 20:47:04 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: linux-next: build warnings after merge of the keys tree
Message-ID: <20190730034704.GA1966@sol.localdomain>
References: <20190730123042.1f17cdd4@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730123042.1f17cdd4@canb.auug.org.au>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>, David Howells <dhowells@redhat.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Linux Next Mailing List <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jul 30, 2019 at 12:30:42PM +1000, Stephen Rothwell wrote:
> Subject: [PATCH] fsverity: merge fix for keyring_alloc API change
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  fs/verity/signature.c | 17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/verity/signature.c b/fs/verity/signature.c
> index c8b255232de5..a7aac30c56ae 100644
> --- a/fs/verity/signature.c
> +++ b/fs/verity/signature.c
> @@ -131,15 +131,26 @@ static inline int __init fsverity_sysctl_init(void)
>  }
>  #endif /* !CONFIG_SYSCTL */
>  
> +static struct key_acl fsverity_acl = {
> +	.usage	= REFCOUNT_INIT(1),
> +	.possessor_viewable = true,

I don't think .possessor_viewable should be set here, since there's no
KEY_POSSESSOR_ACE(KEY_ACE_VIEW) in the ACL.  David, this bool is supposed to
mean such an entry is present, right?  Is it really necessary, since it's
redundant with the ACL itself?

> +	.nr_ace	= 2,
> +	.aces = {
> +		KEY_POSSESSOR_ACE(KEY_ACE_SEARCH | KEY_ACE_JOIN |
> +				  KEY_ACE_INVAL),
> +		KEY_OWNER_ACE(KEY_ACE_VIEW | KEY_ACE_READ | KEY_ACE_WRITE |
> +			      KEY_ACE_CLEAR | KEY_ACE_SEARCH |
> +			      KEY_ACE_SET_SECURITY | KEY_ACE_REVOKE),
> +	}
> +};
> +
>  int __init fsverity_init_signature(void)
>  {
>  	struct key *ring;
>  	int err;
>  
>  	ring = keyring_alloc(".fs-verity", KUIDT_INIT(0), KGIDT_INIT(0),
> -			     current_cred(), KEY_POS_SEARCH |
> -				KEY_USR_VIEW | KEY_USR_READ | KEY_USR_WRITE |
> -				KEY_USR_SEARCH | KEY_USR_SETATTR,
> +			     current_cred(), &fsverity_acl,
>  			     KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);

Otherwise this looks good, thanks Stephen.  I'll want to remove a few of these
permissions in a separate patch later, but for now we can just keep it
equivalent to the original code as you've done.

We'll have the same problem in fs/crypto/ in a week or two if/when I apply
another patch series.  For that one I'll send you a merge resolution so you
don't have to do it yourself...

Thanks,

- Eric
