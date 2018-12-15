Return-Path: <SRS0=ekgu=OY=gmail.com=guaneryu@kernel.org>
Date: Sat, 15 Dec 2018 22:40:29 +0800
From: Eryu Guan <guaneryu@gmail.com>
Subject: Re: [PATCH 3/7] generic: test access controls on the fs-verity ioctls
Message-ID: <20181215144029.GX3889@desktop>
References: <20181210222142.222342-1-ebiggers@kernel.org>
 <20181210222142.222342-4-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210222142.222342-4-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Dec 10, 2018 at 02:21:38PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Test access controls on the fs-verity ioctls.  FS_IOC_MEASURE_VERITY is
> allowed on any file, whereas FS_IOC_ENABLE_VERITY requires write access.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  tests/generic/901     | 71 +++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/901.out | 14 +++++++++
>  tests/generic/group   |  1 +
>  3 files changed, 86 insertions(+)
>  create mode 100755 tests/generic/901
>  create mode 100644 tests/generic/901.out
> 
> diff --git a/tests/generic/901 b/tests/generic/901
> new file mode 100755
> index 00000000..860e646f
> --- /dev/null
> +++ b/tests/generic/901
> @@ -0,0 +1,71 @@
> +#! /bin/bash
> +# SPDX-License-Identifier: GPL-2.0
> +# Copyright 2018 Google LLC
> +#
> +# FS QA Test generic/901
> +#
> +# Test access controls on the fs-verity ioctls.  FS_IOC_MEASURE_VERITY is
> +# allowed on any file, whereas FS_IOC_ENABLE_VERITY requires write access.
> +#
> +seq=`basename $0`
> +seqres=$RESULT_DIR/$seq
> +echo "QA output created by $seq"
> +
> +here=`pwd`
> +tmp=/tmp/$$
> +status=1	# failure is the default!
> +trap "_cleanup; exit \$status" 0 1 2 3 15
> +
> +_cleanup()
> +{
> +	cd /
> +	rm -f $tmp.*
> +}
> +
> +# get standard environment, filters and checks
> +. ./common/rc
> +. ./common/filter
> +. ./common/verity
> +
> +# remove previous $seqres.full before test
> +rm -f $seqres.full
> +
> +# real QA test starts here
> +_supported_fs generic
> +_supported_os Linux
> +_require_scratch_verity
> +_require_user
> +
> +_scratch_mkfs_verity &>> $seqres.full
> +_scratch_mount
> +fsv_file=$SCRATCH_MNT/file.fsv
> +
> +_fsv_begin_subtest "FS_IOC_ENABLE_VERITY doesn't require root"
> +_fsv_create_setup_file $fsv_file >> $seqres.full
> +chmod 666 $fsv_file
> +su $qa_user -c "$FSVERITY_PROG enable $fsv_file"

Use _user_do instead of a bare su?

> +
> +_fsv_begin_subtest "FS_IOC_ENABLE_VERITY requires write access"
> +_fsv_create_setup_file $fsv_file >> $seqres.full
> +chmod 444 $fsv_file
> +su $qa_user -c "$FSVERITY_PROG enable $fsv_file" |& _filter_scratch
> +
> +_fsv_begin_subtest "FS_IOC_ENABLE_VERITY requires !append-only"
> +_fsv_create_setup_file $fsv_file >> $seqres.full
> +chattr +a $fsv_file
> +$FSVERITY_PROG enable $fsv_file |& _filter_scratch
> +chattr -a $fsv_file

Need "_require_chattr ia" then, and use $CHATTR_PROG.

Thanks,
Eryu

> +
> +_fsv_begin_subtest "FS_IOC_ENABLE_VERITY requires !immutable"
> +_fsv_create_setup_file $fsv_file >> $seqres.full
> +chattr +i $fsv_file
> +$FSVERITY_PROG enable $fsv_file |& _filter_scratch
> +chattr -i $fsv_file
> +
> +_fsv_begin_subtest "FS_IOC_MEASURE_VERITY doesn't require root"
> +_fsv_create_enable_file $fsv_file >> $seqres.full
> +su $qa_user -c "$FSVERITY_PROG measure $fsv_file" >> $seqres.full
> +
> +# success, all done
> +status=0
> +exit
> diff --git a/tests/generic/901.out b/tests/generic/901.out
> new file mode 100644
> index 00000000..d0b16e7c
> --- /dev/null
> +++ b/tests/generic/901.out
> @@ -0,0 +1,14 @@
> +QA output created by 901
> +
> +# FS_IOC_ENABLE_VERITY doesn't require root
> +
> +# FS_IOC_ENABLE_VERITY requires write access
> +ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Permission denied
> +
> +# FS_IOC_ENABLE_VERITY requires !append-only
> +ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Operation not permitted
> +
> +# FS_IOC_ENABLE_VERITY requires !immutable
> +ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Operation not permitted
> +
> +# FS_IOC_MEASURE_VERITY doesn't require root
> diff --git a/tests/generic/group b/tests/generic/group
> index 2a9109ac..f14ad790 100644
> --- a/tests/generic/group
> +++ b/tests/generic/group
> @@ -526,3 +526,4 @@
>  521 soak long_rw
>  522 soak long_rw
>  900 auto quick verity
> +901 auto quick verity
> -- 
> 2.20.0.rc2.403.gdbc3b29805-goog
> 
