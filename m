Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from lilium.sigma-star.at ([109.75.188.150]:40010 "EHLO
        lilium.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbeFEQK2 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Jun 2018 12:10:28 -0400
From: Richard Weinberger <richard@sigma-star.at>
Subject: Re: [GIT PULL] fscrypt updates for 4.18
Date: Tue, 05 Jun 2018 18:10:24 +0200
Message-ID: <30587992.7Od65ROsjm@blindfold>
In-Reply-To: <20180605153501.GC7839@thunk.org>
References: <20180605150751.GA9436@thunk.org> <CAFLxGvysjYbCpkqbVqD8Q1v3isGnRrNo5KdUn7TgCVt9WxzE2g@mail.gmail.com> <20180605153501.GC7839@thunk.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Am Dienstag, 5. Juni 2018, 17:35:01 CEST schrieb Theodore Y. Ts'o:
> On Tue, Jun 05, 2018 at 05:13:35PM +0200, Richard Weinberger wrote:
> > > Add bunch of cleanups, and add support for the Speck128/256
> > > algorithms.  Yes, Speck is contrversial, but the intention is to use
> > > them only for the lowest end Android devices, where the alternative
> > > *really* is no encryption at all for data stored at rest.
> > 
> > Will Android tell me that Speck is being used?
> 
> Well, today Android doesn't tell you, "Your files aren't being
> encrypted" in some big dialog box.  :-)  
> 
> Whether a phone is using no encryption or not, and what encryption
> algorithm, is fundamentally a property of the phone.  It's used to
> encrypt data at rest on the phone, so this isn't a data interchange
> issue.  I'm sure there will be some way of finding out --- by looking
> at the source code for that phone, if nothing else.
> 
> But I suspect that if you are buying a phone in a first world country,
> you're never going to see a phone with Speck on it --- unless you
> build your own AOSP build and deliberately enable it for yourself,
> anyway.  :-)

That's the question. I understand the use case, but I fear attack scenarios
where someone manages to downgrade the crypto of my phone.
This is why I was asking whether Android tells me whether Speck is used or not.
"it does encryption" is clearly not enough.

Thanks,
//richard

P.s. Sorry for hijacking this PR. :-)

-- 
sigma star gmbh - Eduard-Bodem-Gasse 6 - 6020 Innsbruck - Austria
ATU66964118 - FN 374287y
