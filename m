Return-Path: <SRS0=xC99=LZ=huawei.com=gaoxiang25@kernel.org>
Subject: Re: [RFC PATCH v2 2/2] fscrypt: enable RCU-walk path for
 .d_revalidate
References: <1536584468-15695-2-git-send-email-gaoxiang25@huawei.com>
 <1536584937-16960-1-git-send-email-gaoxiang25@huawei.com>
 <20180910232007.GA19951@gmail.com>
From: Gao Xiang <gaoxiang25@huawei.com>
Message-ID: <f10986d8-1edf-3834-2daf-1a0115484f97@huawei.com>
Date: Tue, 11 Sep 2018 13:29:33 +0800
MIME-Version: 1.0
In-Reply-To: <20180910232007.GA19951@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Chao Yu <yuchao0@huawei.com>, Miao Xie <miaoxie@huawei.com>, weidu.du@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On 2018/9/11 7:20, Eric Biggers wrote:
> Hi Gao,
> 
> On Mon, Sep 10, 2018 at 09:08:57PM +0800, Gao Xiang wrote:
>> This patch attempts to enable RCU-walk for fscrypt.
>> It looks harmless at glance and could have better
>> performance than do ref-walk only.
>>
>> Signed-off-by: Gao Xiang <gaoxiang25@huawei.com>
>> ---
>> change log v2:
>> 	- READ_ONCE(dir->d_parent) -> READ_ONCE(dentry->d_parent)
>>
>>  fs/crypto/crypto.c | 22 +++++++++++++---------
>>  1 file changed, 13 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
>> index b38c574..9bd21c0 100644
>> --- a/fs/crypto/crypto.c
>> +++ b/fs/crypto/crypto.c
>> @@ -319,20 +319,24 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
>>  {
>>  	struct dentry *dir;
>>  	int dir_has_key, cached_with_key;
>> -
>> -	if (flags & LOOKUP_RCU)
>> -		return -ECHILD;
>> -
>> -	dir = dget_parent(dentry);
>> -	if (!IS_ENCRYPTED(d_inode(dir))) {
>> -		dput(dir);
>> +	struct inode *dir_inode;
>> +
>> +	rcu_read_lock();
>> +repeat:
>> +	dir = READ_ONCE(dentry->d_parent);
>> +	dir_inode = d_inode_rcu(dir);
>> +	if (!IS_ENCRYPTED(dir_inode)) {
>> +		rcu_read_unlock();
>>  		return 0;
>>  	}
>> +	dir_has_key = (dir_inode->i_crypt_info != NULL);
>> +	if (unlikely(READ_ONCE(dir->d_lockref.count) < 0 ||
>> +		READ_ONCE(dentry->d_parent) != dir))
>>
>>
>> +	rcu_read_unlock();
>>  
>>  	cached_with_key = READ_ONCE(dentry->d_flags) &
>>  		DCACHE_ENCRYPTED_WITH_KEY;
>> -	dir_has_key = (d_inode(dir)->i_crypt_info != NULL);
>> -	dput(dir);
>>  
> 
> I think you're right that we don't have to drop out of RCU mode here, but can
> you please Cc linux-fsdevel so that people more knowledgeable about path lookup
> can review this too?  This kind of stuff is very tricky.  Please resend both
> patches.
> 
> Also please indent properly:
> 
> 	if (unlikely(READ_ONCE(dir->d_lockref.count) < 0 ||
>                      READ_ONCE(dentry->d_parent) != dir))
> 		goto repeat;
> 
> Why read d_lockref.count directly instead of using __lockref_is_dead()?

will be fixed in the next version, thanks.

> 
> Also since there's no longer any reference to the parent dentry taken, how do
> you know it's still positive (non-NULL d_inode), i.e. that the directory hasn't
> been removed and turned into a negative dentry (NULL d_inode)?

I think you are right. I saw this fscrypt piece of code when I was locating a
problem related to fscrypt (I am still taking part in it since the problem is urgent).
It seems that it could be turned into a negative dentry by d_delete() etc.

I will rethink this flow more, make the next patch later and Cc linux-devel
the next time.

> 
> I'm also wondering whether the retry loop is actually needed.  Can you explain
> your thoughts more?  But if it is needed, in principle you'd actually need to
> wait until after the loop before taking any action based on dir_inode, right?
> That would mean the 'rcu_read_unlock(); return 0;' is in the wrong place.
What I thought was that I guess it needs to be more strict to claim the dentry is
still valid than other cases (therefore IS_ENCRYPTED is not so strict, that is
my personal thought tho.)

If the parent dentry just sampled is invalid, since the dentry and inode are
protected by rcu, so there is no way to READ_ONCE(dentry->d_parent) == dir.

Therefore I sampled (IS_ENCRYPTED, dir_has_key) and do a final basic validity
check at last --- currently dentry itself (maybe inode later), and I tend to
try again especially for ref-walk case (which not governed by d_seq) since it is
more lightweight (like a seqlock) than taking & releasing d_lock (or even
return 0 to do real lookup again) I think.

That is my personal thought, could not be accurate, and I am trying to learn
more about the fscrypt due to the urgent problem.

If any error, please kindly point out, thanks...

Thanks,
Gao Xiang

> 
> Thanks,
> 
> - Eric
> 
