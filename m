Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4089C001B0
	for <linux-fscrypt@archiver.kernel.org>; Sat, 12 Aug 2023 22:34:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230078AbjHLWeo (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 12 Aug 2023 18:34:44 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55512 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229589AbjHLWeh (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 12 Aug 2023 18:34:37 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1D5931985;
        Sat, 12 Aug 2023 15:34:41 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id ACF236188F;
        Sat, 12 Aug 2023 22:34:40 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BE908C433C8;
        Sat, 12 Aug 2023 22:34:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1691879680;
        bh=CQDg6zUXw3J0ox/1/CzOeuQlFKtmCULtOMLvAiXWZ0Q=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=qOeh19aacJOszFonsaIDiB7w1eut04TUwN+yPihdBeTdVvTZ0mUsJfOImF+8fSkg8
         Ux6Dy+EzWnqIHe3GOnCwXnFex32m8Wmv4kPoHsgqjL6W+eoX0PXIQB8ItxHoz1PPuY
         EGL+fxlda1JSdOJj6/ncSuBDIBzU/87SSrh6d2Igd2uC0EsMJmEdEvtXBhKHgQuS6A
         nHBJz1jTqoj4d0A2w88h1vutyGqdDAJI+bQ8FyyKMxsAGA9wz5rTychwoOWKI593Uk
         iRLLTkuxcKm4ioj1RHyFlydisjwDBEA3h6s2iTl9c1JZyTuT8wrMGKsOSlRexwbw2F
         ltusL38kUUL+w==
Date:   Sat, 12 Aug 2023 15:34:08 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Cc:     Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
        David Sterba <dsterba@suse.com>,
        "Theodore Y . Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, kernel-team@meta.com,
        linux-btrfs@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH v3 12/16] fscrypt: save session key credentials for
 extent infos
Message-ID: <20230812223408.GA41642@sol.localdomain>
References: <cover.1691505882.git.sweettea-kernel@dorminy.me>
 <bb78cdd486094afb51c431c089d92f951f391c6d.1691505882.git.sweettea-kernel@dorminy.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bb78cdd486094afb51c431c089d92f951f391c6d.1691505882.git.sweettea-kernel@dorminy.me>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Aug 08, 2023 at 01:08:29PM -0400, Sweet Tea Dorminy wrote:
> For v1 encryption policies using per-session keys, the thread which
> opens the inode and therefore initializes the encryption info is part of
> the session, so it can get the key from the session keyring. However,
> for extent encryption, the extent infos are likely loaded from a
> different thread, which does not have access to the session keyring.
> This change saves the credentials of the inode opening thread and reuses
> those credentials temporarily when dealing with extent infos, allowing
> finding the encryption key correctly.
> 
> v1 encryption policies using per-session keys should probably not exist
> for new usages such as extent encryption, but this makes more tests
> work without change; maybe the right answer is to disallow v1 session
> keys plus extent encryption and deal with editing tests to not use v1
> session encryption so much.
> 
> Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>

I don't understand why you would need to look up the master key for each extent.
The master key should just come from the inode, which the master key was already
looked up for when the file was opened.

- Eric
