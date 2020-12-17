Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.2 required=3.0 tests=BAYES_00,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBC97C4361B
	for <linux-fscrypt@archiver.kernel.org>; Thu, 17 Dec 2020 20:52:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B396323A1D
	for <linux-fscrypt@archiver.kernel.org>; Thu, 17 Dec 2020 20:52:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731524AbgLQUwA (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 17 Dec 2020 15:52:00 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38978 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728966AbgLQUwA (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 17 Dec 2020 15:52:00 -0500
Received: from mail-pj1-x1033.google.com (mail-pj1-x1033.google.com [IPv6:2607:f8b0:4864:20::1033])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 27519C061794
        for <linux-fscrypt@vger.kernel.org>; Thu, 17 Dec 2020 12:51:20 -0800 (PST)
Received: by mail-pj1-x1033.google.com with SMTP id b5so82954pjk.2
        for <linux-fscrypt@vger.kernel.org>; Thu, 17 Dec 2020 12:51:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=nH4vnOfqXUS7gwxv1RANkNTAFbgtr06PbQXxBVDkxQU=;
        b=o2D5JCXv7JshlKHecTF945qen6oARQ9FYv6oQjNeC+GDmUbCBZLkeoY7HIyyUSP4D8
         47XcwEJmcP0sXIkHhCHUkLZt3ObIdMh3X04ZhRV85l5u6BvJ6U2gUrKcMHWVMNX7+k1S
         F62oR7+AyBi417VuTWxe9rS8bWBl0dJLkEwaIugVXbxjHG7jurwCFQ2sgmLKq9hxwaib
         DCzS2M7d/bcDgLC0vCHJlZch6Aj4VrwMnnOofRCoCs7sMKeCpH1PNMTWO8Gnp+494iLw
         9JymtqZvMU+2h8NXkV/rKA1KAow9rMBuUwebk6ELVrVZg//YO6z9sF7r7nUaw3nVei6V
         Ng4Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=nH4vnOfqXUS7gwxv1RANkNTAFbgtr06PbQXxBVDkxQU=;
        b=DZWKAiRinf2WHKP98N+L/NtH4tjsYHQdR1skndopKPkXwcQ5a9SrFb5Ag4NiIEztb8
         9tzuS6N6jm5WtVQOGALqcWEnrwwK365TN32g4x8LtwbJUr3T2nnNbUpEJJzVl8WwnNeW
         PxqYh6t91rVN4HQzdjxpO2z6RzH3ln/XmWDjkwp/KVSDJfyY7BjAuZRa8nTGfdwAZMJq
         9YR5DbqoT1z/s8IIu+7OTID6YorEg0l13iUt0xOIhbuTrgh6OrWBW8IYtkOH9okwFQq5
         V6wpuOm0oBQXt75L1RtZSRvw23Th3k3Vz9WBqc85l9fpjUyytBCkSVRr0rkG7/j6vGWN
         yTnQ==
X-Gm-Message-State: AOAM530zML1/w4wIJpHbF9od6su6aUuEUcFebOXdz9JzdgSmiNCrUUrc
        fvz1syht0xSkiP02Au1Ot+uwRA==
X-Google-Smtp-Source: ABdhPJxZL/yVwax1xI84IxNTqxuO6lSubHgIxsTLLS+VrdJjZ7NJ8YCkRuXgWSgbji6o/23F/9fmCA==
X-Received: by 2002:a17:902:a3ca:b029:da:df3c:91c8 with SMTP id q10-20020a170902a3cab02900dadf3c91c8mr1091233plb.41.1608238279445;
        Thu, 17 Dec 2020 12:51:19 -0800 (PST)
Received: from google.com (139.60.82.34.bc.googleusercontent.com. [34.82.60.139])
        by smtp.gmail.com with ESMTPSA id y15sm5525255pju.13.2020.12.17.12.51.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 17 Dec 2020 12:51:18 -0800 (PST)
Date:   Thu, 17 Dec 2020 20:51:14 +0000
From:   Satya Tangirala <satyat@google.com>
To:     "Theodore Y. Ts'o" <tytso@mit.edu>
Cc:     Jaegeuk Kim <jaegeuk@kernel.org>,
        Eric Biggers <ebiggers@kernel.org>, Chao Yu <chao@kernel.org>,
        linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net
Subject: Re: [PATCH v2 0/3] add support for metadata encryption to F2FS
Message-ID: <X9vEwgHlURxvxqiM@google.com>
References: <20201217150435.1505269-1-satyat@google.com>
 <X9uesUH1oetyyoA0@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <X9uesUH1oetyyoA0@mit.edu>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Dec 17, 2020 at 01:08:49PM -0500, Theodore Y. Ts'o wrote:
> On Thu, Dec 17, 2020 at 03:04:32PM +0000, Satya Tangirala wrote:
> > This patch series adds support for metadata encryption to F2FS using
> > blk-crypto.
> 
> Is there a companion patch series needed so that f2fstools can
> check/repair a file system with metadata encryption enabled?
> 
> 	       	    	   	- Ted
Yes! It's at
https://lore.kernel.org/linux-f2fs-devel/20201217151013.1513045-1-satyat@google.com/
