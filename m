Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Mon, 12 Aug 2019 15:58:49 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190812225848.GA175194@gmail.com>
References: <20190811213557.1970-1-ebiggers@kernel.org>
 <20190811213557.1970-4-ebiggers@kernel.org>
 <e5d57ee4-f022-12ca-7f09-e4b8ef86c6b6@huawei.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <e5d57ee4-f022-12ca-7f09-e4b8ef86c6b6@huawei.com>
Subject: Re: [f2fs-dev] [PATCH 3/6] f2fs: skip truncate when verity in
 progress in ->write_begin()
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Chao Yu <yuchao0@huawei.com>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chao,

On Mon, Aug 12, 2019 at 08:25:33PM +0800, Chao Yu wrote:
> Hi Eric,
> 
> On 2019/8/12 5:35, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > When an error (e.g. ENOSPC) occurs during f2fs_write_begin() when called
> > from f2fs_write_merkle_tree_block(), skip truncating the file.  i_size
> > is not meaningful in this case, and the truncation is handled by
> > f2fs_end_enable_verity() instead.
> > 
> > Fixes: 60d7bf0f790f ("f2fs: add fs-verity support")
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> >  fs/f2fs/data.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
> > index 3f525f8a3a5fa..00b03fb87bd9b 100644
> > --- a/fs/f2fs/data.c
> > +++ b/fs/f2fs/data.c
> > @@ -2476,7 +2476,7 @@ static void f2fs_write_failed(struct address_space *mapping, loff_t to)
> >  	struct inode *inode = mapping->host;
> >  	loff_t i_size = i_size_read(inode);
> >  
> > -	if (to > i_size) {
> 
> Maybe adding one single line comment to mention that it's redundant/unnecessary
> truncation here is better, if I didn't misunderstand this.
> 
> Thanks,
> 
> > +	if (to > i_size && !f2fs_verity_in_progress(inode)) {
> >  		down_write(&F2FS_I(inode)->i_gc_rwsem[WRITE]);
> >  		down_write(&F2FS_I(inode)->i_mmap_sem);
> >  

Do you mean add a comment instead of the !f2fs_verity_in_progress() check, or in
addition to it?  ->write_begin(), ->writepages(), and ->write_end() are all
supposed to ignore i_size when verity is in progress, so I don't think this
particular part should be different, even if technically it's still correct to
truncate twice.  Also, ext4 needs this check in its ->write_begin() for locking
reasons; we should keep f2fs similar.

How about having both a comment and the check, like:

        /* In the fs-verity case, f2fs_end_enable_verity() does the truncate */
        if (to > i_size && !f2fs_verity_in_progress(inode)) {

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
