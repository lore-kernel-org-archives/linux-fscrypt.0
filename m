Return-Path: <ebiggers3@gmail.com>
Date: Fri, 14 Jul 2017 17:52:22 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 4/6] fscrypt: verify that the correct master key was
 supplied
Message-ID: <20170715005222.GA31022@gmail.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-5-ebiggers3@gmail.com>
 <CAH8yC8naCiyXKeaYbyw=B1DgM3vvBtUSmDCZ+B7VVqZ6QD1uhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH8yC8naCiyXKeaYbyw=B1DgM3vvBtUSmDCZ+B7VVqZ6QD1uhg@mail.gmail.com>
To: Jeffrey Walton <noloader@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jeff,

On Fri, Jul 14, 2017 at 01:34:48PM -0400, Jeffrey Walton wrote:
> On Wed, Jul 12, 2017 at 5:00 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> > From: Eric Biggers <ebiggers@google.com>
> >
> >....
> > Solve the problem for v2 encryption policies by storing a "hash" of the
> > master encryption key in the encryption xattr and verifying it before
> > accepting the user-provided key.
> > ...
> 
> Forgive my ignorance... Doesn't that setup an oracle so an attacker
> can query keys?
> 
> It seems like the problem is deeper into the design. Namely, the
> caching and sharing of keys.
> 

Your concerns are a little vague, so I'll try to cover both major attack
scenarios.  We can assume that key_hash is public information, available to the
attacker.  (For offline attacks that's obviously the case.  For online attacks
it's not obvious since no API exposes it yet, but we'll consider it available
nonetheless, perhaps via a side-channel attack.)

The first attack scenario is breaking the encryption itself, and specifically
whether having key_hash makes it easier.  Fundamentally, adding a 128-bit
key_hash reduces by a factor of 2^128 the number of keys which may be the
correct one.  Thus, to not weaken the encryption, it needs to be infeasible to
enumerate the possible keys which hash to a particular value.  If that could be
done faster than brute force, then recovering the key would in turn be faster
than brute force, so the cryptosystem would be broken in a theoretical sense.

However, in practice I don't think we should be too concerned about it.  SHA-512
has been holding up pretty well to preimage attacks, and enumerating all
possible source messages of a particular length is much more specific than even
a preimage attack actually.  And even if this scheme were, incredibly, fully
broken to the extent that the hash might as well just be the first 128 bits of
the key, if the recommended AES-256-XTS mode is used the master key is actually
512 bits, so there would *still* be 384 bits remaining to brute-force.

The second attack scenario would be not breaking the encryption directly, but
rather causing "someone else's" data to be encrypted (or decrypted) with the
wrong key, or even left unencrypted.  I'll limit the focus to online attacks,
since offline attacks are a different story for this.  Previously we had no
protection against this attack beyond visibility of files: anyone with *read*
access to someone's encrypted directory or files could provision the wrong key.
With this patchset this problem is solved, at least in practice: to provision
the wrong key, the attacker will now need to compute a preimage of key_hash,
which as noted is intended to be computationally expensive.  Note that
brute-forcing a 128-bit hash's preimage would take over 10 million years if you
had 1 trillion computers each performing 1 trillion hashes per second --- so
clearly a practical attack would have to be much more clever.

Now, even if a preimage could be found much more easily, as long as it still had
a decent cost I really, really doubt that an attacker --- who, given that the
attack scenario is *online* very likely already has code execution on the system
--- would perform an expensive cryptographic attack to *maybe* gain the ability
to later decrypt some particular new file contents belonging to one particular
user on one particular device, vs. just exploiting a security vulnerability to
elevate privileges or gain kernel code execution, then reading everything from
memory.  Remember, attacks take the path of least resistance.

Therefore, I actually felt confident enough in the hash to use it as the only
identifier in ->s_master_keys, even though that expands the "providing the wrong
key" attack surface to the whole filesystem rather than just the files visible
to the attacker.  If we are truly concerned about this, we could add raw_key to
struct fscrypt_master_key, always do the keyring lookup, and compare the raw_key
in the keyring key with the fscrypt_master_key.  It would arguably be a step
backwards towards relying less on keyrings and their visibility problems, and it
would leave another copy of the master key in memory, but it could be done.

I think another scenario which you may be getting at is whether the presence of
key_hash makes it easier to test whether a candidate key is the right one.  The
answer is potentially yes, but it doesn't really matter.  If an attacker is
actually able to enumerate your key, then you are already screwed as they can
likely validate it in some other efficient way, e.g. by encrypting some known
plaintext blocks and comparing it to the ciphertext.  If your "encryption" key
doesn't contain enough randomness to prevent it from being enumerated in a
practical sense then it's not encryption --- it's obfuscation.

Eric
