Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:54466 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750929AbeDYFal (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 25 Apr 2018 01:30:41 -0400
Date: Wed, 25 Apr 2018 01:30:28 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 0/5] crypto: Speck support
Message-ID: <20180425053028.GA3412@thunk.org>
References: <20180212235209.117393-1-ebiggers@google.com>
 <CAHmME9oA4j=iGrrBYME92JfUsyi5r42PnAvzWiuXzGCRXMnXtA@mail.gmail.com>
 <20180424181623.GA174675@google.com>
 <CAHmME9qG+nPmj5c7hU4+STUsmWmwSBsKe-0mOLEXH+hJ1z4z=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHmME9qG+nPmj5c7hU4+STUsmWmwSBsKe-0mOLEXH+hJ1z4z=g@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Eric Biggers <ebiggers@google.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tashur@esat.kuleuven.be
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 24, 2018 at 10:58:35PM +0200, Jason A. Donenfeld wrote:
> > Note that Linux
> > doesn't bow down to any particular standards organization, and it offers
> > algorithms that were specified in various places, even some with no more than a
> > publication by the author.  In fact, support for SM4 was just added too, which
> > is a Chinese government standard.  Are you going to send a patch to remove that
> > too, or is it just NSA designed algorithms that are not okay?
> 
> No need to be belittling; I have much less tinfoil strapped around my
> head than perhaps you think. I'm not blindly opposed to
> government-designed algorithms. Take SHA2, for example -- built by the
> NSA.
> 
> But I do care quite a bit about using ciphers that have acceptance of
> the academic community and a large body of literature documenting its
> design decisions and analyzing it.....

So where is the large body of literature documenting the design
decisions of SM2?  Has it received as much analysis as Speck?  And if
not, why aren't you gunning after it?

					- Ted
