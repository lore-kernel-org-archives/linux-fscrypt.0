Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34387 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdFPSmn (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 16 Jun 2017 14:42:43 -0400
Received: by mail-pg0-f46.google.com with SMTP id v18so23833223pgb.1
        for <linux-fscrypt@vger.kernel.org>; Fri, 16 Jun 2017 11:42:43 -0700 (PDT)
Date: Fri, 16 Jun 2017 11:42:40 -0700
From: Michael Halcrow <mhalcrow@google.com>
Subject: Re: [RFC PATCH 0/4] Allow file systems to selectively bypass dm-crypt
Message-ID: <20170616184240.GA13904@google.com>
References: <20170614234040.4326-1-mhalcrow@google.com>
 <0b268ff7-5fc8-c85f-a530-82e9844f0400@gmail.com>
 <20170615172450.GA27384@google.com>
 <0df74dd8-f29d-8925-7cc1-783d09c6a42c@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0df74dd8-f29d-8925-7cc1-783d09c6a42c@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Milan Broz <gmazyland@gmail.com>
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, dm-devel@redhat.com, linux-ext4@vger.kernel.org, Tyler Hicks <tyler.hicks@canonical.com>, dm-crypt <dm-crypt@saout.de>, "Daniel P. Berrange" <berrange@redhat.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 15, 2017 at 08:17:02PM +0200, Milan Broz wrote:
> On 06/15/2017 07:24 PM, Michael Halcrow wrote:
> ...
> >> If this is accepted, we basically allow attacker to trick system to
> >> write plaintext to media just by setting this flag. This must never
> >> ever happen with FDE - BY DESIGN.
> > 
> > That's an important point.  This expands the attack surface to include
> > the file system, so if an adversary can provide a bad encryption key
> > or policy at the file system layer or if there's a bug in the file
> > system that an adversary can exploit, then users setting the
> > allow_encrypt_override option on dmcrypt would be vulnerable.
> > 
> >> For me, ABSOLUTE NACK to this approach.
> > 
> > I can understand where you're coming from.  Given our challenges on
> > mobile, do you have any suggestions for an alternative approach?
> 
> Well, what I really do not like here that you are solving problem
> of missing properly designed cryptographic filesystem by hacking
> some layers together that were not designed to it.

Agreed.  I enthusiastically withdraw this proposal.

I think I'm instead going to look into proposing something new in the
block layer to address performance concerns with file system
encryption and inline cryptographic engine support.

> Obvious solution is to implement encryption in fs properly and encrypt
> fs metadata there. I guess this is your long term goal?

My long-term goal is to delegate all encryption to the block layer,
with the file system indicating which keys should encrypt which
blocks.  Given your concerns along with the backup/restore scenario
that Daniel Barrange pointed out, I'm convinced dmcrypt is not the
right place to do that.  At least not without more substantial
modifications to dmcrypt, and I would rather leave dmcrypt's behavior
as boring and predictable as possible.

> Is the double encryption really such a big problem?  With some hw
> support it should not cost much time and energy.  Do you have some
> numbers to show that is it real problem?

We have run numbers on several devices to measure the perf impact of
storage encryption, and it's a big enough on some of the lower-end
devices to threaten the ability to ship with storage encryption
enabled by default.

> What I am missing here is the definition of your threat model.

The original design document has some details regarding the threat
model for file system-level encryption, but there's a lot more the
story as you factor in how various approaches to storage encryption
impact device behavior.

https://docs.google.com/document/d/1ft26lUQyuSpiu6VleP70_npaWdRfXFoNnB8JYnykNTg/preview

> If the encryption of metadata in block layer is ok for you, why it
> is not ok for the data?

In short, because there are classes of data and classes of
adversaries.

The longer answer to that question also brings up how keys are managed
and protected across a spectrum of devices with a variety of hardware
capabilities.

Ideally, it would be impossible for an adversary to access any
plaintext at all without the user's credentials.  However, for the
vast majority of users a device needs to be able to boot and be
minimally functional without the user authenticating on the device --
think of a device rebooting in the middle of the night, and then its
alarm doesn't go off in the morning because it's stuck on a screen
asking for a pin.  Incoming phone calls don't go through.  That's a
recipe for encryption being disabled by default.

While a user might not care whether someone with enough resources to
mount a hardware attack can find out that that their alarm is set for
6:45am or that the directory structure reveals that they have a
particular app installed, they might care if a sophisticated and
well-funded adversary can read the contents of their email or their
location history without the user authenticating with "something they
know."

Meanwhile, if the key that protects metadata is locked in a secure
hardware element, a non-trivial number adversaries can be effectively
locked out from discovering anything at all simply because of the
costs associated with compromising the key.  This protection is
worthwhile.

> What are you solving there? Is it that one user must not see other users data?
> (And who is an user on a mobile device - an application in own sandbox?)
> 
> Because the confidentiality in the case of stolen device is there with
> encryption on any layer. And ext4 encryption uses the same algorithms
> as dmcrypt IIRC.
> 
> It would better to go with some model that actually increases security.
> 
> For example, if your patch marks IO operation that comes from fs as
> REQ_NOENCRYPT, could fs send some metadata information in bio of
> owner (user, translated to key id) instead and encrypt the sector
> with a different key?

I really like this idea.  However because users can access the dmcrypt
device without the file system, I wouldn't want to try to do it
without dmcrypt maintaining additional metadata about which keys
protect which blocks.  Even then, the user directly accessing the
dmcrypt device would be surprised when dmcrypt returns EIO because it
doesn't have a key for the blocks at offsets 42 and 128.

At this point I do think something new at the block layer for file
system managed encryption and inline cryptographic engine support will
be necessary.

> I am not sure how complicated this would be to implement but we have already
> concept of multiple keys in dmcrypt (there is 64 keys for loopAES mapping
> and the used key id is calculated as sector# modulo 64).
> 
> Maybe the keys can be taken from kernel keyring and loaded dynamically,
> according to optional table parameters that defines policy for it.
> The IV could be shared (in XTS mode it is not a problem).
> If the key is not available, the bio should simply fail early.
> 
> Dunno, just an idea - it really depends what are you trying to solve.
> 
> Milan
