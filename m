Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E1A1C2B9F4
	for <linux-fscrypt@archiver.kernel.org>; Mon, 14 Jun 2021 23:26:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 01B4861246
	for <linux-fscrypt@archiver.kernel.org>; Mon, 14 Jun 2021 23:26:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230075AbhFNX2c (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 14 Jun 2021 19:28:32 -0400
Received: from mail.kernel.org ([198.145.29.99]:34976 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229649AbhFNX2c (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 14 Jun 2021 19:28:32 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 31CE961246
        for <linux-fscrypt@vger.kernel.org>; Mon, 14 Jun 2021 23:26:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1623713189;
        bh=cVSGF4ykrGmbpuldZkYLXR0TKC8opayYKfV/kzk47es=;
        h=Date:From:To:Subject:From;
        b=NE5pk7FQdnBUogvMxoaRezYj6WFrbPRoW8CiElBSXipe+5RlNQ6lZE22wNz39G0cR
         Lp4gDMm9jTKIq2ePmZ8IlhqeleKZjGQhJxj3qeUEPagXUQ69maakdvx7PELaiiO8jq
         W+5T4z5Lq/FigSJ8jfq0Q5P9z8GZX2li8xCe+qUttykSPomV0pY/yQoJsRk8lyBWQo
         8bNNlfcegdelhwWUrEdBih6PrTq4YnoHwk9NS8Qe8x/m3T+vpOdehyCoo15RQcDt24
         fq+LRPJSYZUdYPCgtObFcw8sZKTjxIcz9c4sNA/peAPVDIbWvf19IMUyFhu180S63T
         PY1vHcpxOKEtg==
Date:   Mon, 14 Jun 2021 16:26:27 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Subject: [ANNOUNCE] fsverity-utils v1.4
Message-ID: <YMflo6Y5HWmRBlqe@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

I've released fsverity-utils v1.4:

Git: https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/fsverity-utils.git/tag/?h=v1.4
Tarball: https://kernel.org/pub/linux/kernel/people/ebiggers/fsverity-utils/v1.4/

Release notes (these can also be found in the NEWS.md file):

    * Added a manual page for the `fsverity` utility.

    * Added the `fsverity dump_metadata` subcommand.

    * Added the `--out-merkle-tree` and `--out-descriptor` options to
      `fsverity digest` and `fsverity sign`.

    * Added metadata callbacks support to `libfsverity_compute_digest()`.

- Eric
