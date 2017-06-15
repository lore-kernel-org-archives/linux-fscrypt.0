Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36509 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752321AbdFOSRG (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 15 Jun 2017 14:17:06 -0400
Subject: Re: [RFC PATCH 0/4] Allow file systems to selectively bypass dm-crypt
References: <20170614234040.4326-1-mhalcrow@google.com>
 <0b268ff7-5fc8-c85f-a530-82e9844f0400@gmail.com>
 <20170615172450.GA27384@google.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <0df74dd8-f29d-8925-7cc1-783d09c6a42c@gmail.com>
Date: Thu, 15 Jun 2017 20:17:02 +0200
MIME-Version: 1.0
In-Reply-To: <20170615172450.GA27384@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Michael Halcrow <mhalcrow@google.com>
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, dm-devel@redhat.com, linux-ext4@vger.kernel.org, Tyler Hicks <tyler.hicks@canonical.com>, dm-crypt <dm-crypt@saout.de>
List-ID: <linux-fscrypt@vger.kernel.org>

On 06/15/2017 07:24 PM, Michael Halcrow wrote:
...
>> If this is accepted, we basically allow attacker to trick system to
>> write plaintext to media just by setting this flag. This must never
>> ever happen with FDE - BY DESIGN.
> 
> That's an important point.  This expands the attack surface to include
> the file system, so if an adversary can provide a bad encryption key
> or policy at the file system layer or if there's a bug in the file
> system that an adversary can exploit, then users setting the
> allow_encrypt_override option on dmcrypt would be vulnerable.
> 
>> For me, ABSOLUTE NACK to this approach.
> 
> I can understand where you're coming from.  Given our challenges on
> mobile, do you have any suggestions for an alternative approach?

Well, what I really do not like here that you are solving problem
of missing properly designed cryptographic filesystem by hacking
some layers together that were not designed to it.

Obvious solution is to implement encryption in fs properly and encrypt
fs metadata there. I guess this is your long term goal?

Is the double encryption really such a big problem?
With some hw support it should not cost much time and energy.
Do you have some numbers to show that is it real problem?

What I am missing here is the definition of your threat model.

If the encryption of metadata in block layer is ok for you, why it is not
ok for the data?

What are you solving there? Is it that one user must not see other users data?
(And who is an user on a mobile device - an application in own sandbox?)

Because the confidentiality in the case of stolen device is there with
encryption on any layer. And ext4 encryption uses the same algorithms
as dmcrypt IIRC.

It would better to go with some model that actually increases security.

For example, if your patch marks IO operation that comes from fs as REQ_NOENCRYPT,
could fs send some metadata information in bio of owner (user, translated to key id)
instead and encrypt the sector with a different key?

I am not sure how complicated this would be to implement but we have already
concept of multiple keys in dmcrypt (there is 64 keys for loopAES mapping
and the used key id is calculated as sector# modulo 64).

Maybe the keys can be taken from kernel keyring and loaded dynamically,
according to optional table parameters that defines policy for it.
The IV could be shared (in XTS mode it is not a problem).
If the key is not available, the bio should simply fail early.

Dunno, just an idea - it really depends what are you trying to solve.

Milan
