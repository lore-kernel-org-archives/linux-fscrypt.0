Return-Path: <SRS0=Z22n=DA=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98171C4363D
	for <linux-fscrypt@archiver.kernel.org>; Wed, 23 Sep 2020 06:07:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6634A235FC
	for <linux-fscrypt@archiver.kernel.org>; Wed, 23 Sep 2020 06:07:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600841273;
	bh=kyWQ8LYf7qzECEdXjAoNSqNNVC8G8Y8QllK22Douvts=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=Qc37O3K08yZ26NVML7cacLSPuLTZJTJagaST/Nf0pjqAv6LTQtUL9+3QKfxEsHi85
	 h6lZdWnqSEDoNi+raoAZdDgw6szKBQKoSOBBLAatVGG8WhSH+KX1xSP11dCN2PDr37
	 1shoMoR8yo9JnDyg4chpX+O7A/jHLU/a6aOt+Ajc=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726686AbgIWGHt (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 23 Sep 2020 02:07:49 -0400
Received: from mail.kernel.org ([198.145.29.99]:46104 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726827AbgIWGHR (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 23 Sep 2020 02:07:17 -0400
Received: from sol.localdomain (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7BEC9235FC;
        Wed, 23 Sep 2020 06:07:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600841236;
        bh=kyWQ8LYf7qzECEdXjAoNSqNNVC8G8Y8QllK22Douvts=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=lDlsAnvlLTFfh5gvzZnIhu6t8x8513xuoBHUj/FJRyY6n5ixwf7t/gfjtYU2abUJE
         2ANdE+NbEuR3FdILpOGpbTXLaRP3o1THWDT+g2nbv/P27sYI3n3sxUEW6aIt4GnFmx
         0qPYtcS2uf+FibkrZAMT596HZyf3H9QGvUW8bUz0=
Date:   Tue, 22 Sep 2020 23:07:15 -0700
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
Subject: Re: [PATCH 3/5] libfs: Add generic function for setting dentry_ops
Message-ID: <20200923060715.GD9538@sol.localdomain>
References: <20200923010151.69506-1-drosen@google.com>
 <20200923010151.69506-4-drosen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200923010151.69506-4-drosen@google.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Sep 23, 2020 at 01:01:49AM +0000, Daniel Rosenberg wrote:
> This adds a function to set dentry operations at lookup time that will
> work for both encrypted files and casefolded filenames.

"encrypted files" => "encrypted filenames"

> 
> A filesystem that supports both features simultaneously can use this
> function during lookup preperations to set up its dentry operations once
> fscrypt no longer does that itself.

"preperations" => "preparations"

> 
> Currently the casefolding dentry operation are always set because the
> feature is toggleable on empty directories. Since we don't know what
> set of functions we'll eventually need, and cannot change them later,
> we add just add them.

"are always set" => "are always set if the filesystem defines an encoding"

> +/**
> + * generic_set_encrypted_ci_d_ops - helper for setting d_ops for given dentry
> + * @dentry:	dentry to set ops on
> + *
> + * This function sets the dentry ops for the given dentry to handle both
> + * casefolding and encryption of the dentry name.
> + */

But it also seems that some of the information in the commit message should go
into this comment so that it isn't lost.  It's not clear to someone reading this
code what "handling encryption of the dentry name" means (hint: it doesn't
actually mean handling encryption...), and why setting the casefolding
operations isn't conditional on IS_CASEFOLDED(dir).

- Eric
