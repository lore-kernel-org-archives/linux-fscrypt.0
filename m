Return-Path: <SRS0=+d/j=TV=mit.edu=tytso@kernel.org>
Date: Mon, 20 May 2019 20:16:36 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v6 00/16] fscrypt: key management improvements
Message-ID: <20190521001636.GA2369@mit.edu>
References: <20190520172552.217253-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520172552.217253-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>, linux-api@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, keyrings@vger.kernel.org, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 20, 2019 at 10:25:36AM -0700, Eric Biggers wrote:
> 
> This patchset makes major improvements to how keys are added, removed,
> and derived in fscrypt, aka ext4/f2fs/ubifs encryption.  It does this by
> adding new ioctls that add and remove encryption keys directly to/from
> the filesystem, and by adding a new encryption policy version ("v2")
> where the user-provided keys are only used as input to HKDF-SHA512 and
> are identified by their cryptographic hash.

Do you have userspace programs which use these new ioctl's?  What's
are testing strategy for these new ioctls?

Thanks,

						- Ted
