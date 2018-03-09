Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:40460 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751075AbeCIMcP (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 9 Mar 2018 07:32:15 -0500
From: Chao Yu <chao@kernel.org>
Subject: Re: [f2fs-dev] [RFC PATCH v4 1/3] f2fs: introduce
 F2FS_FEATURE_LOST_FOUND feature
References: <20180309075312.62357-1-shengyong1@huawei.com>
 <20180309075312.62357-2-shengyong1@huawei.com>
Message-ID: <3b87131c-7c8e-0904-f46c-36de2b3d4d3d@kernel.org>
Date: Fri, 9 Mar 2018 20:31:47 +0800
MIME-Version: 1.0
In-Reply-To: <20180309075312.62357-2-shengyong1@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Sheng Yong <shengyong1@huawei.com>, jaegeuk@kernel.org, yuchao0@huawei.com, ebiggers@google.com, tytso@mit.edu
Cc: linux-fscrypt@vger.kernel.org, miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On 2018/3/9 15:53, Sheng Yong wrote:
> This patch introduces a new feature, F2FS_FEATURE_LOST_FOUND, which
> is set by mkfs. mkfs creates a directory named lost+found, which saves
> unreachable files. If fsck finds a file which has no parent, or its
> parent is removed by fsck, the file will be placed under lost+found
> directory by fsck.
> 
> lost+found directory could not be encrypted. As a result, the root
> directory cannot be encrypted too. So if LOST_FOUND feature is enabled,
> let's avoid to encrypt root directory.
> 
> Signed-off-by: Sheng Yong <shengyong1@huawei.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>

Thanks,
