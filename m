Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C61B9C3A5A7
	for <linux-fscrypt@archiver.kernel.org>; Tue,  6 Dec 2022 21:04:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229847AbiLFVE5 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 6 Dec 2022 16:04:57 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51378 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229840AbiLFVEw (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 6 Dec 2022 16:04:52 -0500
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu [18.9.28.11])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B059747316;
        Tue,  6 Dec 2022 13:04:50 -0800 (PST)
Received: from cwcc.thunk.org (pool-173-48-120-46.bstnma.fios.verizon.net [173.48.120.46])
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 2B6L4hb3003623
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Tue, 6 Dec 2022 16:04:44 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mit.edu; s=outgoing;
        t=1670360684; bh=fMwVX4UxKI+NUwzpQSTT4neoisRqyhXXltho6hFAv6s=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To;
        b=C3R9Naw1FOBHaZbZ/jPo0zymWFHZpNtg1gNlYf1+8WMXW1z1I9VUM5bYzvKGJ74w3
         e/95Lxv0KRF9x+P3vAdIKe6wqV9Hfc5WkHH2AWRR5c3kxFlBZQPLmLviD0wzE3n+6k
         z4rFbs4hTwFKUrp1IJJgMqmId9BdCny0M1EuWKsgf71medCamOB40yLDQfHBO9ZNbE
         6SBwIh3EeBXkDT2V1XwJNtCxC29u+pLyDE83GFvE26s99GnO6+EVWHEIgKPtQiNzmm
         q7dYRAB39d+zUAaQgDxYfbWpLqBOe+ZF7tu0B+GXjMHL6UKb7XukZ2U9e6zKI8wijO
         Aq654mE9DhOzA==
Received: by cwcc.thunk.org (Postfix, from userid 15806)
        id 2798C15C3489; Tue,  6 Dec 2022 16:04:43 -0500 (EST)
Date:   Tue, 6 Dec 2022 16:04:43 -0500
From:   "Theodore Ts'o" <tytso@mit.edu>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        Harshad Shirwadkar <harshadshirwadkar@gmail.com>
Subject: Re: [PATCH 0/7] ext4 fast-commit fixes
Message-ID: <Y4+ua2XftbAYd8xq@mit.edu>
References: <20221106224841.279231-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221106224841.279231-1-ebiggers@kernel.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Sun, Nov 06, 2022 at 02:48:34PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@kernel.org
> 
> This series fixes several bugs in the fast-commit feature.
> 
> Patch 6 may be the most controversial patch of this series, since it
> would make old kernels unable to replay fast-commit journals created by
> new kernels.  I'd appreciate any thoughts on whether that's okay.  I can
> drop that patch if needed.

Mumble.  Normally, it's something we would avoid, since there aren't
that many users using fast commit, since it's not enabled by default.
And given that the off-by-one errors are bugs, an it's a question of
old kernels requiring a pretty buggy layout, the question is whether
it's worth it to do an explicit version / feature flag and support
both for some period of time.

I'm inclined to say no, and just let things slide, and instead make
sure that e2fsck can handle both the old and the new format, and let
that handle the fast commit replay if necessary.

Harshad, what do you think?

						- Ted
