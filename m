Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V3 07/12] mpage_readpage[s]: Introduce post process callback parameters
Date: Wed, 30 May 2018 08:39:11 +0530
In-Reply-To: <20180529175317.GB166256@gmail.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com> <1832647.byIzkSnT1k@localhost.localdomain> <20180529175317.GB166256@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2745869.vkToJMq4hA@localhost.localdomain>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tuesday, May 29, 2018 11:23:17 PM IST Eric Biggers wrote:
> Hi Chandan,
> 
> On Tue, May 29, 2018 at 08:34:21AM +0530, Chandan Rajendra wrote:
> > On Tuesday, May 29, 2018 1:04:37 AM IST Theodore Y. Ts'o wrote:
> > > On Mon, May 28, 2018 at 11:05:52AM +0530, Chandan Rajendra wrote:
> > > > > Can you describe more of what you are doing here; specifically, you
> > > > > deleted all of fs/ext4/readpage.c --- was this because you moved
> > > > > functionality back into fs/mpage.c?  Did you make sure all of the
> > > > > local changes in fs/ext4/readpage was moved back to fs/mpage.c?
> > > > > 
> > > > > If the goal is to refactor code to remove the need for
> > > > > fs/ext4/readpage.c, you should probably make that be the first patch
> > > > > as a prerequisite patch.  And we then need to make sure we don't
> > > > > accidentally break anyone else who might be using fs/mpage.c.  Saying
> > > > > a bit more about why you think the refactor is a good thing would also
> > > > > be useful.
> > > > 
> > > > I will split this patch into two as suggested by you. Also, I will update 
> > > > the commit messages.
> > > 
> > > Note that I was planning on making changes to fs/ext4/readpage.c as
> > > part of integrating fsverity[1][2] support into ext4.  Basically, I
> > > need to do something like [3] to fs/ext4/readpage.c.
> > > 
> > > [1] https://www.spinics.net/lists/linux-fsdevel/msg121182.html
> > > [2] https://www.youtube.com/watch?v=GlEWcVuRbNA
> > > [3] https://git.kernel.org/pub/scm/linux/kernel/git/mhalcrow/linux.git/commit/?h=fs-verity-dev&id=827faba05972517f49fa2f2aaf272150f5766af2
> > > 
> > > Which is why I'm really interested in your reasoning for why you
> > > propose to drop fs/ext4/readpage.c.  :-)
> > > 
> > 
> > The first patchset to support encryption in subpage-blocksize scenario copied
> > the block_read_full_page() from fs/buffer.c to ext4/readpage.c and had made
> > changes required to support encryption in that function. However, the
> > conclusion was to not create copies of existing code but rather add support
> > for decryption inside generic mpage_readpage[s] functions. Hence this patchset
> > implements the required decryption logic in the generic mpage_readpage[s]
> > functions. Since this makes the code in ext4/readpage.c redundant, I had
> > decided to delete the ext4/readpage.c.
> > 
> 
> Strictly speaking, I don't think anything has been "concluded" yet.  The issue,
> as I saw it, was that your original patchset just copy-and-pasted lots more
> generic code from fs/buffer.c into ext4, without consideration of alternatives
> that would allow the code to be shared, such as adding a postprocessing callback
> to mpage_readpage{,s}().  My hope was that you would thoughtfully consider the
> alternatives and make a decision of what was the best solution, and then explain
> that decision as part of your patchset -- not just implement some solution
> without much explanation, which makes it very difficult for people to decide
> whether it's the best solution or not.
> 
> And yes, now that fs-verity is planned to be a thing too, we should stop
> thinking of the problem as specifically "how to support decryption", but rather
> how to support the ability to post-process the data using potentially multiple
> length-preserving postprocessing steps such as decryption,
> integrity/authenticity verification, etc.
> 
> I'll take a closer look at this patch when I have a chance, but as Ted pointed
> out it really needs to be split out into multiple patches.  Just as a
> preliminary comment, it looks like you are directly calling into fs/crypto/ from
> fs/buffer.c, e.g. fscrypt_enqueue_decrypt_bio().  I don't understand that.  If
> you're doing that (which would start requiring that fscrypt be built-in, not
> modular) then there should be no need for the filesystem to pass a
> postprocessing callback to the generic code, as you could just check
> S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode) in generic code to tell whether
> decryption needs to be done.  The whole point of the postprocessing callback
> would be to allow the generic read code to be used without it having to be aware
> of all the specific types of post-read processing that filesystems may want.

Hi Eric,

I had misunderstood the requirement. Sorry about that. I had written the
patchset in its current form with the understanding that fs/buffer.c and
fs/ext4/*.c would need to get compiled even when fscrypt code isn't compiled
at all. When the fscrypt module isn't selected for build in the kernel config,
calls to fscrypt_*() functions would end up calling the equivalent nop
functions in fscrypt_notsupp.h file.

For the generic code to be completely unaware of several stages of "post
processing" functionality, I would most likely have to add more callback
pointers into the newly introduced "struct post_process_read" structure. I
will work on this and post the results in the next version of the patchset.


-- 
chandan
