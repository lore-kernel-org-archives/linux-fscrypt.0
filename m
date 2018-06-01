Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from rhcavuit01.kulnet.kuleuven.be ([134.58.240.129]:42372 "EHLO
        rhcavuit01.kulnet.kuleuven.be" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752019AbeFATXc (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 1 Jun 2018 15:23:32 -0400
Received: from icts-p-smtps-2.cc.kuleuven.be (icts-p-smtps-2e.kulnet.kuleuven.be [134.58.240.34])
        by rhcavuit01.kulnet.kuleuven.be (Postfix) with ESMTP id E738412032C
        for <linux-fscrypt@vger.kernel.org>; Fri,  1 Jun 2018 21:23:28 +0200 (CEST)
Subject: [PATCH v2 0/5] crypto: Speck support
References: <8c9dc804-1f59-a245-57ba-51db3c234621@esat.kuleuven.be>
From: Tomer Ashur <tomer.ashur@esat.kuleuven.be>
Message-ID: <3cb37d45-1acf-811d-821f-2a3c8ff85b04@esat.kuleuven.be>
Date: Fri, 1 Jun 2018 21:23:28 +0200
MIME-Version: 1.0
In-Reply-To: <8c9dc804-1f59-a245-57ba-51db3c234621@esat.kuleuven.be>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="cjGsx6m6v7UboEDR1dWiHqaQh9g8AGuo3"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: Samuel Neves <samuel.c.p.neves@gmail.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cjGsx6m6v7UboEDR1dWiHqaQh9g8AGuo3
Content-Type: multipart/mixed; boundary="Ce4YXhdjlsvLufXiD44uu6MkiAFriEvJ0";
 protected-headers="v1"
X-Kuleuven: This mail passed the K.U.Leuven mailcluster
From: Tomer Ashur <tomer.ashur@esat.kuleuven.be>
To: Eric Biggers <ebiggers@google.com>
Cc: Samuel Neves <samuel.c.p.neves@gmail.com>,
 "Jason A. Donenfeld" <Jason@zx2c4.com>,
 Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
 Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>,
 Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>,
 Paul Lawrence <paullawrence@google.com>,
 Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Message-ID: <3cb37d45-1acf-811d-821f-2a3c8ff85b04@esat.kuleuven.be>
Subject: [PATCH v2 0/5] crypto: Speck support
References: <8c9dc804-1f59-a245-57ba-51db3c234621@esat.kuleuven.be>
In-Reply-To: <8c9dc804-1f59-a245-57ba-51db3c234621@esat.kuleuven.be>

--Ce4YXhdjlsvLufXiD44uu6MkiAFriEvJ0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US

[Resending because the email bounced back from all 3 mailing lists.
Sorry if you get this email twice]
Hi Eric et al.,
I know that this thread is already stale, and I'm sorry I couldn't join
earlier but maybe late is better than never. Allow me to first introduce
myself: my name is Tomer Ashur and I'm a post-doctoral fellow in KU
Leuven. I am part of symmetric-key group led by Vincent Rijmen where I'm
mostly involved in cryptanalysis. I am also part of ISO/IEC JTC 1/SC
27/WG 2, the group which decided to reject Simon and Speck from ISO. If
it's okay with you, I'd like to give my perspective on what happened in
ISO and what is Speck's real standing with the academic community.

First, I'd like to say that the NSA has done quite extensive work in
muddying the waters, arguing that Simon & Speck are secure and that all
objections are political. This is not true, as I will now show with
examples. The bottom line is that there are still many open questions
about their security, questions that the NSA has, on multiple occasions,
refused to answer.

> It seems to me justified about as well as one would hope for a new ciph=
er -=20
>   "Notes on the design and analysis of Simon and Speck" seems to me to =
give ... detail on the reasoning
This is actually an optical illusion. First you need to understand the
context for this document. The NSA (in particular, the exact same person
who previously promoted DUAL_EC in ISO) proposed to include Simon &
Speck in ISO/IEC 29192-2 back in 2015. For obvious reasons they were met
with skepticism. A main concern was the lack of any design rationale and
internal cryptanalytic results. The NSA people fought tooth and nail for
a year and a half simultaneously arguing two almost mutually-exclusive
points: (i) they employ the most talented cryptographers and hence, we
should trust them when they say that an algorithm is secure; and (ii)
they are average cryptographers and hence they would not be able to
insert a backdoor into the algorithm.

More than once they argued in a meeting that the cryptanalysis for the
ciphers has been stabilized (i.e., that attacks will not improve) just
to be proved wrong in the next meeting (their answer: "well, _now_ it
has fully stabilized", which was again proven wrong in the next
meeting). One of them even had a bet with Tanja Lange that no attack on
either Simon or Speck would be extended by 3 rounds or more in the
upcoming year. He lost this bet. They were very uncooperative, and made
it a point to let us know that they will not be providing more
information about the algorithms.

So, in this climate, you can imagine how surprised we all were when in
one of the meetings (after not getting the votes they needed in order to
proceed to the next stage) they announced that they will provide a
design rationale. At first they distributed it to us in ISO, but per my
suggestion they then uploaded it to ePrint (see ePrint 2017/560).

But our joy was short-lived. Once you read this so-called design
rationale you can immediately notice two things. Firstly, that they
explain in length all decisions affecting performance (in particular,
rotation amounts - which in one of the meetings they described as
"most-efficient; secure-enough"). The second thing is that when it comes
to cryptanalysis this document is merely a literature review. There is
literally nothing new there - all they do is to cite published works by
academics, something wrongly.

Now, there is no nice way to say that, but this document includes
omissions, falsehoods, half-truths and outright lies. I will not go into
the full analysis of the document, but here are some examples:

 1. Omissions - I already said that this document does not provide any
    new information. This becomes apparent when you try to find out how
    they chose the number of rounds. The document remains quite vague on
    this question. There is a lot of hand waving about "Matsui-like
    techniques", "multipath effect", etc. but nowhere you can find (in
    the old version, they recently uploaded a new version which I didn't
    have time to read yet) a place where they say: "this is how we set
    the number of rounds".

    Another omission is about the key schedule - you won't find any
    useful information about the design decisions leading to these
    particular key schedules. Simon uses 3 matrices U,V, and W which are
    not explained, not does the constant c. Speck's key schedule is more
    straightforward but a discussion about the symmetries that may arise
    from using the round function for the key schedule would still be
    appropriate here. Not discussing the combined security of the cipher
    with its key schedule goes against the current trend in linear
    cryptanalysis (see e.g., [2] and many follow up papers).
 2. Half-truths -=C2=A0 take a look at page 16 where they explain how the=
