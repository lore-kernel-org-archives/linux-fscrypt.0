Return-Path: <SRS0=jYOy=O6=gmail.com=richard.weinberger@kernel.org>
MIME-Version: 1.0
References: <20181219071420.GC2628@infradead.org> <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu> <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu> <20181221070447.GA21687@infradead.org>
In-Reply-To: <20181221070447.GA21687@infradead.org>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Fri, 21 Dec 2018 11:06:45 +0100
Message-ID: <CAFLxGvxKPNDBQfBnx0obRrriCq9S3U_JsE4bwDwM8QxE+En9=w@mail.gmail.com>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Content-Type: text/plain; charset="UTF-8"
To: Christoph Hellwig <hch@infradead.org>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Dec 21, 2018 at 9:58 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Thu, Dec 20, 2018 at 05:01:58PM -0500, Theodore Y. Ts'o wrote:
> > That's simply not true.  Number one, fsverity is not mandatory for all
> > file systems to implement.  If XFS doesn't want to implement fscrypt
> > or fsverity, it doesn't have to.  Number two, we're not *making* any
> > changes to the kernel code; nothing in mm/filemap.c, et. al.  So
> > saying that we are making changes that are impacted by /everyone/ just
> > doesn't make any sense.
>
> Ted, I think you know yourself this isn't true.  Whenever we added
> useful interface to one of the major file systems we had other pick
> it up, and that is a good thing because the last thing we need is
> fragmentation of interfaces.  And even if that wasn't the case I don't
> think we should take short cuts, because even if an interface was just
> for a file system or two it still needs to be properly desgined.
>
> There is no reason to rush interfacs in, because everytime we have done
> that it has turned out to be a very bad idea in retrospective.

Speaking of interfaces, one thing that needs IMHO more thought is the
user facing interface. Not only in the fsverity case, in all cases.

Linux has currently many different ways to implement and check
(cryptographic)-integrity.
Just to name a few, fsverity, UBIFS' auth feature, BTRFS csum,
EVM/IMA, dm-integrity,
dm-verity, ...

At least for filesystems it would be good to have a common interface
to query the
integrity status of a file.
So far we have mixture of different return codes (EPERM, EUCLEAN, EINVAL),
audit events plus cryptic kernel logs.

In UBIFS we return EPERM in case of an auth failure, we followed EVM/IMA.
fsverity goes the EUCLEAN route, just like BTRFS for check sum failures.

Before everything is set in stone, let's try to consolidate at least this.

Along with that, what about the statx() interface?
We have already STATX_ATTR_ENCRYPTED, why no STATX_ATTR_AUTHENTICATED?

-- 
Thanks,
//richard
