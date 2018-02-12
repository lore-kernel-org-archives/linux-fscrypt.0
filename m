Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:46098 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752392AbeBLTTI (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 12 Feb 2018 14:19:08 -0500
Received: by mail-io0-f193.google.com with SMTP id k80so7121349ioe.13
        for <linux-fscrypt@vger.kernel.org>; Mon, 12 Feb 2018 11:19:07 -0800 (PST)
Date: Mon, 12 Feb 2018 11:19:03 -0800
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH 0/5] crypto: Speck support
Message-ID: <20180212191903.GD193902@google.com>
References: <20180208001001.19180-1-ebiggers@google.com>
 <CAH8yC8m4F9SWum9D5ZV2wzVAsJaDxnkc1L6eSeEOV-cOdkcg6Q@mail.gmail.com>
 <20180208210107.GA6720@google.com>
 <CAH8yC8k2ZNffeb6oak0_xCUVS+kyO_9SiFmbTjY7SdseN2xULw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH8yC8k2ZNffeb6oak0_xCUVS+kyO_9SiFmbTjY7SdseN2xULw@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Jeffrey Walton <noloader@gmail.com>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Wingers, Louis R." <lrwinge@tycho.ncsc.mil>, "Weeks, Bryan" <beweeks@tycho.ncsc.mil>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi all,

On Fri, Feb 09, 2018 at 07:07:01PM -0500, Jeffrey Walton wrote:
> > Hi Jeffrey,
> >
> > I see you wrote the SPECK implementation in Crypto++, and you are treating the
> > words as big endian.
> >
> > Do you have a reference for this being the "correct" order?  Unfortunately the
> > authors of the cipher failed to mention the byte order in their paper.  And they
> > gave the test vectors as words, so the test vectors don't clarify it either.
> >
> > I had assumed little endian words, but now I am having second thoughts...  And
> > to confuse things further, it seems that some implementations (including the
> > authors own implementation for the SUPERCOP benchmark toolkit [1]) even consider
> > the words themselves in the order (y, x) rather than the more intuitive (x, y).
> >
> > [1] https://github.com/iadgov/simon-speck-supercop/blob/master/crypto_stream/speck128128ctr/ref/stream.c
> >
> > In fact, even the reference code from the paper treats pt[0] as y and pt[1] as
> > x, where 'pt' is a u64 array -- although that being said, it's not shown how the
> > actual bytes should be translated to/from those u64 arrays.
> >
> > I'd really like to avoid people having to add additional versions of SPECK later
> > for the different byte and word orders...
> 
> Hi Eric,
> 
> Yeah, this was a point of confusion for us as well. After the sidebar
> conversations I am wondering about the correctness of Crypto++
> implementation.
> 

We've received another response from one of the Speck creators (Louis Wingers)
that (to summarize) the intended byte order is little endian, and the intended
word order is (y, x), i.e. 'y' is at a lower memory address than 'x'.  Or
equivalently: the test vectors given in the original paper need to be read as
byte arrays from *right-to-left*.

(y, x) is not the intuitive order, but it's not a huge deal.  The more important
thing is that we don't end up with multiple implementations with different byte
and/or word orders.

So, barring any additional confusion, I'll send a revised version of this
patchset that flips the word order.  Jeff would need to flip both the byte and
word orders in his implementation in Crypto++ as well.

- Eric

