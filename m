Return-Path: <fstests-owner@vger.kernel.org>
Date: Thu, 27 Jun 2019 10:37:19 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fscrypt: document testing with xfstests
Message-ID: <20190627173719.GH686@sol.localdomain>
References: <20190620181658.225792-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620181658.225792-1-ebiggers@kernel.org>
Sender: fstests-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: fstests@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 20, 2019 at 11:16:58AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Document how to test ext4, f2fs, and ubifs encryption with xfstests.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  Documentation/filesystems/fscrypt.rst | 39 +++++++++++++++++++++++++++
>  1 file changed, 39 insertions(+)
> 
> diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
> index 87d4e266ffc86d..82efa41b0e6c02 100644
> --- a/Documentation/filesystems/fscrypt.rst
> +++ b/Documentation/filesystems/fscrypt.rst
> @@ -649,3 +649,42 @@ Note that the precise way that filenames are presented to userspace
>  without the key is subject to change in the future.  It is only meant
>  as a way to temporarily present valid filenames so that commands like
>  ``rm -r`` work as expected on encrypted directories.
> +
> +Tests
> +=====
> +
> +To test fscrypt, use xfstests, which is Linux's de facto standard
> +filesystem test suite.  First, run all the tests in the "encrypt"
> +group on the relevant filesystem(s).  For example, to test ext4 and
> +f2fs encryption using `kvm-xfstests
> +<https://github.com/tytso/xfstests-bld/blob/master/Documentation/kvm-quickstart.md>`_::
> +
> +    kvm-xfstests -c ext4,f2fs -g encrypt
> +
> +UBIFS encryption can also be tested this way, but it should be done in
> +a separate command, and it takes some time for kvm-xfstests to set up
> +emulated UBI volumes::
> +
> +    kvm-xfstests -c ubifs -g encrypt
> +
> +No tests should fail.  However, tests that use non-default encryption
> +modes (e.g. generic/549 and generic/550) will be skipped if the needed
> +algorithms were not built into the kernel's crypto API.  Also, tests
> +that access the raw block device (e.g. generic/399, generic/548,
> +generic/549, generic/550) will be skipped on UBIFS.
> +
> +Besides running the "encrypt" group tests, for ext4 and f2fs it's also
> +possible to run most xfstests with the "test_dummy_encryption" mount
> +option.  This option causes all new files to be automatically
> +encrypted with a dummy key, without having to make any API calls.
> +This tests the encrypted I/O paths more thoroughly.  To do this with
> +kvm-xfstests, use the "encrypt" filesystem configuration::
> +
> +    kvm-xfstests -c ext4/encrypt,f2fs/encrypt -g auto
> +
> +Because this runs many more tests than "-g encrypt" does, it takes
> +much longer to run; so also consider using `gce-xfstests
> +<https://github.com/tytso/xfstests-bld/blob/master/Documentation/gce-xfstests.md>`_
> +instead of kvm-xfstests::
> +
> +    gce-xfstests -c ext4/encrypt,f2fs/encrypt -g auto
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

Applied to fscrypt.git for v5.3.

- Eric
