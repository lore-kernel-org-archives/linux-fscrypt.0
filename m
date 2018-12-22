Return-Path: <SRS0=FGNy=O7=linuxfoundation.org=torvalds@kernel.org>
MIME-Version: 1.0
References: <20181219071420.GC2628@infradead.org> <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu> <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu> <20181221070447.GA21687@infradead.org>
 <20181221154714.GA26547@mit.edu> <CAHk-=wgdzWgoPSuHeVcqmGE1hB3Gan72r2_AhtC14e60=z45yg@mail.gmail.com>
 <20181222041712.GC26547@mit.edu>
In-Reply-To: <20181222041712.GC26547@mit.edu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 22 Dec 2018 14:47:22 -0800
Message-ID: <CAHk-=wgPz4dfq4sPWxHwMR3g_R3xHhWjofXTu8rV0QU2DP0JhA@mail.gmail.com>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Content-Type: text/plain; charset="UTF-8"
To: Theodore Ts'o <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Dec 21, 2018 at 8:20 PM Theodore Y. Ts'o <tytso@mit.edu> wrote:
>
> On Fri, Dec 21, 2018 at 11:13:07AM -0800, Linus Torvalds wrote:
> >
> > In other words: either the model is that the file *itself* contains
> > its own merkle tree that validates the file, or it isn't. You can't
> > have it two ways. No silly "layout changes when you apply the hash"
> > garbage. That's just crazy talk and invalidates the whole model.
>
> Userspace applications which are reading the file aren't going to be
> expecting Merkle tree.  For example, one of the use cases is Android
> APK files, which are essentially ZIP files.  ZIP files can be parsed
> both from the front-end (streaming), or by looking for the complete
> directory of all of the files in the ZIP file by starting at the end
> of the file and moving backwards.  If the Merkle tree was visible to
> userspace programs that are opening and reading the file, it would
> confuse them mightily.
>
> So what we do for ext4 and f2fs is make the Merkle tree invisible

Again, this has nothing that is per-filesystem in it.

If we were to decide to support the notion of "append merkle hashes to
the file for validation" at the vfs layer, the same logic would apply:
obviously the merkle data shouldn't be visible to user space.

But that's not a reason to do it at a filesystem layer, quite the
reverse: exactly like you say, as far as the *filesystem* is
concerned, the data is there in the file. It's literally about the
*view* of the file, ie the system call interface:

>    From the *file system's* perspective,
> though, the metadata blocks are part of the file.

To me that only argues that this all should be at the vfs layer, and
that it shouldn't be the filesystem that hides it. Exactly because as
far as the filesystem is concerned, the merkle data is there, it's
just that we hide it at read (and stat) time.

Preferably some way where it's namespace-dependent or whatever, so
that you could still access the original file data from user space if
you want to (eg some backup purpose or other).

What I'm missing is any kind of sane explanation for why it was done
so badly, and why it should be upstreamed despite the apparent bad
implementation.

It sounds like a complete hack.

Again, to me either the point is that it's a generic extension of the
file data, _or_ it's some filesystem-specific hidden data. The way
you've done it and written the documentation, it's clearly a generic
extension of normal file data, and I don't see what's fs-specific to
it.

> The problem is that xattrs are designed to be accessed via a set/get
> interface, are currently limited, IIRC at 32k.  The max size of an APK
> is 300 megabytes; and the Merkle tree for a file that size will be
> about 2.3 megabytes.  That's way too big to store as an xattr;
> certainly using the existing xattr interfaces.  And it's also bigger
> than most file systems can handle as xattrs today --- because they've
> been optimzied for relatively small sizes, for things like SELinux
> labels and ACL structures.

So *this* kind of argument is what I'm looking for.

That at least explains why it's not an xattr. Ugly, but understandable.

> > So why is this sold as some unholy mess of "filesystem-specific" and
> > "generic"? That part just annoys the hell out of me. Why isn't this
> > sold as an *actual* generic model, where you just say "append the
> > merkle tree to the file, then enable verity testing of the end result
> > and validate the top-level hash".
>
> That was the original way it was sold, but Cristoph and Dave have
> NACK'ed it in that form.

That seems entirely irrelevant. What do Christoph and Dave have to do
with it once it's generic? It would have _zero_ filesystem component
if it's actually done in a generic manner. It would be a total no-op
to XFS.

Which makes me think "it wasn't actually sold as being
filesystem-independent" at all.

So I want to understand why this was made a filesystem operation in
the first place. What's fs-specific about this implementation?

                 Linus
