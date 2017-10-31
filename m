Return-Path: <tytso@thunk.org>
Date: Tue, 31 Oct 2017 13:47:36 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v2] fscrypt: fix dereference of NULL user_key_payload
Message-ID: <20171031174736.q5meeukzbrtcugp2@thunk.org>
References: <20171009194618.67494-1-ebiggers3@gmail.com>
 <20171029102305.4ifapjehlrgwsqmu@thunk.org>
 <20171029163246.GA566@zzz.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171029163246.GA566@zzz.localdomain>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, keyrings@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Oct 29, 2017 at 09:32:46AM -0700, Eric Biggers wrote:
> 
> Hi Ted, you should drop this one, since it's already in mainline; David Howells
> ended up taking the original series via the keyrings tree.

Ah, I see it landed in v4.14-rc6.  I'll drop it from the fscrypt tree.

      	     	       		   	     - Ted
