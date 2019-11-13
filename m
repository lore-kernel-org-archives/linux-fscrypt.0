Return-Path: <SRS0=DXB5=ZF=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB2E5C432C3
	for <linux-fscrypt@archiver.kernel.org>; Wed, 13 Nov 2019 20:19:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 68203206F2
	for <linux-fscrypt@archiver.kernel.org>; Wed, 13 Nov 2019 20:19:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1573676356;
	bh=j4gN5NwjBXBqoaj2hP3JnJYtyUSYX8bUB1lxuJirsFQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=wJumuSuvyM7FcGpkUvUPEHQtK41x0aPlilvi/rI+o3VMH/HLqIAjzEgnE6bXBsO3u
	 SWN03ouRuRdfnSb7aLBDBpOT4fm9Gw5ZEtUHYBmlhoqOBa1nu+x0Cqy0kmapfIr7Y6
	 XaNcLJDufRyX+qez0m1Mvf0XmJ6sOmzDMc1+g4nA=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726410AbfKMUTP (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 13 Nov 2019 15:19:15 -0500
Received: from mail.kernel.org ([198.145.29.99]:49236 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726179AbfKMUTP (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 13 Nov 2019 15:19:15 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id EABCB206EF;
        Wed, 13 Nov 2019 20:19:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1573676355;
        bh=j4gN5NwjBXBqoaj2hP3JnJYtyUSYX8bUB1lxuJirsFQ=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=d1SPOgo+YLlhI7eIc/HM7xo3j4m7eFhYIqoqJtwFcO7Ik8PFl+TXKyqaozsEFO2N2
         2Ow+eQ9wJFntacwFDb7yOVvjpEYYbhwI67BOSydN8S8WikS/zHAy5YlYefGXZ2P2fG
         rwWMrauVIkErWIYMVi4KW1naelLhv8hKz3JdfOOs=
Date:   Wed, 13 Nov 2019 12:19:12 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Subject: Re: [PATCH] docs: fs-verity: document first supported kernel version
Message-ID: <20191113201911.GF221701@gmail.com>
Mail-Followup-To: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net
References: <20191030221915.229858-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191030221915.229858-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Oct 30, 2019 at 03:19:15PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> I had meant to replace these TODOs with the actual version when applying
> the patches, but forgot to do so.  Do it now.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  Documentation/filesystems/fsverity.rst | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/filesystems/fsverity.rst b/Documentation/filesystems/fsverity.rst
> index 3355377a2439..a95536b6443c 100644
> --- a/Documentation/filesystems/fsverity.rst
> +++ b/Documentation/filesystems/fsverity.rst
> @@ -406,7 +406,7 @@ pages have been read into the pagecache.  (See `Verifying data`_.)
>  ext4
>  ----
>  
> -ext4 supports fs-verity since Linux TODO and e2fsprogs v1.45.2.
> +ext4 supports fs-verity since Linux v5.4 and e2fsprogs v1.45.2.
>  
>  To create verity files on an ext4 filesystem, the filesystem must have
>  been formatted with ``-O verity`` or had ``tune2fs -O verity`` run on
> @@ -442,7 +442,7 @@ also only supports extent-based files.
>  f2fs
>  ----
>  
> -f2fs supports fs-verity since Linux TODO and f2fs-tools v1.11.0.
> +f2fs supports fs-verity since Linux v5.4 and f2fs-tools v1.11.0.
>  
>  To create verity files on an f2fs filesystem, the filesystem must have
>  been formatted with ``-O verity``.
> -- 
> 2.23.0
> 

Applied to fscrypt.git#fsverity for 5.5.

- Eric
