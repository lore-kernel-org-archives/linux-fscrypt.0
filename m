Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:59594 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751063AbeEUAzQ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 20 May 2018 20:55:16 -0400
Date: Sun, 20 May 2018 20:55:02 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: use unbound workqueue for decryption
Message-ID: <20180521005502.GA4464@thunk.org>
References: <20180420233002.134687-1-ebiggers@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420233002.134687-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Paul Crowley <paulcrowley@google.com>, Enric Balletbo i Serra <enric.balletbo@collabora.com>, Mikulas Patocka <mpatocka@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Apr 20, 2018 at 04:30:02PM -0700, Eric Biggers wrote:
> Improve fscrypt read performance by switching the decryption workqueue
> from bound to unbound.  With the bound workqueue, when multiple bios
> completed on the same CPU, they were decrypted on that same CPU.  But
> with the unbound queue, they are now decrypted in parallel on any CPU.
> 
> Although fscrypt read performance can be tough to measure due to the
> many sources of variation, this change is most beneficial when
> decryption is slow, e.g. on CPUs without AES instructions.  For example,
> I timed tarring up encrypted directories on f2fs.  On x86 with AES-NI
> instructions disabled, the unbound workqueue improved performance by
> about 25-35%, using 1 to NUM_CPUs jobs with 4 or 8 CPUs available.  But
> with AES-NI enabled, performance was unchanged to within ~2%.
> 
> I also did the same test on a quad-core ARM CPU using xts-speck128-neon
> encryption.  There performance was usually about 10% better with the
> unbound workqueue, bringing it closer to the unencrypted speed.
> 
> The unbound workqueue may be worse in some cases due to worse locality,
> but I think it's still the better default.  dm-crypt uses an unbound
> workqueue by default too, so this change makes fscrypt match.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied, thanks.

						- Ted
