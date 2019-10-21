Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:40524 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729406AbfJUU1w (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 21 Oct 2019 16:27:52 -0400
Date: Mon, 21 Oct 2019 13:27:50 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fscrypt: invoke crypto API for ESSIV handling
Message-ID: <20191021202749.GA122863@gmail.com>
References: <20191009233840.224128-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191009233840.224128-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-crypto@vger.kernel.org, linux-mtd@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Oct 09, 2019 at 04:38:40PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Instead of open-coding the calculations for ESSIV handling, use an ESSIV
> skcipher which does all of this under the hood.  ESSIV was added to the
> crypto API in v5.4.
> 
> This is based on a patch from Ard Biesheuvel, but reworked to apply
> after all the fscrypt changes that went into v5.4.
> 
> Tested with 'kvm-xfstests -c ext4,f2fs -g encrypt', including the
> ciphertext verification tests for v1 and v2 encryption policies.
> 
> Originally-from: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---

Applied to fscrypt.git for 5.5.

- Eric
