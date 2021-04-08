Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C275BC433B4
	for <linux-fscrypt@archiver.kernel.org>; Thu,  8 Apr 2021 18:36:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 880B861108
	for <linux-fscrypt@archiver.kernel.org>; Thu,  8 Apr 2021 18:36:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232517AbhDHSgo (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 8 Apr 2021 14:36:44 -0400
Received: from mail.kernel.org ([198.145.29.99]:43960 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231676AbhDHSgn (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 8 Apr 2021 14:36:43 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 2718C610CB;
        Thu,  8 Apr 2021 18:36:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1617906992;
        bh=6Q3stkufbEgNz8Ef1ZjVH7pO/Duo93fnpdpc9InNIdc=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=isvHBObz4dfJBlIp9Q2YxNGFImZ2PY36Wgt4wHz9ZbqEEpcJ2qZGV8zA+bqiku97I
         RKuASZKB3L379mncb1r946UMbCoj5hZw/CHmcFKclo0Ilti0EuvsK8dTGL3YW29BHa
         O+pmpY1fQsQnpebB0eHAEZvElw3/KfsP3M/Qjx75h52+mF9F+LTNGw2C+wzQHnKcpv
         zNufdbg9jC6w82CrEHKoWL9MNPpjSvnkcIYZzRiXUDDlOD1Cq3+GtHQLkaF3fpsDxb
         1+MhOAJL9sUlcMZiFKG2VlolwuxPkO9HfJ9+jo9r0HSESjQV13hwSzdWKtss9lViMb
         tlPgIfYsho4bw==
Date:   Thu, 8 Apr 2021 11:36:30 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Boris Burkov <boris@bur.io>
Cc:     fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-btrfs@vger.kernel.org, kernel-team@fb.com
Subject: Re: [PATCH v2 0/3] tests for btrfs fsverity
Message-ID: <YG9NLpg/EV3zfvsa@sol.localdomain>
References: <cover.1617906318.git.boris@bur.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1617906318.git.boris@bur.io>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Apr 08, 2021 at 11:30:10AM -0700, Boris Burkov wrote:
> This patchset provides tests for fsverity support in btrfs.
> 
> It includes modifications for generic tests to pass with btrfs as well
> as new btrfs specific tests.

Which commit does this apply to?  It doesn't apply to the latest xfstests master
branch.

- Eric
