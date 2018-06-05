Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:39342 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752708AbeFEVMl (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Jun 2018 17:12:41 -0400
Date: Tue, 5 Jun 2018 17:12:38 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [GIT PULL] fscrypt updates for 4.18
Message-ID: <20180605211238.GH7839@thunk.org>
References: <20180605150751.GA9436@thunk.org>
 <30587992.7Od65ROsjm@blindfold>
 <20180605170208.GE7839@thunk.org>
 <5151941.CDXohbuWeC@blindfold>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5151941.CDXohbuWeC@blindfold>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Richard Weinberger <richard@sigma-star.at>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jun 05, 2018 at 07:05:52PM +0200, Richard Weinberger wrote:
> > An attack scenario where someone manages to downgrade the crypto of
> > your phone would require replacing your kernel and your /system
> > partition --- at which point, you've got other problems.  :-)
> 
> This means Speck is never enabled at kernel level on non-cheap phones?

No.  And even if it were, the /system partition is going to request
that the kernel encrypt files using one and only encryption algorithm:
namely, AES.

Things aren't as configurable on an Android phone as you might be used
to on a laptop.  Some manufacturers use ext4; some manufacturers
decide they want to use f2fs.  They make that decision not you, and
only the file system utilities for that one file system are compiled
into the system.

Similarly, you don't get to choose what crypto algorithm you use;
that's decided for you by the manufacturer.  Which is good; it's one
less thing that hte attacker can spoof, and one less thing for users
to potentially get wrong.

					- Ted
