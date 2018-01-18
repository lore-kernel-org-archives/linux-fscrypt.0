Return-Path: <ebiggers3@gmail.com>
Date: Wed, 17 Jan 2018 16:18:41 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 1/3] encrypted-keys: add fscrypt format support
Message-ID: <20180118001841.ntui5j2nsszgy3aj@gmail.com>
References: <20180110124418.24385-1-git@andred.net>
 <20180111040022.GA943@zzz.localdomain>
 <1516199369.28972.93.camel@andred.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1516199369.28972.93.camel@andred.net>
To: =?iso-8859-1?Q?Andr=E9?= Draszik <git@andred.net>
Cc: linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Andr�,

On Wed, Jan 17, 2018 at 02:29:29PM +0000, Andr� Draszik wrote:
> Thanks Eric for the review!
> 
> On Wed, 2018-01-10 at 20:00 -0800, Eric Biggers wrote:
> > Hi Andr�,
> > 
> > On Wed, Jan 10, 2018 at 12:44:16PM +0000, Andr� Draszik wrote:
> > > This is heavily based on commit 79a73d188726
> > > ("encrypted-keys: add ecryptfs format support").
> > > 
> > > The 'encrypted' key type defines its own payload format which contains a
> > > symmetric key randomly generated that cannot be used directly by the
> > > fscrypt subsystem, because it instead expects an fscrypt_key structure.
> > > 
> > > This patch introduces the new format 'fscrypt' that allows to store an
> > > fscrypt_key structure inside the encrypted key payload containing
> > > a randomly generated symmetric key, as the same for the format 'default'
> > > and 'ecryptfs'.
> > > 
> > > More details about the usage of encrypted keys with the fscrypt
> > > subsystem can be found in the file
> > > 'Documentation/security/keys/fscrypt.rst'.
> > > 
> > 
> > I don't think a new encrypted-key format is needed.  fscrypt really only
> > needs
> > the raw key.
> 
> This was actually my original approach, but I thought it might potentially
> be useful to have a new encrypted-key type to be able to do verification of
> parameters (e.g. key size) early.
> Additionally, because the type is then encoded in the blob stored in the
> file system (keyctl pipe), it'd be easy to spot incompatibilities in case
> fscrypt internal data structures change, whereas without one can only rely
> on the name of the key (key description), should such a change ever happen.

'struct fscrypt_key' isn't really useful because it doesn't have any reserved
fields.  So if we wanted to change the format we'd have to change the key
description anyway, by setting some flag in the fscrypt_policy and the
fscrypt_context that indicates a different key description should be used.

And fscrypt does verify the key's size before it uses it already.  Sure, it
might to nice to verify it at add_key() time, but I don't think it's necessary.

> 
> > Also I have proposed an fscrypt ioctl to add keys to a filesystem-level
> > keyring,
> > and it doesn't use 'struct fscrypt_key' at all:
> > https://marc.info/?l=linux-fsdevel&m=150879505206393
> > 
> > So I think you should just use the "default" encrypted-key format, where
> > the
> > payload is just the raw key.  fscrypt can very easily be updated to work
> > with
> > such keys.
> 
> I've done that in v2 - I am generating the fscrypt_key temporarily on the
> fly but haven't gotten rid of fscrypt_key altogether... Is that what you had
> in mind?

That would work, but we don't actually need the fscrypt_key structure at all.
Just declare 'const u8 *raw' and 'u32 size' local variables and set them
appropriately, then pass those into derive_key_aes() (changing its prototype)
rather than the fscrypt_key.

> 
> I also haven't based it on your work mentioned above, would that be
> preferred?

Not really, that patch series ("fscrypt: filesystem-level keyring and v2 policy
support") is still in RFC status, so we don't know which would be merged first.
I'm still looking for people with the interest and expertise to review it :-)

That being said, we could choose to support the "encrypted" key type using only
FS_IOC_ADD_ENCRYPTION_KEY, rather than the current mechanism of
process-subscribed keyrings.  (With FS_IOC_ADD_ENCRYPTION_KEY, we'd need to use
a flag in 'struct fscrypt_add_key_args' to indicate that the key should be found
by searching the current process's keyrings for an "encrypted" key with the
given description, rather than taking the key directly from the ioctl argument.)
But it wouldn't be a huge deal to support it both ways.

Eric
