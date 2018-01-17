Return-Path: <andre.draszik@gmail.com>
Return-Path: <andre.draszik@gmail.com>
Message-ID: <1516199939.28972.101.camel@andred.net>
Subject: Re: [PATCH 3/3] encrypted-keys: document new fscrypt key format
From: =?ISO-8859-1?Q?Andr=E9?= Draszik <git@andred.net>
Date: Wed, 17 Jan 2018 14:38:59 +0000
In-Reply-To: <20180111044801.GB943@zzz.localdomain>
References: <20180110124418.24385-1-git@andred.net>
	 <20180110124418.24385-3-git@andred.net>
	 <20180111044801.GB943@zzz.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On Wed, 2018-01-10 at 20:48 -0800, Eric Biggers wrote:
> Hi André,
> 
> On Wed, Jan 10, 2018 at 12:44:18PM +0000, André Draszik wrote:
> > diff --git a/Documentation/security/keys/fscrypt.rst
> > b/Documentation/security/keys/fscrypt.rst
> > new file mode 100644
> > index 000000000000..e4a29592513e
> > --- /dev/null
> > +++ b/Documentation/security/keys/fscrypt.rst
> > @@ -0,0 +1,67 @@
> > +========================================
> > +Encrypted keys for the fscrypt subsystem
> > +========================================
> 
> There is now documentation for fscrypt in
> Documentation/filesystems/fscrypt.rst;
> see in particular the "Adding keys" section.  The documentation for any
> new ways
> to add keys should go in there.

Done.

> 
> > +
> > +fscrypt allows file systems to implement transparent encryption and
> > decryption
> > +of files, similar to eCryptfs, using keys derived from a master key
> > descriptor.
> 
> Note that the master key *descriptor* refers to the hex string used in the
> keyring key description.  It is not the same as the master key itself,
> which is
> stored in the payload.  The cryptography is done with the master key, not
> with
> the master key *descriptor*.

Ups, thanks.

> > [...]
> 
> Please be very clear about exactly what security properties are achieved
> by
> using encrypted-keys.

I've left out all of this in the updated documentation, as any such
information should probably be in Documentation/security/keys/trusted-
encrypted.rst in the first place.

> 
[...]
> > +
> > +Example of encrypted key usage with the fscrypt subsystem:
> > +
> > +Create an encrypted key "1234567890123456" of length 64 bytes with
> > format
> > +'fscrypt' and save it using a previously loaded user key "test"::
> > +
> > +    $ keyctl add encrypted fscrypt:1234567890123456 "new fscrypt
> > user:test 64" @u
> > +    1023935199
> > +
> > +    $ keyctl print 1023935199
> > +    fscrypt user:test 64
> > e5606689fdc25d78a787249f4069fb3b007e992f4b21d0eda60
> > +    c97986fc2e3326b5542e2b32216fc5007d9fd19cd3cb6668fa9850e954d2ba25e1b
> > 8a331
> > +    1b0c1f20666c
> > +
> > +    $ keyctl pipe 1023935199 > fscrypt.blob
> 
> What is the point of having the kernel wrap a key with the "user" key
> type?  It
> seems pointless; userspace could just do it instead.

Yes... My real reasoning is being able to use an encrypted key, backed by a
trusted TPM key.

I've updated the examples.

> 
[...]
> I think it's really only "trusted" wrapping keys where this new feature
> would
> have any useful security properties.  So the documentation needs to
> explain
> that, and use that in the examples.

You're right. Done.


Cheers,
André
