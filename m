Return-Path: <SRS0=uzTQ=LI=thunk.org=tytso@kernel.org>
Date: Sat, 25 Aug 2018 13:06:24 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH 02/10] fs-verity: add data verification hooks for
 ->readpages()
Message-ID: <20180825170624.GB10619@thunk.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-3-ebiggers@kernel.org>
 <2f2382c3-e5e9-f0da-dc89-42dfc7b2b636@huawei.com>
 <20180825041647.GA726@sol.localdomain>
 <21e86199-28a7-4693-aef5-5fc28842535c@huawei.com>
 <20180825071827.GD726@sol.localdomain>
 <c907ad1d-c7c8-714a-0e59-373c1df3afe8@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c907ad1d-c7c8-714a-0e59-373c1df3afe8@huawei.com>
To: Gao Xiang <gaoxiang25@huawei.com>
Cc: Eric Biggers <ebiggers@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Aug 25, 2018 at 03:43:43PM +0800, Gao Xiang wrote:
> > I don't know of any plan to use fs-verity on Android's system partition or to
> > replace dm-verity on the system partition.  The use cases so far have been
> > verifying files on /data, like APK files.
> > 
> > So I don't think you need to support fs-verity in EROFS.
> 
> Thanks for your information about fs-verity, that is quite useful for us
> Actually, I was worrying about that these months...  :)

I'll be even clearer --- I can't *imagine* any situation where it
would make sense to use fs-verity on the Android system partition.
Remember, for OTA to work the system image has to be bit-for-bit
identical to the official golden image for that release.  So the
system image has to be completely locked down from any modification
(to data or metadata), and that means dm-verity and *NOT* fs-verity.

The initial use of fs-verity (as you can see if you look at AOSP) will
be to protect a small number of privileged APK's that are stored on
the data partition.  Previously, they were verified when they were
downloaded, and never again.

Part of the goal which we are trying to achieve here is that even if
the kernel gets compromised by a 0-day, a successful reboot should
restore the system to a known state.  That is, the secure bootloader
checks the signature of the kernel, and then in turn, dm-verity will
verify the root Merkle hash protecting the system partition, and
fs-verity will protect the privileged APK's.  If malware modifies any
these components in an attempt to be persistent, the modifications
would be detected, and the worst it could do is to cause subsequent
reboots to fail until the phone's software could be reflashed.

Cheers,

					- Ted
