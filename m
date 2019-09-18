Return-Path: <SRS0=y2Dn=XN=dilger.ca=adilger@kernel.org>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <0EE70FDE-E6F8-4B5C-87CA-5ADC445B6848@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_F8CF1AF7-DBCB-44DD-BDB2-343F86BCEA54";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v5] e2fsck: check for consistent encryption policies
Date: Wed, 18 Sep 2019 17:06:43 -0600
In-Reply-To: <20190918010734.253049-1-ebiggers@kernel.org>
References: <20190918010734.253049-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_F8CF1AF7-DBCB-44DD-BDB2-343F86BCEA54
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On Sep 17, 2019, at 7:07 PM, Eric Biggers <ebiggers@kernel.org> wrote:
> 
> From: Eric Biggers <ebiggers@google.com>
> 
> By design, the kernel enforces that all files in an encrypted directory
> use the same encryption policy as the directory.  It's not possible to
> violate this constraint using syscalls.  Lookups of files that violate
> this constraint also fail, in case the disk was manipulated.
> 
> But this constraint can also be violated by accidental filesystem
> corruption.  E.g., a power cut when using ext4 without a journal might
> leave new files without the encryption bit and/or xattr.  Thus, it's
> important that e2fsck correct this condition.
> 
> Therefore, this patch makes the following changes to e2fsck:
> 
> - During pass 1 (inode table scan), create a map from inode number to
>  encryption policy for all encrypted inodes.  But it's optimized so
>  that the full xattrs aren't saved but rather only 32-bit "policy IDs",
>  since usually many inodes share the same encryption policy.  Also, if
>  an encryption xattr is missing, offer to clear the encrypt flag.  If
>  an encryption xattr is clearly corrupt, offer to clear the inode.
> 
> - During pass 2 (directory structure check), use the map to verify that
>  all regular files, directories, and symlinks in encrypted directories
>  use the directory's encryption policy.  Offer to clear any directory
>  entries for which this isn't the case.
> 
> Add a new test "f_bad_encryption" to test the new behavior.
> 
> Due to the new checks, it was also necessary to update the existing test
> "f_short_encrypted_dirent" to add an encryption xattr to the test file,
> since it was missing one before, which is now considered invalid.
> 
> Google-Bug-Id: 135138675
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Andreas Dilger <adilger@dilger.ca>


Cheers, Andreas






--Apple-Mail=_F8CF1AF7-DBCB-44DD-BDB2-343F86BCEA54
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAl2CuIMACgkQcqXauRfM
H+ArzhAAgvcV7rVD1sDS91a03F9/kjhtbG5hEHON8S296qTI7r1J4inIyUyG5ieC
nE4ws/rILNb4U/KiyWGC7kMngQ2/QF288BwKs+feJK5qTGolPyhIcf1kd4VgjM8b
6fnxgOfmj5+rhwE4s4VBsGQjB+N5AZfPTh2UubpZ61Auj8litpRxajc3Ml4DapPf
khsm99Dm6VxFJsWXW5IRTBOoPPPa6nR9kaTTvmWET34Pdf9znI52pA0oh0oBsTBx
0igOnjMNHQYWTJSXHDEuaTD6lIQzryiWhl0HNUDgd90YHlIV5Fh50l4L5sZEJZnV
PBPvgOqEvwcdL+9j61LOCn3rFB9Qy3uF4MYprle8V+q2dzKrOuYsFlCfNF3dmumZ
bVzG10MxM6BjlS4RL28LNrQX3+qSAVXssFXKYALovIQiBAH39oBTkBR1AbTzuJI4
f+5PkWYbp/LAnY5r1yJ4iGnTI0o60QJb76v6zWWGQNA//pi9Mw4iO7ZzzGpJkqgU
sY2RrRToAmFyCB7D0PBijgbSX8ACgYKHCRsGPhZUX27ur9PKbuOdI01LOQBDWCr4
nmSLTQthqR8N8Q1PC0p3vQYmt1pAppENY+VGc5OofHH63nnmYwU4PLHFOGnoDK3J
44xamn9rjyOwSFl5III2InXcqqFONl9BXS1XnRXF8hiQPpii3Sg=
=zUIG
-----END PGP SIGNATURE-----

--Apple-Mail=_F8CF1AF7-DBCB-44DD-BDB2-343F86BCEA54--
