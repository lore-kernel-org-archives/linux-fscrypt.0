Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D5C6C433FE
	for <linux-fscrypt@archiver.kernel.org>; Fri, 11 Dec 2020 19:49:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 34BE823EF5
	for <linux-fscrypt@archiver.kernel.org>; Fri, 11 Dec 2020 19:49:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392755AbgLKSM6 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 11 Dec 2020 13:12:58 -0500
Received: from mail.kernel.org ([198.145.29.99]:44894 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2392763AbgLKSMy (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 11 Dec 2020 13:12:54 -0500
Date:   Fri, 11 Dec 2020 10:12:12 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1607710334;
        bh=mHRhHK/uPbQfjsIdHi95Bh/ntFtEmWkWCTpNoAuwNks=;
        h=From:To:Cc:Subject:References:In-Reply-To:From;
        b=ba/F2KmiBuXm1Fa5WG+ONGi+feUdILjz3bwClOatJSHb/nxSffb7iVWbQjGQxhKJz
         hdXOxE0hvAHPzJVv9epsIPEW67tryUUuGz+VEcM6W3ohp0ceZ+Lqxs9KKbGX9wYILY
         hAxVI1TFoQq8pm7mWsoMCrkintqFcnNKVeJvovCBGol6uYP55DMRaimCzWjD5b9DTE
         IOEYIP9UC2ESaf6+gHaihtIu2OF2acSex7q+abe89VoZshfVl00zNpZjmyWn01OZhc
         OQUQJnPvRHPsjW0MNP8fttuejAGzkkhFZ20K2sQgb0jjNnLQhiSCrM/wDGsFq9ODtV
         pVBIZLy3YElyA==
From:   Eric Biggers <ebiggers@kernel.org>
To:     Chirantan Ekbote <chirantan@chromium.org>
Cc:     Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel@vger.kernel.org,
        Dylan Reid <dgreid@chromium.org>,
        Suleiman Souhlal <suleiman@chromium.org>,
        fuse-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH v2 2/2] fuse: Support FS_IOC_GET_ENCRYPTION_POLICY_EX
Message-ID: <X9O2fJBjgKsOiIAy@sol.localdomain>
References: <20201207040303.906100-1-chirantan@chromium.org>
 <20201208093808.1572227-1-chirantan@chromium.org>
 <20201208093808.1572227-3-chirantan@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201208093808.1572227-3-chirantan@chromium.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Dec 08, 2020 at 06:38:08PM +0900, Chirantan Ekbote wrote:
> Chrome OS would like to support this ioctl when passed through the fuse
> driver. However since it is dynamically sized, we can't rely on the
> length encoded in the command.  Instead check the `policy_size` field of
> the user provided parameter to get the max length of the data returned
> by the server.
> 
> Signed-off-by: Chirantan Ekbote <chirantan@chromium.org>

Reviewed-by: Eric Biggers <ebiggers@google.com>
