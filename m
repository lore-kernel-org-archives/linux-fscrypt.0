Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33252 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726166AbfHNWbr (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 14 Aug 2019 18:31:47 -0400
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id BEB7D2064A
        for <linux-fscrypt@vger.kernel.org>; Wed, 14 Aug 2019 22:31:46 +0000 (UTC)
Date: Wed, 14 Aug 2019 15:31:45 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 0/4] fscrypt: logging improvements, and use ENOPKG
Message-ID: <20190814223144.GD101319@gmail.com>
References: <20190724195422.42495-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724195422.42495-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jul 24, 2019 at 12:54:18PM -0700, Eric Biggers wrote:
> Patches 1-3 make some small improvements to warning and error messages
> in fs/crypto/, including logging all types of unsupported encryption
> contexts rather than just ones where the encryption modes are invalid.
> 
> Patch 4 changes the error code for "missing crypto API support" from
> ENOENT to ENOPKG, to avoid an ambiguity.  This is a logically separate
> change, but it's in this series to avoid conflicts.
> 
> Eric Biggers (4):
>   fscrypt: make fscrypt_msg() take inode instead of super_block
>   fscrypt: improve warning messages for unsupported encryption contexts
>   fscrypt: improve warnings for missing crypto API support
>   fscrypt: use ENOPKG when crypto API support missing
> 
>  fs/crypto/crypto.c          | 13 ++++----
>  fs/crypto/fname.c           |  8 ++---
>  fs/crypto/fscrypt_private.h | 10 +++---
>  fs/crypto/hooks.c           |  6 ++--
>  fs/crypto/keyinfo.c         | 61 +++++++++++++++++++++++++------------
>  5 files changed, 57 insertions(+), 41 deletions(-)
> 
> -- 
> 2.22.0.657.g960e92d24f-goog
> 

All applied to fscrypt tree for 5.4.

- Eric
