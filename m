Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:32930 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728262AbfHNW3s (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 14 Aug 2019 18:29:48 -0400
Date: Wed, 14 Aug 2019 15:29:46 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fscrypt: remove loadable module related code
Message-ID: <20190814222945.GB101319@gmail.com>
References: <20190724194438.39975-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724194438.39975-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jul 24, 2019 at 12:44:38PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Since commit 643fa9612bf1 ("fscrypt: remove filesystem specific build
> config option"), fs/crypto/ can no longer be built as a loadable module.
> Thus it no longer needs a module_exit function, nor a MODULE_LICENSE.
> So remove them, and change module_init to late_initcall.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied to fscrypt tree for 5.4.

- Eric
