Return-Path: <SRS0=Bj0P=OV=bombadil.srs.infradead.org=BATV+a4c84aa40f04b2dbfbde+5589+infradead.org+hch@kernel.org>
Date: Wed, 12 Dec 2018 01:15:54 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/7] xfstests: add fs-verity tests
Message-ID: <20181212091554.GB7855@infradead.org>
References: <20181210222142.222342-1-ebiggers@kernel.org>
 <20181211135231.GA14965@infradead.org>
 <20181211172931.GA221175@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211172931.GA221175@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Dec 11, 2018 at 09:29:32AM -0800, Eric Biggers wrote:
> Hi Christoph,
> 
> On Tue, Dec 11, 2018 at 05:52:31AM -0800, Christoph Hellwig wrote:
> > On Mon, Dec 10, 2018 at 02:21:35PM -0800, Eric Biggers wrote:
> > > Add tests for fs-verity, a new feature for read-only file-based
> > > authenticity protection.  fs-verity will be supported by ext4 and f2fs,
> > > and perhaps other filesystems later.  Running these tests requires:
> > 
> > Seriously, given how broken the current fs-verify support is we should
> > neither merge it into the kernel nor fstests.
> > 
> > Nothing against the highlevel feature per-se, but the implementation
> > posted to linux-fsdevel a while ago is simply too broken.
> 
> Please explain.  Broken, how so?  What changes do you suggest, specifically?

Don't magically pass the hash in the file data, that is just broken
beyond repairable.

> Also, if you have feedback it would be helpful if you posted it in response to
> the actual kernel patchset, not just the tests.  AFAICS, this is your first time
> responding to any fs-verity related thread, despite it being out for review for
> months; is that correct or did I miss something you previously posted?

No.  But given how broken it I'd rather ignore it rather than wasting
my time.  It isn't like it did get any other serious review either.