y
    avoided rotation/slide attacks. They give the standard explanation
    that using round-constants would thwart these attacks. This could
    have been fine if the last sentence wasn't "/Also see [AL16]/". From
    the text it seems as if /AL16/ supports the claims made in this
    paragraph. However, /AL16/ is a paper I co-authored which is how I
    know that not only that it doesn't support the claim, it actually
    shows how to adapt rotational cryptanalysis to algorithms using
    round constants.

    As a side note, the goal of /AL16/ was to present a novel way to use
    rotational cryptanalysis in the presence of round constants. This
    paper was published in FSE'17 and we followed up on it with a paper
    in FSE'18 using this attack against Speck{32,48,64} [1]. The reason
    we focused on these versions and not the larger one is not, as was
    suggested in this thread, that they are somehow more secure. The
    actual reason is much less prosaic: these are the resources we had
    at our disposal. This is also the reason the weak-key classes are so
    small. But the fact that my publicly funded university cannot afford
    a better number cruncher doesn't mean that someone with access to
    such won't be able to find better results. In fact, I am quite
    convinced that if you give our tool the resources it needs, it would
    penetrate way more than the currently best known distinguisher of 19
    rounds for Speck128 (translating to better key recovery attacks).

    What is important to understand here is in the same way you do
    "real-world crypto", academics often do "proofs of concept". After
    publishing the attack technique and the attack on (reduced-)Speck, I
    moved to my next project because the scientific marginal benefit is
    small. There is of course the personal gain of being known as the
    guy who broke Speck, but I'm not particularly interested in such
    fame. All of that being said, if anyone has the firepower to run
    this tool and to improve the existing attacks for Speck128, feel
    free to drop me an email.
 3. Falsehoods - with this word I refer to claims in the so-called
    design rationale that are wrong. We can argue whether they were
    included on purpose or if they are simply mistakes. But in either
    case, they are exist and they are worrisome. I would only give one
    example: "/the design team=E2=80=99s early analytic efforts led us to=

    believe that the limiting cryptanalytic features for Simon and
    Speck-type block ciphers would be of the linear and differential
    sort"/ (see Page 4). Believing that differential and linear attacks
    would be the most dangerous attacks is reasonable, but as we can see
    from [1], it is wrong.
 4. Lies - this is the most troubling part. The NSA lies to the public
    (including the American people) on official documents. I already
    wrote that the choice for the exact number of rounds is only
    motivated through some hand waving. This makes it hard to tell what
    the real security margin is. But even if you interpret the hand
    waving conservatively, the math results in much smaller security
    margins than what is claimed. I gave a rump session talk about this
    in Crypto 2017 which you can view here [3]. The talk focuses on
    Simon but the story for Speck is similar and results in security
    margins of 15.6%, 15.6%, and 14.7% for Speck128 with key sizes 128,
    192, and 256, respectively. According to the NSA, that is, and only
    if you accept the claim that attacks have stabilized.

    the choice for the number of rounds was heavily discussed in the ISO
    meeting in Berlin about 6 months ago. When confronted with this
    question, the NSA answered (again) that they will not be providing
    further information, added that anyone with a decent level of
    English would immediately understand what they meant, and called me
    an incompetent cryptographer. Nevertheless, a few months after the
    meeting they updated the so-called design rationale and added a
    footnote that reads:
