Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:6651 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751665AbeCPIuH (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 16 Mar 2018 04:50:07 -0400
Subject: Re: [RFC PATCH v5 2/3] f2fs: introduce a new mount option
 test_dummy_encryption
References: <20180315105143.133050-1-shengyong1@huawei.com>
 <20180315105143.133050-3-shengyong1@huawei.com>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <656a3814-7454-f12a-ad4a-4bd673c17fa3@huawei.com>
Date: Fri, 16 Mar 2018 16:49:49 +0800
MIME-Version: 1.0
In-Reply-To: <20180315105143.133050-3-shengyong1@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Sheng Yong <shengyong1@huawei.com>, jaegeuk@kernel.org, ebiggers@google.com, tytso@mit.edu
Cc: miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 2018/3/15 18:51, Sheng Yong wrote:
> This patch introduces a new mount option `test_dummy_encryption'
> to allow fscrypt to create a fake fscrypt context. This is used
> by xfstests.
> 
> Signed-off-by: Sheng Yong <shengyong1@huawei.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>

Thanks,

