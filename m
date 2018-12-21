Return-Path: <SRS0=zyzT=O6=infradead.org=willy@kernel.org>
Date: Fri, 21 Dec 2018 08:11:50 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181221161150.GD10600@bombadil.infradead.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101225230.88058-2-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Nov 01, 2018 at 03:52:19PM -0700, Eric Biggers wrote:
> +In the recommended configuration of SHA-256 and 4K blocks, 128 hash
> +values fit in each block.  Thus, each level of the hash tree is 128
> +times smaller than the previous, and for large files the Merkle tree's
> +size converges to approximately 1/129 of the original file size.

I think you mean 1/127, not 1/129.

> +fsveritysetup format
> +--------------------
> +
> +When enabling fs-verity on a file via the `FS_IOC_ENABLE_VERITY`_
> +ioctl, the kernel requires that the verity metadata has been appended
> +to the file contents.  Specifically, the file must be arranged as:
> +
> +#. Original file contents
> +#. Zero-padding to next block boundary
> +#. `Merkle tree`_
> +#. `fs-verity descriptor`_
> +#. fs-verity footer
> +
> +We call this file format the "fsveritysetup format".  It is not
> +necessarily the on-disk format actually used by the filesystem, since
> +the filesystem is free to move things around during the ioctl.
> +However, the easiest way to implement fs-verity is to just keep this
> +arrangement in-place, as ext4 and f2fs do; see `Filesystem support`_.
> +
> +Note that "block" here means the fs-verity block size, which is not
> +necessarily the same as the filesystem's block size.  For example, on
> +ext4, fs-verity can use 4K blocks on top of a filesystem formatted to
> +use a 1K block size.
> +
> +The fs-verity footer is a structure of the following format::
> +
> +    struct fsverity_footer {
> +            __le32 desc_reverse_offset;
> +            __u8 magic[8];
> +    };
> +
> +``desc_reverse_offset`` is the distance in bytes from the end of the
> +fs-verity footer to the beginning of the fs-verity descriptor; this
> +allows software to find the fs-verity descriptor.  ``magic`` is the
> +ASCII bytes "FSVerity"; this allows software to quickly identify a
> +file as being in the "fsveritysetup" format as well as find the
> +fs-verity footer if zeroes have been appended.
> +
> +The kernel cannot handle fs-verity footers that cross a page boundary.
> +Padding must be prepended as needed to meet this constaint.

I think this ioctl is the start of the disagreement.  How about this
strawman:

verity_fd = ioctl(fd, FS_IOC_VERITY_FD);
write(verity_fd, &merkle_tree);
close(verity_fd);

At final close of that verity_fd, the filesystem behaves in the same way
that it does on receipt of this FS_IOC_ENABLE_VERITY ioctl today.

> +FS_IOC_MEASURE_VERITY
> +---------------------
> +
> +The FS_IOC_MEASURE_VERITY ioctl retrieves the fs-verity measurement of
> +a regular file.  This is a digest that cryptographically summarizes
> +the file contents that are being enforced on reads.  The file must
> +have fs-verity enabled.
> +
> +This ioctl takes in a pointer to a variable-length structure::
> +
> +    struct fsverity_digest {
> +            __u16 digest_algorithm;
> +            __u16 digest_size; /* input/output */
> +            __u8 digest[];
> +    };
> +
> +``digest_size`` is an input/output field.  On input, it must be
> +initialized to the number of bytes allocated for the variable-length
> +``digest`` field.
> +
> +On success, 0 is returned and the kernel fills in the structure as
> +follows:
> +
> +- ``digest_algorithm`` will be the hash algorithm used for the file
> +  measurement.  It will match the algorithm used in the Merkle tree,
> +  e.g. FS_VERITY_ALG_SHA256.  See ``include/uapi/linux/fsverity.h``
> +  for the list of possible values.
> +- ``digest_size`` will be the size of the digest in bytes, e.g. 32
> +  for SHA-256.  (This can be redundant with ``digest_algorithm``.)
> +- ``digest`` will be the actual bytes of the digest.
> +
> +This ioctl is guaranteed to be very fast.  Due to fs-verity's use of a
> +Merkle tree, its running time is independent of the file size.
> +
> +This ioctl can fail with the following errors:
> +
> +- ``EFAULT``: invalid buffer was specified
> +- ``ENODATA``: the file is not a verity file
> +- ``ENOTTY``: this type of filesystem does not implement fs-verity
> +- ``EOPNOTSUPP``: the kernel was not configured with fs-verity support
> +  for this filesystem, or the filesystem superblock has not had the
> +  'verity' feature enabled on it.  (See `Filesystem support`_.)
> +- ``EOVERFLOW``: the file measurement is longer than the specified
> +  ``digest_size`` bytes.  Try providing a larger buffer.

Should this ioctl be better implemented as an xattr?

> +- Direct I/O is not supported on verity files.  Attempts to use direct
> +  I/O on such files will fall back to buffered I/O.

That makes sense; the filesystem can't verify the data before presenting
it to userspace if it's being copied directly into userspace.

> +- DAX (Direct Access) is not supported on verity files.

That makes less sense.  The kernel can check the checksum before
copying the data to the user.  Is this simply a current limitation of
the implementation?

> +Thus, when ascending the tree reading hash pages, fs-verity can stop
> +as soon as it finds an already-checked hash page.  This optimization,
> +which is also used by dm-verity, results in excellent sequential read
> +performance since usually the deepest needed hash page will already be
> +cached and checked.  However, random reads perform worse.

I think you mean "all but the deepest"?
