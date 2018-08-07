Return-Path: <SRS0=n9St=KW=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20180807031526.GD5048@thunk.org>
References: <20180806223300.113891-1-ebiggers@kernel.org> <20180806230437.21431-1-Jason@zx2c4.com>
 <20180807011937.GA133621@gmail.com> <CAHmME9oTApV-zHD60QPryaoQf45ODpG25Da5FgB8c+LO162gWQ@mail.gmail.com>
 <20180807031237.GA779@sol.localdomain> <20180807031526.GD5048@thunk.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 7 Aug 2018 14:51:22 +0200
Message-ID: <CAKv+Gu_Dr1KvEOMdkhxZtq093MDgvcP_G-5=JMmqsx+zYV-=mw@mail.gmail.com>
Subject: Re: [PATCH] crypto: remove speck
Content-Type: text/plain; charset="UTF-8"
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@kernel.org>, "Jason A. Donenfeld" <Jason@zx2c4.com>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, stable <stable@vger.kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On 7 August 2018 at 05:15, Theodore Y. Ts'o <tytso@mit.edu> wrote:
> On Mon, Aug 06, 2018 at 08:12:38PM -0700, Eric Biggers wrote:
>> I mention this because people are naturally going to be curious about that, e.g.
>> speculating that Google found a "backdoor" -- remember that we do have some good
>> cryptographers!  I'm just stating what we know, out of honesty and openness; I
>> don't really intend to be arguing for Speck with this statement, and in any case
>> we already made the decision to not use Speck.
>
> Let's be clear --- the arguments about whether or not to use Speck,
> and whether or not to remove Speck from the kernel, are purely
> political --- not techinical.
>

Whether or not to use it may be a political rather than a technical
motivation. But the reason I acked this patch is not because removing
it aligns with my political conviction regarding Speck, but simply
because its contributor, primary intended user and therefore de facto
maintainer stated publicly that it no longer had any intention to use
it going forward.