>     "The original version of this paper said 50% here, but noted that
>     this was =E2=80=9Cvery conser-
>     vative.=E2=80=9D This led to confusion by some, who interpreted 50%=
 as an
>     exact value, rather than
>     the very conservative upper bound we intended it to be. This is
>     supported by the literature
>     (see, e.g., [CW15]) and by our internal analysis. Indeed 50% is a
>     significant overestimate;
>     25% appears to be a more accurate estimate. We apologize for the
>     lack of clarity here, and
>     note that even if future advances increased the 25% to 50% Simon
>     would still be secure." (Page 11)
    This is a fine clarification except that it is an outrageous lie.
    For example, for Simon32 the so-called design rationale reports that
    the best linear trail can penetrate at most 12 rounds. As part of my
    research I found an 18-round linear hull which _was confirmed, in
    writing,_ by the NSA (I should have the email somewhere and can find
    it if anyone is interested). The difference between 12 and 18 rounds
    is indeed 50% and not 25% as they argue in the updated document.

These are only part of the problems I and others found with the
so-called design rationale. Having so many problems in a document meant
to convince people that you're not doing anything sinister is either an
indication for some serious incompetence, or an indication that
something sinister is actually happening. Either way, it is clear that
this document is meant for PR and has no scientific value. It surely
does not inspire confidence in the algorithms.

All of this was known to the people in the room when ISO made its
decision to reject Simon and Speck (after deliberating about this for
more than 3 years. Not because there were disagreements but because we
wanted to give the NSA a fair chance). These people also got a first
hand impression of how poorly the people the NSA sent fare with
_technical_ questions, basically refusing to answer all, and throwing
tantrums instead. And then, the ISO people also saw another thing.
During the discussions I asked the NSA two non-technical questions (from
a crypto point of view. These are technical questions from a
standardization point of view):=C2=A0
=C2=A0=C2=A0=C2=A0 - Q: You claim that third party analysis is indicative=
 of the
algorithm's real security. Were you aware of all these results when you
published the algorithms, or are any of them better than what you knew of=
?
=C2=A0=C2=A0=C2=A0 - A: I refuse to answer that
=C2=A0=C2=A0=C2=A0 -Q: Are you aware of any cryptanalytic results better =
than those
already found by academia?
=C2=A0=C2=A0=C2=A0 -A: I refuse to answer that either.

Now, there seem to be some notion that the people in ISO are bureaucrats
with limited understanding in cryptography. The truth is that WG 2 (the
cryptography experts) includes people like Kan Yasuda, Shiho Moriai, Dan
Berenstein, Pascal Paillier, Tanja Lange, Orr Dunkelman and Jian Guo
(partial list). You can't say that they don't know what they're doing.
Which is why, having all this information, we decided that including
these algorithms in one of our standards would undermine the trust
people have in ISO and the work it is doing.

