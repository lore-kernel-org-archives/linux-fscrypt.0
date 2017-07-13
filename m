Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:53404 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdGMQIo (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 13 Jul 2017 12:08:44 -0400
Date: Fri, 14 Jul 2017 00:07:54 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/6] fscrypt: use HKDF-SHA512 to derive the per-inode
 encryption keys
Message-ID: <20170713160753.GA25989@gondor.apana.org.au>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-4-ebiggers3@gmail.com>
 <2034167.Brpu2WxA6s@tauon.chronox.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2034167.Brpu2WxA6s@tauon.chronox.de>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Stephan =?iso-8859-1?Q?M=FCller?= <smueller@chronox.de>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

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

Sure.  Though I'd like to see what it looks like before I commit :)

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
