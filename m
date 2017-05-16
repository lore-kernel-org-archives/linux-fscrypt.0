Return-Path: <richard@nod.at>
Subject: Re: Question on fscrypt_d_revalidate() and fstest generic/429
References: <e2d845a3-a863-1506-a0de-576049c84e81@nod.at>
 <20170515194553.GA20264@gmail.com>
 <489e1437-990f-3e88-d426-b47b82441009@nod.at>
 <20170515232556.GA46783@gmail.com>
 <fbf20418-0819-b980-7b68-089e0d1c3d18@nod.at>
 <20170516220709.GB113464@gmail.com>
From: Richard Weinberger <richard@nod.at>
Message-ID: <76ca65df-8ffb-97b8-50ca-29f22ecf7c34@nod.at>
Date: Wed, 17 May 2017 00:27:44 +0200
MIME-Version: 1.0
In-Reply-To: <20170516220709.GB113464@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, David Gstir <david@sigma-star.at>, David Oberhollenzer <david.oberhollenzer@sigma-star.at>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Eric,

Am 17.05.2017 um 00:07 schrieb Eric Biggers:
>>> I can reproduce this on an unencrypted directory after updating path_init() in
>>> fs/namei.c to always clear LOOKUP_RCU, so that all path lookups are done in
>>> ref-walk mode.  So I think fscrypt_d_revalidate() was only relevant because it
>>> causes all path lookups to drop out of rcu-walk mode.
>>
>> On ext4 or UBIFS?
>
> Both; the inode "leak" isn't filesystem-specific, beyond the fact that UBIFS
> apparently limits the number of inodes on its orphan list while ext4 does not.
> (How do I know it happens on ext4 then?  /proc/slabinfo shows that lots of ext4
> inodes have been allocated, and after an unclean shutdown and remounting, it's
> reported that 50,000+ orphan inodes were deleted.)

UBIFS's orphan list is limited by the size of a LEB (logical erase block).
With nandsim's default settings such a LEB is rather small and can store only
2k orphans.

> There are lots of cases in which path lookups switch from rcu-walk mode into
> ref-walk mode, so the fact that it was being caused by ->d_revalidate() in this
> specific situation isn't really important, IMO.
> 
> I think the actual fix would be something along the lines of making vfs_rmdir()
> unhash any negative child dentries, so that they get "killed" by dput() later.

Thanks,
//richard
