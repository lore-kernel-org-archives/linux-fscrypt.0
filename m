Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57200 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725821AbfIYXLu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 25 Sep 2019 19:11:50 -0400
Date: Wed, 25 Sep 2019 16:11:48 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 3/8] xfs_io/encrypt: add new encryption modes
Message-ID: <20190925231147.GB3163@gmail.com>
References: <20190812175635.34186-1-ebiggers@kernel.org>
 <20190812175635.34186-4-ebiggers@kernel.org>
 <20190924224744.GD2229799@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190924224744.GD2229799@magnolia>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Sep 24, 2019 at 03:47:44PM -0700, Darrick J. Wong wrote:
> On Mon, Aug 12, 2019 at 10:56:29AM -0700, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Add new encryption modes: AES-128-CBC and AES-128-CTS (supported since
> > Linux v4.11), and Adiantum (supported since Linux v5.0).
> > 
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> >  io/encrypt.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/io/encrypt.c b/io/encrypt.c
> > index ac473ed7..11eb4a3e 100644
> > --- a/io/encrypt.c
> > +++ b/io/encrypt.c
> > @@ -156,7 +156,7 @@ set_encpolicy_help(void)
> >  " -v VERSION -- version of policy structure\n"
> >  "\n"
> >  " MODE can be numeric or one of the following predefined values:\n"
> > -"    AES-256-XTS, AES-256-CTS\n"
> > +"    AES-256-XTS, AES-256-CTS, AES-128-CBC, AES-128-CTS, Adiantum\n"
> 
> What do you think of generating the list of predefined values from
> the available_modes[] array?  Then you wouldn't have to keep the help
> text in sync with the C definitions, since it's not like there's a
> meaningful translation for them anyway.
> 

Yes, good idea.  I'll do that.

- Eric
