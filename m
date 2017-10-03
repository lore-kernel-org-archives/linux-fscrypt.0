Return-Path: <jmorris@namei.org>
Date: Tue, 3 Oct 2017 21:52:54 +1100 (AEDT)
From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/7] lib/digsig: fix dereference of NULL
 user_key_payload
In-Reply-To: <20170928212602.41744-4-ebiggers3@gmail.com>
Message-ID: <alpine.LRH.2.21.1710032152430.25033@namei.org>
References: <20170928212602.41744-1-ebiggers3@gmail.com> <20170928212602.41744-4-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: Eric Biggers <ebiggers3@gmail.com>
Cc: keyrings@vger.kernel.org, David Howells <dhowells@redhat.com>, Michael Halcrow <mhalcrow@google.com>, linux-cachefs@redhat.com, ecryptfs@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, 28 Sep 2017, Eric Biggers wrote:

> From: Eric Biggers <ebiggers@google.com>
> 
> digsig_verify() requests a user key, then accesses its payload.
> However, a revoked key has a NULL payload, and we failed to check for
> this.  request_key() *does* skip revoked keys, but there is still a
> window where the key can be revoked before we acquire its semaphore.
> 
> Fix it by checking for a NULL payload, treating it like a key which was
> already revoked at the time it was requested.
> 
> Fixes: 051dbb918c7f ("crypto: digital signature verification support")
> Cc: <stable@vger.kernel.org>    [v3.3+]
> Signed-off-by: Eric Biggers <ebiggers@google.com>


Reviewed-by: James Morris <james.l.morris@oracle.com>

-- 
James Morris
<jmorris@namei.org>
