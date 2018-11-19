Return-Path: <SRS0=KV6n=N6=huawei.com=yuchao0@kernel.org>
Subject: Re: [f2fs-dev] [PATCH 6/7] f2fs: use IS_VERITY() to check inode's
 fsverity status
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
 <20181119052324.31456-7-chandan@linux.vnet.ibm.com>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <b29b57fa-e8e8-7800-ac09-9093d3d989b6@huawei.com>
Date: Mon, 19 Nov 2018 14:25:05 +0800
MIME-Version: 1.0
In-Reply-To: <20181119052324.31456-7-chandan@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: ebiggers@kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

On 2018/11/19 13:23, Chandan Rajendra wrote:
> This commit now uses IS_VERITY() macro to check if fsverity is
> enabled on an inode.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>

Acked-by: Chao Yu <yuchao0@huawei.com>

Thanks,
