Return-Path: <SRS0=Hq3S=N4=gmail.com=gmazyland@kernel.org>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <20181019190411.GB246441@gmail.com>
 <1f65ce09-93b3-f43e-49d5-9d9d6c0bb9e0@gmail.com>
 <20181116215249.GA27149@gmail.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <56883f08-26cb-ecef-5698-1c2948714773@gmail.com>
Date: Sat, 17 Nov 2018 11:29:23 +0100
MIME-Version: 1.0
In-Reply-To: <20181116215249.GA27149@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On 16/11/2018 22:52, Eric Biggers wrote:
> Hi Milan,
> 
> On Sat, Oct 20, 2018 at 12:26:20PM +0200, Milan Broz wrote:
>>
>> Adiantum (as in your current git branches on kernel.org) can be used for dm-crypt
>> without any changes (yes, I played with it :) and with some easy tricks directly
>> through cryptsetup/LUKS as well.
>>
>> I think we should have this as an alternative to length-preserving wide-block
>> cipher modes for FDE.
>>
> 
> Yes, dm-crypt can use Adiantum by specifying the cipher as
> "capi:adiantum(xchacha12,aes)-plain64".
> 
> But, I'm having trouble getting cryptsetup/LUKS to use Adiantum.
> Using LUKS1, the following works:
> 
>     cryptsetup luksFormat /dev/$partition --cipher='capi:adiantum(xchacha12,aes)-plain64' --key-size 256
> 
> However, when possible we'd like people to use 4K sectors for better
> performance, which I understand requires using the LUKS2 format along with
> cryptsetup v2.0.0+ and Linux v4.12+.  But the following does *not* work:
> 
>     cryptsetup luksFormat /dev/$partition --cipher='capi:adiantum(xchacha12,aes)-plain64' --key-size 256 --type luks2 --sector-size 4096

Hi Eric,

actually I planned to test it and then reply to these patches with example cryptsetup
commands, but did not have time for it yet.
So thanks for a reminder ;-)

Recent cryptsetup supports sector-size even for plain device.

You actually do not need to use capi: prefix, Adiantum is a composition,
so "xchacha20,aes-adiantum-plain64" works as well (and it should work even for old cryptsetup).
(It is ugly, but it should be compatible.)

# cryptsetup open --type plain -c xchacha20,aes-adiantum-plain64 -s 256 --sector-size 4096 /dev/sdb test

For LUKS and benchmark, Adiantum need to use 32 bytes IV. And we have these parameter,
unfortunately, hardcoded...
(I guess there is already a way how to get this dynamically from userspace crypto API now.)

So, I already added patch to devel branch patch for benchmark to support Adiantum few days ago
https://gitlab.com/cryptsetup/cryptsetup/commit/bce567db461e558af7d735c694a50146db899709

This allows trivial benchmark (but it just encrypts one big blob of data):

#  cryptsetup benchmark -c xchacha20,aes-adiantum -s 256
# Tests are approximate using memory only (no storage IO).
#            Algorithm |       Key |      Encryption |      Decryption
xchacha20,aes-adiantum        256b       146.6 MiB/s       148.0 MiB/s
...

# ./cryptsetup benchmark -c xchacha12,aes-adiantum -s 256
xchacha12,aes-adiantum        256b       181.7 MiB/s       184.6 MiB/s

For LUKS2, we need a similar change to cryptoAPI IV size (unfortunately it does not
fallback to old keyslot handling, so LUKS2 does not work currently now).

I quickly added a workaround that fallbacks to default keyslot encryption for keyslots
in this case
https://gitlab.com/cryptsetup/cryptsetup/commit/29e87add5aac9d5eb0087881146988d9c4280915

then you can use LUKS2
# cryptsetup luksFormat --type luks2 --sector-size 4096 -c xchacha20,aes-adiantum-plain64 -s 256 /dev/sdb

(Example above will encrypt keyslots with AES-XTS and use Aviantum for data only.)

So, unfortunately yes, we need some small changes in cryptsetup for LUKS;
plain mode should work out of the box (with the syntax above).

Milan
