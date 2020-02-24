Return-Path: <SRS0=VJke=4M=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30721C38BE7
	for <linux-fscrypt@archiver.kernel.org>; Mon, 24 Feb 2020 20:50:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EFF8A218AC
	for <linux-fscrypt@archiver.kernel.org>; Mon, 24 Feb 2020 20:50:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1582577455;
	bh=3ws2XCyy6ILZso2oH4i/yzvd9uzvxwvQWJJv4TRuz70=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=1YwBSajKhqEIKDlpyIWSlWCK4IgVFJ7gmp90kRLNJYGkHypJi34eV6YXA3UeLKjBp
	 O0LwksCwU/mGeqFLPwx6e1A8wUTdqqO5D0p6oiTBACHUKpQnmR1zf8ms5GmYIkBC72
	 IsV3nY8DrSe7LC6wxhjT51kSVsG+EgwlF8CggTDI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727421AbgBXUuy (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 24 Feb 2020 15:50:54 -0500
Received: from mail.kernel.org ([198.145.29.99]:36942 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727249AbgBXUux (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 24 Feb 2020 15:50:53 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1FAF220726;
        Mon, 24 Feb 2020 20:50:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1582577453;
        bh=3ws2XCyy6ILZso2oH4i/yzvd9uzvxwvQWJJv4TRuz70=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=I9K9/4BBR6t94BgsvQWvL0MElmPNMiRWdsQHvAkOcAoRolDDWAYFaRQbGHAX/th9Y
         RfGNU35wJz/tbi+gRRQcx+ddhCAfCvP4LZS2XAnCxT4tDvB3hZsUZzmiW3hP0rlS1M
         0H4NWqJWja70WOgXrjABzy9YWTQImgBaVYFeNivo=
Date:   Mon, 24 Feb 2020 12:50:51 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     mtk.manpages@gmail.com
Cc:     linux-man@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org
Subject: Re: [man-pages PATCH v2] statx.2: document STATX_ATTR_VERITY
Message-ID: <20200224205051.GE109047@gmail.com>
References: <20200128192449.260550-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200128192449.260550-1-ebiggers@kernel.org>
User-Agent: Mutt/1.12.2 (2019-09-21)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Jan 28, 2020 at 11:24:49AM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Document the verity attribute for statx(), which was added in
> Linux 5.5.
> 
> For more context, see the fs-verity documentation:
> https://www.kernel.org/doc/html/latest/filesystems/fsverity.html
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  man2/statx.2 | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/man2/statx.2 b/man2/statx.2
> index d2f1b07b8..d015ee73d 100644
> --- a/man2/statx.2
> +++ b/man2/statx.2
> @@ -461,6 +461,11 @@ See
>  .TP
>  .B STATX_ATTR_ENCRYPTED
>  A key is required for the file to be encrypted by the filesystem.
> +.TP
> +.B STATX_ATTR_VERITY
> +Since Linux 5.5: the file has fs-verity enabled.  It cannot be written to, and
> +all reads from it will be verified against a cryptographic hash that covers the
> +entire file, e.g. via a Merkle tree.
>  .SH RETURN VALUE
>  On success, zero is returned.
>  On error, \-1 is returned, and
> -- 
> 2.25.0.341.g760bfbb309-goog
> 

Ping?  Michael, can you apply this man-pages patch?

- Eric
