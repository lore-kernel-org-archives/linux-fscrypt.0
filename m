Date: Thu, 13 Dec 2018 21:39:06 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181214053905.GA710@sol.localdomain>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214051722.GF20880@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214051722.GF20880@thunk.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Dec 14, 2018 at 12:17:22AM -0500, Theodore Y. Ts'o wrote:
> Furthermore, it would require extra complexity in the common fsverity code
> --- which looks for the Merkle tree at the end of file data --- for no real
> benefit.

To clarify, while this is technically true currently, as I mentioned it's been
kept flexible enough such that a filesystem *could* store the metadata elsewhere
with only some slight changes to the common fs/verity/ code which won't break
other filesystems.  Though of course, keeping all filesystems using the
"metadata after EOF" approach does allow a couple simplifications.

- Eric
