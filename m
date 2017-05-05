Return-Path: <eguan@redhat.com>
Date: Fri, 5 May 2017 18:12:06 +0800
From: Eryu Guan <eguan@redhat.com>
Subject: Re: [PATCH] generic: test revalidation of encrypted dentries
Message-ID: <20170505101206.GS7250@eguan.usersys.redhat.com>
References: <20170504215548.13698-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170504215548.13698-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: fstests@vger.kernel.org, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, May 04, 2017 at 02:55:48PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add a test which verifies that dentries in an encrypted directory are
> invalidated when an encryption key is added --- which should cause the
> plaintext filenames to be visible and accessible, replacing the encoded
> ciphertext filenames and any negative dentries for the plaintext names.
> This primarily tests for a bug which was fixed in the v4.5 kernel, plus
> a v4.6 fix for incorrect RCU usage in the earlier fix.
> 
> Cc: linux-fscrypt@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good to me, ext4 passed this test with 4.11-rc8 kernel.

...
> +_filter_ciphertext_filenames()
> +{
> +	_filter_scratch | sed 's|edir/[a-zA-Z0-9+,_]\+|edir/ENCRYPTED_NAME|g'
> +}
> +
> +_show_file_contents()
> +{
> +	echo "--- Contents of files using plaintext names:"
> +	cat $SCRATCH_MNT/edir/@@@ |& _filter_scratch
> +	cat $SCRATCH_MNT/edir/abcd |& _filter_scratch
> +	echo "--- Contents of files using ciphertext names:"
> +	cat ${ciphertext_names[@]} |& _filter_ciphertext_filenames
> +}
> +
> +_show_directory_with_key()
> +{
> +	echo "--- Directory listing:"
> +	find $SCRATCH_MNT/edir -mindepth 1 | sort | _filter_scratch
> +	_show_file_contents
> +}

I just removed the leading underscore from above three local functions,
leading underscores are reserved for global helpers.

Thanks,
Eryu
