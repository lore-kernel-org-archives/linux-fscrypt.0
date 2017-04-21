Return-Path: <ebiggers3@gmail.com>
Date: Fri, 21 Apr 2017 12:26:25 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: use 32 bytes of encrypted filename
Message-ID: <20170421192625.GD12755@gmail.com>
References: <20170418210642.6039-1-gwendal@chromium.org>
 <20170418230136.GA96152@gmail.com>
 <20170419001005.GA143911@gmail.com>
 <20170419014209.GB12215@jaegeuk.local>
 <20170419040138.GA563@zzz>
 <20170419204448.GA1021@jaegeuk.local>
 <20170421074402.GA7459@zzz>
 <20170421173503.GA1228@jaegeuk.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170421173503.GA1228@jaegeuk.local>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, ebiggers@google.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-mtd@lists.infradead.org, tytso@mit.edu, linux-ext4@vger.kernel.org, kinaba@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jaegeuk,

On Fri, Apr 21, 2017 at 10:35:03AM -0700, Jaegeuk Kim wrote:
> 
> > In any case, I guess that unless there are other ideas we can do these patches:
> > 
> > 1.) f2fs patch to start checking the name, as above
> > 2.) patch to start encoding last 32 bytes of the name (or second-to-last CTS
> >     block, I haven't decided yet) rather than last 16 bytes, changing
> >     fs/crypto/, fs/ext4/, and fs/f2fs/
> > 3.) cleanup patches to introduce helper function and switch ext4 and f2fs to it
> 
> IMO, it'd better to do 3.) followed by 2.), since 2.) already needs to change
> fs/crypto which does not give much backporting effort.
> 

That would be ideal, but unfortunately the main users of filesystem encryption
are using old kernel versions which don't have fs/crypto/, usually 4.4 at
latest.  So it would be nice for it to be easier to backport the "use different
bytes from the encrypted filename" change to 4.4-stable, as I've been doing for
some of the other filesystem encryption fixes.  And people do need it, it seems,
as it causes real problems like undeletable files; Gwendal is even already
trying to merge a fix into some Chrome OS kernel.

> 
> I found one issue in my patch and modified it in f2fs tree [1]. Given next merge
> window probable starting next week, let me upstream this modified one first
> through f2fs. Then, you can see it in 4.12-rc1 two weeks later, so fscrypt
> patches can be easily integrated after then. If you have any concern, I'm also
> okay to push this patch through fscrypt. Let me know.
> 
> [1] https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs.git/commit/?h=dev-test&id=1585cfbbb269be6a112e0629a52123c0f9eaf4fa
> 

I think the series through fscrypt makes more sense, though if I don't have it
ready soon please go ahead and take the f2fs portion through the f2fs tree.

Thanks!

- Eric
