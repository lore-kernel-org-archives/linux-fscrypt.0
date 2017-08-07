Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:44854 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751247AbdHGNzP (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 7 Aug 2017 09:55:15 -0400
Date: Mon, 7 Aug 2017 09:55:13 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [GIT PULL] ext4 bug fixes for 4.13
Message-ID: <20170807135513.6d4d2z6uv52f4pki@thunk.org>
References: <20170806192703.5xelufkwd2a4jkha@thunk.org>
 <CA+55aFz+_-KRuOHRrOaaTYGcUgWtn4aFm=C4sUCtGRs8BBgJMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz+_-KRuOHRrOaaTYGcUgWtn4aFm=C4sUCtGRs8BBgJMw@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Aug 06, 2017 at 12:39:23PM -0700, Linus Torvalds wrote:
> On Sun, Aug 6, 2017 at 12:27 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> >
> > A large number of ext4 bug fixes and cleanups for v4.13
> 
> A couple of these appear to be neither cleanups nor fixes. And a lot
> of them appear to be very recent.
> 
> I've pulled this, but if I hear about problems, ext4 is going to be on
> my shit-list, and you'd better be a *lot* more careful about pull
> requests. Because this is not ok.

Sorry, I'll be conservative in sending pull requests to you in the
future.  The one commit that wasn't a bug fix, cleanup, or prereq for
a bugfix/cleanup was an optimization for a feature that landed during
this merge window (large xattrs using xattr inodes).

The patches did go through a full regression test cycle, and
everything was reviewed by at least a second person, but yeah, -rc4 is
getting a bit late in the cycle.  I certainly wouldn't have sent it
any later...

					- Ted
					
