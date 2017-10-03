Return-Path: <jmorris@namei.org>
Date: Tue, 3 Oct 2017 21:51:06 +1100 (AEDT)
From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/7] KEYS: encrypted: fix dereference of NULL
 user_key_payload
In-Reply-To: <20170928212602.41744-2-ebiggers3@gmail.com>
Message-ID: <alpine.LRH.2.21.1710032150550.25033@namei.org>
References: <20170928212602.41744-1-ebiggers3@gmail.com> <20170928212602.41744-2-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: Eric Biggers <ebiggers3@gmail.com>
Cc: keyrings@vger.kernel.org, David Howells <dhowells@redhat.com>, Michael Halcrow <mhalcrow@google.com>, linux-cachefs@redhat.com, ecryptfs@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, 28 Sep 2017, Eric Biggers wrote:

> From: Eric Biggers <ebiggers@google.com>
> 
> A key of type "encrypted" references a "master key" which is used to
> encrypt and decrypt the encrypted key's payload.  However, when we
> accessed the master key's payload, we failed to handle the case where
> the master key has been revoked, which sets the payload pointer to NULL.
> Note that request_key() *does* skip revoked keys, but there is still a
> window where the key can be revoked before we acquire its semaphore.
> 
> Fix it by checking for a NULL payload, treating it like a key which was
> already revoked at the time it was requested.
> 
> This was an issue for master keys of type "user" only.  Master keys can
> also be of type "trusted", but those cannot be revoked.
> 
> Fixes: 7e70cb497850 ("keys: add new key-type encrypted")
> Cc: <stable@vger.kernel.org>    [v2.6.38+]
> Signed-off-by: Eric Biggers <ebiggers@google.com>


Reviewed-by: James Morris <james.l.morris@oracle.com>


-- 
James Morris
<jmorris@namei.org>
