Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8FE4EE49A3
	for <linux-fscrypt@archiver.kernel.org>; Wed, 23 Aug 2023 04:10:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231131AbjHWEKJ (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 23 Aug 2023 00:10:09 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49492 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229477AbjHWEKI (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 23 Aug 2023 00:10:08 -0400
Received: from symantec4.comsats.net.pk (symantec4.comsats.net.pk [203.124.41.30])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CEBA9E46
        for <linux-fscrypt@vger.kernel.org>; Tue, 22 Aug 2023 21:10:02 -0700 (PDT)
X-AuditID: cb7c291e-055ff70000002aeb-2e-64e571b24581
Received: from iesco.comsatshosting.com (iesco.comsatshosting.com [210.56.28.11])
        (using TLS with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        by symantec4.comsats.net.pk (Symantec Messaging Gateway) with SMTP id 2D.F5.10987.2B175E46; Wed, 23 Aug 2023 07:40:50 +0500 (PKT)
DomainKey-Signature: a=rsa-sha1; c=nofws; q=dns;
        d=iesco.com.pk; s=default;
        h=received:content-type:mime-version:content-transfer-encoding
          :content-description:subject:to:from:date:reply-to;
        b=SvrCivhlgbo9ZW/J828FnGMkxlScOnBJtE0y7WV3BxJ4ERTnlHaSQ/BIjeC+qzZ+2
          QpDRs0tKggfHW6f+feRfTe3WWaAUOPqpZXvv+XeoQaByyXdehHbhV9K9bokQno6d5
          nkNoyinw7Z3bVh/mac/0s682PxZtUIrf7448bz6e0=
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=iesco.com.pk; s=default;
        h=reply-to:date:from:to:subject:content-description
          :content-transfer-encoding:mime-version:content-type;
        bh=GMzYzcyTxDsE6wX/XHG6MHqAdAiHrhqbmmLQ/TZ1QnQ=;
        b=YaWyye4eR+/vep/vYRzZb9JITKBRWWNAM0WNWpFrDWCh+snXbjjs07ZXXW+5823hM
          9Z0GHSJUNud1Jg5T+sttnO35myFJpGwS4Un0EU2FjaOgFc0Hf3SpJVogsr940CLn5
          7IZfeTN4Jy6ZCK6P6tXPUsEkH6OdSEXwmRibwTmII=
Received: from [94.156.6.90] (UnknownHost [94.156.6.90]) by iesco.comsatshosting.com with SMTP;
   Wed, 23 Aug 2023 04:31:00 +0500
Message-ID: <2D.F5.10987.2B175E46@symantec4.comsats.net.pk>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Description: Mail message body
Subject: Re; Interest,
To:     linux-fscrypt@vger.kernel.org
From:   "Chen Yun" <pso.chairmanbod@iesco.com.pk>
Date:   Tue, 22 Aug 2023 16:31:14 -0700
Reply-To: chnyne@gmail.com
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFlrLLMWRmVeSWpSXmKPExsVyyUKGW3dT4dMUgzdTpCxezfvG4sDo8XmT
        XABjFJdNSmpOZllqkb5dAlfGknUXWAp2M1e09S9iaWB8zNTFyMkhIWAiMe3Ne/YuRi4OIYE9
        TBKfLuxkA3FYBFYzSzSe/McO4TxklnjZ8YANoqyZUWL29tWMIP28AtYSXZ++sYHYzAJ6Ejem
        TmGDiAtKnJz5hAUiri2xbOFr5i5GDiBbTeJrVwlIWFhATOLTtGXsILaIgKLEk8f7wEayCehL
        rPjaDGazCKhKrNtwE8wWEpCS2HhlPdsERv5ZSLbNQrJtFpJtsxC2LWBkWcUoUVyZmwgMtmQT
        veT83OLEkmK9vNQSvYLsTYzAQDxdoym3g3HppcRDjAIcjEo8vD/XPUkRYk0sA+o6xCjBwawk
        wiv9/WGKEG9KYmVValF+fFFpTmrxIUZpDhYlcV5boWfJQgLpiSWp2ampBalFMFkmDk6pBsab
        C7inOwjtNJy+XSzD+PXRtVvZRDtuORaduXboic4CLtHF70++iXVPW8+3eLHB6gqzX+q2Hb9W
        flJL9NbWr758VPj/lQ0FqySNCmJ2N/96ZNZ15v6dFVZaTLf2KMvv+j79GMPDpwuq3r9IVZIo
        k20w7ndWZ7bkbdiYe5m3wW/xS43kyav3uOorsRRnJBpqMRcVJwIA88CbQEACAAA=
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Re; Interest,

I am interested in discussing the Investment proposal as I explained
in my previous mail. May you let me know your interest and the
possibility of a cooperation aimed for mutual interest.

Looking forward to your mail for further discussion.

Regards

------
Chen Yun - Chairman of CREC
China Railway Engineering Corporation - CRECG
China Railway Plaza, No.69 Fuxing Road, Haidian District, Beijing, P.R.
China

