Return-Path: <linux-fsdevel-owner@vger.kernel.org>
Date: Fri, 16 Jun 2017 16:02:40 +0200
From: Arno Wagner <arno@wagner.name>
Subject: Re: [dm-crypt] [RFC PATCH 0/4] Allow file systems to selectively
 bypass dm-crypt
Message-ID: <20170616140240.GA6284@tansi.org>
References: <20170614234040.4326-1-mhalcrow@google.com>
 <0b268ff7-5fc8-c85f-a530-82e9844f0400@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b268ff7-5fc8-c85f-a530-82e9844f0400@gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Milan Broz <gmazyland@gmail.com>
Cc: Michael Halcrow <mhalcrow@google.com>, "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, dm-devel@redhat.com, linux-ext4@vger.kernel.org, Tyler Hicks <tyler.hicks@canonical.com>, dm-crypt <dm-crypt@saout.de>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 15, 2017 at 09:33:39 CEST, Milan Broz wrote:
> On 06/15/2017 01:40 AM, Michael Halcrow wrote:
> > Several file systems either have already implemented encryption or are
> > in the process of doing so.  This addresses usability and storage
> > isolation requirements on mobile devices and in multi-tenant
> > environments.
> >
[...]
> > 
> > Should there be an encryption disable flag?  I'm interested in
> > considering other solutions.
> 
> The whole reason for full disk encryption (FDE) is the it is FULL disk
> encryption.
> 
> If you do not need encryption on dmcrypt level, just do not use it
> by properly configuring storage stack!
> 
> The file-level encryption and dm-crypt encryption can have completely different
> purpose, even one can be authenticated one (providing integrity)
> and second just providing confidentiality.
>
> It is not "redundant" encryption, it is the encryption for different purpose
> on different layer.

I fully agree. And FDE does protect unused space as well and swap.
FDE is for when you need to be sure that nothing unencrypted goes
to the disk (or specific area of the disk, loop-file, etc.) under 
any circumstances. 
 
> IMO what you are proposing is incredible security hack and very ugly
> layer violation.

Indeed. Do _NOT_ do this. It would have to be disabled or patched 
out by anybody that really cares about security. Performance must
not trump security or you lose security. And performance is really
good enough in most cases anyways.

This would also mean that you lose the ability to move a LUKS 
container transparently because it is not self-contained anymore.
That iwould be extremely bad for backups.

> If this is accepted, we basically allow attacker to trick system to write
> plaintext to media just by setting this flag. This must never ever happen
> with FDE - BY DESIGN.

Indeed.
 
> For me, ABSOLUTE NACK to this approach.

Same here. And I do not want to maintain documentation telling
users how to reliably get rid of this "feature". 

Regards,
Arno


> (cc dmcrypt list as well)
> 
> Milan
> 
> 
> > 
> > Michael Halcrow (4):
> >   block: Add bio req flag to disable encryption in block
> >   dm-crypt: Skip encryption of file system-encrypted blocks
> >   ext4: Set the bio REQ_NOENCRYPT flag
> >   f2fs: Set the bio REQ_NOENCRYPT flag
> > 
> >  drivers/md/dm-crypt.c     | 17 +++++++++++++----
> >  fs/crypto/bio.c           |  2 +-
> >  fs/ext4/ext4.h            |  3 +++
> >  fs/ext4/inode.c           | 13 ++++++++-----
> >  fs/ext4/page-io.c         |  5 +++++
> >  fs/ext4/readpage.c        |  3 ++-
> >  fs/f2fs/data.c            | 10 ++++++++--
> >  include/linux/blk_types.h |  2 ++
> >  8 files changed, 42 insertions(+), 13 deletions(-)
> > 
> 
> _______________________________________________
> dm-crypt mailing list
> dm-crypt@saout.de
> http://www.saout.de/mailman/listinfo/dm-crypt

-- 
Arno Wagner,     Dr. sc. techn., Dipl. Inform.,    Email: arno@wagner.name
GnuPG: ID: CB5D9718  FP: 12D6 C03B 1B30 33BB 13CF  B774 E35C 5FA1 CB5D 9718
----
A good decision is based on knowledge and not on numbers. -- Plato

If it's in the news, don't worry about it.  The very definition of 
"news" is "something that hardly ever happens." -- Bruce Schneier
