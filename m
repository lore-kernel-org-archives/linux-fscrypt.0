Return-Path: <richard@nod.at>
Subject: Re: Question on fscrypt_d_revalidate() and fstest generic/429
References: <e2d845a3-a863-1506-a0de-576049c84e81@nod.at>
 <20170515194553.GA20264@gmail.com>
From: Richard Weinberger <richard@nod.at>
Message-ID: <489e1437-990f-3e88-d426-b47b82441009@nod.at>
Date: Mon, 15 May 2017 21:51:03 +0200
MIME-Version: 1.0
In-Reply-To: <20170515194553.GA20264@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, David Gstir <david@sigma-star.at>, David Oberhollenzer <david.oberhollenzer@sigma-star.at>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Eric,

Am 15.05.2017 um 21:45 schrieb Eric Biggers:
>> If a directory is encrypted, evict() is not being called although the inode has no
>> users anymore.
>> It turned out evict() is not being called because fscrypt's fscrypt_d_revalidate()
>> function.
>> When I omit fscrypt_set_d_op() in UBIFS code, the test works just fine.
> 
> Well, I assume you mean the t_encrypted_d_revalidate portion of the test.
> generic/429 will still fail overall if you remove fscrypt_set_d_op() --- which
> is expected, since it's testing dentry revalidation after all.

Ah, yes.

>>
>> Can it be that fscrypt_d_revalidate() misses the case of i_nlink being 0?
>> It seem to treat unlinked inodes as already gone and they stay.
>>
>> The following change makes the problem go away here:
>>
>> diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
>> index 6d6eca394d4d..d0c19838e513 100644
>> --- a/fs/crypto/crypto.c
>> +++ b/fs/crypto/crypto.c
>> @@ -327,6 +327,7 @@ EXPORT_SYMBOL(fscrypt_decrypt_page);
>>  static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
>>  {
>>         struct dentry *dir;
>> +       struct inode *inode = d_inode(dentry);
>>         int dir_has_key, cached_with_key;
>>
>>         if (flags & LOOKUP_RCU)
>> @@ -359,6 +360,10 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
>>                         (!cached_with_key && dir_has_key) ||
>>                         (cached_with_key && !dir_has_key))
>>                 return 0;
>> +
>> +       if (!inode || inode->i_nlink == 0)
>> +               return 0;
>> +
>>         return 1;
>>  }
>>
>> Does this change make sense? TBH, I'm not really an expert in this area and it is also
>> not clear to me why you don't see these issue on ext4 or f2fs.
>> Maybe UBIFS' limitations kick in much earlier. ;-)
> 
> The test is repeatedly creating and removing a directory "dir" while lookups are
> being done in it.  It seems the problem is that many dentries are being created
> for "dir", and they pin many different inodes, all at the same time.  This
> actually happens for ext4 too; it just doesn't cause an observable error.
> 
> I doubt it's the right solution to make fscrypt_d_revalidate() look at
> ->i_nlink, since ->d_revalidate() is meant to validate the filename, not the
> inode.  I think there is probably a VFS bug that is causing the dentries to not
> be freed.

Not sure. Al? :-)

Thanks,
//richard
