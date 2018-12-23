Return-Path: <SRS0=DN85=PA=infradead.org=willy@kernel.org>
Date: Sat, 22 Dec 2018 20:10:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181223041007.GL10600@bombadil.infradead.org>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu>
 <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu>
 <20181221070447.GA21687@infradead.org>
 <20181221154714.GA26547@mit.edu>
 <CAHk-=wgdzWgoPSuHeVcqmGE1hB3Gan72r2_AhtC14e60=z45yg@mail.gmail.com>
 <20181222041712.GC26547@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181222041712.GC26547@mit.edu>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Dec 21, 2018 at 11:17:12PM -0500, Theodore Y. Ts'o wrote:
> Userspace applications which are reading the file aren't going to be
> expecting Merkle tree.  For example, one of the use cases is Android
> APK files, which are essentially ZIP files.  ZIP files can be parsed
> both from the front-end (streaming), or by looking for the complete
> directory of all of the files in the ZIP file by starting at the end
> of the file and moving backwards.  If the Merkle tree was visible to
> userspace programs that are opening and reading the file, it would
> confuse them mightily.

Pretty much every file format has the ability to put arbitrary blocks
of information into a file somewhere the tools which don't know about
it will skip it.  For example, ZIP "includes an extra field facility
within file headers, which can be used to store extra data not defined
by existing ZIP specifications, and which allow compliant archivers that
do not recognize the fields to safely skip them. Header IDs 0–31 are
reserved for use by PKWARE. The remaining IDs can be used by third-party
vendors for proprietary usage. " (Wikipedia)

ELF, PNG, PDF and many other formats have the ability to put data
_somewhere_.  It might not be at the tail of the file, but there's
somewhere to do it.

(I appreciate this isn't what Linus is asking for, but I'm pointing out
that this is by no means as intractable as you make it sound.)
