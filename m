Return-Path: <SRS0=dpHo=UY=huawei.com=yuchao0@kernel.org>
Subject: Re: [PATCH v5 16/16] f2fs: add fs-verity support
References: <20190620205043.64350-1-ebiggers@kernel.org>
 <20190620205043.64350-17-ebiggers@kernel.org>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <90495fb1-72eb-ca42-8457-ef8e969eda51@huawei.com>
Date: Tue, 25 Jun 2019 15:55:57 +0800
MIME-Version: 1.0
In-Reply-To: <20190620205043.64350-17-ebiggers@kernel.org>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "Darrick J . Wong" <darrick.wong@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On 2019/6/21 4:50, Eric Biggers wrote:
> +static int f2fs_begin_enable_verity(struct file *filp)
> +{
> +	struct inode *inode = file_inode(filp);
> +	int err;
> +

I think we'd better add condition here (under inode lock) to disallow enabling
verity on atomic/volatile inode, as we may fail to write merkle tree data due to
atomic/volatile inode's special writeback method.

> +	err = f2fs_convert_inline_inode(inode);
> +	if (err)
> +		return err;
> +
> +	err = dquot_initialize(inode);
> +	if (err)
> +		return err;

We can get rid of dquot_initialize() here, since f2fs_file_open() ->
dquot_file_open() should has initialized quota entry previously, right?

Thanks,

> +
> +	set_inode_flag(inode, FI_VERITY_IN_PROGRESS);
> +	return 0;
> +}
> +
