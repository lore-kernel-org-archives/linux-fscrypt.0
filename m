Return-Path: <smueller@chronox.de>
From: Stephan =?ISO-8859-1?Q?M=FCller?= <smueller@chronox.de>
Subject: Re: [PATCH 3/6] fscrypt: use HKDF-SHA512 to derive the per-inode encryption keys
Date: Thu, 13 Jul 2017 16:54:55 +0200
Message-ID: <2034167.Brpu2WxA6s@tauon.chronox.de>
In-Reply-To: <20170712210035.51534-4-ebiggers3@gmail.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com> <20170712210035.51534-4-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
To: herbert@gondor.apana.org.au
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Am Mittwoch, 12. Juli 2017, 23:00:32 CEST schrieb Eric Biggers:

Hi Herbert,

This patch adds a second KDF to the kernel -- the first is found in the keys 
subsystem.

The next KDF that may come in is in the TLS scope.

Would it make sense to warm up the KDF patches adding generic KDF support to 
the kernel crypto API that I supplied some time ago? The advantages would be 
to have one location of KDF implementations and the benefit of the testmgr.

Ciao
Stephan
