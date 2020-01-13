Return-Path: <SRS0=g+Ji=3C=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A02B2C33CA9
	for <linux-fscrypt@archiver.kernel.org>; Mon, 13 Jan 2020 19:36:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7B94A2084D
	for <linux-fscrypt@archiver.kernel.org>; Mon, 13 Jan 2020 19:36:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728641AbgAMTga (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 13 Jan 2020 14:36:30 -0500
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:57057 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1728516AbgAMTga (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 13 Jan 2020 14:36:30 -0500
Received: from callcc.thunk.org (guestnat-104-133-0-111.corp.google.com [104.133.0.111] (may be forged))
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 00DJaO8l005571
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Mon, 13 Jan 2020 14:36:25 -0500
Received: by callcc.thunk.org (Postfix, from userid 15806)
        id 4B58F4207DF; Mon, 13 Jan 2020 14:36:24 -0500 (EST)
Date:   Mon, 13 Jan 2020 14:36:24 -0500
From:   "Theodore Y. Ts'o" <tytso@mit.edu>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH] fscrypt: document gfp_flags for bounce page allocation
Message-ID: <20200113193624.GE76141@mit.edu>
References: <20191231181026.47400-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191231181026.47400-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Dec 31, 2019 at 12:10:26PM -0600, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Document that fscrypt_encrypt_pagecache_blocks() allocates the bounce
> page from a mempool, and document what this means for the @gfp_flags
> argument.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, feel free to add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>