> As a first step here is the official test vector for Speck-128(128)
> from Appendix C, p. 42 (https://eprint.iacr.org/2013/404.pdf):
> 
>     Speck128/128
>     Key: 0f0e0d0c0b0a0908 0706050403020100
>     Plaintext: 6c61766975716520 7469206564616d20
>     Ciphertext: a65d985179783265 7860fedf5c570d18
> 
> We had some confusion over the presentation. Here is what the Simon
> and Speck team sent when I asked about it, what gets plugged into the
> algorithm, and how it gets plugged in:
> 
> <BEGIN SNIP PERSONAL EMAIL>
> 
> On Mon, Nov 20, 2017 at 10:50 AM, <lrwinge@xxxx.xxxx.xxx> wrote:
> > ...
> > I'll explain the problem you have been having with our test vectors.
> >
> > The key is:  0x0f0e0d0c0b0a0908 0x0706050403020100
> > The plaintext is:  6c61766975716520 7469206564616d20
> > The ciphertext is:  a65d985179783265 7860fedf5c570d18
> >
> > The problem is essentially one of what goes where and we probably could
> > have done a better job explaining things.
> >
> > For the key, with two words, K=(K[1],K[0]).  With three words K=(K[2],K[1],K[0]),
> > with four words K=(K[3],K[2],K[1],K[0]).
> >
> > So for the test vector you should have K[0]= 0x0706050403020100, K[1]= 0x0f0e0d0c0b0a0908
> > which is the opposite of what you have done.
> >
> > If we put this K into ExpandKey(K,sk) then the first few round keys
> > are:
> >
> > 0706050403020100
> > 37253b31171d0309
> > f91d89cc90c4085c
> > c6b1f07852cc7689
> > ...
> >
> > For the plaintext, P=(P[1],P[0]), i.e., P[1] goes into the left word of the block cipher
> > and P[0] goes into the right word of the block cipher.  So you should have
> > m[0]= 7469206564616d20 and m[1]= 6c61766975716520, which is again opposite of what you
> > have. If c[0]=m[0] and c[1]=m[1], then the encrypt function should be called as
> > Encrypt(c+1,c+0,sk).   The resulting ciphertext is (c+1,c+0).
> >
> > In general, everything goes in as a byte stream (not 64-bit words).  In this case,
> > if the 16 bytes of key are 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f then
> > we first need to turn these into two 64-bit words.  The first word, K[0] is
> > 0706050403020100 and the second word is K[1]=0f0e0d0c0b0a0908.  On x86 processors,
> > if the key bytes are in the array k[] of type uint8_t, then a simple
> > casting should get you K[1] and K[0].  That is, K[0]=((uint64_t *)k)[0] and
> > K[1]=((uint64_t *)k)[1].  The key expansion is run with ExpandKey(K,sk).
> > So that was what we had in mind.
> >
> > Similarly, if the plaintext "bytes" were:  20 6d 61 64 65 20 69 74 20 65 71 75 69 76 61 6c
> > (which is ascii for " made it equival")
> > then we first need to turn these into two 64-bit words.  The first word is
> > pt[0]=7469206564616d20 and the second word is pt[1]= 6c61766975716520.  The Encrypt
> > routine is run as Encrypt(pt[1],pt[0],sk).  The resulting ciphertext is (ct[1],ct[0])
> > which you would turn back into a byte stream in the reverse of what we did.  For
> > example, if ct[1]= a65d985179783265 and ct[0]= 7860fedf5c570d18, then if c[] is a
> > byte stream (i.e., of type uint8_t), then we would have c[0]=18, c[1]=0d, c[2]=57, c[3]=5c, etc.
> > This is easy to do on x86 with a cast.
> >
> > Let me know if all of this is now clear.
> >
> > Best regards,
> 
> <END SNIP PERSONAL EMAIL>
> 
> Finally, here is the Simon and Speck team GitHub. It is the
> implementation the team submitted to SUPERCOP:
> https://github.com/iadgov/simon-speck-supercop . The files of interest
> are in crypto_stream:
> 
>    * speck128128ctr/ref/stream.c
>    * speck128192ctr/ref/stream.c
>    * speck128256ctr/ref/stream.c
>    * speck64128ctr/ref/stream.c
>    * speck6496ctr/ref/stream.c
> 
> The reference implementation uses CTR mode rather then ECB mode. After
> the CTR -> ECB conversion (mostly trivial), and then plugging in the
> test vectors data (key and message), we could not arrive at the same
> answer as the published test vector. However, we may have been
> plugging things in incorrectly. We were able to arrive at test vector
> results after a minor modification, but it may have been the wrong
> thing to do (in hindsight). I'll be revisiting this shortly.
> 
> Hopefully this should get things started on sorting out the details.
> 
> Jeff
