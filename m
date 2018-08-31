Return-Path: <SRS0=Or42=LO=pengutronix.de=jlu@kernel.org>
Message-ID: <1535745923.25742.1.camel@pengutronix.de>
Subject: Re: [RFC PATCH 00/10] fs-verity: filesystem-level integrity
 protection
From: Jan =?ISO-8859-1?Q?L=FCbbe?= <jlu@pengutronix.de>
Reply-To: jlu@pengutronix.de
Date: Fri, 31 Aug 2018 22:05:23 +0200
In-Reply-To: <20180824161642.1144-1-ebiggers@kernel.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
To: Eric Biggers <ebiggers@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 2018-08-24 at 09:16 -0700, Eric Biggers wrote:
[...]
> Since fs-verity provides the Merkle tree root hash in constant time and
> verifies data blocks on-demand, it is useful for efficiently verifying
> the authenticity of, or "appraising", large files of which only a small
> portion may be accessed -- such as Android application (APK) files.  It
> can also be useful in "audit" use cases where file hashes are logged.
> fs-verity also provides better protection against malicious disk
> firmware than an ahead-of-time hash, since fs-verity re-verifies data
> each time it's paged in.
[...]
> Feedback on the design and implementation is greatly appreciated.

Hi,

I've looked at the series and the slides linked form the recent lwn.net
article, but I'm not sure how fs-verity intends to protect against
malicious firmware (or offline modification). Similar to IMA/EVM, fs-
verity doesn't seem to include the name/location of the file into it's
verification. So the firmware/an attacker could replace one fs-verity-
protected file with another (maybe a trusted system APK with another
one for which a vulnerability was discovered, or /sbin/init with
/bin/sh).

Is the expected root hash of the file provided from somewhere else, so
this is not a problem on Android? Or is this problem out-of-scope for
fs-verity?

For IMA/EVM, there were patches by Dmitry to address this class of
attacks (they were not merged, though):
https://lwn.net/Articles/574221/

Thanks,
Jan

[1] https://events.linuxfoundation.org/wp-content/uploads/2017/11/fs-ve
rify_Mike-Halcrow_Eric-Biggers.pdf
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
