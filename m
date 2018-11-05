Return-Path: <SRS0=lu1b=NQ=dilger.ca=adilger@kernel.org>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <F1AB58DE-E8D8-449C-B07C-4868B181F5E9@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_F0C1406D-50AB-4BE0-B275-698A345B0C1F";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2 10/12] ext4: add basic fs-verity support
Date: Mon, 5 Nov 2018 14:05:24 -0700
In-Reply-To: <20181101225230.88058-11-ebiggers@kernel.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-11-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_F0C1406D-50AB-4BE0-B275-698A345B0C1F
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On Nov 1, 2018, at 4:52 PM, Eric Biggers <ebiggers@kernel.org> wrote:
> 
> From: Eric Biggers <ebiggers@google.com>
> 
> Add basic fs-verity support to ext4.  fs-verity is a filesystem feature
> that enables transparent integrity protection and authentication of
> read-only files.  It uses a dm-verity like mechanism at the file level:
> a Merkle tree is used to verify any block in the file in log(filesize)
> time.  It is implemented mainly by helper functions in fs/verity/.
> See Documentation/filesystems/fsverity.rst for details.
> 
> This patch adds everything except the data verification hooks that will
> needed in ->readpages().
> 
> On ext4, enabling fs-verity on a file requires that the filesystem has
> the 'verity' feature, e.g. that it was formatted with
> 'mkfs.ext4 -O verity' or had 'tune2fs -O verity' run on it.
> This requires e2fsprogs 1.44.4-2 or later.
> 
> In ext4, we choose to retain the fs-verity metadata past the end of the
> file rather than trying to move it into an external inode xattr, since
> in practice keeping the metadata in-line actually results in the
> simplest and most efficient implementation.  One non-obvious advantage
> of keeping the verity metadata in-line is that when fs-verity is
> combined with fscrypt, the verity metadata naturally gets encrypted too;
> this is actually necessary because it contains hashes of the plaintext.

On the plus side, this means that the verity data will automatically be
invalidated if the file is truncated or extended, but on the negative side
it means that the verity Merkle tree needs to be recalculated for the
entire file if e.g. the file is appended to.

I guess the current implementation will generate the Merkle tree in
userspace, but at some point it might be useful to generate it on-the-fly
to have proper data integrity from the time of write (e.g. like ZFS)
rather than only allowing it to be stored after the entire file is written?

Storing the Merkle tree in a large xattr inode would allow this to change
in the future rather than being stuck with the current implementation.  We
could encrypt the xattr data just as easily as the file data (which should
be done anyway even for non-verity files to avoid leaking data), and having
the verity attr keyed to the inode version/size/mime(?) would ensure the
kernel knows it is stale if the inode is modified.

I'm not going to stand on my head and block this implementation, I just
thought it is worthwhile to raise these issues now rather than after it
is a fait accompli.

> We also choose to keep the on-disk i_size equal to the original file
> size, in order to make the 'verity' feature a RO_COMPAT feature.  Thus,
> ext4 has to find the fsverity_footer by looking in the last extent.


Cheers, Andreas






--Apple-Mail=_F0C1406D-50AB-4BE0-B275-698A345B0C1F
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAlvgsJUACgkQcqXauRfM
H+CsRRAAuh1XSvfDwsO1atgPaFlL0Q7PcY1+CYff3nkv3uRh9ipcCTihtLAhGOVf
BLqR6uikUyIJefr4j0iFYOI8bI/StscPRXIUR6iYwIzqiErTlnvb0ClQ1VMS5tyu
y+LpKLpkXeTnZHAv5HWgviAM0IotgdpwrEjkuStGj5AHIsMr2Cmh045PXBqmv6yt
uuUmZTmmsHGN8FzaHy75APglMH4axBhgCburXs1Bj9eK54uppuhSIUnS5GKzJhA1
OLlBExpkqCrMmlYgDtOUFfWtJfzTG5HMsMHIR/90I6ahxMw2Qcudud16gthMAuKv
ZSqjOz9hBRTfLICoY4ZN2BhUUhujU5FvGGLLAg23U11BtusfcKerFUql4pZTXgaN
HQpfQy5ST7reXn2xuhkxH0amPoebf9+f6vY0TCKv8w0RpZS6qOHkzbMocuvpuW42
V7i8s+Cd9SH9DGsfGce75MGy2YZu0R/iHbY1BhYZeRRQUEqubLoH/xQREltNjAp3
g7l12NF47h5glm73urKdfIiOq+zNSX8XgiVceuIX5ij4T6z8VcpyJv8lASfpcH+d
z8Tjt3aI+h4vZaCpHteZ9FOuarSoULSbIMRzEaYV2oX3zbM6JCOlb/A9cVKf/522
KsoOjOofDsPNfMRUNo+/egSKVsg1CySgsuUkaF2v1I4QoFXYO4Q=
=XiFo
-----END PGP SIGNATURE-----

--Apple-Mail=_F0C1406D-50AB-4BE0-B275-698A345B0C1F--