Note that in parallel to the Simon and Speck process, people from the
NSA (different from those involved in Simon and Speck) are successfully
promoting at least two other projects. So you can't say that there
really is a significant anti-NSA bias either. No, these algorithms seem
insecure, attacks against them keep improving, their designers either
refuse to answer basic questions about their security or lie... What
other conclusion could we have reached except that there might be a
security problem with these algorithms?

This of course brings us back to the question asked early in this thread:=


> support for SM4 was just added too, which is a Chinese government stand=
ard. Are you going to send a patch to remove that
> too, or is it just NSA designed algorithms that are not okay?
This seems pretty obvious to me. If you don't feel comfortable with SM4,
don't add it either. There are at least that many reasons to distrust
the Chinese government as there are to distrust the NSA.

However, the answer to the question
> Could you say a little more about what it is that separates Speck from =
SM4
> for you?
is a bit different. There are two main things that separate Speck from
SM4. Firstly, it seems more secure. This is either because it actually
is more secure, or because the Chinese did a better job in hiding their
backdoors; but at least it doesn't scream "something strange is going on
here!!!". Second, SM4 is also being standardized in ISO these days and
the Chinese are very cooperative with the process. Whatever question you
have about this algorithm, I can get you an answer from the person
promoting SM4. This inspires confidence in the algorithm and the
process. Is this enough? I don't think so. But being a member of ISO I'm
bound by certain rules that don't allow me to reject algorithms based on
my intuition, so it seems that SM4 (as well as LEA and Kuznyechik) would
probably find their way into the respective standards.

That being said, if you ask for my opinion, just don't include SM4.

Which bring us to the million dollar question:
> So, what do you propose replacing it with?
Nothing. I am usually not one to argue for maintaining the status quo
and I sure am in favor of encryption-for-all but this case is the text
book example for employing the Precautionary Principle. You yourself are
not fully convinced that Speck is secure and does not contain any
backdoors. If it was really secure, it could have been used in all cases
and not only on low-end devices where AES is too slow. AES is slower
than Speck on most platforms.

Now, I'm a sort of a mathematician which doesn't know much about
processor generations and implementation efficiency. Things like 134833
KB/s are Chinese to me. But the way I understand it, these devices that
are to weak to support AES would not be around in 2-5 years which would
make the problem go away. In the foreseeable future, even if the
crypto-extension isn't added to low-end processors, they would still
improve to a degree they can run some of the efficient-but-not-enough
algorithms of today, no?

I would also like to point out that including an algorithm because "it's
better than nothing" result in something that is not
better-than-nothing, but stands in the way of good solutions. Since
there is no acute problem, why do we need to solve it? This is from the
cryptographers' point of view. From the end-user point of view when they
get something bundled into Android, they don't know that it was included
there as something that is "better than nothing". They think of it as
"good enough; endorsed by Android/Google/Linux". What you give them is a
false sense of security because they don't know of all the question
marks surrounding Speck (both technical and political).

So I think that as a first step, no-encryption is better than using
Speck. Then we can move for a longer term solution. Since this is an
important enough issue I asked around and people are happily willing to
help. For example, Dan Berenstein seems to believe that a solution can
be built using a generic construction along the lines of your discussion
with Samuel (with or without a variant of ChaCha). Even if a generic
construction cannot be used Berenstein told me he's willing to help
design a solution. I also asked Vincent Rijmen and Orr Dunkelman and
they both told me they'd be willing to work in a team to find (or
design) a solution. This is already an impressive cadre and I'm sure it
would not be too much of a problem to solicit other notable
cryptographer because basically, no one in this community thinks it's a
good idea to use Speck.

Sorry for the long post and Shabbat Shalom,

Tomer Ashur, PhD
Senior Researcher
COSIC, KU Leuven

[1] https://eprint.iacr.org/2017/1036
[2] https://eprint.iacr.org/2012/303
[3] https://www.youtube.com/watch?v=3D3d-xruyR89g&t=3D2s




