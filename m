Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-eopbgr810107.outbound.protection.outlook.com ([40.107.81.107]:36256
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726050AbfAFT4O (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 6 Jan 2019 14:56:14 -0500
Date: Sun, 6 Jan 2019 14:56:06 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [GIT PULL] fscrypt update for 4.21
Message-ID: <20190106195606.GA6741@mit.edu>
References: <20190106134912.GA27028@mit.edu>
 <20190106172005.GA699@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20190106172005.GA699@sol.localdomain>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Jan 06, 2019 at 09:20:07AM -0800, Eric Biggers wrote:

> Hi Ted, that tag is still on an old commit.  Probably you forgot to push.

My scripts check to see that it was right (at least from my view of
git.kernel.org) before it generates the push.  I just checked and it's
correct now, and I haven't done any intervening pushes.  I think it
must have been a stale cache entry that you saw?

	    	       	     	- Ted
