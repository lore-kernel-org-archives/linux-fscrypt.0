Return-Path: <SRS0=92zr=Z6=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_NONE,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 467FDC43603
	for <linux-fscrypt@archiver.kernel.org>; Sun,  8 Dec 2019 12:38:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0F07420706
	for <linux-fscrypt@archiver.kernel.org>; Sun,  8 Dec 2019 12:38:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="U1XvJNbZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726229AbfLHMi2 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sun, 8 Dec 2019 07:38:28 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:43270 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726163AbfLHMi2 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 8 Dec 2019 07:38:28 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=2ELcNaQndnrwr3FiX1NwpMEheNcsO2lBa0QVqsnMeCA=; b=U1XvJNbZbJPCjOt3AAVxDS0oF
        Mh4MI6C2RCv9V/mL1VeDkpDKRcIa5JCrtsA48oc1ZWffNGpUIw9aDPdgh/eY/Z/Q4WtyE7XL7R13H
        aNZLECIv8MGDhMqhxhCqK1oiWpsqzhojIEowfJv2H/LvRalBHVMMUfsS4I77I7ns/h7iIXi4HWqwb
        GyxnngdRgaYtkRI5xGHMfFDIC8rl7qT9qa1tjyHUshnhjuP/W8K7z2hDCCVU0qUcb7uczdDPfpylS
        gPg1CQlcwkjyKfXr2gYv2md+i1a3Ba+MfYDEpJDNCATOzq/5SM/3hvEgbW0A9/aYLu+vajeb1GHPp
        ylpQUn9Uw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.3 #3 (Red Hat Linux))
        id 1idvp6-00061v-LN; Sun, 08 Dec 2019 12:38:04 +0000
Date:   Sun, 8 Dec 2019 04:38:04 -0800
From:   Matthew Wilcox <willy@infradead.org>
To:     Al Viro <viro@zeniv.linux.org.uk>
Cc:     Tiezhu Yang <yangtiezhu@loongson.cn>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>,
        Eric Biggers <ebiggers@kernel.org>,
        Tyler Hicks <tyhicks@canonical.com>,
        linux-fsdevel@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-fscrypt@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] fs: introduce is_dot_dotdot helper for cleanup
Message-ID: <20191208123804.GB32169@bombadil.infradead.org>
References: <1575718548-19017-1-git-send-email-yangtiezhu@loongson.cn>
 <20191208034144.GP4203@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191208034144.GP4203@ZenIV.linux.org.uk>
User-Agent: Mutt/1.12.1 (2019-06-15)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Sun, Dec 08, 2019 at 03:41:44AM +0000, Al Viro wrote:
> On Sat, Dec 07, 2019 at 07:35:48PM +0800, Tiezhu Yang wrote:
> > There exists many similar and duplicate codes to check "." and "..",
> > so introduce is_dot_dotdot helper to make the code more clean.
> 
> Umm...  No objections, in principle, but... you try to say that name
> (e.g. in a phone conversation) without stuttering ;-/
> 
> Any suggestions from native speakers?

I used "is_dot_or_dotdot" when discussing this patch with my wife verbally.
