Return-Path: <SRS0=jAdU=R4=insidesecure.com=pvanleeuwen@kernel.org>
From: Pascal Van Leeuwen <pvanleeuwen@insidesecure.com>
Subject: RE: [PATCH 0/17] Add zinc using existing algorithm implementations
Date: Mon, 25 Mar 2019 09:10:08 +0000
Message-ID: 
 <AM5PR0901MB1155FD05113D6DC79A6274CED25E0@AM5PR0901MB1155.eurprd09.prod.outlook.com>
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
 <CAKv+Gu_mgyzqUCeb+wke--8Gn8YbjOb8jyrSgFr3-tcNP8ccEQ@mail.gmail.com>
 <CAHk-=wg2LJ5qQ0B2y+_6Ue62SBP4h9MLxLvn89bfcP7Cp2ac6A@mail.gmail.com>
In-Reply-To: 
 <CAHk-=wg2LJ5qQ0B2y+_6Ue62SBP4h9MLxLvn89bfcP7Cp2ac6A@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, "linux-fscrypt@vger.kernel.org" <linux-fscrypt@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

As someone who has been working on crypto acceleration hardware for the bet=
ter
part of the past 20 years, I feel compelled to respond to this, in defence =
of
the crypto API (which we're really happy with ...).

> And honestly, I'm 1000% with Jason on this. The crypto/ model is hard to =
use,
> inefficient, and completely pointless when you know what your cipher or
> hash algorithm is, and your CPU just does it well directly.
>
> > we even have support already for async accelerators that implement it,
>
> Afaik, none of the async accelerator code has ever been worth anything on
> real hardware and on any sane and real loads. The cost of going outside t=
he
> CPU is *so* expensive that you'll always lose, unless the algorithm has b=
een
> explicitly designed to be insanely hard on a regular CPU.
>
The days of designing them *specifically* to be hard on a CPU are over, but
nevertheless, due to required security properties, *good* crypto is usually
still hard work for a CPU.
Especially *asymmetric* crypto, which can easily take milliseconds per oper=
ation
even on a high-end CPU. You can do a lot of interrupt processing in a milli=
second
Now some symmetric algorithms (AES,SHA,GHASH) have actually made it *into*
the CPU, somewhat changing the landscape, but:
a) That's really only a small subset of the crypto being used out there.
   There's much more to crypto than just AES, SHA and GHASH.
b) This only applies to high-end CPU's. The large majority of embedded CPU'=
s do
   not have such embedded crypto instructions. This may change, but I don't
   really expect that to happen soon.
c) You're still keeping a big, power-hungry CPU busy for a lot of cycles do=
ing
   some fairly trivial work.

> (Corollary: "insanely hard on a regular CPU" is also easy to do by making=
 the
> CPU be weak and bad. Which is not a case we should optimize for).
>

Linux is being used a lot for embedded systems which usually DO have fairly
weak CPU's. I would argue that's exactly the case you SHOULD optimize for,
as that's where you can *really* still make the difference as a programmer.

> The whole "external accelerator" model is odd. It was wrong. It only make=
s
> sense if the accelerator does *everything* (ie it's the network card), an=
d
> then you wouldn't use the wireguard thing on the CPU at all, you'd have a=
ll
> those things on the accelerator (ie a "network card that does WG").
>
> One of the (best or worst, depending on your hangups) arguments for
> external accelerators has been "but I trust the external hardware with th=
e
> key, but not my own code", aka the TPM or Disney argument.  I don't think
> that's at all relevant to the discussion either.
>
> The whole model of async accelerators is completely bogus. The only crypt=
o
> or hash accelerator that is worth it are the ones integrated on the CPU c=
ores,
> which have the direct access to caches.
>
NOT true. We wouldn't still be in business after 20 years if that were true=
.

> And if the accelerator is some tightly coupled thing that has direct acce=
ss to
> your caches, and doesn't need interrupt overhead or address translation e=
tc
> (at which point it can be worth using) then you might as well just consid=
er it
> an odd version of the above. You'd want to poll for the result anyway,
> because not polling is too expensive.
>
It's HARD to get the interfacing right to take advantage of the acceleratio=
n.
And that's exacly why you MUST have an async interface for that: to cope wi=
th
the large latency of external acceleration, going through the memory subsys=
tem
and external buses as - as you already pointed out - you cannot access the =
CPU
cache directly (though you can be fully coherent with it).
So to cope with that latency, you will need to batch queue and pipeline you=
r
processing. This is not unique to crypto acceleration, the same principles
apply to e.g. your GPU as well. Or any HW worth anything, for that matter.

What that DOES mean is that external crypto accelerators are indeed useless=
 for
doing the occasional crypto operation, it really only makes sense for strea=
ming
and/or bulk use cases, such as network packet or disk encryption. And for
operations that really take significant time, such as asymmetic crypto.
For the occasional symmetric crypto operation, by all means, do that on the=
 CPU
using a very thin API layer for efficiency and simplicity. This is where Zi=
nc
makes a lot of sense - I'm not against Zinc at all. But DO realise that whe=
n
you go that route, you forfeit any chances of benefitting from acceleration=
.

Ironically, for doing what Wireguard is doing - bulk packet encryption - th=
e
async crypto API makes a lot more sense than Zinc. In Jason's defense, as
far as I know, there is no Poly/Chacha HW acceleration out there yet, but I
can assure you that that situation is going to change soon :-)
Still,  I would really recommend running Wireguard on top of crypto API.
How much performance would you really lose by doing that? If there's
anything wrong with the efficiency of the crypto API implementation of
P/C, then just fix that.

> Just a single interrupt would completely undo all the advantages you got
> from using specialized hardware - both power and performance.
>
We have done plenty of measurements, on both power and performance, to prov=
e
you wrong there. Typically our HW needs *at least* a full order of a magnit=
ude
less power to do the actual work. The CPU load for handing the interrupts e=
tc.
tends to be around 20%. So assuming the CPU goes to sleep for the other 80%
of the time,  the combined solution would need about 1/3rd of the power of =
a
CPU only solution. It's one of our biggest selling points.

As for performance - in the embedded space you can normally expect the cryp=
to
accelerator to be *much* faster than the CPU subsystem as well. So yes, big
multi-core multi-GHz Xeons can do AES-GCM extremely fast and we'd have a ha=
rd
time competing with that, but that's not the relevant use case here.

> And that kind of model would work just fine with zinc.

>
> So an accelerator ends up being useful in two cases:
>
>  - it's entirely external and part of the network card, so that there's n=
o extra
> data transfer overhead
>
There are inherent efficiency advantages to integrating the crypto there, b=
ut
it's also very inflexible as you're stuck with a particular, usually very l=
imited,
implementation. And it doesn't fly very well with current trends of Softwar=
e
Defined Networking and Network Function Virtualization.
As for data transfer overhead: as long as the SoC memory subsystem was desi=
gned
to cope with this, it's really irrelevant as you shouldn't notice it.

>  - it's tightly coupled enough (either CPU instructions or some on-die ca=
che
> coherent engine) that you can and will just use it synchronously anyway.
>
> In the first case, you wouldn't run wireguard on the CPU anyway - you hav=
e a
> network card that just implements the VPN.
>
The irony here is, that network card would probably be an embedded system r=
unning
Linux on an embedded CPU, offloading the crypto operations to our accelerat=
or ...
Most smart NICs are architected that way.

Pascal van Leeuwen,
Silicon IP Architect @ Inside Secure
