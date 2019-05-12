Return-Path: <SRS0=6ZyK=TM=gmail.com=guaneryu@kernel.org>
Date: Sun, 12 May 2019 20:21:52 +0800
From: Eryu Guan <guaneryu@gmail.com>
Subject: Re: [RFC PATCH 1/7] common/encrypt: introduce helpers for
 set_encpolicy and get_encpolicy
Message-ID: <20190512122152.GI15846@desktop>
References: <20190426204153.101861-1-ebiggers@kernel.org>
 <20190426204153.101861-2-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426204153.101861-2-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Apr 26, 2019 at 01:41:47PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> For conciseness in tests, add helper functions that wrap the xfs_io
> commands 'set_encpolicy' and 'get_encpolicy'.  Then update all
> encryption tests to use them.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  common/encrypt        | 34 ++++++++++++++++++++++++++++++++--
>  tests/ext4/024        |  3 +--
>  tests/generic/395     | 28 +++++++++++++---------------
>  tests/generic/395.out |  2 +-
>  tests/generic/396     | 15 +++++++--------
>  tests/generic/397     |  3 +--
>  tests/generic/398     |  5 ++---
>  tests/generic/399     |  3 +--
>  tests/generic/419     |  3 +--
>  tests/generic/421     |  3 +--
>  tests/generic/429     |  3 +--
>  tests/generic/435     |  3 +--
>  tests/generic/440     |  5 ++---
>  13 files changed, 64 insertions(+), 46 deletions(-)
> 
> diff --git a/common/encrypt b/common/encrypt
> index 1b10aa71..54d873fa 100644
> --- a/common/encrypt
> +++ b/common/encrypt
> @@ -38,8 +38,7 @@ _require_scratch_encryption()
>  	# presence of /sys/fs/ext4/features/encryption, but this is broken on
>  	# some older kernels and is ext4-specific anyway.)
>  	mkdir $SCRATCH_MNT/tmpdir
> -	if $XFS_IO_PROG -c set_encpolicy $SCRATCH_MNT/tmpdir \
> -		2>&1 >>$seqres.full | \
> +	if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \
>  		egrep -q 'Inappropriate ioctl for device|Operation not supported'
>  	then
>  		_notrun "kernel does not support $FSTYP encryption"
> @@ -175,3 +174,34 @@ _revoke_encryption_key()
>  	local keyid=$($KEYCTL_PROG search @s logon $FSTYP:$keydesc)
>  	$KEYCTL_PROG revoke $keyid >>$seqres.full
>  }
> +
> +# Set an encryption policy on the specified directory.
> +_set_encpolicy()
> +{
> +	local dir=$1
> +	shift
> +
> +	$XFS_IO_PROG -c "set_encpolicy $*" "$dir"
> +}
> +
> +_user_do_set_encpolicy()
> +{
> +	local dir=$1
> +	shift
> +
> +	_user_do "$XFS_IO_PROG -c \"set_encpolicy $*\" \"$dir\""
> +}
> +
> +_require_get_encpolicy()
> +{
> +	_require_xfs_io_command "get_encpolicy"
> +}

This doesn't seem necessary to me, just calling

_require_xfs_io_command "get_encpolicy"

explicitly is fine to me.

Thanks,
Eryu
