Return-Path: <ebiggers3@gmail.com>
Date: Tue, 5 Sep 2017 11:08:54 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v2] fscrypt: add a documentation file for
 filesystem-level encryption
Message-ID: <20170905180854.GA85970@gmail.com>
References: <20170901000217.36965-1-ebiggers3@gmail.com>
 <20170902001228.GA27020@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170902001228.GA27020@google.com>
To: Michael Halcrow <mhalcrow@google.com>
Cc: linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Michael,

On Fri, Sep 01, 2017 at 05:12:28PM -0700, Michael Halcrow wrote:
> > +fscrypt is only resistant to side-channel attacks, such as timing or
> > +electromagnetic attacks, to the extent that the underlying Linux
> > +Cryptographic API algorithms are.  If a vulnerable algorithm is used,
> > +such as a table-based implementation of AES, it may be possible for an
> > +attacker to mount a side channel attack against the online system.
> 
> Conservatively, I'd go a step further and say that even if the kernel
> crypto API were to mitigate all side channel attacks, we don't make
> any claims as to whether encryption key material (or data for that
> matter) would be vulnerable from code in fs/crypto or the individual
> filesystems.

If possible, I'd prefer to make a stronger claim, at least for the key material.
We are very careful with how we manage the keys in the kernel, and I'd consider
any timing attack against the keys to be a bug --- and I expect that other
people would too.

Data is a different story though, since ultimately it is used by applications to
actually do something.

> > +After an encryption key has been provided, fscrypt is not designed to
> > +hide the plaintext file contents or filenames from other users on the
> > +same system, regardless of the visibility of the keyring key.
> > +Instead, existing access control mechanisms such as file mode bits,
> > +POSIX ACLs, or SELinux should be used for this purpose.  Also note
> 
> Suggest replacing "SELinux" with "LSMs."  Also do you think we should
> mention namespaces?

We could mention that a filesystem containing encrypted files can be "hidden" by
unmounting it, though that should be obvious.  It's also possible to hide
individual files or directories by bind-mounting stuff over them, though that is
getting somewhat eccentric; usually mode bits, ACLs, etc. would be used instead.

> > +that as long as the encryption keys are *anywhere* in memory, an
> > +online attacker can necessarily compromise them by mounting a physical
> > +attack or by exploiting any kernel security vulnerability which
> > +provides an arbitrary memory read primitive.
> 
> Or hooking into a FireWire port and doing DMA?

That falls under the category of "physical attack".

> > +Currently, fscrypt does not prevent a user from maliciously providing
> > +an incorrect key for another user's existing encrypted files.  A
> > +protection against this is planned.
> 
> How's the review for that patch coming along?

So far you're the only person who has reviewed the patchset in detail.  I've
tried to get more people interested, but it has been difficult.  Perhaps the new
documentation will help people understand the problems that the patchset solves.
Being able to provide the wrong key for another user's encrypted files is a
security vulnerability, so we *have* to fix it eventually.

> > +- Per-file keys strengthen the encryption of filenames, where IVs are
> > +  reused out of necessity.  With a unique key per directory, IV reuse
> > +  is limited to within a single directory.
> 
> Side note: Alex's HEH patchset addresses this.  Is there interest in
> the community for us to push for a merge at this point?
> 
> https://www.spinics.net/lists/linux-crypto/msg22411.html

Well, I think there are higher priorities right now, but if we want to start
that conversation we'd first need to send the updated version of the patchset
which implements the latest version of the algorithm
(https://tools.ietf.org/html/draft-cope-heh-01) and has been rebased onto the
latest kernel.

> > +Note: this KDF meets the primary security requirement, which is to
> > +produce unique derived keys that preserve the entropy of the master
> > +key, assuming that the master key is already a good pseudorandom key.
> > +However, it is nonstandard and has some theoretical problems such as
> > +being reversible, so it is generally considered to be a mistake!  It
> 
> Being reversible isn't theoretical -- it's trivially reversible *if*
> you can exploit kernel memory.  The attack I'm concerned about is that
> an adversary is somehow able to get to an inode key but isn't able to
> get to the master key.  Exploiting kernel memory wasn't in my
> adversarial model at the time, and when I suggested going to something
> like HKDF, Ted convinced me that it would be too painful since he had
> already merged the code.
> 
> Regardless, I'm happy to call it a mistake.
> 
> > +may be replaced with HKDF or another more standard KDF in the future.
> 
> Again, I should point out that your patchset that includes migrating
> to HKDF is still pending merge.  I'd like to see that go in soon.

It is too late for v4.14 since that merge window is already open.  It could
potentially go into v4.15, though as a prerequisite for that I expect that Ted
would like to see more people review/discuss it first.  Note that we do not want
to rush it, since we will be locked into the new on-disk format once merged.

- Eric
