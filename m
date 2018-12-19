Return-Path: <SRS0=PPrJ=O4=linuxfoundation.org=torvalds@kernel.org>
MIME-Version: 1.0
References: <20181101225230.88058-1-ebiggers@kernel.org> <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org> <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org> <20181214044802.GA681@sol.localdomain>
 <20181217200039.GD8111@magnolia> <20181219071149.GB2628@infradead.org>
In-Reply-To: <20181219071149.GB2628@infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 18 Dec 2018 23:16:08 -0800
Message-ID: <CAHk-=wiB8vGbje+NgNkMZupHsZ_cqg6YEBV+ZXSF4wnywFLRHQ@mail.gmail.com>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Content-Type: multipart/alternative; boundary="000000000000610d41057d5aca1b"
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, ebiggers@kernel.org, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

--000000000000610d41057d5aca1b
Content-Type: text/plain; charset="UTF-8"

On Tue, Dec 18, 2018, 23:11 Christoph Hellwig <hch@infradead.org wrote:

>
> I think the fd would have to be on the same fs for this interface to
> make sense. But it could be an O_TMPFILE one.  And given that ext4
> already supports a variant of swapext this interface should also work
> with the existing ext4 on disk format.
>

Why is the merkle tree not just an xattr of the file?

      Linus

>

--000000000000610d41057d5aca1b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">=
On Tue, Dec 18, 2018, 23:11 Christoph Hellwig &lt;<a href=3D"mailto:hch@inf=
radead.org">hch@infradead.org</a> wrote:<br></div><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex"><br>
I think the fd would have to be on the same fs for this interface to<br>
make sense. But it could be an O_TMPFILE one.=C2=A0 And given that ext4<br>
already supports a variant of swapext this interface should also work<br>
with the existing ext4 on disk format.<br></blockquote></div></div><div dir=
=3D"auto"><br></div><div dir=3D"auto">Why is the merkle tree not just an xa=
ttr of the file?</div><div dir=3D"auto"><br></div><div dir=3D"auto">=C2=A0 =
=C2=A0 =C2=A0 Linus</div><div dir=3D"auto"><div class=3D"gmail_quote"><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #cc=
c solid;padding-left:1ex">
</blockquote></div></div></div>

--000000000000610d41057d5aca1b--
