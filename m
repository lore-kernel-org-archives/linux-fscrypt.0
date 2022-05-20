Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 858E5C433EF
	for <linux-fscrypt@archiver.kernel.org>; Fri, 20 May 2022 17:21:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1348238AbiETRV0 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 20 May 2022 13:21:26 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54874 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237912AbiETRVZ (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 20 May 2022 13:21:25 -0400
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk [46.235.227.227])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 27A4A39164;
        Fri, 20 May 2022 10:21:24 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
        (Authenticated sender: krisman)
        with ESMTPSA id BFD491F46726
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=collabora.com;
        s=mail; t=1653067283;
        bh=nxHUg1U1wjVU0hfczLwATkd9dA/b0ruMNZpmXbtKT4A=;
        h=From:To:Cc:Subject:References:Date:In-Reply-To:From;
        b=j/9SsfLfim+cTj5jMfVxQ34lLVnFspAX/TnPixbH6JdcuuaI3E3YzOlkC4N8qwGcU
         slCCuUhMftUXUZ5q6sCNZvoa1cWMibArHRErbqGPDqsQyFTq37C1NvfQjqX8e6Az9t
         tlsvP+jtkbu6LYWBxC3xSmiLpSMg7ufA3+5RlG/7bW4UEmNQmaZxyB3eueYsglWsth
         m7cC4XO8HBeJztqpxmYGg9KufkvMK4uuVE1ye2St0JCEPOEUDCoPD09Kf+8h5Fz0pj
         ty7i9jpXJZUFKoz636w2kBgJuO0yIkYkeM2Ryve5ySUHR2RJdpAYlnazoVPdUYwDta
         eNR+O/DmLq+Ew==
From:   Gabriel Krisman Bertazi <krisman@collabora.com>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     fstests@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-fscrypt@vger.kernel.org, Daniel Rosenberg <drosen@google.com>
Subject: Re: [xfstests PATCH] generic/556: add test case for top-level dir
 rename
Organization: Collabora
References: <20220514180146.44775-1-ebiggers@kernel.org>
Date:   Fri, 20 May 2022 13:21:19 -0400
In-Reply-To: <20220514180146.44775-1-ebiggers@kernel.org> (Eric Biggers's
        message of "Sat, 14 May 2022 11:01:46 -0700")
Message-ID: <87sfp46rxs.fsf@collabora.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Eric Biggers <ebiggers@kernel.org> writes:

> From: Eric Biggers <ebiggers@google.com>
>
> Test renaming a casefolded directory located in the top-level directory,
> while the cache is cold.  When $MOUNT_OPTIONS contains
> test_dummy_encryption, this detects an f2fs bug.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  tests/generic/556 | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)

Reviewed-by: Gabriel Krisman Bertazi <krisman@collabora.com>

-- 
Gabriel Krisman Bertazi
