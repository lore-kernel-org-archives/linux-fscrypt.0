Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57850 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751060AbdFTOoc (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 20 Jun 2017 10:44:32 -0400
Date: Tue, 20 Jun 2017 10:44:23 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [RFC PATCH 0/4] Allow file systems to selectively bypass dm-crypt
Message-ID: <20170620144423.GA22495@redhat.com>
References: <20170614234040.4326-1-mhalcrow@google.com>
 <0b268ff7-5fc8-c85f-a530-82e9844f0400@gmail.com>
 <20170615172450.GA27384@google.com>
 <0df74dd8-f29d-8925-7cc1-783d09c6a42c@gmail.com>
 <20170616184240.GA13904@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616184240.GA13904@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Michael Halcrow <mhalcrow@google.com>
Cc: Milan Broz <gmazyland@gmail.com>, "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, dm-crypt <dm-crypt@saout.de>, dm-devel@redhat.com, linux-block@vger.kernel.org, Tyler Hicks <tyler.hicks@canonical.com>, linux-fscrypt@vger.kernel.org, "Daniel P. Berrange" <berrange@redhat.com>, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jun 16 2017 at  2:42pm -0400,
Michael Halcrow <mhalcrow@google.com> wrote:

> On Thu, Jun 15, 2017 at 08:17:02PM +0200, Milan Broz wrote:
> > On 06/15/2017 07:24 PM, Michael Halcrow wrote:
> > ...
> > >> If this is accepted, we basically allow attacker to trick system to
> > >> write plaintext to media just by setting this flag. This must never
> > >> ever happen with FDE - BY DESIGN.
> > > 
> > > That's an important point.  This expands the attack surface to include
> > > the file system, so if an adversary can provide a bad encryption key
> > > or policy at the file system layer or if there's a bug in the file
> > > system that an adversary can exploit, then users setting the
> > > allow_encrypt_override option on dmcrypt would be vulnerable.
> > > 
> > >> For me, ABSOLUTE NACK to this approach.
> > > 
> > > I can understand where you're coming from.  Given our challenges on
> > > mobile, do you have any suggestions for an alternative approach?
> > 
> > Well, what I really do not like here that you are solving problem
> > of missing properly designed cryptographic filesystem by hacking
> > some layers together that were not designed to it.
> 
> Agreed.  I enthusiastically withdraw this proposal.
> 
> I think I'm instead going to look into proposing something new in the
> block layer to address performance concerns with file system
> encryption and inline cryptographic engine support.

As should have been done from the start.  The emergence of ICE support
for mobile/embedded platforms should result in a properly designed
solution to enable dm-crypt to leverage them (easier said than done!).
And if only certain files need to be encrypted then dm-crypt may or may
not be configured in the stack.

> > It would better to go with some model that actually increases security.
> > 
> > For example, if your patch marks IO operation that comes from fs as
> > REQ_NOENCRYPT, could fs send some metadata information in bio of
> > owner (user, translated to key id) instead and encrypt the sector
> > with a different key?
> 
> I really like this idea.  However because users can access the dmcrypt
> device without the file system, I wouldn't want to try to do it
> without dmcrypt maintaining additional metadata about which keys
> protect which blocks.  Even then, the user directly accessing the
> dmcrypt device would be surprised when dmcrypt returns EIO because it
> doesn't have a key for the blocks at offsets 42 and 128.
> 
> At this point I do think something new at the block layer for file
> system managed encryption and inline cryptographic engine support will
> be necessary.

Yes.
