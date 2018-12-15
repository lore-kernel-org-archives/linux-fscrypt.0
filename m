Return-Path: <SRS0=ekgu=OY=gmail.com=guaneryu@kernel.org>
Date: Sat, 15 Dec 2018 22:38:00 +0800
From: Eryu Guan <guaneryu@gmail.com>
Subject: Re: [PATCH 1/7] common/verity: add common functions for testing
 fs-verity
Message-ID: <20181215143800.GW3889@desktop>
References: <20181210222142.222342-1-ebiggers@kernel.org>
 <20181210222142.222342-2-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210222142.222342-2-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Dec 10, 2018 at 02:21:36PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add common functions for setting up and testing fs-verity, a new feature
> for read-only file-based authenticity protection.  fs-verity will be
> supported by ext4 and f2fs, and perhaps other filesystems later.
> Running the fs-verity tests requires:
> 
> - A kernel with the fs-verity patches from
>   https://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git/log/
>   (should be merged in 4.21) and configured with CONFIG_FS_VERITY.
> - The fsverity utility program, which can be installed from
>   https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/fsverity-utils.git/
> - e2fsprogs v1.44.4-2 or later for ext4 tests, or f2fs-tools v1.11.0 or
>   later for f2fs tests.
> 
> See the file Documentation/filesystem/fsverity.rst in the kernel tree
> for more information about fs-verity.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  common/config |   1 +
>  common/verity | 198 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 199 insertions(+)
>  create mode 100644 common/verity
> 
> diff --git a/common/config b/common/config
> index a87cb4a2..b2160667 100644
> --- a/common/config
> +++ b/common/config
> @@ -194,6 +194,7 @@ export GETCAP_PROG="$(type -P getcap)"
>  export CHECKBASHISMS_PROG="$(type -P checkbashisms)"
>  export XFS_INFO_PROG="$(type -P xfs_info)"
>  export DUPEREMOVE_PROG="$(type -P duperemove)"
> +export FSVERITY_PROG="$(type -P fsverity)"
>  
>  # use 'udevadm settle' or 'udevsettle' to wait for lv to be settled.
>  # newer systems have udevadm command but older systems like RHEL5 don't.
> diff --git a/common/verity b/common/verity
> new file mode 100644
> index 00000000..4da63b69
> --- /dev/null
> +++ b/common/verity
> @@ -0,0 +1,198 @@
> +# SPDX-License-Identifier: GPL-2.0
> +# Copyright 2018 Google LLC
> +#
> +# Functions for setting up and testing fs-verity
> +
> +FSV_BLOCK_SIZE=4096
> +
> +_require_scratch_verity()
> +{
> +	_require_scratch
> +	_require_command "$FSVERITY_PROG" fsverity
> +
> +	if ! _scratch_mkfs_verity &>>$seqres.full; then
> +		# ext4: need e2fsprogs v1.44.4-2 or later
> +		# f2fs: need f2fs-tools v1.11.0 or later
> +		_notrun "$FSTYP userspace tools don't support fs-verity"
> +	fi
> +
> +	# Try to mount the filesystem.  If this fails, then the filesystem is
> +	# unaware of the fs-verity feature.
> +	if ! _try_scratch_mount &>>$seqres.full; then
> +		_notrun "kernel doesn't know about $FSTYP verity feature"
> +	fi
> +	_scratch_unmount
> +
> +	# The filesystem may be aware of fs-verity but have it disabled by
> +	# CONFIG_FS_VERITY=n.  Detect support via sysfs.
> +	if [ ! -e /sys/fs/$FSTYP/features/verity ]; then
> +		_notrun "kernel $FSTYP isn't configured with verity support"
> +	fi
> +
> +	# fs-verity with block_size != PAGE_SIZE isn't implemented yet.
> +	# ("block_size" here refers to the fs-verity block size, not to the
> +	# filesystem's block size.)
> +	if [ "$(getconf PAGE_SIZE)" != $FSV_BLOCK_SIZE ]; then

We could use helper "get_page_size" here.

> +		_notrun "verity not yet supported for PAGE_SIZE != $FSV_BLOCK_SIZE"
> +	fi
> +}
> +
> +_scratch_mkfs_verity()
> +{
> +	case $FSTYP in
> +	ext4|f2fs)
> +		_scratch_mkfs -O verity
> +		;;
> +	*)
> +		_notrun "No verity support for $FSTYP"
> +		;;
> +	esac
> +}
> +
> +_scratch_mkfs_encrypted_verity()
> +{
> +	case $FSTYP in
> +	ext4)
> +		_scratch_mkfs -O encrypt,verity
> +		;;
> +	f2fs)
> +		# f2fs-tools as of v1.11.0 doesn't allow comma-separated
> +		# features with -O.  Instead -O must be supplied multiple times.
> +		_scratch_mkfs -O encrypt -O verity
> +		;;
> +	*)
> +		_notrun "$FSTYP not supported in _scratch_mkfs_encrypted_verity"
> +		;;
> +	esac
> +}
> +
> +_fsv_randstring()
> +{
> +	local nchars=$1
> +
> +	tr -d -C 0-9a-f < /dev/urandom | head -c "$nchars"
> +}

