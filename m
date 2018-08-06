Return-Path: <SRS0=hU7U=KV=google.com=paulcrowley@kernel.org>
MIME-Version: 1.0
References: <20180806223300.113891-1-ebiggers@kernel.org> <20180806223300.113891-4-ebiggers@kernel.org>
 <CAHmME9rbe6eT6dkUqKnp-GxcqGrp-tvMfTMr8kZtsn=S3cmP8A@mail.gmail.com>
In-Reply-To: <CAHmME9rbe6eT6dkUqKnp-GxcqGrp-tvMfTMr8kZtsn=S3cmP8A@mail.gmail.com>
From: Paul Crowley <paulcrowley@google.com>
Date: Mon, 6 Aug 2018 16:47:30 -0700
Message-ID: <CA+_SqcDghOP_pBvmer_4AGHoQcWHYHF1=NAmYBDSf=K08z5RWA@mail.gmail.com>
Subject: Re: [RFC PATCH 3/9] crypto: chacha20-generic - refactor to allow
 varying number of rounds
Content-Type: multipart/alternative; boundary="00000000000042fde80572cce769"
To: Jason@zx2c4.com
Cc: ebiggers@kernel.org, linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, samuel.c.p.neves@gmail.com, tomer.ashur@esat.kuleuven.be, Eric Biggers <ebiggers@google.com>, djb@cr.yp.to
List-ID: <linux-fscrypt@vger.kernel.org>

--00000000000042fde80572cce769
Content-Type: text/plain; charset="UTF-8"

Salsa20 was one of the earlier ARX proposals, and set a very conservative
number of rounds as befits our state of knowledge at the time. Since then
we've learned a lot more about cryptanalysis of such offerings, and I think
we can be comfortable with fewer rounds. The best attack on ChaCha breaks 7
rounds, and that attack requires 2^248 operations. Every round of ChaCha
makes attacks vastly harder.

Performance is absolutely crucial when it comes to disk encryption; users
and vendors will push back hard against encryption that degrades the user
experience. So we're always going to choose the fastest option that gives
us a solid margin of security, and here that's ChaCha12.

I'd like to turn the question around. Why 20? DJB's 20 round proposal
predates his 12 round proposal, but I don't think that's a reason to choose
it when all cryptanalysis has considered reduced-round variants. The 20
round variant is more widely used, but again I think that's informative
more about the historical order of things than the security. If 20 is
better than 12, is 24 better than 20? What is it that draws you to 20
rounds specifically?

On Mon, 6 Aug 2018 at 16:16, Jason A. Donenfeld <Jason@zx2c4.com> wrote:

> Hey Eric,
>
> On Tue, Aug 7, 2018 at 12:35 AM Eric Biggers <ebiggers@kernel.org> wrote:
> > In preparation for adding XChaCha12 support, rename/refactor
> > chacha20-generic to support different numbers of rounds.
>
> I'm interested in learning the motivation behind going with ChaCha12.
> So far, the vast majority of users of ChaCha have been getting along
> quite fine with ChaCha20 and enjoying the very large security margin
> this provides. In some ways, introducing ChaCha12 into the ecosystem
> feels like a bit of a step backwards, even if it probably still
> provides adequate security (though ChaCha8 probably shouldn't be used
> or included at all). I realize the simple answer is just, "because
> it's faster." But I'm wondering specifically about the speed
> requirements and on what hardware and in what circumstances you found
> ChaCha20 was too slow, and if this is the kind of circumstance you
> expect to persist into the future.
>
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fscrypt" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--00000000000042fde80572cce769
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Salsa20 was one of the earlier ARX proposals, and set=
 a very conservative number of rounds as befits our state of knowledge at t=
he time. Since then we&#39;ve learned a lot more about cryptanalysis of suc=
h offerings, and I think we can be comfortable with fewer rounds. The best =
attack on ChaCha breaks 7 rounds, and that attack requires 2^248 operations=
. Every round of ChaCha makes attacks vastly harder.</div><div><br></div><d=
iv><span style=3D"font-size:small;text-decoration-style:initial;text-decora=
tion-color:initial;float:none;display:inline">Performance is absolutely cru=
cial when it comes to disk encryption; users and vendors will push back har=
d against encryption that degrades the user experience. So we&#39;re always=
 going to choose the fastest option that gives us a solid margin of securit=
y, and here that&#39;s ChaCha12.</span><br><br>I&#39;d like to turn the que=
stion around. Why 20?=C2=A0<span style=3D"font-size:small;background-color:=
rgb(255,255,255);text-decoration-style:initial;text-decoration-color:initia=
l;float:none;display:inline">DJB&#39;s 20 round proposal predates his 12 ro=
und proposal, but I don&#39;t think that&#39;s a reason to choose it when a=
ll cryptanalysis has considered reduced-round variants. The 20 round varian=
t is more widely used, but again I think that&#39;s informative more about =
the historical order of things than the security.=C2=A0</span>If 20 is bett=
er than 12, is 24 better than 20? What is it that draws you to 20 rounds sp=
ecifically?</div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr">On M=
on, 6 Aug 2018 at 16:16, Jason A. Donenfeld &lt;<a href=3D"mailto:Jason@zx2=
c4.com">Jason@zx2c4.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">Hey Eric,<br>
<br>
On Tue, Aug 7, 2018 at 12:35 AM Eric Biggers &lt;<a href=3D"mailto:ebiggers=
@kernel.org" target=3D"_blank">ebiggers@kernel.org</a>&gt; wrote:<br>
&gt; In preparation for adding XChaCha12 support, rename/refactor<br>
&gt; chacha20-generic to support different numbers of rounds.<br>
<br>
I&#39;m interested in learning the motivation behind going with ChaCha12.<b=
r>
So far, the vast majority of users of ChaCha have been getting along<br>
quite fine with ChaCha20 and enjoying the very large security margin<br>
this provides. In some ways, introducing ChaCha12 into the ecosystem<br>
feels like a bit of a step backwards, even if it probably still<br>
provides adequate security (though ChaCha8 probably shouldn&#39;t be used<b=
r>
or included at all). I realize the simple answer is just, &quot;because<br>
it&#39;s faster.&quot; But I&#39;m wondering specifically about the speed<b=
r>
requirements and on what hardware and in what circumstances you found<br>
ChaCha20 was too slow, and if this is the kind of circumstance you<br>
expect to persist into the future.<br>
<br>
Jason<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-fscryp=
t&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org" targe=
t=3D"_blank">majordomo@vger.kernel.org</a><br>
More majordomo info at=C2=A0 <a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" rel=3D"noreferrer" target=3D"_blank">http://vger.kernel.org/majord=
omo-info.html</a><br>
</blockquote></div>

--00000000000042fde80572cce769--
