Return-Path: <SRS0=sFEh=B4=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47956C433DF
	for <linux-fscrypt@archiver.kernel.org>; Tue, 18 Aug 2020 02:56:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 24A822054F
	for <linux-fscrypt@archiver.kernel.org>; Tue, 18 Aug 2020 02:56:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1597719402;
	bh=8toQyHiJ3+QrJ66JO76cYSUVxRqL5N8Two2wxzvfBxM=;
	h=Date:From:To:Subject:List-ID:From;
	b=DPi3U6fYf+qTCe0sAZGc8tCPRLEXiHbPmpFwOWejI+uv0eCAf1bJ+HbGpvKIt1zM3
	 Avn0WWagCj9zOjtUddae5J/gKGE4dAGKkf023N8S0x8mYt/f6PURiSh00wwGT/9Or1
	 f5PwLHSl3tsvrqAndKmMH8UEzVFaqY1ovNzbBAXc=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726403AbgHRC4l (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 17 Aug 2020 22:56:41 -0400
Received: from mail.kernel.org ([198.145.29.99]:34972 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726365AbgHRC4l (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 17 Aug 2020 22:56:41 -0400
Received: from sol.localdomain (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id F38132054F
        for <linux-fscrypt@vger.kernel.org>; Tue, 18 Aug 2020 02:56:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1597719401;
        bh=8toQyHiJ3+QrJ66JO76cYSUVxRqL5N8Two2wxzvfBxM=;
        h=Date:From:To:Subject:From;
        b=pZxCZuoLiTDnF/fVTBqeqZVzRv83SFoSJiZ5J3n0px8sYnOuTcmTPcpA/TRCic7Vl
         yyejvhLryCWXAhWTL+cTsrYpealxpJ9mJgesWzHs5ch8ahBjYDK3R4+4ZLwmIjnPF+
         BBhsgOIAmPj66bOwoUf1uZ7/eDzJhAqdktLXroLA=
Date:   Mon, 17 Aug 2020 19:56:39 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Subject: [ANNOUNCE] fsverity-utils v1.2
Message-ID: <20200818025639.GA1156@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

I've released fsverity-utils v1.2:

Git: https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/fsverity-utils.git/tag/?h=v1.2
Tarball: https://kernel.org/pub/linux/kernel/people/ebiggers/fsverity-utils/v1.2/

Release notes:

  * Changed license from GPL to MIT.

  * Fixed build error when /bin/sh is dash.

- Eric
