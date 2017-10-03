Return-Path: <jmorris@namei.org>
Date: Tue, 3 Oct 2017 22:01:21 +1100 (AEDT)
From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 5/7] ecryptfs: fix dereference of NULL user_key_payload
In-Reply-To: <20170928212602.41744-6-ebiggers3@gmail.com>
Message-ID: <alpine.LRH.2.21.1710032158230.25033@namei.org>
References: <20170928212602.41744-1-ebiggers3@gmail.com> <20170928212602.41744-6-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: Eric Biggers <ebiggers3@gmail.com>
Cc: keyrings@vger.kernel.org, David Howells <dhowells@redhat.com>, Michael Halcrow <mhalcrow@google.com>, linux-cachefs@redhat.com, ecryptfs@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, 28 Sep 2017, Eric Biggers wrote:

> From: Eric Biggers <ebiggers@google.com>
> 
> In eCryptfs, we failed to verify that the authentication token keys are
> not revoked before dereferencing their payloads, which is problematic
> because the payload of a revoked key is NULL.  request_key() *does* skip
> revoked keys, but there is still a window where the key can be revoked
> before we acquire the key semaphore.
> 
> Fix it by updating ecryptfs_get_key_payload_data() to return
> -EKEYREVOKED if the key payload is NULL.  For completeness we check this
> for "encrypted" keys as well as "user" keys, although encrypted keys
> cannot be revoked currently.
> 
> Alternatively we could use key_validate(), but since we'll also need to
> fix ecryptfs_get_key_payload_data() to validate the payload length, it
> seems appropriate to just check the payload pointer.
> 
> Fixes: 237fead61998 ("[PATCH] ecryptfs: fs/Makefile and fs/Kconfig")
> Cc: <stable@vger.kernel.org>    [v2.6.19+]
> Signed-off-by: Eric Biggers <ebiggers@google.com>

(A further cleanup might add some inline accessor functions for key data, 
but it's not necessary now).

Reviewed-by: James Morris <james.l.morris@oracle.com>

-- 
James Morris
<jmorris@namei.org>
