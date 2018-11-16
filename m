Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:40914 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725819AbeKQIHA (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 17 Nov 2018 03:07:00 -0500
Date: Fri, 16 Nov 2018 13:52:50 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
Message-ID: <20181116215249.GA27149@gmail.com>
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <20181019190411.GB246441@gmail.com>
 <1f65ce09-93b3-f43e-49d5-9d9d6c0bb9e0@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1f65ce09-93b3-f43e-49d5-9d9d6c0bb9e0@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Milan Broz <gmazyland@gmail.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Milan,

On Sat, Oct 20, 2018 at 12:26:20PM +0200, Milan Broz wrote:
> 
> Adiantum (as in your current git branches on kernel.org) can be used for dm-crypt
> without any changes (yes, I played with it :) and with some easy tricks directly
> through cryptsetup/LUKS as well.
> 
> I think we should have this as an alternative to length-preserving wide-block
> cipher modes for FDE.
> 

Yes, dm-crypt can use Adiantum by specifying the cipher as
"capi:adiantum(xchacha12,aes)-plain64".

But, I'm having trouble getting cryptsetup/LUKS to use Adiantum.
Using LUKS1, the following works:

    cryptsetup luksFormat /dev/$partition --cipher='capi:adiantum(xchacha12,aes)-plain64' --key-size 256

However, when possible we'd like people to use 4K sectors for better
performance, which I understand requires using the LUKS2 format along with
cryptsetup v2.0.0+ and Linux v4.12+.  But the following does *not* work:

    cryptsetup luksFormat /dev/$partition --cipher='capi:adiantum(xchacha12,aes)-plain64' --key-size 256 --type luks2 --sector-size 4096

The problem seems to be that when cryptsetup tries to encrypt the keyslot in
luks2_encrypt_to_storage(), it tries to use the algorithm via AF_ALG, but it
incorrectly requests "plain64(capi:adiantum(xchacha12,aes))" which fails.
It should request just "adiantum(xchacha12,aes)".

What are the "easy tricks" you had in mind -- do you mean there's already a way
to use Adiantum with cryptsetup, or do you mean that cryptsetup still needs to
be updated to fully support algorithms using the crypto API syntax?

Thanks,

- Eric
