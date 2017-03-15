Return-Path: <eguan@redhat.com>
Date: Wed, 15 Mar 2017 18:18:49 +0800
From: Eryu Guan <eguan@redhat.com>
Subject: Re: [PATCH] generic: test encryption key revocation during
 concurrent I/O
Message-ID: <20170315101849.GO14226@eguan.usersys.redhat.com>
References: <20170315002551.9423-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315002551.9423-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Mar 14, 2017 at 05:25:51PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add a test which revokes a keyring key while other processes are
> performing I/O on an encrypted file that was "unlocked" using that key.
> This crashes unpatched kernels with filesystem encryption enabled, so
> place it in the "dangerous" group.
> 
> [The patch to fix this is titled "fscrypt: remove broken support for
> detecting keyring key revocation" but hasn't been merged yet; we may
> want to wait a bit before merging this test.]

Agreed.

> 
> Cc: Theodore Ts'o <tytso@mit.edu>
> Cc: Jaegeuk Kim <jaegeuk@kernel.org>
> Cc: Richard Weinberger <richard@nod.at>
> Cc: Michael Halcrow <mhalcrow@google.com>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

This looks good to me, and it crashed my 4.11-rc2 test host very
quickly. Just one minor comment below.

> ---
>  common/encrypt        |   8 ++++
>  tests/generic/500     | 109 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/500.out |   2 +
>  tests/generic/group   |   1 +
>  4 files changed, 120 insertions(+)
>  create mode 100755 tests/generic/500
>  create mode 100644 tests/generic/500.out
...
> +# remove previous $seqres.full before test
> +rm -f $seqres.full
> +
> +# real QA test starts here
> +_supported_fs ext4 f2fs

supported fs should be generic if it's in generic dir. If it only
supports some specific filesystems, then it should go to shared dir.

Thanks,
Eryu
