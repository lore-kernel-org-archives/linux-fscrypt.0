Return-Path: <SRS0=Z22n=DA=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33A29C4363D
	for <linux-fscrypt@archiver.kernel.org>; Wed, 23 Sep 2020 06:09:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DB8122223E
	for <linux-fscrypt@archiver.kernel.org>; Wed, 23 Sep 2020 06:09:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600841378;
	bh=rjWKuYvC72TU64CYHQyAAX1xM5QOixLenvyV0KeM5yg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=js/tPeOsYBzjggJiI47pC24svOFBDnd5kDvYVtxEwW/edfNOROWi1CejSpg8eFGOW
	 yzRibtq6oUc2CrZuiPgoomxgyoHsFISnzhcrXEUFc1SpYmh/IyMRxSNaWEr1LfpO4A
	 33ZXZ6QUD//5ZFte2mKl0rRm0yd3xKggLcizgNUM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726650AbgIWGJf (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 23 Sep 2020 02:09:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:49678 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726550AbgIWGJf (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 23 Sep 2020 02:09:35 -0400
Received: from sol.localdomain (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7F30F20739;
        Wed, 23 Sep 2020 06:09:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600841374;
        bh=rjWKuYvC72TU64CYHQyAAX1xM5QOixLenvyV0KeM5yg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Fc7Cr1TWw1F2Gy7YQ+eg4Uql7gHXrzuWWK7Gmm1QnZl4nQc2qIxuRa5x17FtV//kK
         Gv7IlZwRiDUYRuyL5wbNG13Rd4FQfR+8pNAW2s/lLo1dKAIgcBsOSY1maq7fKr4ahl
         9NIfE+GlWzOJjeZRBvT8MLy1WsoerMqdur6RkwhA=
Date:   Tue, 22 Sep 2020 23:09:33 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Daniel Rosenberg <drosen@google.com>
Cc:     "Theodore Y . Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Chao Yu <chao@kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Richard Weinberger <richard@nod.at>,
        linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mtd@lists.infradead.org,
        Gabriel Krisman Bertazi <krisman@collabora.com>,
        kernel-team@android.com
Subject: Re: [PATCH 4/5] fscrypt: Have filesystems handle their d_ops
Message-ID: <20200923060933.GE9538@sol.localdomain>
References: <20200923010151.69506-1-drosen@google.com>
 <20200923010151.69506-5-drosen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200923010151.69506-5-drosen@google.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Sep 23, 2020 at 01:01:50AM +0000, Daniel Rosenberg wrote:
> This shifts the responsibility of setting up dentry operations from
> fscrypt to the individual filesystems, allowing them to have their own
> operations while still setting fscrypt's d_revalidate as appropriate.
> 
> Most filesystems can just use generic_set_encrypted_ci_d_ops, unless
> they have their own specific dentry operations as well. That operation
> will set the minimal d_ops required under the circumstances.
> 
> Since the fscrypt d_ops are set later on, we must set all d_ops there,
> since we cannot adjust those later on. This should not result in any
> change in behavior.
> 
> Signed-off-by: Daniel Rosenberg <drosen@google.com>

Looks good,

Reviewed-by: Eric Biggers <ebiggers@google.com>
