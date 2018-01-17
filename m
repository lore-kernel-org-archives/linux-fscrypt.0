Return-Path: <tytso@thunk.org>
Date: Wed, 17 Jan 2018 13:05:37 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 3/3] encrypted-keys: document new fscrypt key format
Message-ID: <20180117180537.GB6948@thunk.org>
References: <20180110124418.24385-1-git@andred.net>
 <20180110124418.24385-3-git@andred.net>
 <20180111044801.GB943@zzz.localdomain>
 <1516199939.28972.101.camel@andred.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1516199939.28972.101.camel@andred.net>
To: =?iso-8859-1?Q?Andr=E9?= Draszik <git@andred.net>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jan 17, 2018 at 02:38:59PM +0000, Andr� Draszik wrote:
> > > [...]
> > 
> > Please be very clear about exactly what security properties are achieved
> > by
> > using encrypted-keys.
> 
> I've left out all of this in the updated documentation, as any such
> information should probably be in Documentation/security/keys/trusted-
> encrypted.rst in the first place.

Where is this document going to be found / when will it be written?
It seems really odd to be requesting a do code review when the
specifications aren't available and/or haven't been written yet.  I
prefer to review the *design* first, as opposed to trying to both
review the code and try to guess at the design and review my guess of
the design at the same time....

					- Ted
				
