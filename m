Return-Path: <SRS0=HLWW=NA=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20181015175424.97147-1-ebiggers@kernel.org> <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <20181019190411.GB246441@gmail.com> <1f65ce09-93b3-f43e-49d5-9d9d6c0bb9e0@gmail.com>
In-Reply-To: <1f65ce09-93b3-f43e-49d5-9d9d6c0bb9e0@gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Sat, 20 Oct 2018 15:47:57 +0200
Message-ID: <CAHmME9qf9OAuFaHvyT7du9Dce7vESLgHt-KewTLsttpS9UxNeg@mail.gmail.com>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
Content-Type: text/plain; charset="UTF-8"
To: Milan Broz <gmazyland@gmail.com>
Cc: Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Milan,

On Sat, Oct 20, 2018 at 12:53 PM Milan Broz <gmazyland@gmail.com> wrote:
> Does it mean, that if Adiantum is based on Zinc, it can be no longer used
> for FDE (dm-crypt)? IOW only file-based encryption is possible?

No, don't worry. All I had in mind was the software implementations of
chacha12 and so forth. There aren't any current plans at this point to
change the scafolding underlying dm-crypt.

Jason
