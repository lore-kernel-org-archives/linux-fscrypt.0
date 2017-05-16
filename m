Return-Path: <richard@nod.at>
Subject: Re: Question on fscrypt_d_revalidate() and fstest generic/429
References: <e2d845a3-a863-1506-a0de-576049c84e81@nod.at>
 <20170515194553.GA20264@gmail.com>
 <489e1437-990f-3e88-d426-b47b82441009@nod.at>
 <20170515232556.GA46783@gmail.com>
From: Richard Weinberger <richard@nod.at>
Message-ID: <fbf20418-0819-b980-7b68-089e0d1c3d18@nod.at>
Date: Tue, 16 May 2017 08:47:43 +0200
MIME-Version: 1.0
In-Reply-To: <20170515232556.GA46783@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, David Gstir <david@sigma-star.at>, David Oberhollenzer <david.oberhollenzer@sigma-star.at>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Eric,

Am 16.05.2017 um 01:25 schrieb Eric Biggers:
> On Mon, May 15, 2017 at 09:51:03PM +0200, Richard Weinberger wrote:
>>>
>>> The test is repeatedly creating and removing a directory "dir" while lookups are
>>> being done in it.  It seems the problem is that many dentries are being created
>>> for "dir", and they pin many different inodes, all at the same time.  This
>>> actually happens for ext4 too; it just doesn't cause an observable error.
>>>
>>> I doubt it's the right solution to make fscrypt_d_revalidate() look at
>>> ->i_nlink, since ->d_revalidate() is meant to validate the filename, not the
>>> inode.  I think there is probably a VFS bug that is causing the dentries to not
>>> be freed.
>>
>> Not sure. Al? :-)
>>
> 
> I can reproduce this on an unencrypted directory after updating path_init() in
> fs/namei.c to always clear LOOKUP_RCU, so that all path lookups are done in
> ref-walk mode.  So I think fscrypt_d_revalidate() was only relevant because it
> causes all path lookups to drop out of rcu-walk mode.

On ext4 or UBIFS?

Thanks,
//richard