On 05/08/2018 01:20 AM, Eric Biggers wrote:
> Hi Samuel,
>
> On Thu, Apr 26, 2018 at 03:05:44AM +0100, Samuel Neves wrote:
>> On Wed, Apr 25, 2018 at 8:49 PM, Eric Biggers <ebiggers@google.com> wr=
ote:
>>> I agree that my explanation should have been better, and should have =
considered
>>> more crypto algorithms.  The main difficulty is that we have extreme =
performance
>>> requirements -- it needs to be 50 MB/s at the very least on even low-=
end ARM
>>> devices like smartwatches.  And even with the NEON-accelerated Speck1=
28-XTS
>>> performance exceeding that after much optimization, we've been gettin=
g a lot of
>>> pushback as people want closer to 100 MB/s.
>>>
>> I couldn't find any NEON-capable ARMv7 chip below 800 MHz, so this
>> would put the performance upper bound around 15 cycles per byte, with
>> the comfortable number being ~7. That's indeed tough, though not
>> impossible.
>>
>>> That's why I also included Speck64-XTS in the patches, since it was
>>> straightforward to include, and some devices may really need that las=
t 20-30% of
>>> performance for encryption to be feasible at all.  (And when the choi=
ce is
>>> between unencrypted and a 64-bit block cipher, used in a context wher=
e the
>>> weakest points in the cryptosystem are actually elsewhere such as the=
 user's
>>> low-entropy PIN and the flash storage doing wear-leveling, I'd certai=
nly take
>>> the 64-bit block cipher.)  So far we haven't had to use Speck64 thoug=
h, and if
>>> that continues to be the case I'd be fine with Speck64 being removed,=
 leaving
>>> just Speck128.
>>>
>> I would very much prefer that to be the case. As many of us know,
>> "it's better than nothing" has been often used to justify other bad
>> choices, like RC4, that end up preventing better ones from being
>> adopted. At a time where we're trying to get rid of 64-bit ciphers in
>> TLS, where data volumes per session are comparatively low, it would be=

>> unfortunate if the opposite starts happening on encryption at rest.
>>
>>> Note that in practice, to have any chance at meeting the performance =
requirement
>>> the cipher needed to be NEON accelerated.  That made benchmarking rea=
lly hard
>>> and time-consuming, since to definitely know how an algorithm perform=
s it can
>>> take upwards of a week to implement a NEON version.  It needs to be v=
ery well
>>> optimized too, to compare the algorithms fairly -- e.g. with Speck I =
got a 20%
>>> performance improvement on some CPUs just by changing the NEON instru=
ctions used
>>> to implement the 8-bit rotates, an optimization that is not possible =
with
>>> ciphers that don't use rotate amounts that are multiples of 8.  (This=
 was an
>>> intentional design choice by the Speck designers; they do know what t=
hey're
>>> doing, actually.)
>>>
>>> Thus, we had to be pretty aggressive about dropping algorithms from
>>> consideration if there were preliminary indications that they wouldn'=
t perform
>>> well, or had too little cryptanalysis, or had other issues such as an=
 unclear
>>> patent situation.  Threefish for example I did test the C implementat=
ion at
>>> https://github.com/wernerd/Skein3Fish, but on ARM32 it was over 4 tim=
es slower
>>> than my NEON implementation of Speck128/256-XTS.  And I did not see a=
 clear way
>>> that it could be improved over 4x with NEON, if at all, so I did not =
take the
>>> long time it would have taken to write an optimized NEON implementati=
on to
>>> benchmark it properly.  Perhaps that was a mistake.  But, time is not=
 unlimited.
>>>
>> In my limited experience with NEON and 64-bit ARX, there's usually a
>> ~2x speedup solely from NEON's native 64-bit operations on ARMv7-A.
>> The extra speedup from encrypting 2 block in parallel is then
>> somewhere between 1x and 2x, depending on various details. Getting
>> near 4x might be feasible, but it is indeed time-consuming to get
>> there.
>>
>>> As for the wide-block mode using ChaCha20 and Poly1305, you'd have to=
 ask Paul
>>> Crowley to explain it properly, but briefly it's actually a pseudoran=
dom
>>> permutation over an arbitrarily-sized message.  So with dm-crypt for =
example, it
>>> would operate on a whole 512-byte sector, and if any bit of the 512-b=
yte
>>> plaintext is changed, then every bit in the 512-byte ciphertext would=
 change
>>> with 50% probability.  To make this possible, the construction uses a=
 polynomial
>>> evalution in GF(2^130-5) as a universal hash function, similar to the=
 Poly1305
