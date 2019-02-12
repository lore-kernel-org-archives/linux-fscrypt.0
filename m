Return-Path: <SRS0=UUxe=QT=linux.ibm.com=zohar@kernel.org>
Subject: Re: Proposal: Yet another possible fs-verity interface
From: Mimi Zohar <zohar@linux.ibm.com>
Date: Tue, 12 Feb 2019 08:06:52 -0500
In-Reply-To: <20190212053123.GR23000@mit.edu>
References: <20190207031101.GA7387@mit.edu>
	 <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
	 <1549807615.12743.109.camel@linux.ibm.com> <20190212053123.GR23000@mit.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <1549976812.12743.225.camel@linux.ibm.com>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong  <darrick.wong@oracle.com>, Eric Biggers" <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, James Bottomley <James.Bottomley@HansenPartnership.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ted,

The context for my comments/questions was Linus' suggestions, which
you've removed.

On Tue, 2019-02-12 at 00:31 -0500, Theodore Y. Ts'o wrote:
> On Sun, Feb 10, 2019 at 09:06:55AM -0500, Mimi Zohar wrote:
> > For which files will the Merkle tree be created?  Is this for all
> > files on a per file system basis?  Or is there some sort of "flag" or
> > policy?  The original design was based on an ioctl enabling/disabling
> > a flag. In this new design, is there still an ioctl?
> 
> So for our first use case, it will be used for "privileged APK files"
> in Android.  You can think of this as a "setuid binary", effectively.

Yes, I understand that your primary goal hasn't changed.  Linus was
suggesting "the interface be made idempotent" to support "filesystems
that don't actually have any long-term storage model for the merkle
tree.  IOW, you could do the merkle tree calculation (and
verification) every time at bootup".  In that context, I asked whether
the Merkle tree file hash would be for every file on the filesystem or
not, and how to identify those files.

> > The existing file hashes included in the measurement list and the
> > audit log, are currently being used for remote attestation, forensics
> > and security analytics.

Again, the context for this comment was Linus' suggestion "each level
of the merkle tree needs to have a hash seeding thing or whatever."
Up to this point, I had assumed the Merkle tree file root hash could
be used as an identifier, similar to the file hash.  With his
suggestion, it sounds like the Merkle tree file root hash would be
system dependent, making it useless for the above usages.

> 
> IMA has a very different set primary use cases than fsverity.

We need to differentiate between IMA's method of calculating the file
hash from the IMA measurement list.  I totally agree there is a place
for both methods of calculating the file hash.  I am hoping that we
would be able to use the Merkle tree file root hash in the IMA
measurement list.  It makes no sense to have to calculate the file
hash for the measurement list, if you're using fs-verity.

Mimi
