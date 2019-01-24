Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Fri, 25 Jan 2019 08:25:45 +1100
From: Dave Chinner <david@fromorbit.com>
Message-ID: <20190124212544.GS6173@dastard>
References: <20190110051500.GA32361@mit.edu> <20190114234101.GQ27534@dastard>
 <20190123051017.GA8785@mit.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190123051017.GA8785@mit.edu>
Subject: Re: [f2fs-dev] Proposal: A new fs-verity interface
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Eric Biggers <ebiggers@kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-f2fs-devel@lists.sourceforge.net, Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jan 23, 2019 at 12:10:17AM -0500, Theodore Y. Ts'o wrote:
> Apologies for the delay in getting responding; I've been on vacation
> last week.
> 
> On Tue, Jan 15, 2019 at 10:41:01AM +1100, Dave Chinner wrote:
> > > int ioctl(fd, FS_IOC_ENABLE_VERITY, struct fsverity_arg *arg);
> > > 
> > > struct fsverity_arg {
> > >        int fsv_donor_fd;
> > >        u64 fsv_offset;
> > >        u64 fsv_size;
> > > };
> > > 
> > > fsv_offset and fsz_size must be a multiple of the file system block
> > > size.  If the ioctl comples successfully, as a side effect the
> > > donor_fd will have a hole punch operation on the specified range.  In
> > > other words, the equivalent of operation of fallocate(fsv_donor_fd,
> > > FALLOC_FL_PUNCH_HOLE, fsv_offset, fsv_size), and the file specified by
> > > fd will be protected using fsverity.
> > 
> > makes no sense to me. What's in {offset, size} and why do you need
> > to call this on that specific range? If it is the equivalent of a
> > hole punch, then why wouldn't you just use FALLOC_FL_PUNCH_HOLE?
> 
> This is how we transfer the metadata (e.g., the Merkle tree plus a
> header block) from userspace to the file system. 


> In the original
> interface, the verity metadata was appended end of the data file, and
> then an ioctl would transfer the metadata to the file system.

So how is this different? You still put the data into a file,
then tell the kernel what file it belongs to, and then the
filesystem does "magic" and *consumes* that part of the file?

That's what I'm asking here - what are the semantics of this
ioctl(). I'mnot asking for justification or a unnecessary history
lesson. I'm asking you to describe the behaviour and interface
precisely.

> For
> ext4 and f2fs, we actually store the fsverity metadata after the data
> blocks and simply adjust i_size visible to userspace so the metadata
> blocks are "invisible".

Yes, I know how it's been implemented in ext4 and f2fs. I don't
care about that - I care about what how this new interface works.

> You objected to this interface, because it was too tightly tied to the
> implementation used in ext4 and f2fs.  So what Darrick suggested is
> that it could be conveyed by passing the metadata via a second file
> descriptor.  The offset and size specifies where the metadata can be
> fetched from the second file.

So it's still "file data" that the filesystem has to magically
transform into hidden metadata in some manner. What writes the
merkel tree into a file, and why can't it just write it direct to
the filesystem rather than having to use an intermediate file?

i.e. the proposed API still seems to be bleeding "merkel tree is
held in file data" implementation artifacts through it. That
you can still append the merkle tree to the target file and
then use the hack "donor_fd = fd" to tell it that is where the
merkel tree data is stored seems like a convenient API hack for the
existing implementation, rather than a well thought through, generic
API.

> As in the original interface, the metadata blocks are "consumed" by
> the ioctl, so they disappear from the second file, as if
> FALLOC_FL_PUNCH_HOLE.  It's not that they are deallocated; the blocks
> in question are simply getting transferred to inode which is being
> protected using fs-verity.

But it's not a "hole punch" in your proposal and current
implementation because a) the merkle tree blocks are istill
accounted as user data on the inode the file and hence visible to
userspace (e.g. via stat()) and b) hole punch does not change the
file size. i.e. FALLOC_FL_PUNCH_HOLE is not an equivalent operation
for the behaviour you are talking about, and the blocks aren't
actually "consumed" because they are still accounted to the same
file.

