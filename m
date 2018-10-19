Date: Fri, 19 Oct 2018 12:04:11 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
Message-ID: <20181019190411.GB246441@gmail.com>
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jason,

On Fri, Oct 19, 2018 at 05:58:35PM +0200, Jason A. Donenfeld wrote:
> Hello Eric,
> 
> > As before, some of these patches conflict with the new "Zinc" crypto
> > library.  But I don't know when Zinc will be merged, so for now I've
> > continued to base this patchset on the current 'cryptodev'.
> 
> I'd appreciate it if you waited to merge this until you can rebase it
> on top of Zinc. In fact, if you already want to build it on top of
> Zinc, I'm happy to work with you on that in a shared repo or similar.
> We can also hash out the details of that in person in Vancouver in a
> few weeks. I think pushing this in before will create undesirable
> churn for both of us.
> 

I won't be at Plumbers, sorry!  For if/when it's needed, I'll start a version of
this based on Zinc.  The basic requirements are that we need (1) xchacha12 and
xchacha20 available as 'skciphers' in the crypto API, and (2) the poly1305_core
functions (see patch 08/12).  In principle, these can be implemented in Zinc.
The Adiantum template and all the NHPoly1305 stuff will be the same either way.
(Unless you'll want one or both of those moved to Zinc too.  To be honest, even
after your explanations I still don't have a clear idea of what is supposed to
go in Zinc and what isn't...)

However, for now I'm hesitant to completely abandon the current approach and bet
the farm on Zinc.  Zinc has a large scope and various controversies that haven't
yet been fully resolved to everyone's satisfaction, including unclear licenses
on some of the essential assembly files.  It's not appropriate to grind kernel
crypto development to grind a halt while everyone waits for Zinc.

So if Zinc is ready, then it makes sense for it to go first;
otherwise, it doesn't.  It's not yet clear which is the case.

Thanks,

- Eric
