Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795280705;
	b=DVcrmgOSgueEa4s6GsXl08gBDI3PHye+Ib3uV0LPjx2rDAxkBr78aAzlIiZfh/VqpPEN
	 4dE3Ww8JJBHFhlMjHZQK2AX9QVFS8CxNFlCsjxDNxiWmaEHYc/akXsRr0XxdPgiXZpxK9
	 VJgkJq9uoSxKvK0bXgRYF4t5NW3WvAC4UCMHzrT5HSaOZJdDrow3DdlILAUkRFsPTVFyQ
	 VBA50/Hbw5MQjCzWeGThRI/JemtaIdn2O+AQioRWldM5CZHH37VzI6OJNLbOvLl3nzJ7Y
	 fBeItPFwDdg3rj/rx1y9ZcmygFyqAcw4UsysiRLCZlxsaxd6rg2fg/TDZfGhRISHrXQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795280705;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 Mail-Followup-To:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=UNb0wSOh+ggizWXdLZ8B0dcP+pg0Eb6nL8do3bvWSZ4=;
	b=a4Qq3446B6wAWYXxYqrm8dzHjNSQ7pvPRy5WEXn9zEeCtZkT4kvk+CI63VEigWHbMuNW
	 nMPDtZvkPdfSBCqiIjLkCF947dAcN+IL1Hvn09/yn6iR7AyM+X5zhY21R5fj77XApDD7m
	 TRCR7n4iwwcrtCzkhZfCue9qSli3XAme5MZuIghrEaOFe9f3iJV/sXMC3MNWzlXkrGfVE
	 jpHjVA9wfcWyWM1Z5BReHoNNykOxKbNoL5MumfY/wzyW2/ZP+udO+QE8MG5sCY6yRG1u0
	 qS8W8yc91+uYdOEn5NTQ6d0EQr0FGssz26Y41qthBc+jUaHDB9d6PCLgbp92Awm/p3w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QrkluMnX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A78C6606A320;
	Sat, 21 Nov 2026 17:05:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QrkluMnX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 52EA81F000C0;
	Sat, 21 Nov 2026 17:04:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795280705;
	bh=UNb0wSOh+ggizWXdLZ8B0dcP+pg0Eb6nL8do3bvWSZ4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=QrkluMnXo6/JIkDevuGtgZBjhz23uAKGN6eyuBu6mFD36gyV/nOyt5Ve9OPZHZM4r
	 M8L9LySmgrMCPIvXMj1sFG6o0lLC6LvOYPGSmUIfVHdoP88lDV20upPO4RHrTRXu6R
	 090gTV7TW6aBu4EVcf2+VB9IgDa8vAwP4ZXtWPvruawUwMr8HJzE/EAcagUuF4ehDa
	 ZUBrayEzna9+mXmNdik23nqthY/z1oyfPLrQdliZWFkraxBobiCQA80WPd1Q2Vi6pN
	 mFEWT06uU/rkufWwGXTsmQPFEfguYlcetLZJLpveWLQC/Yqnhj5U5+d9vJxhJqp31C
	 iDUx/BZX5EIEQ==
Date: Sun, 22 Nov 2026 01:04:48 +0800
From: Zorro Lang <zlang@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	ebiggers@kernel.org, jaegeuk@kernel.org, tytso@mit.edu, linux-ext4@vger.kernel.org, 
	adilger.kernel@dilger.ca, jack@suse.cz, yi.zhang@huawei.com, ojaswin@linux.ibm.com, 
	ritesh.list@gmail.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] common/encrypt: support block sizes larger than the page
 size
Message-ID: <awHJso_ELIgRjbdg@zlang-mailbox>
Mail-Followup-To: Baokun Li <libaokun@linux.alibaba.com>, 
	fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, ebiggers@kernel.org, 
	jaegeuk@kernel.org, tytso@mit.edu, linux-ext4@vger.kernel.org, 
	adilger.kernel@dilger.ca, jack@suse.cz, yi.zhang@huawei.com, ojaswin@linux.ibm.com, 
	ritesh.list@gmail.com, linux-kernel@vger.kernel.org
References: <20261103160906.188544-1-libaokun@linux.alibaba.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261103160906.188544-1-libaokun@linux.alibaba.com>