This function has no caller? And if it has a caller, I think it's
generic enough to move it to common/rc and rename it to a more generic
name. But why limits the string to 0-9a-f, if it's expected to generate
random string?

> +
> +_fsv_begin_subtest()
> +{
> +	local msg=$1
> +
> +	rm -rf "${SCRATCH_MNT:?}"/*

It assumes the test is run against $SCRATCH_DEV/$SCRATCH_MNT, it's
better to either rename the function to _fsv_scratch_begin_subtest to
indicate it takes use of $SCRATCH_DEV/MNT or just pass the working dir
as a argument.

> +	echo -e "\n# $msg"
> +}
> +
> +_fsv_setup()
> +{
> +	$FSVERITY_PROG setup "$@" | awk '/^File measurement: /{print $3}'
> +}
> +
> +_fsv_enable()
> +{
> +	$FSVERITY_PROG enable "$@"
> +}
> +
> +_fsv_measure()
> +{
> +        $FSVERITY_PROG measure "$@" | awk '{print $1}'
> +}
> +
> +# Generate a file with verity metadata, but don't actually enable verity yet
> +_fsv_create_setup_file()
> +{
> +	local file=$1
> +
> +	head -c $((FSV_BLOCK_SIZE * 2)) /dev/zero > "$file"
> +	_fsv_setup "$file"
> +}
> +
> +# Generate a file with verity metadata, then enable verity
> +_fsv_create_enable_file()
> +{
> +	local file=$1
> +
> +	_fsv_create_setup_file "$file"
> +	_fsv_enable "$file"
> +}
> +
> +#
> +# _fsv_corrupt_bytes - Write some bytes to a file, bypassing the filesystem
> +#
> +# Write the bytes sent on stdin to the given offset in the given file, but do so
> +# by writing directly to the extents on the block device, with the filesystem
> +# unmounted.  This can be used to corrupt a verity file for testing purposes,
> +# bypassing the restrictions imposed by the filesystem.  On ext4 and f2fs this
> +# can also write into the metadata region of a verity file.
> +#
> +# The file is assumed to be located on $SCRATCH_DEV.
> +#
> +_fsv_corrupt_bytes()

Same here. Either use rename it to _fsv_scratch_corrupt_bytes or pass
the block device to it.

> +{
> +	local file=$1
> +	local offset=$2
> +	local lstarts=() # extent logical starts, in bytes
> +	local pstarts=() # extent physical starts, in bytes
> +	local lens=() # extent lengths, in bytes
> +	local line
> +	local cmd
> +	local dd_cmds=()
> +	local eidx=0
> +
> +	sync	# Sync to avoid unwritten extents
> +
> +	cat > $tmp.bytes
> +	local end=$(( offset + $(stat -c %s $tmp.bytes ) ))
> +
> +	# Get the list of extents that intersect the requested range
> +	while read -r line; do \
> +		local fields=($line)
> +		local lstart=${fields[0]}
> +		local lend=${fields[1]}
> +		local pstart=${fields[2]}
> +		local pend=${fields[3]}
> +		local llen=$((lend + 1 - lstart))
> +		local plen=$((pend + 1 - pstart))
> +		if (( llen != plen )); then
> +			_fail "Logical and physical extent lengths differ! $line"
> +		fi
> +		lstarts+=( $((lstart * 512)) )
> +		pstarts+=( $((pstart * 512)) )
> +		lens+=( $((llen * 512)) )
> +	done < <($XFS_IO_PROG -r -c "fiemap $offset $((end - offset))" "$file" \
> +		 | grep -E '^[[:space:]]+[0-9]+:' \
> +		 | grep -v '\<hole\>' \
> +		 | sed -E 's/^[[:space:]]+[0-9]+://' \
> +		 | tr '][.:' ' ')

Introduce a new _filter_xfs_io_fiemap helper? We already have
_filter_filefrag which does similar jobs.

Thanks,
Eryu

> +
> +	while (( offset < end )); do
> +		# Find the next extent to write to
> +		while true; do
> +			if (( eidx >= ${#lstarts[@]} )); then
> +				_fail "Extents ended before byte $offset"
> +			fi
> +			if (( offset < ${lstarts[$eidx]} )); then
> +				_fail "Hole in file at byte $offset"
> +			fi
> +			local lend=$(( ${lstarts[$eidx]} + ${lens[$eidx]} ))
> +			if (( offset < lend )); then
> +				break
> +			fi
> +			(( eidx += 1 ))
> +		done
> +		# Add a command that writes to the next extent
> +		local len=$((lend - offset))
> +		local seek=$(( offset + ${pstarts[$eidx]} - ${lstarts[$eidx]} ))
> +		if (( len > end - offset )); then
> +			len=$((end - offset))
> +		fi
> +		dd_cmds+=("head -c $len | dd of=$SCRATCH_DEV oflag=seek_bytes seek=$seek status=none")
> +		(( offset += len ))
> +	done
> +
> +	# Execute the commands to write the data
> +	_scratch_unmount
> +	for cmd in "${dd_cmds[@]}"; do
> +		eval "$cmd"
> +	done < $tmp.bytes
> +	sync	# Sync to flush the block device's pagecache
> +	_scratch_mount
> +}
> -- 
> 2.20.0.rc2.403.gdbc3b29805-goog
> 
