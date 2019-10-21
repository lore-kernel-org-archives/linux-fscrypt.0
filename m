Return-Path: <SRS0=xftb=YO=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E05F2CA9EAF
	for <linux-fscrypt@archiver.kernel.org>; Mon, 21 Oct 2019 20:28:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AA12A20882
	for <linux-fscrypt@archiver.kernel.org>; Mon, 21 Oct 2019 20:28:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1571689694;
	bh=yuyYH5txUJFQLMmsUgKioVsaetUA4KvG58kwl612GrY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=swPM22Dp4uPx8Im6rMeCYfNkCZKXXtkSxXjXALgzdmRyOash+QXc3ADCetRGAswiu
	 vPx5Gvidh8pInKsKUxoiq3GOBGp+Z0YlJ/LxyDKVXDhIeaSE2/21apVTqXJ8S1fzJD
	 mR0/6WOeEt2HcNRyBW5NyZmN7p8ciFelCXjU9E3s=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728914AbfJUU2O (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 21 Oct 2019 16:28:14 -0400
Received: from mail.kernel.org ([198.145.29.99]:40634 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726672AbfJUU2O (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 21 Oct 2019 16:28:14 -0400
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 95FF12067B;
        Mon, 21 Oct 2019 20:28:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1571689693;
        bh=yuyYH5txUJFQLMmsUgKioVsaetUA4KvG58kwl612GrY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=an64t09Xy6VRXqPUL3GAIscODkfzQVFm3dpCFD2yIaAOE6cETIfhBMD87q+snEVE5
         Rom5MN9qzxQyKuQxxFpZ/OaBDo1FMMMEv9GyNL58gw4pnsTnZfAmj0n8bJyss80aop
         /MWy7freDt/FEOXG2dZ+xcYBu84nosqqtIrbVFc0=
Date:   Mon, 21 Oct 2019 13:28:12 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     "Theodore Y . Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH] fscrypt: remove struct fscrypt_ctx
Message-ID: <20191021202811.GB122863@gmail.com>
Mail-Followup-To: linux-fscrypt@vger.kernel.org,
        "Theodore Y . Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        Chandan Rajendra <chandan@linux.ibm.com>
References: <20191009234038.224587-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <20191009234038.224587-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org
Message-ID: <20191021202812.clUfavebHcc_LJVCb4iB4NzvGYiGEbHQnCVYJcnQhFA@z>

On Wed, Oct 09, 2019 at 04:40:38PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Now that ext4 and f2fs implement their own post-read workflow that
> supports both fscrypt and fsverity, the fscrypt-only workflow based
> around struct fscrypt_ctx is no longer used.  So remove the unused code.
> 
> This is based on a patch from Chandan Rajendra's "Consolidate FS read
> I/O callbacks code" patchset, but rebased onto the latest kernel, folded
> __fscrypt_decrypt_bio() into fscrypt_decrypt_bio(), cleaned up
> fscrypt_initialize(), and updated the commit message.
> 
> Originally-from: Chandan Rajendra <chandan@linux.ibm.com>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied to fscrypt.git for 5.5.

- Eric
