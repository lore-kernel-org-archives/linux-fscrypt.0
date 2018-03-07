Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:6161 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933100AbeCGClF (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 6 Mar 2018 21:41:05 -0500
Subject: Re: [RFC PATCH v3] f2fs: introduce F2FS_FEATURE_LOST_FOUND feature
References: <20180306033904.122540-1-shengyong1@huawei.com>
 <20180306193831.GA166451@google.com>
From: Sheng Yong <shengyong1@huawei.com>
Message-ID: <2e812500-42a1-4963-f938-6f3d2ece4789@huawei.com>
Date: Wed, 7 Mar 2018 10:40:36 +0800
MIME-Version: 1.0
In-Reply-To: <20180306193831.GA166451@google.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: jaegeuk@kernel.org, yuchao0@huawei.com, miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi, Eric

On 2018/3/7 3:38, Eric Biggers wrote:
> [+Cc linux-fscrypt]
> 
> Hi Sheng,
> 
> On Tue, Mar 06, 2018 at 11:39:04AM +0800, Sheng Yong wrote:
>> This patch introduces a new feature, F2FS_FEATURE_LOST_FOUND, which
>> is set by mkfs. It creates a directory named lost+found, which saves
>> unreachable files. If fsck finds a file which has no parent, or its
>> parent is removed by fsck, the file will be placed under lost+found
>> directory by fsck.
>>
>> lost+found directory could not be encrypted. As a result, the root
>> directory cannot be encrypted too. So if LOST_FOUND feature is enabled,
>> let's avoid to encrypt root directory.
>>
>> This patch also introduces a new mount option `test_dummy_encryption'
>> to allow fscrypt to create a fake fscrypt context. This is used by
>> xfstests.
> 
> It would be a bit easier to review if this was split into 2 patches:
> 
> 1. Add LOST_FOUND feature
> 2. Add test_dummy_encryption mount option
> 
Thanks for your review, I'll split this into 2 patches.

>> diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
>> index 797eb05cb538..7f908be8d525 100644
>> --- a/fs/f2fs/dir.c
>> +++ b/fs/f2fs/dir.c
>> @@ -361,6 +361,7 @@ struct page *init_inode_metadata(struct inode *inode, struct inode *dir,
>>   			struct page *dpage)
>>   {
>>   	struct page *page;
>> +	int encrypt = DUMMY_ENCRYPTION_ENABLED(F2FS_I_SB(dir));
>>   	int err;
>>   
>>   	if (is_inode_flag_set(inode, FI_NEW_INODE)) {
>> @@ -387,7 +388,8 @@ struct page *init_inode_metadata(struct inode *inode, struct inode *dir,
>>   		if (err)
>>   			goto put_error;
>>   
>> -		if (f2fs_encrypted_inode(dir) && f2fs_may_encrypt(inode)) {
>> +		if ((f2fs_encrypted_inode(dir) || encrypt) &&
>> +					f2fs_may_encrypt(inode)) {
>>   			err = fscrypt_inherit_context(dir, inode, page, false);
>>   			if (err)
>>   				goto put_error;
>> @@ -402,7 +404,7 @@ struct page *init_inode_metadata(struct inode *inode, struct inode *dir,
>>   
>>   	if (new_name) {
>>   		init_dent_inode(new_name, page);
>> -		if (f2fs_encrypted_inode(dir))
>> +		if (f2fs_encrypted_inode(dir) || encrypt)
>>   			file_set_enc_name(inode);
>>   	}
>>   
> 
> 'enc_name' should only be set if the parent directory is encrypted, right?  So
> the condition for file_set_enc_name() should stay 'f2fs_encrypted_inode(dir)'.

Right, should not set enc_name here :)

> 
>> diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
>> @@ -719,6 +721,18 @@ static int parse_options(struct super_block *sb, char *options)
>>   			}
>>   			kfree(name);
>>   			break;
>> +#ifdef CONFIG_F2FS_FS_ENCRYPTION
>> +		case Opt_test_dummy_encryption:
>> +			sbi->mount_flags |= F2FS_MF_TEST_DUMMY_ENCRYPTION;
>> +			f2fs_msg(sb, KERN_INFO,
>> +					"Test dummy encryption mode enabled");
>> +			break;
>> +#else
>> +		case Opt_test_dummy_encryption:
>> +			f2fs_msg(sb, KERN_INFO,
>> +					"Test dummy encryption mount option ignored");
>> +			break;
>> +#endif
> 
> You could write the 'case Opt_test_dummy_encryption:" and break just once, and
> put the #ifdef inside it.
> 
>> @@ -2696,6 +2732,12 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
>>   		}
>>   	}
>>   
>> +	if (DUMMY_ENCRYPTION_ENABLED(sbi) && !f2fs_readonly(sb) &&
>> +				!f2fs_sb_has_encrypt(sb)) {
>> +		f2fs_sb_set_encrypt(sb);
>> +		recovery = 1;
>> +	}
>> +
> [...]
>>   	/* get an inode for meta space */
>>   	sbi->meta_inode = f2fs_iget(sb, F2FS_META_INO(sbi));
>>   	if (IS_ERR(sbi->meta_inode)) {
>> @@ -2870,12 +2912,16 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
>>   	}
>>   	kfree(options);
>>   
>> -	/* recover broken superblock */
>> +	/* recover broken superblock or enable encrypt feature */
>>   	if (recovery) {
>> -		err = f2fs_commit_super(sbi, true);
>> -		f2fs_msg(sb, KERN_INFO,
>> -			"Try to recover %dth superblock, ret: %d",
>> -			sbi->valid_super_block ? 1 : 2, err);
>> +		if (sbi->mount_flags & F2FS_MF_TEST_DUMMY_ENCRYPTION) {
>> +			f2fs_commit_super(sbi, false);
>> +		} else {
>> +			err = f2fs_commit_super(sbi, true);
>> +			f2fs_msg(sb, KERN_INFO,
>> +				"Try to recover %dth superblock, ret: %d",
>> +				sbi->valid_super_block ? 1 : 2, err);
>> +		}
>>   	}
> 
> How about just not allowing mounting with test_dummy_encryption if the 'encrypt'
> feature flag isn't already set?  That would be simpler.  I think it was a
> mistake that ext4 automatically turns the 'encrypt' flag on when
> test_dummy_encryption is specified.
> 
OK. It's better to keep ext4 and f2fs behave the same way. I'll fix this in
next version.

thanks,
Sheng

> - Eric
> 
> .
> 

