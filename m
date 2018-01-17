Return-Path: <andre.draszik@gmail.com>
Return-Path: <andre.draszik@gmail.com>
Message-ID: <1516199369.28972.93.camel@andred.net>
Subject: Re: [PATCH 1/3] encrypted-keys: add fscrypt format support
From: =?ISO-8859-1?Q?Andr=E9?= Draszik <git@andred.net>
Date: Wed, 17 Jan 2018 14:29:29 +0000
In-Reply-To: <20180111040022.GA943@zzz.localdomain>
References: <20180110124418.24385-1-git@andred.net>
	 <20180111040022.GA943@zzz.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Thanks Eric for the review!

On Wed, 2018-01-10 at 20:00 -0800, Eric Biggers wrote:
> Hi André,
> 
> On Wed, Jan 10, 2018 at 12:44:16PM +0000, André Draszik wrote:
> > This is heavily based on commit 79a73d188726
> > ("encrypted-keys: add ecryptfs format support").
> > 
> > The 'encrypted' key type defines its own payload format which contains a
> > symmetric key randomly generated that cannot be used directly by the
> > fscrypt subsystem, because it instead expects an fscrypt_key structure.
> > 
> > This patch introduces the new format 'fscrypt' that allows to store an
> > fscrypt_key structure inside the encrypted key payload containing
> > a randomly generated symmetric key, as the same for the format 'default'
> > and 'ecryptfs'.
> > 
> > More details about the usage of encrypted keys with the fscrypt
> > subsystem can be found in the file
> > 'Documentation/security/keys/fscrypt.rst'.
> > 
> 
> I don't think a new encrypted-key format is needed.  fscrypt really only
> needs
> the raw key.

This was actually my original approach, but I thought it might potentially
be useful to have a new encrypted-key type to be able to do verification of
parameters (e.g. key size) early.
Additionally, because the type is then encoded in the blob stored in the
file system (keyctl pipe), it'd be easy to spot incompatibilities in case
fscrypt internal data structures change, whereas without one can only rely
on the name of the key (key description), should such a change ever happen.

> Also I have proposed an fscrypt ioctl to add keys to a filesystem-level
> keyring,
> and it doesn't use 'struct fscrypt_key' at all:
> https://marc.info/?l=linux-fsdevel&m=150879505206393
> 
> So I think you should just use the "default" encrypted-key format, where
> the
> payload is just the raw key.  fscrypt can very easily be updated to work
> with
> such keys.

I've done that in v2 - I am generating the fscrypt_key temporarily on the
fly but haven't gotten rid of fscrypt_key altogether... Is that what you had
in mind?

I also haven't based it on your work mentioned above, would that be
preferred?

Cheers,
Andre'
