Return-Path: <SRS0=Z22n=DA=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABDD9C4727D
	for <linux-fscrypt@archiver.kernel.org>; Wed, 23 Sep 2020 05:47:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6F66A221EB
	for <linux-fscrypt@archiver.kernel.org>; Wed, 23 Sep 2020 05:47:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600840041;
	bh=++X+8xe8ksxtaAPLTC3s7LLyQp4x7rbFiWoZMedsomY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=SC2YW0uuzA8z76x1NsajFs7cH9M2gaSIfPbytTV9S779bpjK0oZKLLdpRPNZrg9It
	 at3SNZe3gvHV/bu+qVJAF8/hspc5UZvr9y8UpMwQLYR65Sne/kAL8mDqIjTAxqRWeO
	 4oisfbtaykYYlw3wKMS4A2iOXhBGr0tVUaAQ/MY4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726944AbgIWFrQ (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 23 Sep 2020 01:47:16 -0400
Received: from mail.kernel.org ([198.145.29.99]:57882 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726883AbgIWFrQ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 23 Sep 2020 01:47:16 -0400
Received: from sol.localdomain (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D80D82065E;
        Wed, 23 Sep 2020 05:47:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600840036;
        bh=++X+8xe8ksxtaAPLTC3s7LLyQp4x7rbFiWoZMedsomY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=0PaOt3uokBZgumht4KFfo0Bi5Pdzn8rPnyDclTMCD47QGTeVVUypAgZdEFBA3qpw4
         /Xw6aYy/tyPMudYfTpRtjTSmawmtjb9KPK0K8eIaKVS9uBwWBD41gyyYVyx1Tk+Fh6
         p5u+hnxp8N9hejVxJLGIKnaNWU5BPEtdZ3p3QjNY=
Date:   Tue, 22 Sep 2020 22:47:14 -0700
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
Subject: Re: [PATCH 1/5] ext4: Use generic casefolding support
Message-ID: <20200923054714.GB9538@sol.localdomain>
References: <20200923010151.69506-1-drosen@google.com>
 <20200923010151.69506-2-drosen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200923010151.69506-2-drosen@google.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Sep 23, 2020 at 01:01:47AM +0000, Daniel Rosenberg wrote:
> This switches ext4 over to the generic support provided in
> the previous patch.
> 
> Since casefolded dentries behave the same in ext4 and f2fs, we decrease
> the maintenance burden by unifying them, and any optimizations will
> immediately apply to both.
> 
> Signed-off-by: Daniel Rosenberg <drosen@google.com>
> Reviewed-by: Eric Biggers <ebiggers@google.com>

You could also add Gabriel's Reviewed-by from last time:
https://lkml.kernel.org/linux-fsdevel/87lfh4djdq.fsf@collabora.com/

- Eric
