Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752589AbdFPKeK (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 16 Jun 2017 06:34:10 -0400
Date: Fri, 16 Jun 2017 11:34:01 +0100
From: "Daniel P. Berrange" <berrange@redhat.com>
Subject: Re: [dm-crypt] [RFC PATCH 0/4] Allow file systems to selectively
 bypass dm-crypt
Message-ID: <20170616103401.GD25765@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>
References: <20170614234040.4326-1-mhalcrow@google.com>
 <0b268ff7-5fc8-c85f-a530-82e9844f0400@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <0b268ff7-5fc8-c85f-a530-82e9844f0400@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Milan Broz <gmazyland@gmail.com>
Cc: Michael Halcrow <mhalcrow@google.com>, "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, dm-devel@redhat.com, linux-ext4@vger.kernel.org, Tyler Hicks <tyler.hicks@canonical.com>, dm-crypt <dm-crypt@saout.de>
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
> 
> IMO what you are proposing is incredible security hack and very ugly
> layer violation.

This layering violation will make it very easy for administrators to
accidentally corrupt their data. If they open the LUKS volume, and
then want to do a block device level backup / copy plain text content
to another volume, without involving the filesystem layer. dmcrypt will
be missing the info on which sectors should not be decrypted - it'll
just decrypt everything and thus scramble the data. Worse this data
corruption will be totally invisible until an arbitrary future time
when someone tries to use the backup.

It would also harm portability to other LUKS implementations may not
directly integrate with filesystem drivers in the same way. For
example you can take an existing LUKS volume and export it as a disk
to a virtual machine with QEMU's built-in LUKS support, so the guest
sees plain text directly. You still have a filesystem driver involved
but its impossible to have that communicate with the LUKS driver on
the QEMU host side.

IMHO for this to be viable the LUKS metadata would need to include a
way to maintain a bitmap of which sectors were encrypted & which were
not, so impls can guarantee to do the right thing upon read without
needing help from an external source (which may not exist at time of
read).

Regards,
Daniel
-- 
|: https://berrange.com      -o-    https://www.flickr.com/photos/dberrange :|
|: https://libvirt.org         -o-            https://fstop138.berrange.com :|
|: https://entangle-photo.org    -o-    https://www.instagram.com/dberrange :|
