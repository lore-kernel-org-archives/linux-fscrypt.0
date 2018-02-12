Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33575 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbeBLT5H (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 12 Feb 2018 14:57:07 -0500
MIME-Version: 1.0
Reply-To: noloader@gmail.com
In-Reply-To: <20180212191903.GD193902@google.com>
References: <20180208001001.19180-1-ebiggers@google.com> <CAH8yC8m4F9SWum9D5ZV2wzVAsJaDxnkc1L6eSeEOV-cOdkcg6Q@mail.gmail.com>
 <20180208210107.GA6720@google.com> <CAH8yC8k2ZNffeb6oak0_xCUVS+kyO_9SiFmbTjY7SdseN2xULw@mail.gmail.com>
 <20180212191903.GD193902@google.com>
From: Jeffrey Walton <noloader@gmail.com>
Date: Mon, 12 Feb 2018 14:57:06 -0500
Message-ID: <CAH8yC8numVB=XX2M9GhsH8-xOQpsxEE3i6JJLd_nfUd7v7hDFw@mail.gmail.com>
Subject: Re: [PATCH 0/5] crypto: Speck support
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Wingers, Louis R." <lrwinge@tycho.ncsc.mil>, "Weeks, Bryan" <beweeks@tycho.ncsc.mil>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Feb 12, 2018 at 2:19 PM, Eric Biggers <ebiggers@google.com> wrote:
> Hi all,
>
> On Fri, Feb 09, 2018 at 07:07:01PM -0500, Jeffrey Walton wrote:
>> > Hi Jeffrey,
>> >
>> > I see you wrote the SPECK implementation in Crypto++, and you are treating the
>> > words as big endian.
>> >
>> > Do you have a reference for this being the "correct" order?  Unfortunately the
>> > authors of the cipher failed to mention the byte order in their paper.  And they
>> > gave the test vectors as words, so the test vectors don't clarify it either.
>> >
>> > I had assumed little endian words, but now I am having second thoughts...  And
>> > to confuse things further, it seems that some implementations (including the
>> > authors own implementation for the SUPERCOP benchmark toolkit [1]) even consider
>> > the words themselves in the order (y, x) rather than the more intuitive (x, y).
>> >
>> > [1] https://github.com/iadgov/simon-speck-supercop/blob/master/crypto_stream/speck128128ctr/ref/stream.c
>> >
>> > In fact, even the reference code from the paper treats pt[0] as y and pt[1] as
>> > x, where 'pt' is a u64 array -- although that being said, it's not shown how the
>> > actual bytes should be translated to/from those u64 arrays.
>> >
>> > I'd really like to avoid people having to add additional versions of SPECK later
>> > for the different byte and word orders...
>>
>> Hi Eric,
>>
>> Yeah, this was a point of confusion for us as well. After the sidebar
>> conversations I am wondering about the correctness of Crypto++
>> implementation.
>>
>
> We've received another response from one of the Speck creators (Louis Wingers)
> that (to summarize) the intended byte order is little endian, and the intended
> word order is (y, x), i.e. 'y' is at a lower memory address than 'x'.  Or
> equivalently: the test vectors given in the original paper need to be read as
> byte arrays from *right-to-left*.
>
> (y, x) is not the intuitive order, but it's not a huge deal.  The more important
> thing is that we don't end up with multiple implementations with different byte
> and/or word orders.
>
> So, barring any additional confusion, I'll send a revised version of this
> patchset that flips the word order.  Jeff would need to flip both the byte and
> word orders in his implementation in Crypto++ as well.

Thanks Eric.

Yeah, the (y,x) explains a lot of the confusion, and explains the
modification I needed in my GitHub clone of the IAD Team's SUPERCOP to
arrive at test vector results. My clone is available at
https://github.com/noloader/simon-speck-supercop.

So let me ask you... Given the Speck-128(128) test vector from Appendix C:

    Key: 0f0e0d0c0b0a0908 0706050403020100
    Plaintext: 6c61766975716520 7469206564616d20
    Ciphertext: a65d985179783265 7860fedf5c570d18

Will the Linux implementation arrive at the published result, or will
it arrive at a different result? I guess what I am asking, where is
the presentation detail going to be handled?

A related question is, will the kernel be parsing just the key as
(y,x), or will all parameters be handled as (y,x)? At this point I
believe it only needs to apply to the key but I did not investigate
the word swapping in detail because I was chasing the test vector.

Jeff
