Return-Path: <SRS0=REoV=PM=redhat.com=dhowells@kernel.org>
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20190103171659.GA208343@gmail.com>
References: <20190103171659.GA208343@gmail.com> <20181230162906.GI27785@darkstar.musicnaut.iki.fi>
Subject: Re: Bug report: unaligned access with ext4 encryption
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <17390.1546622882.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Fri, 04 Jan 2019 17:28:02 +0000
Message-ID: <17391.1546622882@warthog.procyon.org.uk>
To: Eric Biggers <ebiggers@kernel.org>
Cc: dhowells@redhat.com, Aaro Koskinen <aaro.koskinen@iki.fi>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Eric Biggers <ebiggers@kernel.org> wrote:

> Hi Aaro, thanks for the bug report!  I think you're on the right track; =
it makes
> much more sense to have the keyrings subsystem store the payload with be=
tter
> alignment, than to work around the 2-byte alignment in fscrypt.
> =

> But how about '__aligned(__alignof__(u64))' instead?  4 bytes may not be=
 enough.
> =

> David, what do you think?

Does that even work?

Might be better to just insert 6 bytes of padding with a comment, but yes =
I
agree that it's probably better to align it to at least machine word size.

David
