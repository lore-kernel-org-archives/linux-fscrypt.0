Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37DC6C2B9F8
	for <linux-fscrypt@archiver.kernel.org>; Tue, 25 May 2021 18:12:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 11C73613F6
	for <linux-fscrypt@archiver.kernel.org>; Tue, 25 May 2021 18:12:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230491AbhEYSN5 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 25 May 2021 14:13:57 -0400
Received: from mail.kernel.org ([198.145.29.99]:38694 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229819AbhEYSNx (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 25 May 2021 14:13:53 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 08106613F6;
        Tue, 25 May 2021 18:12:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1621966343;
        bh=cFrrdY8Ap+EPQTOzQz9fhlEp0y3eRjgVjURZ+YE6z8I=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=EFbvcDv+iJGMGCTKAl/zvu64N9sqowA509Drgu70yyERY4LLsWJpxZRwX9hwV7B0n
         WcAmVZmM/V8buqDgpVS5J01q3j6lef+zUYINpgLabBnAA9ovNfVMtxjemDu0jHIhwi
         8bNFg0OIdk1dxuyFgZjYglAY0LUdNgAj3j3gdC535LH8bHFsVTdvMqzLCsQRzBo/0n
         q11aTJYCtj+FI9vaIdQM3GO2wqDbcjYnbY3KYh7+kGhOligM2aqPmwagQmKnbsYgWs
         VDtMUiZd+lUwkQNnVWvxioMn2jfzKMWt2yWdns47FY1Mtp86xMBdR03C5Go+UOs4zF
         GGDQQoh0A8AQQ==
Date:   Tue, 25 May 2021 11:12:21 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Boris Burkov <boris@bur.io>
Cc:     linux-btrfs@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        kernel-team@fb.com
Subject: Re: [PATCH v4 1/5] btrfs: add compat_flags to btrfs_inode_item
Message-ID: <YK0+BU9twmldQ9Q0@sol.localdomain>
References: <cover.1620241221.git.boris@bur.io>
 <6ed83a27f88e18f295f7d661e9c87e7ec7d33428.1620241221.git.boris@bur.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6ed83a27f88e18f295f7d661e9c87e7ec7d33428.1620241221.git.boris@bur.io>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, May 05, 2021 at 12:20:39PM -0700, Boris Burkov wrote:
> The tree checker currently rejects unrecognized flags when it reads
> btrfs_inode_item. Practically, this means that adding a new flag makes
> the change backwards incompatible if the flag is ever set on a file.
> 
> Take up one of the 4 reserved u64 fields in the btrfs_inode_item as a
> new "compat_flags". These flags are zero on inode creation in btrfs and
> mkfs and are ignored by an older kernel, so it should be safe to use
> them in this way.
> 
> Signed-off-by: Boris Burkov <boris@bur.io>

This patchset doesn't have a cover letter anymore for some reason.

Also, please mention where this patchset applies to.  I tried mainline and
btrfs/for-next, but neither works.

- Eric
