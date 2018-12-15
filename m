Return-Path: <SRS0=ekgu=OY=gmail.com=guaneryu@kernel.org>
Date: Sat, 15 Dec 2018 22:28:52 +0800
From: Eryu Guan <guaneryu@gmail.com>
Subject: Re: [PATCH 0/7] xfstests: add fs-verity tests
Message-ID: <20181215142852.GV3889@desktop>
References: <20181210222142.222342-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210222142.222342-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Dec 10, 2018 at 02:21:35PM -0800, Eric Biggers wrote:
> Add tests for fs-verity, a new feature for read-only file-based
> authenticity protection.  fs-verity will be supported by ext4 and f2fs,
> and perhaps other filesystems later.  Running these tests requires:
> 
> - A kernel with the fs-verity patches from
>   https://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git/log/
>   (should be merged in 4.21) and configured with CONFIG_FS_VERITY.
> - The fsverity utility program, which can be installed from
>   https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/fsverity-utils.git/
> - e2fsprogs v1.44.4-2 or later for ext4 tests, or f2fs-tools v1.11.0 or
>   later for f2fs tests.
> 
> Example with kvm-xfstests:
> 
> 	$ kvm-xfstests -c ext4,f2fs -g verity
> 
> See the file Documentation/filesystem/fsverity.rst in the kernel tree
> for more information about fs-verity.
> 
> Eric Biggers (7):
>   common/verity: add common functions for testing fs-verity
>   generic: test general behavior of verity files
>   generic: test access controls on the fs-verity ioctls
>   generic: test fs-verity descriptor validation
>   generic: test corrupting verity files
>   generic: test that fs-verity is using the correct measurement values
>   generic: test using fs-verity and fscrypt simultaneously

The tests look good to me overall, and tests ran fine on my test vm (I
only tested with ext4 though), thanks a lot! There're just a few minor
issues, the comments go to individual patch.

But it seems that there're still disagreements on the implemention of
fsverity, I'd like to wait and see what's the final decision before
taking the tests.

Thanks,
Eryu
