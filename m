Return-Path: <SRS0=0PEj=WL=redhat.com=dhowells@kernel.org>
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20190814222822.GA101319@gmail.com>
References: <20190814222822.GA101319@gmail.com>
Subject: Re: Merge resolution for fscrypt and keyrings trees
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <12088.1565876240.1@warthog.procyon.org.uk>
Date: Thu, 15 Aug 2019 14:37:20 +0100
Message-ID: <12089.1565876240@warthog.procyon.org.uk>
To: Eric Biggers <ebiggers@kernel.org>
Cc: dhowells@redhat.com, Stephen Rothwell <sfr@canb.auug.org.au>, linux-fscrypt@vger.kernel.org, linux-next@vger.kernel.org, keyrings@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Eric Biggers <ebiggers@kernel.org> wrote:

> +static struct key_acl fscrypt_keyring_acl = {
> +	.usage = REFCOUNT_INIT(1),
> +	.nr_ace	= 2,
> +	.aces = {
> +		KEY_POSSESSOR_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL |
> +				  KEY_ACE_JOIN),
> +		KEY_OWNER_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL | KEY_ACE_JOIN |
> +			      KEY_ACE_READ | KEY_ACE_VIEW),
> +	}
> +};

Does you really want JOIN permission for these keyrings?  Are you permitting
them to be used with KEYCTL_JOIN_SESSION_KEYRING?  Do you also want INVAL for
the keyring rather than just the keys it contains?  Would CLEAR be more
appropriate?

> +static struct key_acl fscrypt_key_acl = {
> +	.usage = REFCOUNT_INIT(1),
> +	.nr_ace	= 2,
> +	.aces = {
> +		KEY_POSSESSOR_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL |
> +				  KEY_ACE_JOIN),
> +		KEY_OWNER_ACE(KEY_ACE_SEARCH | KEY_ACE_INVAL | KEY_ACE_JOIN |
> +			      KEY_ACE_VIEW),
> +	}
> +};

JOIN permission is useless here.  This is only used for keys of type
key_type_fscrypt that I can see - and those aren't keyrings and so aren't
joinable.

> +static struct key_acl fscrypt_user_key_acl = {

Ditto.

David
