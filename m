Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Tue, 12 Feb 2019 12:24:33 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Message-ID: <20190212172433.GT23000@mit.edu>
References: <20190207031101.GA7387@mit.edu>
 <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
 <1549807615.12743.109.camel@linux.ibm.com>
 <20190212053123.GR23000@mit.edu>
 <1549976812.12743.225.camel@linux.ibm.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <1549976812.12743.225.camel@linux.ibm.com>
Subject: Re: [f2fs-dev] Proposal: Yet another possible fs-verity interface
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Mimi Zohar <zohar@linux.ibm.com>
Cc: Eric Biggers <ebiggers@kernel.org>, "Darrick J." Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>," linux-f2fs-devel@lists.sourceforge.net, Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Feb 12, 2019 at 08:06:52AM -0500, Mimi Zohar wrote:
> Yes, I understand that your primary goal hasn't changed.=A0=A0Linus was
> suggesting "the interface be made idempotent" to support "filesystems
> that don't actually have any long-term storage model for the merkle
> tree. =A0IOW, you could do the merkle tree calculation (and
> verification) every time at bootup". =A0In that context, I asked whether
> the Merkle tree file hash would be for every file on the filesystem or
> not, and how to identify those files.

I have no idea; *we're* certainly never going to use it in that mode.
Until we have a use case, answering your questions about when the
Merkle tree hash would be calculated, etc. is not something I can do.

If IMA wants to use it in that way, let's talk, and we probably can
drop everyone off the cc line.  But there's a limit to much work the
open source community can expect to extort out of people who are
trying to get a feature upstream.  If it's very closely related, and
it's a small amount of work, that's a no-brainer.  But past a certain
point, it's a completely new feature, and it stops being fair....

> > > The existing file hashes included in the measurement list and the
> > > audit log, are currently being used for remote attestation, forensics
> > > and security analytics.
> =

> Again, the context for this comment was Linus' suggestion "each level
> of the merkle tree needs to have a hash seeding thing or whatever."
> Up to this point, I had assumed the Merkle tree file root hash could
> be used as an identifier, similar to the file hash.=A0=A0With his
> suggestion, it sounds like the Merkle tree file root hash would be
> system dependent, making it useless for the above usages.

Yeah, I have no idea what Linus was talking about there.  The only
thing that really makes sense is that if you don't have any
file-system place to store a seed, you don't use a seed for the Merkle
tree, and for a given set of bytes, the Merkle root hash is the same.
So it's basically an expensive to calculate crypto checksum, as I said.

If that's helpful to IMA, we need a crisp set of requirements and
expectations of how IMA would use it.  And this includes, as I
mentioned in my other e-mail, questions like how long do we keep the
Merkle tree pinned in memory, how it would be used (I assume it would
be something called from IMA's measurement hook, but maybe you have
other ideas).  Bottom line --- I need *you* to answer the questions
that you posed.  :-)

Once we get the requirements, we can figure out how we can architect
something sane --- but adding this extra feature is going to be a lot
work, make no mistake about it.  One of the other things we will need
to figure out is how to hook into other file systems's readpages
model.  There's no standardization here, since file systems don't even
have to use the page cache!

So my strong preference would be to get the base fs-verity feature in,
and then we can look into how it would be extended for this new,
completely different use case.  And hopefully, the people who would
benefit from this new use case, would be willing to contribute some of
the engineering effort to make it happen?  :-)

					- Ted


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
