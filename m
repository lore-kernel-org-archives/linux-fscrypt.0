Return-Path: <ebiggers3@gmail.com>
Date: Wed, 15 Mar 2017 10:57:38 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] generic: test encryption key revocation during
 concurrent I/O
Message-ID: <20170315175738.GA85449@gmail.com>
References: <20170315002551.9423-1-ebiggers3@gmail.com>
 <20170315101849.GO14226@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315101849.GO14226@eguan.usersys.redhat.com>
To: Eryu Guan <eguan@redhat.com>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Mar 15, 2017 at 06:18:49PM +0800, Eryu Guan wrote:
> > +# remove previous $seqres.full before test
> > +rm -f $seqres.full
> > +
> > +# real QA test starts here
> > +_supported_fs ext4 f2fs
> 
> supported fs should be generic if it's in generic dir. If it only
> supports some specific filesystems, then it should go to shared dir.
> 

Indeed, it's supposed to be '_supported_fs generic'.

Thanks for reviewing!

- Eric
