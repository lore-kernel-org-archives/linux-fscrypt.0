Return-Path: <BATV+a531e2bbbc8af89517f3+5043+infradead.org+hch@bombadil.srs.infradead.org>
Date: Wed, 14 Jun 2017 00:06:14 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/3] ext4: require key for truncate(2) of encrypted file
Message-ID: <20170614070614.GA1786@infradead.org>
References: <20170613234755.111167-1-ebiggers3@gmail.com>
 <20170613234755.111167-2-ebiggers3@gmail.com>
 <20170614065210.GA10411@infradead.org>
 <20170614070357.GB605@zzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614070357.GB605@zzz>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jun 14, 2017 at 12:03:57AM -0700, Eric Biggers wrote:
> None of those are allowed because fallocate() requires a file descriptor, and
> open() fails with ENOKEY if the encryption key is not available.  truncate() is
> different because it takes a path, not a file descriptor.

Ok, that makes sense.
