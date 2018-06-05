Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:38228 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751819AbeFERCL (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Jun 2018 13:02:11 -0400
Date: Tue, 5 Jun 2018 13:02:08 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [GIT PULL] fscrypt updates for 4.18
Message-ID: <20180605170208.GE7839@thunk.org>
References: <20180605150751.GA9436@thunk.org>
 <CAFLxGvysjYbCpkqbVqD8Q1v3isGnRrNo5KdUn7TgCVt9WxzE2g@mail.gmail.com>
 <20180605153501.GC7839@thunk.org>
 <30587992.7Od65ROsjm@blindfold>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <30587992.7Od65ROsjm@blindfold>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Richard Weinberger <richard@sigma-star.at>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jun 05, 2018 at 06:10:24PM +0200, Richard Weinberger wrote:
> That's the question. I understand the use case, but I fear attack scenarios
> where someone manages to downgrade the crypto of my phone.
> This is why I was asking whether Android tells me whether Speck is used or not.
> "it does encryption" is clearly not enough.

An attack scenario where someone manages to downgrade the crypto of
your phone would require replacing your kernel and your /system
partition --- at which point, you've got other problems.  :-)

	      	       	      	     	 - Ted
