Return-Path: <SRS0=9x7r=LI=vger.kernel.org=linux-integrity-owner@kernel.org>
Date: Fri, 24 Aug 2018 21:48:53 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 01/10] fs-verity: add setup code, UAPI, and Kconfig
Message-ID: <20180825044852.GB726@sol.localdomain>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-2-ebiggers@kernel.org>
 <1535132549.2855027.1485213752.129E3334@webmail.messagingengine.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535132549.2855027.1485213752.129E3334@webmail.messagingengine.com>
Sender: linux-integrity-owner@vger.kernel.org
To: Colin Walters <walters@verbum.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Colin,

On Fri, Aug 24, 2018 at 01:42:29PM -0400, Colin Walters wrote:
> 
> On Fri, Aug 24, 2018, at 12:16 PM, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > fs-verity is a filesystem feature that provides efficient, transparent
> > integrity verification and authentication of read-only files.  It uses a
> > dm-verity like mechanism at the file level: a Merkle tree hidden past
> > the end of the file is used to verify any block in the file in
> > log(filesize) time.  It is implemented mainly by helper functions in
> > fs/verity/ that will be shared by multiple filesystems.
> > 
> > Essentially, fs-verity reports a file's hash in constant time, but reads
> > that would violate that hash fail at runtime.  This is useful when only
> > a portion of the file is actually accessed, as only the accessed portion
> > has to be hashed, and the latency to the first read is much reduced over
> > a full file hash.  On top of this hashing mechanism, auditing or
> > authentication policies can be implemented to log or verify file hashes.
> > 
> > Note that in general, fs-verity is *not* a replacement for IMA.
> > fs-verity is a lower-level feature, primarily a way to hash a file;
> > whereas IMA deals more with higher-level policy logic, like defining
> > which files are "measured" and what to do with those measurements.  We
> > plan for IMA to support fs-verity measurements as an alternative to the
> > traditional full file hash.  Still, some users find fs-verity useful by
> > itself, so it's also usable without IMA in simple cases, e.g. in cases
> > where just retrieving the file measurement via an ioctl is enough.
> > 
> > A structure containing the properties of the Merkle tree -- such as the
> > hash algorithm used, the block size, and the root hash -- is also stored
> > on-disk, following the Merkle tree.  The actual file measurement hash
> > that fs-verity reports is the hash of this structure.
> > 
> > All fs-verity metadata is written by userspace; the kernel only reads
> > it.  Extended attributes aren't used because the Merkle tree may be much
> > larger than XATTR_SIZE_MAX, we want the hash pages to be cached in the
> > page cache as usual, and in the case of fs-verity combined with fscrypt
> > we want the metadata to be encrypted to avoid leaking plaintext hashes.
> > The fs-verity metadata is hidden from userspace by overriding the i_size
> > of the in-memory VFS inode; ext4 additionally will override the on-disk
> > i_size in order to make verity a RO_COMPAT filesystem feature.
> > 
> > This initial patch only adds the fs-verity Kconfig option, UAPI, and
> > setup code, e.g. the ->open() hook that parses the fs-verity descriptor.
> 
> This first patch also adds a bit of core logic in the
> simple fsverity_prepare_setattr() which ends up being called
> by ext4 later.
> 
> While I'm not too familiar with the vfs, as far as I can
> tell  from inspection of Linus' git master is that pretty much any change (timestamp, hardlinks) ends up
> calling notify_change() which calls the fs-specific one, and in
> the verity case basically denies everything, right?
> 
> Previously I brought up many uses for "content immutable" files:
> https://marc.info/?l=linux-fsdevel&m=151698481512084&w=2
> 
> The discussion sort of died out but...did you have any opinion
> on e.g. my proposal to use the Unix mode bits as a way to describe
> levels of mutablility?
> 
> Let's say that your new _VERITY inode flag becomes "_WRITEPROT"
> or something a bit more generic.
> 
> Do you have any thoughts on my proposal to reuse the Unix mode
> bits to control levels of inode mutability?
> 
> For example, it seems to me we could define u+w as "hardlinks are OK".
> There shouldn't be any reason ext4/f2fs couldn't hardlink a verity-protected
> inode right?  Or if for some reason that is hard, we could disallow that to
> start, but at least have the core VFS support _WRITEPROT inodes?
> 

As Ted pointed out, only truncates are denied on fs-verity files, not other
metadata changes like chmod().

Think of it this way: the purpose of fs-verity is *not* to make files immutable.
It's to hash them.  We can't allow people to change the thing being hashed,
since that would invalidate the hash.  So while fs-verity does make the file
contents immutable, it's actually a requirement for it being hashed (measured),
rather than the end goal.  There's no reason from fs-verity's perspective to
make anything else immutable.

That being said, in the future, we could allow declaring file metadata like the
Unix mode bits in the authenticated portion of the fs-verity descriptor, so they
would be included in the file hash.  fs-verity would then need to enforce that
the declared mode matches the actual one and that the actual one cannot be
changed.  Extended attributes could be included in the hash in the same way.

But that's out of scope for now, as so far users only need the file contents to
be hashed.

- Eric
