Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Sun, 20 May 2018 21:08:00 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2] fscrypt: log the crypto algorithm implementations
Message-ID: <20180521010800.GD4464@thunk.org>
References: <20180518175814.84006-1-ebiggers@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180518175814.84006-1-ebiggers@google.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: linux-fscrypt@vger.kernel.org, linux-crypto@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, May 18, 2018 at 10:58:14AM -0700, Eric Biggers wrote:
> Log the crypto algorithm driver name for each fscrypt encryption mode on
> its first use, also showing a friendly name for the mode.
> 
> This will help people determine whether the expected implementations are
> being used.  In some cases we've seen people do benchmarks and reject
> using encryption for performance reasons, when in fact they used a much
> slower implementation of AES-XTS than was possible on the hardware.  It
> can make an enormous difference; e.g., AES-XTS on ARM is about 10x
> faster with the crypto extensions (AES instructions) than without.
> 
> This also makes it more obvious which modes are being used, now that
> fscrypt supports multiple combinations of modes.
> 
> Example messages (with default modes, on x86_64):
> 
> [   35.492057] fscrypt: AES-256-CTS-CBC using implementation "cts(cbc-aes-aesni)"
> [   35.492171] fscrypt: AES-256-XTS using implementation "xts-aes-aesni"
> 
> Note: algorithms can be dynamically added to the crypto API, which can
> result in different implementations being used at different times.  But
> this is rare; for most users, showing the first will be good enough.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied, thanks.

					- Ted
