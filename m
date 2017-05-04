Return-Path: <eguan@redhat.com>
Date: Thu, 4 May 2017 15:30:08 +0800
From: Eryu Guan <eguan@redhat.com>
Subject: Re: [PATCH] generic: test that encrypted filenames are presented
 without collisions
Message-ID: <20170504073008.GK7250@eguan.usersys.redhat.com>
References: <20170502001524.114018-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170502001524.114018-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: fstests@vger.kernel.org, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 01, 2017 at 05:15:24PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> [RFC for now since the kernel fixes are currently sitting in fscrypt/master and
> haven't been merged to Linus's tree yet; I'll resend this once they're merged]
> 
> Add a test which creates many similarly-named files in an encrypted
> directory, then verifies they can be deleted without access to the
> encryption key.  This is a regression test for two related bugs which
> caused presented names to "collide" and point to the wrong inodes.
> 
> Cc: linux-fscrypt@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@google.com>

The test looks fine to me, it fails on ext4 with rm reporting "Structure
needs cleaning".

One minor issue is that rm reports too many failures (around 98000
lines in my test)

+rm: cannot remove '/mnt/testarea/scratch/edir/_SET,lbqVCybotHoHkKrq4xM7FtbuBCLY': Structure needs cleaning

and that makes the output diff a bit harder to review, and takes too
much space in 500.out.bad file unnecessarily (11M). Better to trim or
limit the error log somehow, e.g. using "head -n 10"?

Thanks,
Eryu
