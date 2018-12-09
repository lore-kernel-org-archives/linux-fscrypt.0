Return-Path: <SRS0=7U2P=OS=thunk.org=tytso@kernel.org>
Date: Sun, 9 Dec 2018 16:56:40 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v4] fscrypt: add Adiantum support
Message-ID: <20181209215640.GC1840@mit.edu>
References: <20181126192737.129355-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181126192737.129355-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Nov 26, 2018 at 11:27:37AM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add support for the Adiantum encryption mode to fscrypt.  Adiantum is a
> tweakable, length-preserving encryption mode with security provably
> reducible to that of XChaCha12 and AES-256, subject to a security bound.
> It's also a true wide-block mode, unlike XTS.  See the paper
> "Adiantum: length-preserving encryption for entry-level processors"
> (https://eprint.iacr.org/2018/720.pdf) for more details.  Also see
> commit 059c2a4d8e16 ("crypto: adiantum - add Adiantum support").

Thanks, applied.

					- Ted
