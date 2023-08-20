Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 602A1EE4996
	for <linux-fscrypt@archiver.kernel.org>; Sun, 20 Aug 2023 22:53:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232082AbjHTWxH (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sun, 20 Aug 2023 18:53:07 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57272 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231810AbjHTWxG (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 20 Aug 2023 18:53:06 -0400
X-Greylist: delayed 122 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Sun, 20 Aug 2023 15:53:03 PDT
Received: from mail.nsr.re.kr (unknown [210.104.33.65])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E44169D
        for <linux-fscrypt@vger.kernel.org>; Sun, 20 Aug 2023 15:53:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; s=LIY0OQ3MUMW6182UNI14; d=nsr.re.kr; t=1692571955; c=relaxed/relaxed; h=content-type:date:from:message-id:mime-version:subject:to; bh=ol+C1xGCyhjNmkvzpFvHJq7CVIgJJ6vr7hRyOSPkJyw=; b=RwqKgYVLYCtAu/xm4KEi52c6+TTUQiQBlgmKKpRQwXTAqfT91siMWWs/Eo8huBy0WKDFR4pG1iwLW7/1nMsPUuVrZWGI/q7/OXxSV20lvgquwiC0Vvc9JRZ4evUxj1F7P4d4IAcizo9rNWITEQ460VbO/tsqOH6FZcOy/LU5i0uRRllRbyprN1sSFEocYD/3GrwdgMbZBlH28f54MtwxZ1UWM9SdLC07PejmKtD9l7EfZG18o1sy+JFWfI5Ggv5664jRNyfZHApFWGhAEVklxUObglL+JDT35pgEY2t8hwjJ+1WZTNsJV4a0sQ2Eui3LiWXoHW7pUMyZHvHcjWaTEg==
Received: from 210.104.33.70 (nsr.re.kr)
        (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128 bits))
        by mail.nsr.re.kr with SMTP; Mon, 21 Aug 2023 07:50:13 +0900
Received: from 192.168.155.188 ([192.168.155.188])
          by mail.nsr.re.kr (Crinity Message Backbone-7.0.1) with SMTP ID 742;
          Mon, 21 Aug 2023 07:50:37 +0900 (KST)
From:   Dongsoo Lee <letrhee@nsr.re.kr>
To:     'Herbert Xu' <herbert@gondor.apana.org.au>,
        "'David S. Miller'" <davem@davemloft.net>,
        'Jens Axboe' <axboe@kernel.dk>,
        'Eric Biggers' <ebiggers@kernel.org>,
        "'Theodore Y. Ts'o'" <tytso@mit.edu>,
        'Jaegeuk Kim' <jaegeuk@kernel.org>
Cc:     linux-crypto@vger.kernel.org, linux-block@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20230630050323.984216-1-letrhee@nsr.re.kr>
In-Reply-To: <20230630050323.984216-1-letrhee@nsr.re.kr>
Subject: RE: [PATCH v4 0/4] crypto: LEA block cipher implementation
Date:   Mon, 21 Aug 2023 07:50:37 +0900
Message-ID: <000001d9d3b8$bca8e9d0$35fabd70$@nsr.re.kr>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Mailer: Microsoft Outlook 16.0
Content-Language: ko
Thread-Index: AQG+zeutOnGLBDU871s4t/JvNXQOJbAp1UiA
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Hello.

Is there any further progress on the patch we submitted and the additional fscrypt documentation? 

https://lore.kernel.org/linux-fscrypt/20230630064811.22569-1-ebiggers@kernel.org/T/#u.

If the LEA cipher is accepted, we would like to add a SIMD implementation for it.
