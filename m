Return-Path: <SRS0=rcnV=XC=dilger.ca=adilger@kernel.org>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <28D1848F-B84A-4D2A-880E-F0C8E8FD36C7@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_669BFA70-DBB2-44E5-8B6B-34CCC80FEE88";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v3] e2fsck: check for consistent encryption policies
Date: Fri, 6 Sep 2019 22:23:03 -0600
In-Reply-To: <20190904155524.GA41757@gmail.com>
References: <20190823162339.186643-1-ebiggers@kernel.org>
 <20190904155524.GA41757@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_669BFA70-DBB2-44E5-8B6B-34CCC80FEE88
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii


On Sep 4, 2019, at 9:55 AM, Eric Biggers <ebiggers@kernel.org> wrote:
> On Fri, Aug 23, 2019 at 09:23:39AM -0700, Eric Biggers wrote:
>> From: Eric Biggers <ebiggers@google.com>
>> 
>> By design, the kernel enforces that all files in an encrypted directory
>> use the same encryption policy as the directory.  It's not possible to
>> violate this constraint using syscalls.  Lookups of files that violate
>> this constraint also fail, in case the disk was manipulated.
>> 
>> But this constraint can also be violated by accidental filesystem
>> corruption.  E.g., a power cut when using ext4 without a journal might
>> leave new files without the encryption bit and/or xattr.  Thus, it's
>> important that e2fsck correct this condition.
>> 
>> Therefore, this patch makes the following changes to e2fsck:
>> 
>> - During pass 1 (inode table scan), create a map from inode number to
>>  encryption policy for all encrypted inodes.  But it's optimized so
>>  that the full xattrs aren't saved but rather only 32-bit "policy IDs",
>>  since usually many inodes share the same encryption policy.  Also, if
>>  an encryption xattr is missing, offer to clear the encrypt flag.  If
>>  an encryption xattr is clearly corrupt, offer to clear the inode.
>> 
>> - During pass 2 (directory structure check), use the map to verify that
>>  all regular files, directories, and symlinks in encrypted directories
>>  use the directory's encryption policy.  Offer to clear any directory
>>  entries for which this isn't the case.
>> 
>> Add a new test "f_bad_encryption" to test the new behavior.
>> 
>> Due to the new checks, it was also necessary to update the existing test
>> "f_short_encrypted_dirent" to add an encryption xattr to the test file,
>> since it was missing one before, which is now considered invalid.
>> 
> 
> Any comments on this patch?

I didn't see the original email for this patch, but I found it on patchworks.

One change is needed if the filesystem is very large and has a lot of
encrypted files.  While your typical use case is going to be Android
handsets, on the flip side I'm often dealing with filesystems with a
few billion files in them, and there are definitely users that want
to use the on-disk encryption.

>> +	/* Append the (ino, policy_id) pair to the list. */
>> +	if (info->files_count == info->files_capacity) {
>> +		size_t new_capacity = info->files_capacity * 2;
>> +
>> +		if (new_capacity < 128)
>> +			new_capacity = 128;
>> +
>> +		if (ext2fs_resize_mem(info->files_capacity * sizeof(*file),
>> +				      new_capacity * sizeof(*file),
>> +				      &info->files) != 0)

If the number of files in the array get very large, then doubling the
array size at the end may consume a *lot* of memory.  It would be
somewhat better to cap new_capacity by the number of inodes in the
filesystem, and better yet scale the array size by a fraction of the
total number of inodes that have already been processed, but this array
might still be several GB of RAM.

What about using run-length encoding for this?  It is unlikely that many
different encryption policies are in a filesystem, and inodes tend to be
allocated in groups by users, so it is likely that you will get large runs
of inodes with the same policy_id, and this could save considerable space.

Cheers, Andreas






--Apple-Mail=_669BFA70-DBB2-44E5-8B6B-34CCC80FEE88
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAl1zMKcACgkQcqXauRfM
H+AvgRAAvW6yJVYdn1B6VDSTQMrY+hj04aHnvhr8jYT+Vwzix2msFLQodxEA9dXX
XsfLeUi23LCmCrZMaxLl3lZDGsstTVAm3ECeZk1E833YaR3Gxy8JVuXQ/Pr4aDwj
pbCwh8D3Un5mZnrq9tg2B7LIIsMnjC6+SfAQHfaAPT+FysSbGZYFgnGSVm0A5e9A
1iUfCVs5lu3Meme+R3urwQyzpuhNnPTQ4QC9haIEp9UQzHsZw4Te4aExtFgPQ6db
24wFquL5bdxUW/QV9/BaNo4aZPxZhyuhXjO72uFqQ2R0Uqh/8sSOkpnH5FXAcMdd
+5W7w8JZNqHOmHkRekqqn/TUpOsC+7rtjzp3jPPEveaCbq5ohI3DGfV//hSEztYZ
/wAttTHxfl6IyTltpdJdzuAzfRjP8Mv3itR1/dAYvVqwtwv3CppBHtucb2x1+Z59
fJZt9FpdJaYWYIU3e4QigUYv747mFomTkO2GUq/KT3zHQpfCqxbhwDRYrWUQ2DdU
aLkuizZXEnlUUE53+HqoZfplL7Xw0e0EulflOEJna3HN/9F26zl6IIGtT123r7nM
KnLg85A6NMUXQLQLVv7/lj7ydcvwMzgKCBGRtBIux9nkrSVzOT0SaMLZpLi0JFhc
7xOvLJ4/guk7z+7cs8rJYFDOmxwkepfA5kmCSairJCbb0KbkHOA=
=+I+v
-----END PGP SIGNATURE-----

--Apple-Mail=_669BFA70-DBB2-44E5-8B6B-34CCC80FEE88--
