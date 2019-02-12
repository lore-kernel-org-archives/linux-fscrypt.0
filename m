Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Tue, 12 Feb 2019 10:42:10 -0800
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190212184209.GA3373@gmail.com>
References: <20190207031101.GA7387@mit.edu>
 <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
 <1549807615.12743.109.camel@linux.ibm.com>
 <20190212053123.GR23000@mit.edu>
 <1549976812.12743.225.camel@linux.ibm.com>
 <20190212172433.GT23000@mit.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190212172433.GT23000@mit.edu>
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
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Mimi Zohar <zohar@linux.ibm.com>, linux-f2fs-devel@lists.sourceforge.net, Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Feb 12, 2019 at 12:24:33PM -0500, Theodore Y. Ts'o wrote:
> =

> > > > The existing file hashes included in the measurement list and the
> > > > audit log, are currently being used for remote attestation, forensi=
cs
> > > > and security analytics.
> > =

> > Again, the context for this comment was Linus' suggestion "each level
> > of the merkle tree needs to have a hash seeding thing or whatever."
> > Up to this point, I had assumed the Merkle tree file root hash could
> > be used as an identifier, similar to the file hash.=A0=A0With his
> > suggestion, it sounds like the Merkle tree file root hash would be
> > system dependent, making it useless for the above usages.
> =

> Yeah, I have no idea what Linus was talking about there.  The only
> thing that really makes sense is that if you don't have any
> file-system place to store a seed, you don't use a seed for the Merkle
> tree, and for a given set of bytes, the Merkle root hash is the same.
> So it's basically an expensive to calculate crypto checksum, as I said.
> =


I think there's confusion due to the use of the phrase "Merkle tree root ha=
sh".
Linus's point was:

> Now, since I assume that only the merkle tree root hash would be
> returned by the "enable merkle tree" operation (so that the code
> enabling it can verify that the hash matches the expected value), you
> do have to worry about the preimage attack, and make sure that you
> can't fool the hashing by making the (bad) file contents themselves be
> just the hashes of the (good) blocks. So each level of the merkle tree
> needs to have a hash seeding thing or whatever.

This is already taken into account in the original design.  The file hash
reported by fs-verity is *not* the Merkle tree root hash directly, but rath=
er a
hash of the Merkle tree root hash and additional metadata in the
fsverity_descriptor including the file size in bytes.  This resulting hash =
is
referred to in the code, documentation, etc. as the "fs-verity file measure=
ment".

Thus you can't fool the hashing in the way that Linus mentioned, because the
file size is included in the hash too.  And I don't expect this part of the
design should change, even if we change the API.

It's been difficult to get people to start saying "fs-verity file measureme=
nt"
rather than "Merkle tree root hash", though, so if anyone has a suggestion =
for a
better name it would be appreciated.  An earlier name was "fs-verity root h=
ash",
but I thought that would too easily be confused with the Merkle tree root h=
ash.

fs-verity does support a salt as well, but it's optional and isn't needed to
prevent preimage attacks, assuming the user chose a strong cryptographic ha=
sh
function such as SHA-256 or SHA-512.

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
