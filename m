Return-Path: <SRS0=KV6n=N6=huawei.com=yuchao0@kernel.org>
Subject: Re: [PATCH 2/7] f2fs: use IS_ENCRYPTED() to check encryption status
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
 <20181119052324.31456-3-chandan@linux.vnet.ibm.com>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <6dec5660-46c0-8061-f1a9-618bed182876@huawei.com>
Date: Mon, 19 Nov 2018 14:24:31 +0800
MIME-Version: 1.0
In-Reply-To: <20181119052324.31456-3-chandan@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: ebiggers@kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

On 2018/11/19 13:23, Chandan Rajendra wrote:
> This commit removes the f2fs specific f2fs_encrypted_inode() and makes
> use of the generic IS_ENCRYPTED() macro to check for the encryption
> status of an inode.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>

Acked-by: Chao Yu <yuchao0@huawei.com>

Thanks,
