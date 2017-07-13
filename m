Return-Path: <ebiggers3@gmail.com>
Date: Thu, 13 Jul 2017 11:10:57 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 3/6] fscrypt: use HKDF-SHA512 to derive the per-inode
 encryption keys
Message-ID: <20170713181057.GA143898@gmail.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-4-ebiggers3@gmail.com>
 <2034167.Brpu2WxA6s@tauon.chronox.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2034167.Brpu2WxA6s@tauon.chronox.de>
To: Stephan =?iso-8859-1?Q?M=FCller?= <smueller@chronox.de>
Cc: herbert@gondor.apana.org.au, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Stephan,

On Thu, Jul 13, 2017 at 04:54:55PM +0200, Stephan M�ller wrote:
> Am Mittwoch, 12. Juli 2017, 23:00:32 CEST schrieb Eric Biggers:
> 
> Hi Herbert,
> 
> This patch adds a second KDF to the kernel -- the first is found in the keys 
> subsystem.
> 
> The next KDF that may come in is in the TLS scope.
> 
> Would it make sense to warm up the KDF patches adding generic KDF support to 
> the kernel crypto API that I supplied some time ago? The advantages would be 
> to have one location of KDF implementations and the benefit of the testmgr.
> 

That may be a good idea.  Looking at the old thread, I share Herbert's concern
(http://www.spinics.net/lists/linux-crypto/msg21231.html) about there likely not
being more than one implementation of each KDF algorithm.  So, perhaps some
simple helper functions would be more appropriate.  However, making the KDFs be
covered by self-tests would be very nice.

Also, it seems your patch
(http://www.spinics.net/lists/linux-crypto/msg21137.html) doesn't allow a salt
to be passed in.  In order to fully support HKDF, crypto_rng_reset() (which as I
understand would be the way to invoke the "extract" step) would somehow need to
accept both the input keying material and salt, both of which are arbitrary
length binary.

Eric
