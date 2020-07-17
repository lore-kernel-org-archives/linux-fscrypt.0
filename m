Return-Path: <SRS0=Y2yf=A4=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD19BC433E6
	for <linux-fscrypt@archiver.kernel.org>; Fri, 17 Jul 2020 06:38:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A40CC20704
	for <linux-fscrypt@archiver.kernel.org>; Fri, 17 Jul 2020 06:38:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728030AbgGQGiA (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 17 Jul 2020 02:38:00 -0400
Received: from szxga06-in.huawei.com ([45.249.212.32]:53672 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726141AbgGQGiA (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 17 Jul 2020 02:38:00 -0400
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id A7FF6FE8DF5955B5C66F;
        Fri, 17 Jul 2020 14:37:55 +0800 (CST)
Received: from [10.134.22.195] (10.134.22.195) by smtp.huawei.com
 (10.3.19.213) with Microsoft SMTP Server (TLS) id 14.3.487.0; Fri, 17 Jul
 2020 14:37:53 +0800
Subject: Re: [PATCH] f2fs: use generic names for generic ioctls
To:     Eric Biggers <ebiggers@kernel.org>,
        <linux-f2fs-devel@lists.sourceforge.net>,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>
CC:     <linux-fscrypt@vger.kernel.org>, Jiaheng Hu <jiahengh@google.com>
References: <20200714221812.43464-1-ebiggers@kernel.org>
From:   Chao Yu <yuchao0@huawei.com>
Message-ID: <40b6e371-e170-88bb-4644-1552e5544175@huawei.com>
Date:   Fri, 17 Jul 2020 14:37:52 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20200714221812.43464-1-ebiggers@kernel.org>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.134.22.195]
X-CFilter-Loop: Reflected
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On 2020/7/15 6:18, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Don't define F2FS_IOC_* aliases to ioctls that already have a generic
> FS_IOC_* name.  These aliases are unnecessary, and they make it unclear
> which ioctls are f2fs-specific and which are generic.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>

Thanks,