>>> mode.
>>>
>> Oh, OK, that sounds like something resembling Naor-Reingold or its
>> relatives. That would work, but with 3 or 4 passes I guess it wouldn't=

>> be very fast.
>>
>>> Using ChaCha20's underlying 512-bit permutation to build a tweakable =
block
>>> cipher is an interesting idea.  But maybe in my crypto-naivety, it is=
 not
>>> obvious to me how to do so.  Do you have references to any relevant p=
apers?
>>> Remember that we strongly prefer a published cipher to a custom one -=
- even if
>>> the core is reused, a mistake may be made in the way it is used.  Thu=
s,
>>> similarly to Paul's wide-block mode, I'd be concerned that we'd have =
to
>>> self-publish a new construction, then use it with no outside crypto r=
eview.
>>> *Maybe* it would be straightforward enough to be okay, but to know I'=
d need to
>>> see the details of how it would actually work.
>>>
>> This would be the 'tweakable Even-Mansour' construction and its
>> variants. The variant I'm most familiar with would be MEM [1],
>> focusing on software friendliness, but there is other provable
>> security work in the same vein, including [3, 4, 5]. It's very similar=

>> to how the XEX mode turns a block cipher into a tweakable block
>> cipher.
>>
>> In [1, 2] we used a 1024-bit permutation out of BLAKE2 instead of
>> ChaCha20's, but everything translates easily from one to the other. We=

>> also included cheap masks for 512-bit permutations, just in case.
>>
>> [1] https://eprint.iacr.org/2015/999
>> [2] https://github.com/MEM-AEAD/mem-aead
>> [3] https://eprint.iacr.org/2015/539
>> [4] https://eprint.iacr.org/2015/476
>> [5] https://competitions.cr.yp.to/round2/minalpherv11.pdf
>>
>>> But in the end, Speck seemed like the clear choice because it had mul=
tiple NEON
>>> implementations available already which showed it could be implemente=
d very
>>> efficiently in NEON; it has over 70 cryptanalysis papers (far more th=
an most
>>> ciphers) yet the security margin is still similar to AES; it has no i=
ntellectual
>>> property concerns; there is a paper clearly explaining the design dec=
isions; it
>>> is naturally resistant to timing attacks; it supports a 128-bit block=
 size, so
>>> it can be easily used in XTS mode; it supports the same key sizes as =
AES; and it
>>> has a simple and understandable design with no "magic numbers" beside=
s 8 and 3
>>> (compare to an actual backdoored algorithm like Dual_EC_DRGB, which b=
asically
>>> had a public key embedded in the algorithm).  Also as Paul mentioned =
he is
>>> confident in the construction, and he has published cryptanalysis on =
Salsa20, so
>>> his opinion is probably more significant than mine :-)
>>>
>>> But I will definitely take a closer look at SPARX and some of the oth=
er ciphers
>>> you mentioned in case I missed something.  I really do appreciate the=

>>> suggestions, by the way, and in any case we do need to be very well p=
repared to
>>> justify our choices.  I just hope that people can understand that we =
are
>>> implementing real-world crypto which must operate under *very* tight =
performance
>>> constraints on ARM processors, and it must be compatible with dm-cryp=
t and
>>> fscrypt with no room for ciphertext expansion.  Thus, many algorithms=
 which may
>>> at first seem reasonable choices had to (unfortunately) be excluded.
>>>
>> I understand it is a tough choice, and it's unfortunate that many of
>> the algorithms we have cater mostly to either the
>> high-hardware-accelerated-end or the extremely low-end, without a lot
>> of good options at the middle-end.
>>
> First, we're planning a publication which explains our choices in more =
detail,
> so please treat this as some more preliminary notes.
>
> To make sure we've exhausted as many alternatives as possible, I wrote =
NEON
> implementations of all the block ciphers you suggested with the excepti=
on of
> SKINNY (which looked very hardware-oriented and not efficient in softwa=
re), as
> well as some that others have suggested.  (It was tough, but after doin=
g a
> couple, it got much easier...)  The following shows the decryption perf=
ormance
> I'm getting on an ARMv7 platform.  Encryption speeds were usually simil=
ar, but
> in our use case we care much more about decryption, as that affects the=
 most
