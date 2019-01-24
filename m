Return-Path: <SRS0=zO3O=QA=linuxfoundation.org=torvalds@kernel.org>
MIME-Version: 1.0
References: <20190110051500.GA32361@mit.edu> <20190114234101.GQ27534@dastard>
 <20190123051017.GA8785@mit.edu> <20190124212544.GS6173@dastard>
In-Reply-To: <20190124212544.GS6173@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 25 Jan 2019 10:40:31 +1300
Message-ID: <CAHk-=wh7jq6U3+ou_FDujB-ipg9JcJAGSjEQ_niCwLG313x6UA@mail.gmail.com>
Subject: Re: Proposal: A new fs-verity interface
Content-Type: text/plain; charset="UTF-8"
To: Dave Chinner <david@fromorbit.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jan 25, 2019 at 10:25 AM Dave Chinner <david@fromorbit.com> wrote:
>
> So it's still "file data" that the filesystem has to magically
> transform into hidden metadata in some manner. What writes the
> merkel tree into a file, and why can't it just write it direct to
> the filesystem rather than having to use an intermediate file?

This does frustrate me too.

I _assume_ (but it's exactly that - just an assumption) this whole
design decision comes from basically having a transport layer that is
entirely unaware of the merle data, so the data  is brought in some
entirely traditional way that can only transfer regular file contents
(ie tar/zip/ar kind of thing, but presumably actually just in the form
of an android APK). And then the new interface is just a way to
"convert" that into the actual final security model.

One thing that is also unclear to me is whether that "secure" model
needs to be stable on disk (ie is this considered an actual write that
*modifies* the underlying filesystem, and the merkle tree data ends up
being associated long-term and over reboots), or whether it would be
acceptable to just have it be a temporary "view" of the file where the
filesystem itself can be read-only, and all that happens is that now
the merkle tree is associated with that file as long as the filesystem
is mounted (or until it is disassociated).

Maybe this was answered in some of the earlier email threads that (at
least for me) were then somewhat overshadowed by the merge window work
and the holidays. So it's possible that I repeat myself. But I do have
to say that I think I'd *still* prefer this to be something more like
an xattr, and that maybe we'd be better off actually improving out
"write to xattr" interface or something.

I understand that you don't want to load the whole merkle tree into
memory, and that is the reason that you want to point to some "stable
on disk" area, but the hole punching does seem to be a particularly
nasty part of it. It would be much better to have the merkle data in
some place where it doesn't then need to be hidden again, no?

             Linus
