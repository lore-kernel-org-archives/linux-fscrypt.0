Return-Path: <SRS0=pu0v=QQ=gmail.com=ali.mezgani@kernel.org>
MIME-Version: 1.0
References: <20190207031101.GA7387@mit.edu> <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
In-Reply-To: <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
From: Ali Mezgani <ali.mezgani@gmail.com>
Date: Sat, 9 Feb 2019 21:54:08 +0100
Message-ID: <CABN_Fg8efREM82Dw6DAuOPXwj5UThqcb6deFDsV4O+cq=16nvA@mail.gmail.com>
Subject: Re: Proposal: Yet another possible fs-verity interface
Content-Type: multipart/alternative; boundary="000000000000a16acb05817c47fb"
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

--000000000000a16acb05817c47fb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Still convinced by linus's reply.

Regards,

Le sam. 9 f=C3=A9vr. 2019 =C3=A0 21:39, Linus Torvalds <torvalds@linux-foun=
dation.org>
a =C3=A9crit :

> On Thu, Feb 7, 2019 at 8:10 AM Theodore Y. Ts'o <tytso@mit.edu> wrote:
> >
> > After doing a lot of thinking and conferring with the other fs-verity
> > developers, our current thinking is to simply move the Merkle tree
> > creation into the kernel.  The upside of doing this is it completely
> > bypasses all of the complaints about how to transfer the Merkle tree
> > from userspace to the kernel.
>
> This sounds very sane to me.
>
> In particular, may I suggest that  the interface be made idempotent,
> so that you can do the merkle tree operation several times with the
> same offset/length arguments, and if the merkle tree has already been
> calculated, you just return the resulting root hash directly.
>
> Why? That allows you to "validate" images on filesystems that don't
> actually have any long-term storage model for the merkle tree. IOW,
> you could do the merkle tree calculation (and verification) every time
> at bootup, and on a filesystem that supports the long-term storage of
> said merkle data, it's a very cheap operation, but on a filesystem
> that doesn't, it would still be *possible* to just calculate the hash
> and mark it "finalized" for that boot (or that mount). IOW, it would
> work for something like ramfs (but you could also make it work for any
> random on-disk filesystem that doesn't support long-term storage).
>
> At that point, the merkle tree thing ends up fairly equivalent to the
> IMA "measurement" thing, with the exception that the filesystem *may*
> optimize it to be long-term. Hmm?
>
> Now, since I assume that only the merkle tree root hash would be
> returned by the "enable merkle tree" operation (so that the code
> enabling it can verify that the hash matches the expected value), you
> do have to worry about the preimage attack, and make sure that you
> can't fool the hashing by making the (bad) file contents themselves be
> just the hashes of the (good) blocks. So each level of the merkle tree
> needs to have a hash seeding thing or whatever.
>
>               Linus
>

--000000000000a16acb05817c47fb
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Still convinced by linus&#39;s reply.</div><div><br><=
/div><div>Regards,<br></div></div><br><div class=3D"gmail_quote"><div dir=
=3D"ltr" class=3D"gmail_attr">Le=C2=A0sam. 9 f=C3=A9vr. 2019 =C3=A0=C2=A021=
:39, Linus Torvalds &lt;<a href=3D"mailto:torvalds@linux-foundation.org">to=
rvalds@linux-foundation.org</a>&gt; a =C3=A9crit=C2=A0:<br></div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px s=
olid rgb(204,204,204);padding-left:1ex">On Thu, Feb 7, 2019 at 8:10 AM Theo=
dore Y. Ts&#39;o &lt;<a href=3D"mailto:tytso@mit.edu" target=3D"_blank">tyt=
so@mit.edu</a>&gt; wrote:<br>
&gt;<br>
&gt; After doing a lot of thinking and conferring with the other fs-verity<=
br>
&gt; developers, our current thinking is to simply move the Merkle tree<br>
&gt; creation into the kernel.=C2=A0 The upside of doing this is it complet=
ely<br>
&gt; bypasses all of the complaints about how to transfer the Merkle tree<b=
r>
&gt; from userspace to the kernel.<br>
<br>
This sounds very sane to me.<br>
<br>
In particular, may I suggest that=C2=A0 the interface be made idempotent,<b=
r>
so that you can do the merkle tree operation several times with the<br>
same offset/length arguments, and if the merkle tree has already been<br>
calculated, you just return the resulting root hash directly.<br>
<br>
Why? That allows you to &quot;validate&quot; images on filesystems that don=
&#39;t<br>
actually have any long-term storage model for the merkle tree. IOW,<br>
you could do the merkle tree calculation (and verification) every time<br>
at bootup, and on a filesystem that supports the long-term storage of<br>
said merkle data, it&#39;s a very cheap operation, but on a filesystem<br>
that doesn&#39;t, it would still be *possible* to just calculate the hash<b=
r>
and mark it &quot;finalized&quot; for that boot (or that mount). IOW, it wo=
uld<br>
work for something like ramfs (but you could also make it work for any<br>
random on-disk filesystem that doesn&#39;t support long-term storage).<br>
<br>
At that point, the merkle tree thing ends up fairly equivalent to the<br>
IMA &quot;measurement&quot; thing, with the exception that the filesystem *=
may*<br>
optimize it to be long-term. Hmm?<br>
<br>
Now, since I assume that only the merkle tree root hash would be<br>
returned by the &quot;enable merkle tree&quot; operation (so that the code<=
br>
enabling it can verify that the hash matches the expected value), you<br>
do have to worry about the preimage attack, and make sure that you<br>
can&#39;t fool the hashing by making the (bad) file contents themselves be<=
br>
just the hashes of the (good) blocks. So each level of the merkle tree<br>
needs to have a hash seeding thing or whatever.<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Linus<br>
</blockquote></div>

--000000000000a16acb05817c47fb--
