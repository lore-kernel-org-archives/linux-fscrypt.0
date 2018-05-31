Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V3 07/12] mpage_readpage[s]: Introduce post process callback parameters
Date: Thu, 31 May 2018 19:14:48 +0530
In-Reply-To: <20180530160225.GC27959@thunk.org>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com> <8086194.2RCvbI17Vi@localhost.localdomain> <20180530160225.GC27959@thunk.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <1859578.T8RXr9DR7V@localhost.localdomain>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wednesday, May 30, 2018 9:32:25 PM IST Theodore Y. Ts'o wrote:
> On Wed, May 30, 2018 at 05:03:40PM +0530, Chandan Rajendra wrote:
> > On Wednesday, May 30, 2018 10:36:42 AM IST Theodore Y. Ts'o wrote:
> > > Note: we may want to move this thread so that it's on linux-fscrypt
> > > exclusively.  I'm thinking that we should consider using linux-fscrypt
> > > for fscrypt and fsverity discussions.  That way we can avoid adding
> > > extra noise to the linux-fsdevel and linux-ext4 lists.  Comments?
> > 
> > I agree.
> 
> OK, I've moved linux-ext4 and linux-fsdevel to bcc.
> 
> > > I now think this was a mistake, and that we should handle this the
> > > same way we handle CONFIG_QUOTA.  If we enable fscrypt or fsverity, it
> > > should be enabled for all file sytems which support that feature.
> > 
> > Do we continue to retain ext4/readpage.c? I ask because if the logic in
> > ext4/readpage.c has to be moved to fs/buffer.c (to avoid code duplication) then 
> > we end up losing the ability to build fscrypt as a module even if one of
> > the filesystems using fs/bio_post_read.c is itself built as a module.
> 
> It's not necessarily an either-or.  For example, we could use function
> pointers to allow avoid needing code in the built-in portion of the
> kernel from linking directly to the module.  Just as an illustration,
> we could hang a pointer off of the struct super data structure which
> is an array of post-processing functions, so each file system can
> register post-processing handlers for each "post processing step".
> 
> I think the bigger deal is that mpage_readpage() and mpage_readpages()
> are used by a large number of file systems, with a variety of
> requirements --- including some with high performance requirements.
> So if we make changes to fs/mpage.c, we need to make sure we don't
> make things worse for them.  In particular, if post-processing isn't
> needed, we shouldn't be doing any extra memory allocations or taking
> any extra locks.

I agree. Lets get things implemented in ext4/readpage.c first. If we are
then sure that the corresponding changes in fs/mpage.c won't harm
performance/memory consumption, we could move over the code to fs/mpage.c.

> 
> The somewhat smaller concern is that because mpage_readpages() has to
> be used for some very old file systems, it uses a very simple
> interface for getting the mapping from a logical block # to the
> physical block number.  One of the benefits when I created
> fs/ext4/readpage.c was that I dind't need to restrict myself to using
> the old get_blocks_t interface, but could call ext4_map_blocks()
> directly.  So for a readpages() call, we don't need end up needing to
> call ext4_get_block() for each block mapping.  This saves CPU and the
> need to take a read spinlock multiple times.  On the other hand,
> readpages() is only used for for preallocation reads (so it's not
> _quite_ as performance critical) and as an indication, XFS, which
> tends to be highly performance sensitive, is using mpage_readpages()
> without worrying too much about this issue.

Sorry, This is not related to the "bio post processing" topic. 
do_mpage_readpages() has the following,

		if (block_in_file < last_block) {
			map_bh->b_size = (last_block-block_in_file) << blkbits;
			if (get_block(inode, block_in_file, map_bh, 0))
				goto confused;
			*first_logical_block = block_in_file;
		}

So ext4_get_block() would have been invoked for mapping over a range that is
larger than a block. do_mpage_readpages() would continue to use this
mapping without invoking get_block() callback until it has exhausted all the 
mapped blocks.

> 
> The bottom line is that there is a large set of engineering tradeoffsh
> to be made here, which is why we should talk about the approach first.
> It may be there are people who can emit large amounts of perfectly
> designed code all at once at high speed (perhaps like Mozart, who once
> compared is musical composition process to vomiting, to the point
> where he was bottlenecked on the speed that he could write notes on
> staff paper), but I'm not smart enough to do that.  For code this
> complex, doing some design ahead of time is a good thing.  :-)
> 
> > Relying on bio->bi_private to check for requirement of post processing steps
> > does not seem to be correct. AFAIK (please correct me if I am wrong) the
> > convention is that bi_private field is owned by the code that allocates the
> > bio and the owner can assign its own value to this field.
> 
> Well, there is precedence for common code creating a convention for
> using a private field.  For example, page_buffers() uses
> page->private.  If a page belongs to a user such as a file system,
> it's up the owner to decide how to use the private field, that's true.
> However, if it uses fs/mpage.c, fs/mpage.c does use page_buffers(), so
> a file system which uses mpage_readpages() has to allow page->private
> to be used according to the page_buffers convention.
> 
> If we try to use bio->bi_private for fscrypt and fsveirty, *and* we
> want to fold this support into common code like fs/mpage.c --- we're
> probably OK, since at the moment, the fs/mpage.c code:
> 
>    * creates the bio
>    * submits the bio
>    * handles the bio completion handling
> 
> There is no way callers of mpage_readpage() and mpage_readpages() can
> override how the bio is created (and hence control setting bi_private)
> nor can they provide a bio completion handler (which could consume the
> bi_private) field.

I am diverging a bit here (since it was decided that we will get the "bio post
processing" working for blocksize == pagesize first). W.r.t
block_read_full_page(), we will have a 'struct buffer_head *'
assigned to bio->bi_private and hence the condition to check for if "bio
post processing" is required, will incorrectly return true value for such bios.

> 
> > Ideally we should be checking for per-inode encryption/verity flags to decide
> > if any post-processing steps are required to be executed
> 
> At least for fsverity, it can't be a per-inode flag, since whether or
> not verity processing is enabled depends on what part of the inode you
> are reading.  (For example, if you are reading the Merkle tree or the
> verity footer block, that's file metadata which does need verity
> processing.)
> 
> We could make that be handled in the post-processing function, which
> either returns an ERR_PTR, 0 if whatever work it did was done
> immediately and nothing had to be queued on a workqueue, so the
> bio-post-read code should try figure out what is the next
> post-processing function should be called, and then call it, or 1 if
> the work was queued on a workqueue, and so bio-post-read processor
> should exit, since the bio-post-read processing function will be
> called once the workqueue function is done doing its thing.
> 
> I'm not saying that's how we must do things; this is all part of the
> design brainstorming process.  It's a lot easier to throw out possible
> ideas for discussion than to spend days or weeks coding, only to
> discover that it's not the best way forward.  :-)
> 

-- 
chandan
