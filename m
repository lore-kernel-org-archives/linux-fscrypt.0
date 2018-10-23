Return-Path: <SRS0=wPgC=ND=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20181020071206.GE876@sol.localdomain>
References: <20181015175424.97147-1-ebiggers@kernel.org> <20181015175424.97147-12-ebiggers@kernel.org>
 <CAKv+Gu9wrOOk-LGPYmxgLbv86uXzMeHN6th3mMEDT3Vg893HWw@mail.gmail.com> <20181020071206.GE876@sol.localdomain>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 23 Oct 2018 07:40:34 -0300
Message-ID: <CAKv+Gu9zBKK7ughbBAKkHdfgX2KrBXkF6MhH3xrSdLegrjjYJQ@mail.gmail.com>
Subject: Re: [RFC PATCH v2 11/12] crypto: adiantum - add Adiantum support
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On 20 October 2018 at 15:12, Eric Biggers <ebiggers@kernel.org> wrote:
> Hi Ard,
>
> On Sat, Oct 20, 2018 at 12:17:58PM +0800, Ard Biesheuvel wrote:
>> On 16 October 2018 at 01:54, Eric Biggers <ebiggers@kernel.org> wrote:
>> > From: Eric Biggers <ebiggers@google.com>
>> >
>> > Add support for the Adiantum encryption mode.  Adiantum was designed b=
y
>> > Paul Crowley and is specified by our paper:
>> >
>> >     Adiantum: length-preserving encryption for entry-level processors
>> >     (https://eprint.iacr.org/2018/720.pdf)
>> >
>> > See our paper for full details; this patch only provides an overview.
>> >
>> > Adiantum is a tweakable, length-preserving encryption mode designed fo=
r
>> > fast and secure disk encryption, especially on CPUs without dedicated
>> > crypto instructions.  Adiantum encrypts each sector using the XChaCha1=
2
>> > stream cipher, two passes of an =CE=B5-almost-=E2=88=86-universal (=CE=
=B5A=E2=88=86U) hash
>> > function, and an invocation of the AES-256 block cipher on a single
>> > 16-byte block.  On CPUs without AES instructions, Adiantum is much
>> > faster than AES-XTS; for example, on ARM Cortex-A7, on 4096-byte secto=
rs
>> > Adiantum encryption is about 4 times faster than AES-256-XTS encryptio=
n,
>> > and decryption about 5 times faster.
>> >
>> > Adiantum is a specialization of the more general HBSH construction.  O=
ur
>> > earlier proposal, HPolyC, was also a HBSH specialization, but it used =
a
>> > different =CE=B5A=E2=88=86U hash function, one based on Poly1305 only.=
  Adiantum's
>> > =CE=B5A=E2=88=86U hash function, which is based primarily on the "NH" =
hash function
>> > like that used in UMAC (RFC4418), is about twice as fast as HPolyC's;
>> > consequently, Adiantum is about 20% faster than HPolyC.
>> >
>> > This speed comes with no loss of security: Adiantum is provably just a=
s
>> > secure as HPolyC, in fact slightly *more* secure.  Like HPolyC,
>> > Adiantum's security is reducible to that of XChaCha12 and AES-256,
>> > subject to a security bound.  XChaCha12 itself has a security reductio=
n
>> > to ChaCha12.  Therefore, one need not "trust" Adiantum; one need only
>> > trust ChaCha12 and AES-256.  Note that the =CE=B5A=E2=88=86U hash func=
tion is only
>> > used for its proven combinatorical properties so cannot be "broken".
>> >
>>
>> So what happens if the part of the input covered by the block cipher
>> is identical between different generations of the same disk block
>> (whose sector count is used as the 'outer' IV). How are we not in the
>> same boat as before when using stream ciphers for disk encryption?
>>
>
> This is the point of the hash step.  The value encrypted with the block c=
ipher
> to produce the intermediate value C_M (used as the stream cipher nonce) i=
s
> H(T, P_L) + P_R.  (T is the tweak a.k.a the IV, P_L is the plaintext exce=
pt the
> last 16 bytes, P_R is the last 16 bytes.)  A collision in this value occu=
rs iff:
>
>         H(T1, P1_L) + P1_R =3D H(T2, P2_L) + P2_R
> i.e.
>         H(T1, P1_L) - H(T2, P2_L) =3D P2_R - P1_R
>
> If (T1, P1_L) =3D (T2, P2_L) then P1_R !=3D P2_R so the equation has no s=
olutions
> (since we don't consider queries where the whole input is the same; those
> unavoidably produce the same ciphertext).  Otherwise (T1, P1_L) !=3D (T2,=
 P2_L),
> and since the hash function H is =CE=B5-almost-=E2=88=86-universal over i=
ntegers mod 2^128,
> the equation is true for at most a very small proportion '=CE=B5' of hash=
 keys.
> But, the hash key is chosen at random and is unknown to the attacker.
>
> The same applies in the other direction, for chosen ciphertext attacks.
>
> Basically, it's very difficult for an attacker to cause the intermediate =
value
> C_M to be reused, and the outputs will appear random until they do.
>
> Of course, all this is explained much more precisely and comprehensively =
in our
> paper.  See section 5, "Security reduction".
>

Thanks for the explanation. I saw that the result of the AES
encryption was used as the XChaCha nonce, but I failed to spot that
the result of the nhpoly1305 pass is added/subtracted to/from that
particular block first.

In any case, this looks good to me: as far as I can tell, the code
implements the algorithm as described in the paper, and the plumbing
into the crypto API looks correct to me as well.

Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Whether the paper is correct is a different matter: it looks
convincing to me but IANAC.

The only request I have is to add a speed test to tcrypt as well so we
can easily benchmark it.
