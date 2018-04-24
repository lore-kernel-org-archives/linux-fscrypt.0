Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36257 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbeDXWri (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 24 Apr 2018 18:47:38 -0400
Received: by mail-pf0-f176.google.com with SMTP id g14so13480678pfh.3
        for <linux-fscrypt@vger.kernel.org>; Tue, 24 Apr 2018 15:47:38 -0700 (PDT)
Date: Tue, 24 Apr 2018 15:47:34 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH v2 0/5] crypto: Speck support
Message-ID: <20180424224734.GA109345@google.com>
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
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tashur@esat.kuleuven.be
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jason,

On Tue, Apr 24, 2018 at 10:58:35PM +0200, Jason A. Donenfeld wrote:
> Hi Eric,
> 
> On Tue, Apr 24, 2018 at 8:16 PM, Eric Biggers <ebiggers@google.com> wrote:
> > So, what do you propose replacing it with?
> 
> Something more cryptographically justifiable.
> 

It's easy to say that, but do you have an actual suggestion?  As I mentioned,
for disk encryption without AES instructions the main alternatives we've
considered are ChaCha20 with reused nonces, an unpublished wide-block mode based
on ChaCha20 and Poly1305 (with no external cryptanalysis yet, and probably
actually using ChaCha8 or ChaCha12 to meet performance requirements), or the
status quo of no encryption at all.

It *might* be possible to add per-block metadata support to f2fs, in which it
could be used with ChaCha20 in fscrypt.  But if feasible at all it would be
quite difficult (requiring some significant filesystem surgery, and disabling
conflicting filesystem features that allow data to be updated in-place) and
would not cover dm-crypt, nor ext4.

Note also that many other lightweight block ciphers are designed for hardware
and perform poorly in software, e.g. PRESENT is even slower than AES.  Thus
there really weren't many options.

Any concrete suggestions are greatly appreciated!

> > outside crypto review, vs. the many cryptanalysis papers on Speck.  (In that
> > respect the controversy about Speck has actually become an advantage, as it has
> > received much more cryptanalysis than other lightweight block ciphers.)
> 
> That's the thing that worries me, actually. Many of the design
> decisions behind Speck haven't been justified.
> 

Originally that was true, but later there were significant clarifications
released, e.g. the paper "Notes on the design and analysis of Simon and Speck"
(https://eprint.iacr.org/2017/560.pdf).  In fact, from what I can see, many
competing lightweight block ciphers don't have as much design justification
available as Speck.  Daniel Bernstein's papers are excellent, but unfortunately
he has only designed a stream cipher, not a block cipher or another algorithm
that is applicable for disk encryption.

> > The reason we chose Speck had nothing to do with the proposed ISO standard or
> > any sociopolitical factors, but rather because it was the only algorithm we
> > could find that met the performance and security requirements.
> 
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
> design decisions and analyzing it. Some of the best symmetric
> cryptographers in academia have expressed reservations about it, and
> it was just rejected from a major standard's body. Linux, of course,
> is free to disagree -- or "bow down" as you oddly put it -- but I'd
> make sure you've got a pretty large bucket of justifications for that
> disagreement.
> 

There have actually been many papers analyzing Speck.  As with other ciphers,
reduced-round variants have been successfully attacked, while the full variants
have held up.  This is expected.  It's true that some other ciphers such as
ChaCha20 have a higher security margin, which has resulted in some criticism of
Speck.  But the correct security margin is always debatable, and in a
performance-oriented cipher it's desirable to not have an excessive number of
rounds.  In fact it was even looking like ChaCha20 was not going to be fast
enough on some CPUs, so if we went the ChaCha route we may have actually have
had to use ChaCha12 or ChaCha8 instead.

Also, some papers present results for just the weakest variants of Speck
(Speck32 and Speck48) while omitting the strongest (Speck128, the one that's
planned to be offered for Android), presumably because the authors weren't able
to attack it as successfully.  I think that's causing some confusion.

I don't see how the ISO standarization process means much for crypto algorithms.
It seems very political, and actually it seems that people involved were pretty
clear that Speck was rejected primarily for political reasons.  Interestingly,
ChaCha20 is not an ISO standard either.  Does that mean ChaCha20 shouldn't be
used?

In any case, given that the status quo on low-end Android devices is no
encryption, it would be great to start having them be encrypted.  It would be a
shame if pushback for non-technical reasons prevents that from happening.

> > (in fact, you'd
> > probably have a different opinion of it if the authors had simply worked
> > somewhere else and published the exact same algorithm);
> 
> Again, no need to patronize. I don't actually have a bias like that.
> 
> > But I hope you can understand that all *technical* indicators are that Speck is
> > secure enough
> 
> That's the thing I'm worried about.
>

Thanks,

- Eric
