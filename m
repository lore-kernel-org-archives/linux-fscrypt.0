Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35763 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdFORYx (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 15 Jun 2017 13:24:53 -0400
Received: by mail-pf0-f173.google.com with SMTP id l89so10368154pfi.2
        for <linux-fscrypt@vger.kernel.org>; Thu, 15 Jun 2017 10:24:52 -0700 (PDT)
Date: Thu, 15 Jun 2017 10:24:50 -0700
From: Michael Halcrow <mhalcrow@google.com>
Subject: Re: [RFC PATCH 0/4] Allow file systems to selectively bypass dm-crypt
Message-ID: <20170615172450.GA27384@google.com>
References: <20170614234040.4326-1-mhalcrow@google.com>
 <0b268ff7-5fc8-c85f-a530-82e9844f0400@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b268ff7-5fc8-c85f-a530-82e9844f0400@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Milan Broz <gmazyland@gmail.com>
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, dm-devel@redhat.com, linux-ext4@vger.kernel.org, Tyler Hicks <tyler.hicks@canonical.com>, dm-crypt <dm-crypt@saout.de>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 15, 2017 at 09:33:39AM +0200, Milan Broz wrote:
> On 06/15/2017 01:40 AM, Michael Halcrow wrote:
> > Several file systems either have already implemented encryption or are
> > in the process of doing so.  This addresses usability and storage
> > isolation requirements on mobile devices and in multi-tenant
> > environments.
> > 
> > While distinct keys locked down to user accounts protect the names and
> > contents of individual files, a volume-level encryption key should
> > protect the file system metadata.  When using dm-crypt to do this, the
> > blocks that the file system encrypts undergo another round of
> > encryption.  In many contexts this isn't necessary, and it results in
> > decreased performance and increased power consumption.  This
> > discourages users and vendors from taking steps to protect file system
> > metadata in addition to file contents.
> > 
> > This patchset provides a new I/O request flag that suggests to lower
> > layers that encryption may not be necessary because the file system
> > has already done it.  The first patch targets the block subsystem and
> > adds the REQ_NOENCRYPT flag.  The second patch targets dm-crypt and
> > adds logic to observe the flag only when the user has opted-in by
> > passing allow_encrypt_override as one of the optional parameters to
> > the dm-crypt target.  The third patch targets ext4 and sets the
> > REQ_NOENCRYPT flag for blocks it encrypts and decrypts.  The fourth
> > patch does the same for f2fs.
> > 
> > In this patchset I'm proposing that we make dm-crypt's observation of
> > the file system "don't encrypt" request optional, but I'm not sure
> > that's a good tradeoff.  Under the assumption that encryption in
> > upstream file systems is sound, the most common way I expect things
> > can go awry is if the file system keys don't meet security
> > requirements while dm-crypt keys do.  However I'm not convinced that
> > will end up being a widespread problem in practice, and there's a real
> > data corruption concern with making dm-crypt's observation of the flag
> > optional.
> > 
> > The problem is that once dm-crypt observes the flag, it must always
> > continue to do so or dm-crypt might decrypt content that it didn't
> > encrypt.  This can lead to scenarios where a vendor sets the dm-crypt
> > option to observe the "don't encrypt" flag, and then down the road a
> > user follows one of the many online guides to manually recover a
> > dm-crypt partition without setting this new option.
> > 
> > Should there be an encryption disable flag?  I'm interested in
> > considering other solutions.
>
> The whole reason for full disk encryption (FDE) is the it is FULL disk
> encryption.

Milan, I appreciate what dmcrypt is designed to do, and I would
prefer that everyone use it all the time!  I'm just concerned that
vendors, particularly in the mobile space, aren't enabling it to
protect file system metadata because of performance and power
utilization concerns.

> If you do not need encryption on dmcrypt level, just do not use it
> by properly configuring storage stack!

Unless we implement file system metadata encryption in all the file
systems that support file-based encryption, we're going to need
encryption somewhere in the block layer.  How can we do this on mobile
platforms where encrypting twice incurs too high a cost?

> The file-level encryption and dm-crypt encryption can have completely different
> purpose, even one can be authenticated one (providing integrity)
> and second just providing confidentiality.
> 
> It is not "redundant" encryption, it is the encryption for different purpose
> on different layer.
> 
> IMO what you are proposing is incredible security hack and very ugly
> layer violation.

With the advent of inline cryptographic engine (ICE) capability in
more recent hardware, we have a challenging layering problem to
address.  The file system needs to control encryption happening at the
block layer, such as by providing encryption keys for certain sets of
blocks along with initialization vectors.

> If this is accepted, we basically allow attacker to trick system to
> write plaintext to media just by setting this flag. This must never
> ever happen with FDE - BY DESIGN.

That's an important point.  This expands the attack surface to include
the file system, so if an adversary can provide a bad encryption key
or policy at the file system layer or if there's a bug in the file
system that an adversary can exploit, then users setting the
allow_encrypt_override option on dmcrypt would be vulnerable.

> For me, ABSOLUTE NACK to this approach.

I can understand where you're coming from.  Given our challenges on
mobile, do you have any suggestions for an alternative approach?

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
