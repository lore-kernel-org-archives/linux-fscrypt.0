Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2BE1C433E0
	for <linux-fscrypt@archiver.kernel.org>; Tue, 19 Jan 2021 22:57:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9936F23104
	for <linux-fscrypt@archiver.kernel.org>; Tue, 19 Jan 2021 22:57:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729170AbhASW46 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 19 Jan 2021 17:56:58 -0500
Received: from mail.kernel.org ([198.145.29.99]:56192 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728962AbhASW4R (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 19 Jan 2021 17:56:17 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id 67E1123104;
        Tue, 19 Jan 2021 22:55:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1611096935;
        bh=R/lM9Vl+ModSqOgzRKWJAsP+zlQAnR76x+geSirUkcg=;
        h=Date:From:To:Cc:Subject:From;
        b=E7FiB2q1qTCTiT8cUYY7o74vvE9r30DuFMpm4e5aidVUfgL/VI1ilXg9qyScq6Cav
         r2Q9Clg4UVulYJvmctS32IbYTFM/Vk2lhVV/Sc9ixkx5nSlvkakJDcRIVznUXY/JOg
         fiyf/Ce4YCnLJGMLTv9F99+jH4IhzZP/lEHpeGlB2jAYjTztBMT/nczNAxWDA5iZEe
         ZpWGjjwkZTLM0BqY5ExvQiTejMvP5capW/+mUmdf+xKfEGAKuCCQgyUpZIqgnBCXvI
         /O4DUKMjNwNmj9HPO1NO3TwawvDWwco4jBhqyHgSSPGfdmV+wOtySUtIrbJKlpRTBj
         aof6A2L+IUgcA==
Date:   Tue, 19 Jan 2021 14:55:33 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     Colin Walters <walters@verbum.org>,
        Luca Boccassi <luca.boccassi@microsoft.com>,
        Jes Sorensen <jsorensen@fb.com>
Subject: [ANNOUNCE] fsverity-utils v1.3
Message-ID: <YAdjZRKzblp5ypJ3@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

I've released fsverity-utils v1.3:

Git: https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/fsverity-utils.git/tag/?h=v1.3
Tarball: https://kernel.org/pub/linux/kernel/people/ebiggers/fsverity-utils/v1.3/

Release notes (these can also be found in the NEWS.md file):

    * Added a `fsverity digest` subcommand.

    * Added `libfsverity_enable()` and `libfsverity_enable_with_sig()`.

    * Added basic support for Windows builds of `fsverity` using MinGW.

    * `fsverity` now defaults to 4096-byte blocks on all platforms.

    * libfsverity now will use SHA-256 with 4096-byte blocks if the
      `hash_algorithm` and `block_size` fields are left 0.

    * `make install` now installs a pkg-config file for libfsverity.

    * The Makefile now uses pkg-config to get the libcrypto build flags.

    * Fixed `make check` with `USE_SHARED_LIB=1`.

- Eric