> critical metrics such as the time to launch applications.
>
> 	ChaCha8-MEM: 183256 KB/s
> 	ChaCha12-MEM: 134833 KB/s
> 	Chaskey-LTS-XTS: 99097 KB/s
> 	ChaCha20-MEM: 87875 KB/s
> 	Speck64/128-XTS: 85332 KB/s
> 	Speck128/128-XTS: 73404 KB/s
> 	RC5-128/12/256-XTS: 69887 KB/s
> 	Speck128/256-XTS: 69597 KB/s
> 	RC5-64/12/128-XTS: 69267 KB/s
> 	LEA-128-XTS: 67986 KB/s
> 	CHAM128/128-XTS: 52982 KB/s
> 	LEA-256-XTS: 50429 KB/s
> 	Threefish-256: 48349 KB/s
> 	RC6-XTS: 46855 KB/s
> 	RC5-128/20/256-XTS: 44291 KB/s
> 	RC5-64/20/128-XTS: 43924 KB/s
> 	NOEKEON-XTS: 40705 KB/s
> 	Sparx128/128-XTS: 39191 KB/s
> 	XTEA-XTS: 38239 KB/s
> 	AES-128-XTS: 25549 KB/s
> 	AES-256-XTS: 18640 KB/s
>
> Remember that for dm-crypt or fscrypt over flash storage and/or f2fs, a=
 stream
> cipher is insecure.  Moreover, on these (low-end) devices the status qu=
o is no
> encryption, and we need every bit of performance available.  Anything b=
elow
> 50 MB/s is definitely unacceptable.  But even at that speed we get many=

> complaints, so in practice we need something faster.  That means that t=
he
> algorithms close to 50 MB/s, such as Threefish, still aren't fast enoug=
h.
>
> ChaCha-MEM (based roughly on your paper: https://eprint.iacr.org/2015/9=
99), has
> the best performance, especially if we allow for the 12 or 8-round vari=
ants.  My
> code for it is based roughly on the existing
> arch/arm/crypto/chacha20-neon-core.S, but updated to support the invers=
e
> permutation (on 4 blocks at a time, using all 16 NEON registers) and do=
 the
> masking required by MEM.  However, ChaCha-MEM would be a pretty bleedin=
g-edge
> and customized construction, and Paul Crowley and I have concerns about=
 its
> security.  The problem is that the MEM security proof assumes that the
> underlying permutation has no more detectable structural properties tha=
n a
> randomly selected permutation.  However, the ChaCha permutation is know=
n to have
> certain symmetries, e.g. if the sixteen 32-bit words are (a, a, a, a, b=
, b, b,
> b, c, c, c, c, d, d, d, d), then they always map to some (e, e, e, e, f=
, f, f,
> f, g, g, g, g, h, h, h, h).
>
> For the MEM mask generation, we can use the "expand 32-byte k" constant=
 to break
> the symmetry, like is done in the ChaCha stream cipher.  However, that'=
s not
> possible for the inner application of the permutation.  So, we'd be usi=
ng the
> ChaCha permutation in a manner in which it wasn't intended, and the sec=
urity of
> the ChaCha stream cipher wouldn't directly carry over.  Granted, it's n=
ot
> impossible that it would be secure, but at the present time it doesn't =
seem like
> a good choice to actually field.
>
> Chaskey-LTS is faster than Speck, but unfortunately it's not really a v=
iable
> option because it has only a 64-bit security level, due to its use of t=
he
> Even-Mansour construction with a 128-bit key.  Of course, it would stil=
l be
> better than nothing, but we prefer a cipher that has a security level i=
n line
> with what is accepted for modern crypto.
>
> RC5 with the traditional 12 rounds is about as fast as Speck, but there=
 is a
> known differential attack on that number of rounds.  So if we choose RC=
5 we'd
> almost certainly have to use the 20-round variant, which is much slower=
=2E
>
> That leaves LEA-128-XTS as the only other algorithm that might meet the=

> performance requirement, as it is only slightly slower than Speck128-XT=
S.  It
> may be the most viable alternative, but beyond the slight performance l=
oss it
> still has some disadvantages compared to Speck:
>
> - Importantly, the LEA authors forgot to include test vectors, so I'm n=
ot yet
>   100% sure I implemented it correctly.  (The Speck authors unfortunate=
ly didn't
>   make the endianness of their test vectors clear in their initial publ=
ication,
>   but at least they actually provided test vectors!)
> - LEA has received some cryptanalysis, but not nearly as much as Speck.=

