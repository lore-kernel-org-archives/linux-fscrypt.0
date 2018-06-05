Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:37824 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751807AbeFEPfD (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Jun 2018 11:35:03 -0400
Date: Tue, 5 Jun 2018 11:35:01 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [GIT PULL] fscrypt updates for 4.18
Message-ID: <20180605153501.GC7839@thunk.org>
References: <20180605150751.GA9436@thunk.org>
 <CAFLxGvysjYbCpkqbVqD8Q1v3isGnRrNo5KdUn7TgCVt9WxzE2g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFLxGvysjYbCpkqbVqD8Q1v3isGnRrNo5KdUn7TgCVt9WxzE2g@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jun 05, 2018 at 05:13:35PM +0200, Richard Weinberger wrote:
> > Add bunch of cleanups, and add support for the Speck128/256
> > algorithms.  Yes, Speck is contrversial, but the intention is to use
> > them only for the lowest end Android devices, where the alternative
> > *really* is no encryption at all for data stored at rest.
> 
> Will Android tell me that Speck is being used?

Well, today Android doesn't tell you, "Your files aren't being
encrypted" in some big dialog box.  :-)  

Whether a phone is using no encryption or not, and what encryption
algorithm, is fundamentally a property of the phone.  It's used to
encrypt data at rest on the phone, so this isn't a data interchange
issue.  I'm sure there will be some way of finding out --- by looking
at the source code for that phone, if nothing else.

But I suspect that if you are buying a phone in a first world country,
you're never going to see a phone with Speck on it --- unless you
build your own AOSP build and deliberately enable it for yourself,
anyway.  :-)

This is really intended for "The Next Billion Users"; phones like
Android Go that was disclosed at the 2017 Google I/O conference, where
the unsubsidized price is well under $100 USD (so cheaper than the
original OLPC target).

						- Ted
