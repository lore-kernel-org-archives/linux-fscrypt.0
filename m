Return-Path: <SRS0=MaxI=D7=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EC2DC2D0A3
	for <linux-fscrypt@archiver.kernel.org>; Sat, 24 Oct 2020 04:07:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 07EE02225E
	for <linux-fscrypt@archiver.kernel.org>; Sat, 24 Oct 2020 04:07:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1603512449;
	bh=hqh72VHTWfo2/XdP+NWPn5Z+9BF9shn0FDKDKpnUsWI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=d0dYBfiRldUucV07kG4vP7KrTdtlAEiglj19EF8X7PXH0/tieWaOAy9rBa0qCuP8O
	 HsdKh599KmZuhx8Ve1JHaPI7SMdtjsZiMA5nF8ZWB50aaXy0paVdG+gLWX+f2sRPu9
	 hkje6NsO137tk/TzxqK/tINGVzSb1mYgRITwFF9Y=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727305AbgJXEH2 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 24 Oct 2020 00:07:28 -0400
Received: from mail.kernel.org ([198.145.29.99]:42728 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726998AbgJXEH2 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 24 Oct 2020 00:07:28 -0400
Received: from sol.localdomain (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 091D622201;
        Sat, 24 Oct 2020 04:07:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1603512448;
        bh=hqh72VHTWfo2/XdP+NWPn5Z+9BF9shn0FDKDKpnUsWI=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=d11JbLSvwXv4uuQNTzUls8wFtLtmqlNOBFrNRaIoL7GUWO+T7Jx2GdA2lK8F2jhj8
         h/U2aFfU0OBMv1Hs5wWvAB62sga4YcScpAQOfnEk7d2UkN6mWyiBz0mAIoDSf0L+TE
         o+CFjSijCm/LcSfGTlDc5bNm4wdSJIb4gY6lmg3k=
Date:   Fri, 23 Oct 2020 21:07:26 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     luca.boccassi@gmail.com
Cc:     linux-fscrypt@vger.kernel.org
Subject: Re: [fsverity-utils PATCH 1/2] Use pkg-config to get libcrypto build
 flags
Message-ID: <20201024040726.GB83494@sol.localdomain>
References: <20201022175934.2999543-1-luca.boccassi@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201022175934.2999543-1-luca.boccassi@gmail.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Oct 22, 2020 at 06:59:33PM +0100, luca.boccassi@gmail.com wrote:
> From: Luca Boccassi <luca.boccassi@microsoft.com>
> 
> Especially when cross-compiling or other such cases, it might be necessary
> to pass additional compiler flags. This is commonly done via pkg-config,
> so use it if available, and fall back to the hardcoded -lcrypto if not.
> 
> Signed-off-by: Luca Boccassi <luca.boccassi@microsoft.com>
> ---
>  Makefile | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/Makefile b/Makefile
> index 3fc1bec..122c0a2 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -58,6 +58,7 @@ BINDIR          ?= $(PREFIX)/bin
>  INCDIR          ?= $(PREFIX)/include
>  LIBDIR          ?= $(PREFIX)/lib
>  DESTDIR         ?=
> +PKGCONF         ?= pkg-config
>  
>  # Rebuild if a user-specified setting that affects the build changed.
>  .build-config: FORCE
> @@ -69,7 +70,8 @@ DESTDIR         ?=
>  
>  DEFAULT_TARGETS :=
>  COMMON_HEADERS  := $(wildcard common/*.h)
> -LDLIBS          := -lcrypto
> +LDLIBS          := $(shell $(PKGCONF) libcrypto --libs 2>/dev/null || echo -lcrypto)
> +CFLAGS          += $(shell $(PKGCONF) libcrypto --cflags 2>/dev/null || echo)

There should be a way to prevent pkg-config from being used if someone wants to
link to a local copy of libcrypto.  One might expect setting PKGCONF to an empty
string to work, and it kind of does, but then the shell command executes
"libcrypto", which is strange.  How about quoting "$(PKGCONF)" so that the shell
command is guaranteed to fail as expected in that case?

- Eric
