Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:37862 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752665AbeDQRbY (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 17 Apr 2018 13:31:24 -0400
Received: by mail-pf0-f175.google.com with SMTP id p6so12472889pfn.4
        for <linux-fscrypt@vger.kernel.org>; Tue, 17 Apr 2018 10:31:24 -0700 (PDT)
Date: Tue, 17 Apr 2018 10:31:20 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH 2/2] f2fs: refactor read path to allow multiple
 postprocessing steps
Message-ID: <20180417173120.GA7428@google.com>
References: <20180416193147.104555-1-ebiggers@google.com>
 <20180416193147.104555-3-ebiggers@google.com>
 <20180416221542.GB51421@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180416221542.GB51421@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Michael Halcrow <mhalcrow@google.com>
Cc: linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Victor Hsieh <victorhsieh@google.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Chuck Lever <chuck.lever@oracle.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Michael,

On Mon, Apr 16, 2018 at 03:15:42PM -0700, Michael Halcrow wrote:
> Given recent talk I've seen on potentially applying file-based
> protections in NFS, I think it's worth making some cautionary
> observations at this stage.
> 
> Moxie's Cryptographic Doom Principle is an approachable take on the
> argument that one should verify before performing any other
> cryptographic operations.
> 
> https://moxie.org/blog/the-cryptographic-doom-principle/
> 
> As we consider inline cryptographic engines, this becomes challenging
> because encryption is delegated to the block layer, but authenticity
> still happens at the file system layer.
> 
> That said, the feasibility of applying attacks such as CCA2 against
> file sytem content is in question, depending on the adversarial model
> for the context in which the file system is integrated.  In
> particular, does the model include a MiTM between the kernel and the
> storage?
> 
> The fs-crypt adversarial model explicitly concerns itself only with a
> single point-in-time permanent offline compromise of storage.  I'm not
> aware of any real analysis anyone has done when we're instead dealing
> with storage that can be arbitrarily modified at arbitrary points in
> time.

I feel that your concerns are a bit off-topic for what this patch actually does,
but yes I don't think data confidentiality with fscrypt is guaranteed when an
attacker controls the disk.  And actually, fs-verity won't really change this
because fs-verity will only protect the file contents of immutable files.  It
won't protect filesystem metadata, or of mutable files.  In other words, most
files the user cares about the confidentiality of won't be protected by
fs-verity anyway.

Also, fs-verity will need to authenticate the plaintext (i.e. STEP_VERITY will
come after STEP_DECRYPT) because it may need to authenticate some well known
file, like an APK file that was signed by a certain entity.  But, when combined
with fscrypt, by the design of fscrypt on each device the file will be encrypted
with a unique key, resulting in a unique ciphertext.  The ciphertext is also not
visible to userspace currently so it would not be possible for a userspace tool
to generate the fs-verity metadata.

> 
> Is the user concerned about malicious drive controller firmware?  Will
> the content be transmitted over an insecure network connection?  Will
> the content be otherwise manipulatable by an adversary who can change
> to the backing storage?
> 
> The other caution relates to compress-then-encrypt.  I refer to the
> CRIME and BREACH attacks.
> 
> https://en.wikipedia.org/wiki/CRIME
> 
> https://en.wikipedia.org/wiki/BREACH
> 
> Again, it's context-dependent whether or how attacks like this can
> apply to a file system.  We'll need to be explicit about our
> expectations as we investigate whether or how to use fs-crypt and
> fs-verity capabilities in NFS.  I think this feeds into a discussion
> on efficient protection of file system metadata, but I'll defer to
> some future thread for that.

To be clear, neither f2fs nor NFS actually supports compression yet.  At least
for f2fs it's just a feature that some people want, and *might* be implemented
in the future.  Note that some people will want just compression and others will
want just encryption, so having both features available won't mean that everyone
will use both.  It will need to be discussed at that time how risky combining
them really is and whether it should be allowed or not -- or perhaps allowed but
with a warning explaining the risk.

> >  
> > -static void f2fs_read_end_io(struct bio *bio)
> > +/* postprocessing steps for read bios */
> > +enum bio_post_read_step {
> > +	STEP_INITIAL = 0,
> > +	STEP_DECRYPT,
> > +};
> > +
> > +struct bio_post_read_ctx {
> > +	struct bio *bio;
> > +	struct work_struct work;
> > +	unsigned int cur_step;
> > +	unsigned int enabled_steps;
> 
> What if enabled_steps has gaps?  E.g., 0x09 will be feasible if
> there's compression, encryption, virus signature scanning, and verity.
> I'm don't really see how the cur_step logic can be made to be elegant
> in that case.
> 
> If you start "inital" at 1, then you could collapse these two into
> "pending_steps", setting each bit position to 0 after processing.
> Just a thought.
> 

It will actually work fine.  In bio_post_read_processing(), we'll just fall
through and increment 'cur_step' until we get to the next step.  When there are
many steps we certainly could optimize it to use a bitmask and ffs() to
efficiently find the next step, but for now we are talking about maybe 1-3 steps
only, so I went with what seemed simplest.

Thanks,

Eric
