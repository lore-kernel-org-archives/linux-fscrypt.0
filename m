Return-Path: <SRS0=jwQZ=W4=gmail.com=guaneryu@kernel.org>
Date: Sun, 1 Sep 2019 20:08:06 +0800
From: Eryu Guan <guaneryu@gmail.com>
Subject: Re: [RFC PATCH 3/9] common/encrypt: support checking for v2
 encryption policy support
Message-ID: <20190901120320.GE2622@desktop>
References: <20190812175809.34810-1-ebiggers@kernel.org>
 <20190812175809.34810-4-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812175809.34810-4-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 12, 2019 at 10:58:03AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Allow passing '-v 2' to _require_scratch_encryption() to check for v2
> encryption policy support on the scratch device, and for xfs_io support
> for setting and getting v2 encryption policies.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  common/encrypt | 41 +++++++++++++++++++++++++++++++----------
>  1 file changed, 31 insertions(+), 10 deletions(-)
> 
> diff --git a/common/encrypt b/common/encrypt
> index a086e80f..fa6e2672 100644
> --- a/common/encrypt
> +++ b/common/encrypt
> @@ -6,12 +6,13 @@
>  
>  #
>  # _require_scratch_encryption [-c CONTENTS_MODE] [-n FILENAMES_MODE]
> +#			      [-v POLICY_VERSION]
>  #
>  # Require encryption support on the scratch device.
>  #
> -# This checks for support for the default type of encryption policy (AES-256-XTS
> -# and AES-256-CTS).  Options can be specified to also require support for a
> -# different type of encryption policy.
> +# This checks for support for the default type of encryption policy (v1 with
> +# AES-256-XTS and AES-256-CTS).  Options can be specified to also require
> +# support for a different type of encryption policy.
>  #
>  _require_scratch_encryption()
>  {
> @@ -68,13 +69,15 @@ _require_encryption_policy_support()
>  	local mnt=$1
>  	local dir=$mnt/tmpdir
>  	local set_encpolicy_args=""
> +	local policy_version=1
>  	local c
>  
>  	OPTIND=2
> -	while getopts "c:n:" c; do
> +	while getopts "c:n:v:" c; do
>  		case $c in
> -		c|n)
> +		c|n|v)
>  			set_encpolicy_args+=" -$c $OPTARG"
> +			[ $c = v ] && policy_version=$OPTARG

Why not checking 'v' in a separate case?

>  			;;
>  		*)
>  			_fail "Unrecognized option '$c'"
> @@ -87,10 +90,26 @@ _require_encryption_policy_support()
>  		>> $seqres.full
>  
>  	mkdir $dir
> -	_require_command "$KEYCTL_PROG" keyctl
> -	_new_session_keyring
> -	local keydesc=$(_generate_session_encryption_key)
> -	if _set_encpolicy $dir $keydesc $set_encpolicy_args \
> +	if (( policy_version > 1 )); then
> +		_require_xfs_io_command "get_encpolicy" "-t"
> +		local output=$(_get_encpolicy $dir -t)
> +		if [ "$output" != "supported" ]; then
> +			if [ "$output" = "unsupported" ]; then
> +				_notrun "kernel does not support $FSTYP encryption v2 API"
> +			fi
> +			_fail "Unexpected output from 'get_encpolicy -t'"

Print $output in the _fail message as well?

Thanks,
Eryu

> +		fi
> +		# Both the kernel and xfs_io support v2 encryption policies, and
> +		# therefore also filesystem-level keys -- since that's the only
> +		# way to provide keys for v2 policies.
> +		local raw_key=$(_generate_raw_encryption_key)
> +		local keyspec=$(_add_enckey $mnt "$raw_key" | awk '{print $NF}')
> +	else
> +		_require_command "$KEYCTL_PROG" keyctl
> +		_new_session_keyring
> +		local keyspec=$(_generate_session_encryption_key)
> +	fi
> +	if _set_encpolicy $dir $keyspec $set_encpolicy_args \
>  		2>&1 >>$seqres.full | egrep -q 'Invalid argument'; then
>  		_notrun "kernel does not support encryption policy: '$set_encpolicy_args'"
>  	fi
> @@ -103,7 +122,9 @@ _require_encryption_policy_support()
>  	if ! echo foo > $dir/file; then
>  		_notrun "encryption policy '$set_encpolicy_args' is unusable; probably missing kernel crypto API support"
>  	fi
> -	$KEYCTL_PROG clear @s
> +	if (( policy_version <= 1 )); then
> +		$KEYCTL_PROG clear @s
> +	fi
>  	rm -r $dir
>  }
>  
> -- 
> 2.23.0.rc1.153.gdeed80330f-goog
> 
