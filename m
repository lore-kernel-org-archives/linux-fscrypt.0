Return-Path: <SRS0=SM74=UY=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V3 6/7] Add decryption support for sub-pagesized blocks
Date: Tue, 25 Jun 2019 11:52:43 +0530
In-Reply-To: <20190621212916.GD167064@gmail.com>
References: <20190616160813.24464-1-chandan@linux.ibm.com> <20190616160813.24464-7-chandan@linux.ibm.com> <20190621212916.GD167064@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <3201150.UV5xBNPoiD@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Saturday, June 22, 2019 2:59:17 AM IST Eric Biggers wrote:
> On Sun, Jun 16, 2019 at 09:38:12PM +0530, Chandan Rajendra wrote:
> > To support decryption of sub-pagesized blocks this commit adds code to,
> > 1. Track buffer head in "struct read_callbacks_ctx".
> > 2. Pass buffer head argument to all read callbacks.
> > 3. Add new fscrypt helper to decrypt the file data referred to by a
> >    buffer head.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
> > ---
> >  fs/buffer.c                    |  55 +++++++++------
> >  fs/crypto/bio.c                |  21 +++++-
> >  fs/f2fs/data.c                 |   2 +-
> >  fs/mpage.c                     |   2 +-
> >  fs/read_callbacks.c            | 118 +++++++++++++++++++++++++--------
> >  include/linux/buffer_head.h    |   1 +
> >  include/linux/read_callbacks.h |  13 +++-
> >  7 files changed, 158 insertions(+), 54 deletions(-)
> > 
> 
> This is another patch that unnecessarily changes way too many components at
> once.  My suggestions elsewhere would resolve this, though:
> 
> - This patch changes fs/f2fs/data.c and fs/mpage.c only to pass a NULL
>   buffer_head to read_callbacks_setup().  But as per my comments on patch 1,
>   read_callbacks_setup() should be split into read_callbacks_setup_bio() and
>   read_callbacks_end_bh().
> 
> - This patch changes fs/crypto/ only to add support for the buffer_head
>   decryption work.  But as per my comments on patch 1, that should be in
>   read_callbacks.c instead.
> 
> And adding buffer_head support to fs/read_callbacks.c should be its own patch,
> *or* should simply be folded into the patch that adds fs/read_callbacks.c.
> 
> Then the only thing remaining in this patch would be updating fs/buffer.c to
> make it use the read_callbacks, which should be retitled to something like
> "fs/buffer.c: add decryption support via read_callbacks".
> 

I agree.

-- 
chandan
