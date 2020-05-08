Return-Path: <SRS0=O/uW=6W=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BFBFC38A2A
	for <linux-fscrypt@archiver.kernel.org>; Fri,  8 May 2020 08:26:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2622C208CA
	for <linux-fscrypt@archiver.kernel.org>; Fri,  8 May 2020 08:26:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726618AbgEHIZ7 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 8 May 2020 04:25:59 -0400
Received: from szxga05-in.huawei.com ([45.249.212.191]:4295 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726598AbgEHIZ7 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 8 May 2020 04:25:59 -0400
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 164BAB348E0F5B7116A3;
        Fri,  8 May 2020 16:25:57 +0800 (CST)
Received: from [10.134.22.195] (10.134.22.195) by smtp.huawei.com
 (10.3.19.210) with Microsoft SMTP Server (TLS) id 14.3.487.0; Fri, 8 May 2020
 16:25:55 +0800
Subject: Re: [PATCH 1/4] f2fs: don't leak filename in
 f2fs_try_convert_inline_dir()
To:     Eric Biggers <ebiggers@kernel.org>,
        <linux-f2fs-devel@lists.sourceforge.net>
CC:     <linux-fscrypt@vger.kernel.org>,
        Daniel Rosenberg <drosen@google.com>,
        Gabriel Krisman Bertazi <krisman@collabora.com>,
        <stable@vger.kernel.org>
References: <20200507075905.953777-1-ebiggers@kernel.org>
 <20200507075905.953777-2-ebiggers@kernel.org>
From:   Chao Yu <yuchao0@huawei.com>
Message-ID: <be078d08-010e-ad47-b693-8eeacc54b198@huawei.com>
Date:   Fri, 8 May 2020 16:25:54 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20200507075905.953777-2-ebiggers@kernel.org>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.134.22.195]
X-CFilter-Loop: Reflected
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On 2020/5/7 15:59, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> We need to call fscrypt_free_filename() to free the memory allocated by
> fscrypt_setup_filename().
> 
> Fixes: b06af2aff28b ("f2fs: convert inline_dir early before starting rename")

Thanks for fixing this.

> Cc: <stable@vger.kernel.org> # v5.6+
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>

Thanks,
