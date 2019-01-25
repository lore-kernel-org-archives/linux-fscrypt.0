Return-Path: <SRS0=z5ey=QB=linuxfoundation.org=torvalds@kernel.org>
MIME-Version: 1.0
References: <20190110051500.GA32361@mit.edu> <20190114234101.GQ27534@dastard>
 <20190123051017.GA8785@mit.edu> <20190124212544.GS6173@dastard>
 <CAHk-=wh7jq6U3+ou_FDujB-ipg9JcJAGSjEQ_niCwLG313x6UA@mail.gmail.com> <20190124232237.GH8785@mit.edu>
In-Reply-To: <20190124232237.GH8785@mit.edu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 25 Jan 2019 13:35:05 +1300
Message-ID: <CAHk-=wjw+tAKu7fM3GwUX9i7LBFuvB=ohqXj+KgQQaW3pCzfxg@mail.gmail.com>
Subject: Re: Proposal: A new fs-verity interface
Content-Type: text/plain; charset="UTF-8"
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jan 25, 2019 at 12:22 PM Theodore Y. Ts'o <tytso@mit.edu> wrote:
>
>
> > I understand that you don't want to load the whole merkle tree into
> > memory, and that is the reason that you want to point to some "stable
> > on disk" area, but the hole punching does seem to be a particularly
> > nasty part of it. It would be much better to have the merkle data in
> > some place where it doesn't then need to be hidden again, no?
>
> It's not really a "hole punch", but we are moving the data around.
> That's because Dave Chinner and Christoph demanded it.  The original
> approach was to put it at the end of the file, and then hide it.  If
> the question is "why hide the metadata", it's because it's metadata.
> We certainly don't want to make it be visible as part of the file
> stream.

But that's the whole hiding thing. Why do you feel you need to do
that? Why not just leave it alone, and leave it visible, and say "hey,
the merkle data for file X comes from here".

Punching a hole, or moving it somewhere else, or hiding or, or
whatever you want to do, all mean "you have to modify the filesystem".
They also mean "you can't back up the original sanely any more and
move it somewhere else".

Wouldn't it be much nicer to simple have a *separate* stream. If it's
not an xattr, then maybe just a separate file entirely. A file that
just contains the merkle data, and has no alignment things because
there's no "it's at the end of the file that it describes" issues,
it's just a standalone thing that is still visible so that you can
copy the original data and it's still valid (even if the merkle tree
then isn't _enabled_ in the copy, but now you could re-enable it in a
new location).

> We could store the metadata somewhere else --- for example, we could
> store it in another inode.  But inodes have overhead, and that would
> mean using two inodes for every fs-verity protected files --- and we
> don't need all of the other metadata (mtime, ctime, etc.) for the
> Merkle tree.

Well, if one of the issues is that the merkle data ends up being
megabytes, I don't see this as being  a huge issue. Particularly since
the alignemnt restrictions in the unified thing means that you still
aren't exactly "packing" the merkle data efficiently to begin with..

In fact, if you want to have merkle data for small files (where the
merkle data itself is just a  few words), then having it in a separate
file and as part of the inode inline data doesn't seem like it's
likely any worse (and might be *better*) than having it at some block
boundary due to alignment...

Hmm?

            Linus