IOWs, "du -sh" now reports a significant mismatch between file sizes
and space consumed by the files. We know from experience that this
will confuse users and they'll think it's a bug:

http://xfs.org/index.php/XFS_FAQ#Q:_Why_do_files_on_XFS_use_more_data_blocks_than_expected.3F

So even though Darrick's proposal is /better/ than just appending
data and flipping the inode size to hide it, this API definition
still allows implementation details specific to "storing merkle tree
as user data beyond EOF" implementations right through it.


> 
> > Can you please write the man page for the interface so that the
> > description of what it does and how it should be used is crystal
> > clear and doesn't assume the reader knows "what darrick proposed"...
> 
> I can do that, but I'd like to make sure we have general agreement
> approach first.

This is why we suck so badly at designing new interfaces. We have to
have "agreement" before anyone even tries to flesh out the full
interface and document all aspects of it. But then we get
"agreement" and the next thing that happens is an implementation
lands in the tree and then we find later on it's full of bugs
because "agreement" doesn't mean ithe API was "fully documented,
understood, reviewed and tested".

We need to change the way we design user APIs - if you don't have a
fully documented proposal (i.e. a man page) that describes the
parameters, the behaviour of the API, the implementation
constraints and requirements, the errors that can be returned, etc,
then it isn't an API proposal we can actually review properly.

So, please, if this is the way you want to go, please document the
API properly.

However, I still have issues with the assumption that the user
application generating the merkel tree must first write the fsverity
information to a user data file before the merkel tree is passed to
the filesystem for permanent storage? Why doesn't it write the
merkel tree directly to the kernel so the filesystem can store it
where it wants to store it on the fly?

Linus wanted the fsverity information to be injected at the VFS so
it's the same for everyone, and that implies that the fsverity
information needs to be treated as a data stream rather than a file
in some filesystem. People have suggested an ADS (alternate data
stream) for this, but that's crazy talk. All we need is a file/fd
flag to say we are "writing fsverity information" so the kernel does
the right thing. e.g.

	vfd = openat(AT_FDCWD, filename, O_APPEND|O_WRONLY);
	flags = fcntl(vfd, F_GETFL, NULL);
	fcntl(vfd, F_SETFL, flags | O_FSVERITY);
	while (....) {
		write(vfd, buf, len);
	}

IOWs, we can communicate to the kernel that this data stream is
special "fs verity" metadata, hence allowing the data that to be
written to where-ever the filesystem stores the merkel tree.
Permissions will be required to set this flag.

(Discussion point: maybe should be a FD_ flag that forces FD_CLOEXEC
so that child processes can't write fsverity information)

>From the tagged data stream,  we can implement filesystem indepedent
storage for the merkel tree data - it doesn't have be be written by
the filesystem at all. e.g.  the VFS could cut the incoming buffer
up into fsverity headers and 64kB data chunks and store them in
separate named xattrs. The filesystem would be none-the-wiser that
there is even fsverity data on the file - it would just work on all
filesystems. You don't even need flags in the inode to tell the fs
that it is protected by fsverity - the presence of the fsverity
xattrs is sufficient to determine that.

(Discussion point: use separate iovecs for fsverity headers and
opaque data chunks w/ pwritev2(RWF_FSVERITY|RWF_APPEND) as a defined
user/kernel fsverity format instead of just write calls which the
kernel then interprets)

This is largely impossible with the "store the merkel tree data in a
file, then use a special ioctl to swizzle it into place" API because
the filesystem has to know the on-disk format of the fsverity
information to be able to break it up sanely into xattrs or some
other internal storage type. The filesystem also needs on disk
format changes to support non-xattr format fsverity storage, while a
"VFS layer translates to xattrs" approach can be done without
needing any changes to any filesystem. It also makes the fsverity
functionality available to network filesystems as well...

IOWs, it seems to me that the API should be based around writing
fsverity data into the kernel as a defined data stream, not an API
that does "something" with opaque data in a file from
"somewhere" and assumes the filesystem will handle it all....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
