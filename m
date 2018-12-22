Return-Path: <SRS0=pCIG=O7=mit.edu=tytso@kernel.org>
Date: Fri, 21 Dec 2018 23:17:12 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181222041712.GC26547@mit.edu>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu>
 <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu>
 <20181221070447.GA21687@infradead.org>
 <20181221154714.GA26547@mit.edu>
 <CAHk-=wgdzWgoPSuHeVcqmGE1hB3Gan72r2_AhtC14e60=z45yg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wgdzWgoPSuHeVcqmGE1hB3Gan72r2_AhtC14e60=z45yg@mail.gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Dec 21, 2018 at 11:13:07AM -0800, Linus Torvalds wrote:
> 
> I do agree that your particular model is pretty damn broken in lots of ways.
> 
> Why is it filesystem specific? If the whole point is that the file
> itself has its own verification data (which I like), then I don't see
> why this is then documented as some filesystem-specific layout model.
> That's complete and utter garbage.
> 
> In other words: either the model is that the file *itself* contains
> its own merkle tree that validates the file, or it isn't. You can't
> have it two ways. No silly "layout changes when you apply the hash"
> garbage. That's just crazy talk and invalidates the whole model.

Userspace applications which are reading the file aren't going to be
expecting Merkle tree.  For example, one of the use cases is Android
APK files, which are essentially ZIP files.  ZIP files can be parsed
both from the front-end (streaming), or by looking for the complete
directory of all of the files in the ZIP file by starting at the end
of the file and moving backwards.  If the Merkle tree was visible to
userspace programs that are opening and reading the file, it would
confuse them mightily.

So what we do for ext4 and f2fs is make the Merkle tree invisible; if
userspace stats the file, st_size will return size of the original
"data" file, and reading beyond the st_size from userspace will behave
like reading beyond EOF.  From the *file system's* perspective,
though, the metadata blocks are part of the file.  There's just a
difference between the userspace visible EOF and the file system's
conception of EOF.  I don't consider this a "layout change", and I
personally believe this should be just *fine* for all file systems.
The XFS developers are convinced that this is horrific, and no one
sane should do this.  OK, call me insane.  But it works, and I think
it's elegant and clean.

So if *they* want to use some other layout, where the Merkle blocks
are stored in some Alternate Data Stream, ala NTFS --- they are *free*
to do that.  It will require more work, and at that point, it will
require a layout change.  But it's Dave and Christoph who are
insisting on doing that; not me!

> And honestly, I still think that it's very odd to add the merge data
> to the end, when the filesystem already supports xattrs. It would have
> made much more sense to just make one xattr contain the merkle tree
> validation data.

The problem is that xattrs are designed to be accessed via a set/get
interface, are currently limited, IIRC at 32k.  The max size of an APK
is 300 megabytes; and the Merkle tree for a file that size will be
about 2.3 megabytes.  That's way too big to store as an xattr;
certainly using the existing xattr interfaces.  And it's also bigger
than most file systems can handle as xattrs today --- because they've
been optimzied for relatively small sizes, for things like SELinux
labels and ACL structures.

> So why is this sold as some unholy mess of "filesystem-specific" and
> "generic"? That part just annoys the hell out of me. Why isn't this
> sold as an *actual* generic model, where you just say "append the
> merkle tree to the file, then enable verity testing of the end result
> and validate the top-level hash".

That was the original way it was sold, but Cristoph and Dave have
NACK'ed it in that form.  The common fsverity code which is generic to
ext4 and f2fs does treat it that way, with the note that we "lie" to
userspace about is the size of the file and where the EOF is.  Dave
and Cristoph have declaimed strongly that this is this layout choice
is horrible, and filesystem specific, and XFS could never do it that
way.  I don't understand why, but they are the XFS experts.  So if
they want to do something else, what I've been trying to point out is
that they can do that, using the existing interface.

> So what's the excuse for doing the crazy odd "let's just support one
> single filesystem" model?

Android devices use both ext4 and f2fs; it's the manufacturer's
choice.  So we wanted fs-verity to support both.  And we didn't want
to duplicate code across ext4 and f2fs; hence trying to put common
code in fs/verity.  So we aren't supporting one file system out of the
gate; we're supporting two.

Whether XFS wants to implement fs-verity is purely XFS's choice.  XFS
has chosen not to support fscrypt, which is currently used by ext4,
f2fs, and ubifs, and both fscrypt's and fs-verity's initial use case
has been for Android, which is not an area where XFS has proven to be
a common choice.

So I was not really expecting that they would have any interest in
fs-verity.  But they seem to have very strong opinions about how they
would want to implement it, and it's different from what we have in
the current "generic code shared by ext4 and f2fs".  I was trying to
show that even if they wanted to do things in this different way ---
and I don't understand why it's so important to them --- it would be
possible to do so.

Cheers,

					- Ted
