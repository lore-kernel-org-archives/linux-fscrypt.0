Return-Path: <SRS0=Bj0P=OV=bombadil.srs.infradead.org=BATV+a4c84aa40f04b2dbfbde+5589+infradead.org+hch@kernel.org>
Date: Wed, 12 Dec 2018 01:14:06 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181212091406.GA31723@infradead.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101225230.88058-2-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

As this apparently got merged despite no proper reviews from VFS
level persons:

NAK - the ioctl format that expects the verifycation hash in the file
data data with padding after the real data is simply not acceptable,
we can't just transform the data in the file itself based on a magic
calls like this.

Also the core code should not depend on this as a storage format,
which is a rather bad idea.  In any modern file system you can
store data like this out of line in something like the attr fork
in XFS, or the attr items in btrfs.
