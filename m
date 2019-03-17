Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33180 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726446AbfCQUWv (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 17 Mar 2019 16:22:51 -0400
Date: Sun, 17 Mar 2019 13:22:49 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: Update fscrypt git URL for linux-next
Message-ID: <20190317202248.GA689@sol.localdomain>
References: <20190312063422.GA9123@sol.localdomain>
 <20190317161908.03c8d104@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190317161908.03c8d104@canb.auug.org.au>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Mar 17, 2019 at 04:19:08PM +1100, Stephen Rothwell wrote:
> Hi Eric,
> 
> On Mon, 11 Mar 2019 23:34:23 -0700 Eric Biggers <ebiggers@kernel.org> wrote:
> >
> > Hi Stephen, we've updated the location of the fscrypt git tree:
> > 
> > Old URL: git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git
> > New URL: git://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git
> > 
> > Branch is still "master".
> > 
> > MAINTAINERS in mainline has already been updated accordingly.
> > 
> > Can you make sure to update the URL for linux-next too?
> 
> Done.  I have also updated the URL for the fscrypt-current tree (using
> the for-stable branch of the above new URL).  Should I also add you to
> the contacts for those trees (currently I only have Ted listed)?
> 

Yes, please add me to the contacts.

Thanks,

- Eric
