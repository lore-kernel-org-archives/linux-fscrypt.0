Return-Path: <SRS0=Kunw=A7=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B83DC433E8
	for <linux-fscrypt@archiver.kernel.org>; Mon, 20 Jul 2020 17:10:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CEDF02176B
	for <linux-fscrypt@archiver.kernel.org>; Mon, 20 Jul 2020 17:10:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1595265001;
	bh=OthK/AQBHEtdjBBAz0n/15WPSHBWT0arVmiBxqHTdbo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=FQ9BDQZJRJEB0zdvqV4HcAzhz3myY5tsJNf0rC4a4hWMSSRPL733RWUbDM0ri2C1/
	 hDZlHs26tNyv3/jNjYK1Ye+P6thPqoHs6FY49GslWdDTG6iVtvcwaJhpwYPWyxh3Mr
	 QmyL1A8RPEENZPiQw3vdjAy6TVMzmMFNDp8FqQ5U=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730553AbgGTRJz (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 20 Jul 2020 13:09:55 -0400
Received: from mail.kernel.org ([198.145.29.99]:46728 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729084AbgGTRJx (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 20 Jul 2020 13:09:53 -0400
Received: from gmail.com (unknown [104.132.1.76])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D5796207DF;
        Mon, 20 Jul 2020 17:09:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1595264993;
        bh=OthK/AQBHEtdjBBAz0n/15WPSHBWT0arVmiBxqHTdbo=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Rwg++Qqd28JZ8teR6Wn7NDm2yRrPKRUXPCfuzh8ZpZPAWd0YfMmSXjxHQP4nWQF0o
         FrYFN3RpBW5U2NGYXWhrdk4coaezy1WR6SdlptXgG5oxgriJtgAPEw45ju74Rm4iSZ
         eBhgXcl8BUAPAe6EtMV4CKHIMUm9uD+CIwQNfKks=
Date:   Mon, 20 Jul 2020 10:09:51 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Theodore Ts'o <tytso@mit.edu>
Cc:     Daniel Rosenberg <drosen@google.com>, linux-ext4@vger.kernel.org,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-fscrypt@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Gabriel Krisman Bertazi <krisman@collabora.com>,
        kernel-team@android.com
Subject: Re: [PATCH v12 0/4] Prepare for upcoming Casefolding/Encryption
 patches
Message-ID: <20200720170951.GE1292162@gmail.com>
References: <20200708091237.3922153-1-drosen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200708091237.3922153-1-drosen@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Jul 08, 2020 at 02:12:33AM -0700, Daniel Rosenberg wrote:
> This lays the ground work for enabling casefolding and encryption at the
> same time for ext4 and f2fs. A future set of patches will enable that
> functionality.
> 
> These unify the highly similar dentry_operations that ext4 and f2fs both
> use for casefolding. In addition, they improve d_hash by not requiring a
> new string allocation.
> 
> Daniel Rosenberg (4):
>   unicode: Add utf8_casefold_hash
>   fs: Add standard casefolding support
>   f2fs: Use generic casefolding support
>   ext4: Use generic casefolding support
> 

Ted, are you interested in taking this through the ext4 tree for 5.9?

- Eric
