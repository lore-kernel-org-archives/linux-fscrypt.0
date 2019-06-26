Return-Path: <SRS0=+J8k=UZ=vger.kernel.org=linux-integrity-owner@kernel.org>
Subject: Re: [PATCH v5 16/16] f2fs: add fs-verity support
References: <20190620205043.64350-1-ebiggers@kernel.org>
 <20190620205043.64350-17-ebiggers@kernel.org>
 <90495fb1-72eb-ca42-8457-ef8e969eda51@huawei.com>
 <20190625175225.GC81914@gmail.com>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <68c5a15f-f6a8-75e2-b485-0f1b51471995@huawei.com>
Date: Wed, 26 Jun 2019 15:34:35 +0800
MIME-Version: 1.0
In-Reply-To: <20190625175225.GC81914@gmail.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-integrity-owner@vger.kernel.org
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "Darrick J . Wong" <darrick.wong@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On 2019/6/26 1:52, Eric Biggers wrote:
> Hi Chao, thanks for the review.
> 
> On Tue, Jun 25, 2019 at 03:55:57PM +0800, Chao Yu wrote:
>> Hi Eric,
>>
>> On 2019/6/21 4:50, Eric Biggers wrote:
>>> +static int f2fs_begin_enable_verity(struct file *filp)
>>> +{
>>> +	struct inode *inode = file_inode(filp);
>>> +	int err;
>>> +
>>
>> I think we'd better add condition here (under inode lock) to disallow enabling
>> verity on atomic/volatile inode, as we may fail to write merkle tree data due to
>> atomic/volatile inode's special writeback method.
>>
> 
> Yes, I'll add the following:
> 
> 	if (f2fs_is_atomic_file(inode) || f2fs_is_volatile_file(inode))
> 		return -EOPNOTSUPP;
> 
>>> +	err = f2fs_convert_inline_inode(inode);
>>> +	if (err)
>>> +		return err;
>>> +
>>> +	err = dquot_initialize(inode);
>>> +	if (err)
>>> +		return err;
>>
>> We can get rid of dquot_initialize() here, since f2fs_file_open() ->
>> dquot_file_open() should has initialized quota entry previously, right?
> 
> We still need it because dquot_file_open() only calls dquot_initialize() if the
> file is being opened for writing.  But here the file descriptor is readonly.
> I'll add a comment explaining this here and in the ext4 equivalent.

Ah, you're right.

f2fs_convert_inline_inode() may grab one more block during conversion, so we
need to call dquot_initialize() before inline conversion?

Thanks,

> 
> - Eric
> .
> 
