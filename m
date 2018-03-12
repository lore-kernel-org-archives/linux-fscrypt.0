Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:6187 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932417AbeCLBNw (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 11 Mar 2018 21:13:52 -0400
Subject: Re: [f2fs-dev] [RFC PATCH v4 2/3] f2fs: introduce a new mount option
 test_dummy_encryption
References: <20180309075312.62357-1-shengyong1@huawei.com>
 <20180309075312.62357-3-shengyong1@huawei.com>
 <854155bc-8a20-89b1-95b3-ac3c66217c9e@kernel.org>
From: Sheng Yong <shengyong1@huawei.com>
Message-ID: <83749420-f06b-29eb-9085-0d801a42b655@huawei.com>
Date: Mon, 12 Mar 2018 09:13:30 +0800
MIME-Version: 1.0
In-Reply-To: <854155bc-8a20-89b1-95b3-ac3c66217c9e@kernel.org>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chao Yu <chao@kernel.org>, jaegeuk@kernel.org, yuchao0@huawei.com, ebiggers@google.com, tytso@mit.edu
Cc: linux-fscrypt@vger.kernel.org, miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

Hi, Chao

On 2018/3/9 20:32, Chao Yu wrote:
> On 2018/3/9 15:53, Sheng Yong wrote:
>> This patch introduces a new mount option `test_dummy_encryption' to
>> allow fscrypt to create a fake fscrypt context. This is used by xfstests.
> 
> It needs to add doc for this new mount option.
>
Oh. Right, I'll update the doc.

>>
[...]
>>   static int f2fs_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
>>   {
>> -	if (unlikely(f2fs_cp_error(F2FS_I_SB(dir))))
>> +	struct f2fs_sb_info *sbi = F2FS_I_SB(dir);
>> +
>> +	if (unlikely(f2fs_cp_error(sbi)))
>>   		return -EIO;
>>   
>> -	if (f2fs_encrypted_inode(dir)) {
>> +	if (f2fs_encrypted_inode(dir) || DUMMY_ENCRYPTION_ENABLED(sbi)) {
> 
> Why we need to add this condition here?
> 
I think it's both OK if we add the check or not. But since commit 304eecc3462e ("f2fs crypto:
check encryption for tmpfile) add f2fs_encrypt_inode() to check encryption earlier, IMO, we
should do the same check if test_dummy_encryption is enabled according to the semantic.

>>   		int err = fscrypt_get_encryption_info(dir);
>>   		if (err)
>>   			return err;
[...]
>> @@ -2620,6 +2642,15 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
>>   	if (err)
>>   		goto free_options;
>>   
>> +	if (DUMMY_ENCRYPTION_ENABLED(sbi) &&
>> +			(sb_rdonly(sb) || !f2fs_sb_has_encrypt(sb))) {
> 
> Use f2fs_readonly() here which can wrap sb_rdonly()?
> OK.

>> +		f2fs_msg(sb, KERN_ERR,
>> +			"Encrypt feature is off or filesystem is read-only");
>> +		err = -EINVAL;
>> +		retry = false;
>> +		goto free_options;
>> +	}
> 
> How about moving this check into parse_options(), so we can check this condition
> in remount_fs() too.
> 
OK.

Thanks,
Sheng

> Thanks,
> 
>> +
>>   	sbi->max_file_blocks = max_file_blocks();
>>   	sb->s_maxbytes = sbi->max_file_blocks <<
>>   				le32_to_cpu(raw_super->log_blocksize);
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fscrypt" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 

