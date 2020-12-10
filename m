Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52470C433FE
	for <linux-fscrypt@archiver.kernel.org>; Thu, 10 Dec 2020 19:20:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0CFE623D9A
	for <linux-fscrypt@archiver.kernel.org>; Thu, 10 Dec 2020 19:20:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388934AbgLJTU3 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 10 Dec 2020 14:20:29 -0500
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:52256 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S2389053AbgLJTUZ (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 10 Dec 2020 14:20:25 -0500
Received: from callcc.thunk.org (pool-72-74-133-215.bstnma.fios.verizon.net [72.74.133.215])
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 0BAJJYRr005124
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Thu, 10 Dec 2020 14:19:35 -0500
Received: by callcc.thunk.org (Postfix, from userid 15806)
        id 48919420136; Thu, 10 Dec 2020 14:19:34 -0500 (EST)
Date:   Thu, 10 Dec 2020 14:19:34 -0500
From:   "Theodore Y. Ts'o" <tytso@mit.edu>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>
Subject: Re: [xfstests-bld PATCH] android-xfstests: create /dev/fd on the
 Android device
Message-ID: <20201210191934.GT52960@mit.edu>
References: <20201209043305.77917-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201209043305.77917-1-ebiggers@kernel.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Dec 08, 2020 at 08:33:05PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> In order for bash process substitution (the syntax like "<(list)" or
> ">(list)") to work, /dev/fd has to be a symlink to /proc/self/fd.
> /dev/fd doesn't exist on Android, so create it if it's missing.
> 
> This fixes xfstest generic/576.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

						- Ted