> - It took some very heavy optimization to get good LEA performance, muc=
h more
>   than I had to do for Speck.  My final LEA code has separate code path=
s for
>   128-bit and 256-bit keys, and has reordered and preprocessed the roun=
d keys,
>   and reordered the operations.  As a result, it's harder to see how it=
 maps to
>   the original paper.  In contrast, my Speck code is more straightforwa=
rd and
>   maintainable.
> - LEA-256 (256-bit key) is much slower than LEA-128 (128-bit key), as i=
t has
>   33% more rounds.  LEA-256 would not be fast enough, so we would have =
to use
>   LEA-128.  In contrast, with Speck we can use Speck128/256 (256-bit ke=
y).
>   We're willing to accept a 128-bit security level, but 256-bit is pref=
erable.
>   (I think the Speck designers took a more informed approach to setting=

>   appropriate security margins for a lightweight cipher; it seems that =
other
>   designers often choose too few or too many rounds, especially as the =
key
>   length is varied.)
> - LEA encryption is also a bit slower than decryption, while with Speck=

>   encryption and decryption are almost exactly the same speed.
>
> Note that like Speck, LEA doesn't appear to be approved by a standards
> organization either; it's just specified in a research paper.
>
> Thus, from a technical perspective, and given the current state of the =
art in
> lightweight cryptography, currently Speck128-XTS seems to be the best c=
hoice for
> the problem domain.  It's unfortunate that there are so few good option=
s and
> that the field is so politicized, but it is what it is.
>
> Still, we don't want to abandon HPolyC (Paul's new ChaCha and Poly1305-=
based
> wide-block mode), and eventually we hope to offer it as an option as we=
ll.  But
> it's not yet published, and it's a more complex algorithm that is harde=
r to
> implement so I haven't yet had a chance to implement and benchmark it. =
 And we
> don't want to continue to leave users unprotected while we spend a long=
 time
> coming up with the perfect algorithm, or for hardware AES support to ar=
rive to
> all low-end CPUs when it's unclear if/when that will happen.
>
> Again, we're planning a publication which will explain all this in more=
 detail.
>
> Thanks!
>
> Eric



--Ce4YXhdjlsvLufXiD44uu6MkiAFriEvJ0--

--cjGsx6m6v7UboEDR1dWiHqaQh9g8AGuo3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJbEZ0wAAoJEJ5gU5DjCgCPDRwP/38oFj6o6/kW886ZkIIsXE68
QgDp9uaecZCd6k2/WdvNmfGG55d8aOVtqrN5/VZQ0hnPfRHx8AWsMRTJqUV+Fg0l
UOtQPcHWKXj8KlaNR0ed7yHjwv/tUI6w6luSnrjaFsk69yrMDsqjwqFKVY1OEF8J
7WWwm1CVL9bDqwDjO1fucW7Mk4W+2zbn71NjnVZFaU3wfufwNOZet4L0orSf0Rx/
5Ko7B3gsmtHEfDYwmtmYLGxBPZFoHY7+4DZs4M9QEDRWqJAA8t/Lzvd/MoDjbzXi
EVSPCpQ9iHmG5wiUuBULze4h6LwR4BJnCn4spNsnvYiPwuwgCkJStaNTn0z4CXvi
q+o2rfck+RtUvPddWYBpMo9658Ygs3TEYblE/hjsEeJG44d7vApjsL5bUyaqjacE
Wq6S+rbmsz9bYJw+/73mZcSY6zmOLhln7Lj5Zf0d6+6IMTLBdDva+r0fAnvlIqv/
XIfIWbT6J7tPF4G/MRCpSCHCmje3rhvoIGKLbUQn0oVKkn4dALDrWGFBw8+Uskok
/cqRetHtfcVnUBiX1DjA3WGhAUtYPJ0JfjMw3RvpgHxPyoTU8DyOfhQylHE9OVhU
e/32Vp9XK+VFNwRu9Z+CBeUo2cfr4VLmfGWxoudpQtLLz37jN3pZUH9PtAQIWzWo
OT982OuqqszX1sAcxYg5
=X99v
-----END PGP SIGNATURE-----

--cjGsx6m6v7UboEDR1dWiHqaQh9g8AGuo3--
