Return-Path: <SRS0=U85J=OU=bombadil.srs.infradead.org=BATV+d2015f5d27e1b7836afa+5588+infradead.org+hch@kernel.org>
Date: Tue, 11 Dec 2018 05:52:31 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/7] xfstests: add fs-verity tests
Message-ID: <20181211135231.GA14965@infradead.org>
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

Seriously, given how broken the current fs-verify support is we should
neither merge it into the kernel nor fstests.

Nothing against the highlevel feature per-se, but the implementation
posted to linux-fsdevel a while ago is simply too broken.
