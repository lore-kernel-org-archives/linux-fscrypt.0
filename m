Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from lilium.sigma-star.at ([109.75.188.150]:41238 "EHLO
        lilium.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753383AbeFERFz (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Jun 2018 13:05:55 -0400
From: Richard Weinberger <richard@sigma-star.at>
Subject: Re: [GIT PULL] fscrypt updates for 4.18
Date: Tue, 05 Jun 2018 19:05:52 +0200
Message-ID: <5151941.CDXohbuWeC@blindfold>
In-Reply-To: <20180605170208.GE7839@thunk.org>
References: <20180605150751.GA9436@thunk.org> <30587992.7Od65ROsjm@blindfold> <20180605170208.GE7839@thunk.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Am Dienstag, 5. Juni 2018, 19:02:08 CEST schrieb Theodore Y. Ts'o:
> On Tue, Jun 05, 2018 at 06:10:24PM +0200, Richard Weinberger wrote:
> > That's the question. I understand the use case, but I fear attack scenarios
> > where someone manages to downgrade the crypto of my phone.
> > This is why I was asking whether Android tells me whether Speck is used or not.
> > "it does encryption" is clearly not enough.
> 
> An attack scenario where someone manages to downgrade the crypto of
> your phone would require replacing your kernel and your /system
> partition --- at which point, you've got other problems.  :-)

This means Speck is never enabled at kernel level on non-cheap phones?

Thanks,
//richard

-- 
sigma star gmbh - Eduard-Bodem-Gasse 6 - 6020 Innsbruck - Austria
ATU66964118 - FN 374287y
