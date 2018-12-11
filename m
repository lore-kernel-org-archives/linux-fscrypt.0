Return-Path: <fstests-owner@vger.kernel.org>
Date: Tue, 11 Dec 2018 09:29:32 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 0/7] xfstests: add fs-verity tests
Message-ID: <20181211172931.GA221175@gmail.com>
References: <20181210222142.222342-1-ebiggers@kernel.org>
 <20181211135231.GA14965@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211135231.GA14965@infradead.org>
Sender: fstests-owner@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Christoph,

On Tue, Dec 11, 2018 at 05:52:31AM -0800, Christoph Hellwig wrote:
> On Mon, Dec 10, 2018 at 02:21:35PM -0800, Eric Biggers wrote:
> > Add tests for fs-verity, a new feature for read-only file-based
> > authenticity protection.  fs-verity will be supported by ext4 and f2fs,
> > and perhaps other filesystems later.  Running these tests requires:
> 
> Seriously, given how broken the current fs-verify support is we should
> neither merge it into the kernel nor fstests.
> 
> Nothing against the highlevel feature per-se, but the implementation
> posted to linux-fsdevel a while ago is simply too broken.

Please explain.  Broken, how so?  What changes do you suggest, specifically?

Also, if you have feedback it would be helpful if you posted it in response to
the actual kernel patchset, not just the tests.  AFAICS, this is your first time
responding to any fs-verity related thread, despite it being out for review for
months; is that correct or did I miss something you previously posted?

- Eric
