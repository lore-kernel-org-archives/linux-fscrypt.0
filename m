Return-Path: <SRS0=ewVE=PM=google.com=dancol@kernel.org>
MIME-Version: 1.0
References: <20181219071420.GC2628@infradead.org> <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu> <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu> <20181221070447.GA21687@infradead.org>
 <20181221154714.GA26547@mit.edu> <CAHk-=wgdzWgoPSuHeVcqmGE1hB3Gan72r2_AhtC14e60=z45yg@mail.gmail.com>
 <20181222041712.GC26547@mit.edu> <20181223041007.GL10600@bombadil.infradead.org>
 <20181223044553.GG26547@mit.edu>
In-Reply-To: <20181223044553.GG26547@mit.edu>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 4 Jan 2019 12:41:24 -0800
Message-ID: <CAKOZuesHHSRCzQEtGEQbm7v7j53hAjkJq-8Pgcyk+M40o-ia0g@mail.gmail.com>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Dec 22, 2018 at 8:46 PM Theodore Y. Ts'o <tytso@mit.edu> wrote:
>
> On Sat, Dec 22, 2018 at 08:10:07PM -0800, Matthew Wilcox wrote:
> > Pretty much every file format has the ability to put arbitrary blocks
> > of information into a file somewhere the tools which don't know about
> > it will skip it.  For example, ZIP "includes an extra field facility
> > within file headers, which can be used to store extra data not defined
> > by existing ZIP specifications, and which allow compliant archivers tha=
t
> > do not recognize the fields to safely skip them. Header IDs 0=E2=80=933=
1 are
> > reserved for use by PKWARE. The remaining IDs can be used by third-part=
y
> > vendors for proprietary usage. " (Wikipedia)
> >
> > ELF, PNG, PDF and many other formats have the ability to put data
> > _somewhere_.  It might not be at the tail of the file, but there's
> > somewhere to do it.
> >
> > (I appreciate this isn't what Linus is asking for, but I'm pointing out
> > that this is by no means as intractable as you make it sound.)
>
> That design would require the fs-verity code to know the type of eacho
> file, and where to find the in-band Merkle tree for each file type
> that we wanted to support.  And if you wanted to use fs-verity to
> protect a sudoers text configuration file (for example), we'd have to
> teach sudo how to ignore the userspace visible Merkle tree.

I'm pretty late to the game, but I just want to bring up one approach
that I'm not sure people have previously considered. You can't put the
verification blob in an xattr due to xattr size limits, but you *can*
put a filename in an xattr. What if, at open time, fs-verity looked
for a specially-named xattr attached to a file, resolved that name
like a symlink target, opened the pointed-to file, and just used
*that* as the authentication blob? It'd also be possible to teach
unlink to delete the pointed-to file when the pointer file is deleted
--- sort of like a simple and stupid kind of data fork.

For example, if you wanted to secure /usr/bin/emacs, you could set an
security.fsverify.verification_file xattr (in the system namespace
because the xattr has special semantics) to
"/.verification-blobs/@usr@bin@emacs.hashtree" or something like that.
Then, open(2) on /usr/bin/emacs would, internally to VFS, also open
/.verification-blobs/@usr@bin@emacs.hashtree and read verification
data from it, transparently to both users and the underlying
filesystem. If someone deleted /usr/bin/emacs, VFS would automatically
delete /.verification-blobs/@usr@bin@emacs.hashtree. If
/.verification-blobs/@usr@bin@emacs.hashtree didn't exist at time of
open(2) of /usr/bin/emacs, or couldn't be opened for whatever reason,
the open(2) of /usr/bin/emacs would fail.

ISTM that a scheme like this would give you some of the advantages of
jumbo xattrs, but with much less implementation complexity. If
someone's proposed something like this before, sorry for the noise.
