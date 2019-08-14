Date: Wed, 14 Aug 2019 15:37:25 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v8 00/20] fscrypt: key management improvements
Message-ID: <20190814223725.GF101319@gmail.com>
References: <20190805162521.90882-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805162521.90882-1-ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: Satya Tangirala <satyat@google.com>, Theodore Ts'o <tytso@mit.edu>, linux-api@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, keyrings@vger.kernel.org, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 05, 2019 at 09:25:01AM -0700, Eric Biggers wrote:
> Hello,
> 
> [Note: I'd like to apply this for v5.4.  Additional review is greatly
>  appreciated, especially of the API before it's set in stone.  Thanks!]
> 
> This patchset makes major improvements to how keys are added, removed,
> and derived in fscrypt, aka ext4/f2fs/ubifs encryption.  It does this by
> adding new ioctls that add and remove encryption keys directly to/from
> the filesystem, and by adding a new encryption policy version ("v2")
> where the user-provided keys are only used as input to HKDF-SHA512 and
> are identified by their cryptographic hash.
> 
> All new APIs and all cryptosystem changes are documented in
> Documentation/filesystems/fscrypt.rst.  Userspace can use the new key
> management ioctls with existing encrypted directories, but migrating to
> v2 encryption policies is needed for the full benefits.
> 

I've applied this patchset to the fscrypt tree for 5.4.

- Eric
