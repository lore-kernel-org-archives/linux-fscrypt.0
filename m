Return-Path: <SRS0=RJsC=SS=mit.edu=tytso@kernel.org>
Date: Tue, 16 Apr 2019 18:45:24 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: remove WARN_ON_ONCE() when decryption fails
Message-ID: <20190416224524.GA13432@mit.edu>
References: <20190315211632.231638-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315211632.231638-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Mar 15, 2019 at 02:16:32PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> If decrypting a block fails, fscrypt did a WARN_ON_ONCE().  But WARN is
> meant for kernel bugs, which this isn't; this could be hit by fuzzers
> using fault injection, for example.  Also, there is already a proper
> warning message logged in fscrypt_do_page_crypto(), so the WARN doesn't
> add much.
> 
> Just remove the unnessary WARN.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, applied.

					- Ted