On Wed, Nov 04, 2026 at 12:09:06AM +0800, Baokun Li wrote:
> v1 encryption policies use the filesystem block size as their data unit
> size, so they cannot be used on a filesystem whose block size exceeds
> the page size.  Make _require_scratch_encryption() skip such tests
> when a v1 policy is requested.  Tests that request a v2 policy but
> also exercise v1 policies, i.e. generic/580, 581, 593, and 613,
> call _require_v1_encryption_support() explicitly.
> 
> A v2 policy with log2_data_unit_size 0 uses min(bs, PS) as its data
> unit size, not the block size. Add _get_encryption_du_size() and
> use it to calculate the expected ciphertext.
> 
> Also skip the v1 policy probe in _require_scratch_encryption() when a
> v2 policy is requested.  Update the ext4/309 and ext4/310 comments for
> the new default data unit size.
> 
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
> ---
>  common/encrypt    | 68 +++++++++++++++++++++++++++++++++++++++--------
>  tests/ext4/309    |  6 ++---
>  tests/ext4/310    |  2 +-
>  tests/generic/580 |  1 +
>  tests/generic/581 |  1 +
>  tests/generic/593 |  1 +
>  tests/generic/613 |  1 +
>  7 files changed, 65 insertions(+), 15 deletions(-)
> 
> diff --git a/common/encrypt b/common/encrypt
> index c9e0853d8d8c..feaef0682a44 100644
> --- a/common/encrypt
> +++ b/common/encrypt
> @@ -18,15 +18,21 @@
>  _require_scratch_encryption()
>  {
>  	local arg
> +	local policy_version=1
> +	local prev=
>  
>  	_require_scratch
>  	_require_xfs_io_command "set_encpolicy"
>  
>  	for arg; do
> +		if [ "$prev" = "-v" ]; then
> +			policy_version=$arg
> +		fi
>  		if [ "$arg" = "-s" ]; then
>  			# -s option was added later.  Make sure it's available.
>  			_require_xfs_io_command "set_encpolicy" "-s"
>  		fi
> +		prev=$arg
>  	done
>  
>  	# The 'test_dummy_encryption' mount option interferes with trying to use
> @@ -56,13 +62,24 @@ _require_scratch_encryption()
>  	# to set an encryption policy.  (For ext4 we could instead check for the
>  	# presence of /sys/fs/ext4/features/encryption, but this is broken on
>  	# some older kernels and is ext4-specific anyway.)
> -	mkdir $SCRATCH_MNT/tmpdir
> -	if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \
> -		grep -Eq 'Inappropriate ioctl for device|Operation not supported'
> -	then
> -		_notrun "kernel does not support $FSTYP encryption"
> +	#
> +	# If the test requires a v2 policy, don't probe with a v1 policy:
> +	# v1 policies are not supported when the block size exceeds the page
> +	# size.  _require_encryption_policy_support() will check for the
> +	# requested policy version below.
> +	if [ "$policy_version" -le 1 ]; then
> +		mkdir $SCRATCH_MNT/tmpdir
> +		if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \
> +			grep -Eq 'Inappropriate ioctl for device|Operation not supported'
> +		then
> +			_notrun "kernel does not support $FSTYP encryption"
> +		fi
> +		rmdir $SCRATCH_MNT/tmpdir
> +
> +		# v1 policies use the block size as their data unit size,
> +		# which doesn't work if the block size exceeds the page size.
> +		_require_v1_encryption_support

How about do _require_v1_encryption_support at first:

  if [ "$policy_version" -le 1 ]; then
      _require_v1_encryption_support
      mkdir $SCRATCH_MNT/tmpdir
      if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \

In that case, if block_size > page_size, we can directly skip the test
with an explicit reason, avoids a redundant mkdir/rmdir and ioctl call.

>  	fi
> -	rmdir $SCRATCH_MNT/tmpdir
>  
>  	# If required, check for support for the specific type of encryption
>  	# policy required by the test.
> @@ -73,6 +90,39 @@ _require_scratch_encryption()
>  	_scratch_unmount
>  }
>  
> +# Require that the filesystem supports v1 encryption policies.  v1
> +# policies use the filesystem block size as their data unit size, so
> +# they aren't supported when the block size exceeds the page size.
> +#
> +# The scratch filesystem must be mounted.
> +_require_v1_encryption_support()
> +{
> +	local block_size=$(_get_block_size $SCRATCH_MNT)
> +
> +	if [ "$block_size" -gt "$(_get_page_size)" ]; then
> +		_notrun "v1 encryption policies aren't supported on filesystems with block size > page size"
> +	fi
> +}
> +
> +# Get the data unit size in bytes for a v2 encryption policy with the
> +# given log2_data_unit_size on the filesystem mounted at $1.  A zero
> +# value selects min(filesystem block size, page size).
> +_get_encryption_du_size()
> +{
> +	local mnt=$1
> +	local log2_dusize=$2
> +	local block_size=$(_get_block_size "$mnt")
> +	local page_size=$(_get_page_size)
> +
> +	if [ "$log2_dusize" -ne 0 ]; then
> +		echo $((1 << log2_dusize))
> +	elif [ "$block_size" -gt "$page_size" ]; then
> +		echo "$page_size"
> +	else
> +		echo "$block_size"
> +	fi
> +}
> +
>  _require_encryption_policy_support()
>  {
>  	local mnt=$1
> @@ -1014,11 +1064,7 @@ _verify_ciphertext_for_encryption_policy()
>  	fi
>  	_scratch_mount
>  
> -	if (( log2_dusize != 0 )); then
> -		crypt_util_contents_args+=" --data-unit-size=$((1 << log2_dusize))"
> -	else
> -		crypt_util_contents_args+=" --data-unit-size=$(_get_block_size $SCRATCH_MNT)"
> -	fi
> +	crypt_util_contents_args+=" --data-unit-size=$(_get_encryption_du_size $SCRATCH_MNT $log2_dusize)"
>  
>  	crypt_util_args+=" --fs-uuid=$(blkid -s UUID -o value $SCRATCH_DEV | tr -d -)"
>  
> diff --git a/tests/ext4/309 b/tests/ext4/309
> index 6bc9b8cb4a4a..aa1b3b68fc8c 100755
> --- a/tests/ext4/309
> +++ b/tests/ext4/309
> @@ -5,9 +5,9 @@
>  # FS QA Test No. ext4/309
>  #
>  # Verify that file contents encryption works on a filesystem with a block size
> -# larger than the page size.  fscrypt uses the block size as the data unit size
> -# by default, so this tests data units that span multiple pages, both for the
> -# writeback path and for the on-disk ciphertext.
> +# larger than the page size.  fscrypt uses min(block size, page size) as the
> +# default data unit size, so this tests 4K data units on a 32K-block

Does ext4/309 hardcode 32k ?

> +# filesystem, both for the writeback path and for the on-disk ciphertext.
>  #
>  . ./common/preamble
>  _begin_fstest auto quick encrypt
> diff --git a/tests/ext4/310 b/tests/ext4/310
> index 215d3a83cd6d..84473930f8cb 100755
> --- a/tests/ext4/310
> +++ b/tests/ext4/310
> @@ -6,7 +6,7 @@
>  #
>  # Test reading and writing an encrypted file with O_DIRECT on a filesystem
>  # with a block size larger than the page size.  The data unit size is the
> -# block size by default, so each data unit spans several pages here.
> +# page size by default on such a filesystem.
>  #
>  . ./common/preamble
>  _begin_fstest auto quick encrypt
> diff --git a/tests/generic/580 b/tests/generic/580
> index eff3f2104bfe..bcb984d1fd82 100755
> --- a/tests/generic/580
> +++ b/tests/generic/580
> @@ -20,6 +20,7 @@ _require_scratch_encryption -v 2
>  
>  _scratch_mkfs_encrypted &>> $seqres.full
>  _scratch_mount
> +_require_v1_encryption_support
>  
>  test_with_policy_version()
>  {
> diff --git a/tests/generic/581 b/tests/generic/581
> index 2773c9108b35..54f31595a832 100755
> --- a/tests/generic/581
> +++ b/tests/generic/581
> @@ -33,6 +33,7 @@ _require_scratch_encryption -v 2
>  
>  _scratch_mkfs_encrypted &>> $seqres.full
>  _scratch_mount
> +_require_v1_encryption_support
>  
>  dir=$SCRATCH_MNT/dir
>  
> diff --git a/tests/generic/593 b/tests/generic/593
> index 05f868f92422..61976df8194d 100755
> --- a/tests/generic/593
> +++ b/tests/generic/593
> @@ -21,6 +21,7 @@ _require_command "$KEYCTL_PROG" keyctl
>  _init_session_keyring
>  _scratch_mkfs_encrypted &>> $seqres.full
>  _scratch_mount
> +_require_v1_encryption_support
>  _require_add_enckey_by_key_id $SCRATCH_MNT
>  
>  test_with_policy_version()
> diff --git a/tests/generic/613 b/tests/generic/613
> index 499af18ef476..aadb3893e73e 100755
> --- a/tests/generic/613
> +++ b/tests/generic/613
> @@ -26,6 +26,7 @@ _require_command "$XZ_PROG" xz
>  
>  _scratch_mkfs_encrypted &>> $seqres.full
>  _scratch_mount
> +_require_v1_encryption_support
>  
>  echo -e "\n# Adding encryption keys"
>  _add_enckey $SCRATCH_MNT "$TEST_RAW_KEY"
> -- 
> 2.43.7
> 
