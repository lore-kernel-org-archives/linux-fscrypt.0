Return-Path: <andre.draszik@gmail.com>
Return-Path: <andre.draszik@gmail.com>
Message-ID: <1516353413.28972.119.camel@andred.net>
Subject: Re: [PATCH 3/3] encrypted-keys: document new fscrypt key format
From: =?ISO-8859-1?Q?Andr=E9?= Draszik <git@andred.net>
Date: Fri, 19 Jan 2018 09:16:53 +0000
In-Reply-To: <20180117180537.GB6948@thunk.org>
References: <20180110124418.24385-1-git@andred.net>
	 <20180110124418.24385-3-git@andred.net>
	 <20180111044801.GB943@zzz.localdomain>
	 <1516199939.28972.101.camel@andred.net> <20180117180537.GB6948@thunk.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
To: Theodore Ts'o <tytso@mit.edu>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Thank you Ted,

On Wed, 2018-01-17 at 13:05 -0500, Theodore Ts'o wrote:
> On Wed, Jan 17, 2018 at 02:38:59PM +0000, André Draszik wrote:
> > > > [...]
> > > 
> > > Please be very clear about exactly what security properties are
> > > achieved
> > > by
> > > using encrypted-keys.
> > 
> > I've left out all of this in the updated documentation, as any such
> > information should probably be in Documentation/security/keys/trusted-
> > encrypted.rst in the first place.
> 
> Where is this document going to be found / when will it be written?
> It seems really odd to be requesting a do code review when the
> specifications aren't available and/or haven't been written yet.  I
> prefer to review the *design* first, as opposed to trying to both
> review the code and try to guess at the design and review my guess of
> the design at the same time....

Does v3's commit message https://patchwork.kernel.org/patch/10173189/ serve
as a good enough design document?

Cheers,
Andre'
