Return-Path: <ebiggers3@gmail.com>
Date: Mon, 21 Aug 2017 20:07:30 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
Message-ID: <20170822030730.GB3577@zzz.localdomain>
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9dcef6c6-a758-ea57-0d51-55f33e365931@oracle.com>
 <20170821230821.GB8847@gmail.com>
 <7a34337d-3214-0a8a-5521-7727364cceb4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7a34337d-3214-0a8a-5521-7727364cceb4@oracle.com>
To: Anand Jain <anand.jain@oracle.com>
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Aug 22, 2017 at 10:22:13AM +0800, Anand Jain wrote:
> 
> 
> 
> > > > +fscrypt is not guaranteed to protect confidentiality or authenticity
> > > > +if an attacker is able to manipulate the filesystem offline prior to
> > > > +an authorized user later accessing the filesystem.
> > > 
> > >   How does fscrypt / Android protect against Evil Maid attack. ?
> 
> > _However_, an "Evil Maid" attacker can probably still do other, perhaps much
> > more effective attacks --- e.g.
> ::
> > .  Or they could attack the actual
> > file contents encryption which is not authenticated.  Or they could mess around
> > with filesystem metadata on the userdata partition, which is neither encrypted
> > nor authenticated.
> 
>   In specific, the scenario I had in mind was the above threat.
> 
> > I suppose that dm-integrity could be used to protect against some of those
> > attacks, but of course it would not protect against hardware key loggers, etc.
> 
>   OK.
> 
> 
>   I think AE is the only good solution for this, File-name encryption at
> this stage won't solve any kind of Evil Maid attack, (as it was quoted
> somewhere else in ML).
> 
> 
>  Further, below,  is define but not used.
> -----
>  #define FS_AES_256_GCM_KEY_SIZE		32
> -----
> 

Yes, authenticated encryption with AES-256-GCM was in an older version of the
ext4 encryption design document.  But unfortunately it was never really thought
through.  The primary problem, even ignoring rollback protection, is that there
is nowhere to store the per-block metadata (GCM authentication tag and IV) *and*
have it updated atomicly with the block contents.  Recently, dm-integrity solves
this at the block device layer, but it uses data journaling which is very
inefficient.  This maybe could be implemented more efficiently on a COW
filesystem like BTRFS.  But even after that, another problem is that
authenticated encryption of file contents only would not stop an attacker from
swapping around blocks, files, directories, or creating links, etc.

Eric
