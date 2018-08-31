Return-Path: <SRS0=D+0f=LO=vger.kernel.org=linux-integrity-owner@kernel.org>
Date: Fri, 31 Aug 2018 14:39:08 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 00/10] fs-verity: filesystem-level integrity
 protection
Message-ID: <20180831213907.GA212813@gmail.com>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <1535745923.25742.1.camel@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1535745923.25742.1.camel@pengutronix.de>
Sender: linux-integrity-owner@vger.kernel.org
To: Jan =?iso-8859-1?Q?L=FCbbe?= <jlu@pengutronix.de>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jan,

On Fri, Aug 31, 2018 at 10:05:23PM +0200, Jan L�bbe wrote:
> On Fri, 2018-08-24 at 09:16 -0700, Eric Biggers wrote:
> [...]
> > Since fs-verity provides the Merkle tree root hash in constant time and
> > verifies data blocks on-demand, it is useful for efficiently verifying
> > the authenticity of, or "appraising", large files of which only a small
> > portion may be accessed -- such as Android application (APK) files.��It
> > can also be useful in "audit" use cases where file hashes are logged.
> > fs-verity also provides better protection against malicious disk
> > firmware than an ahead-of-time hash, since fs-verity re-verifies data
> > each time it's paged in.
> [...]
> > Feedback on the design and implementation is greatly appreciated.
> 
> Hi,
> 
> I've looked at the series and the slides linked form the recent lwn.net
> article, but I'm not sure how fs-verity intends to protect against
> malicious firmware (or offline modification). Similar to IMA/EVM, fs-
> verity doesn't seem to include the name/location of the file into it's
> verification. So the firmware/an attacker could replace one fs-verity-
> protected file with another (maybe a trusted system APK with another
> one for which a vulnerability was discovered, or /sbin/init with
> /bin/sh).
> 
> Is the expected root hash of the file provided from somewhere else, so
> this is not a problem on Android? Or is this problem out-of-scope for
> fs-verity?
> 
> For IMA/EVM, there were patches by Dmitry to address this class of
> attacks (they were not merged, though):
> https://lwn.net/Articles/574221/
> 
> Thanks,
> Jan
> 
> [1] https://events.linuxfoundation.org/wp-content/uploads/2017/11/fs-ve
> rify_Mike-Halcrow_Eric-Biggers.pdf

Well, it's up to the user of fs-verity.

If you know that, say, /bin/sh is supposed to have a fs-verity file measurement
of sha256:01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b, then
you can just check that.

Or, after IMA support is added, users will be able to configure the fs-verity
measurements to go into the IMA measurement log and/or audit log, just regular
file hashes.  Those records include both the file path and hash.

On the other hand, if the policy you want to enforce is just that a particular
file is using fs-verity and that its hash has been signed by a particular key,
then indeed, if there are multiple hashes that were signed with that key, an
attacker can replace the contents with a different signed contents.  But that's
not really fs-verity's fault; it's really the type of policy that the user chose
to use on top of it, as part of their overall system security architecture.

Yes, the initial plan for Android APK verification is to just use that type of
policy, probably using the in-kernel signature verification support included in
patch 07/10.  So it will therefore have that limitation.  Still, it will be a
massive improvement over the status quo where attackers can make arbitrary
changes to APK files post-installation, e.g. to persistently inject arbitrary
malware.

It will also be possible to improve the security properties of APK verification
in the future by doing additional checks, such as optionally including
additional file metadata in the fs-verity measurement (fs-verity's design allows
for this; they can be added as authenticated extensions), or even simply
checking for the correct metadata from trusted userspace code running in the
/system partition.  Or perhaps the trusted userspace code could download the
expected fs-verity measurement of the APK from the app store given the app name.
There are lots of options.  But we have to start somewhere, and fs-verity is a
tool that seems to be needed in any case.

- Eric
