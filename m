Return-Path: <SRS0=OJVQ=BQ=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAF62C43445
	for <linux-fscrypt@archiver.kernel.org>; Thu,  6 Aug 2020 11:01:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C422922CBB
	for <linux-fscrypt@archiver.kernel.org>; Thu,  6 Aug 2020 11:01:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725817AbgHFFg3 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 6 Aug 2020 01:36:29 -0400
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:48115 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1725440AbgHFFg3 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 6 Aug 2020 01:36:29 -0400
Received: from callcc.thunk.org (pool-96-230-252-158.bstnma.fios.verizon.net [96.230.252.158])
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 0765aJdd029747
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Thu, 6 Aug 2020 01:36:20 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
        id BA71E420263; Thu,  6 Aug 2020 01:36:19 -0400 (EDT)
Date:   Thu, 6 Aug 2020 01:36:19 -0400
From:   tytso@mit.edu
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     linux-ext4@vger.kernel.org,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fscrypt@vger.kernel.org, Jiaheng Hu <jiahengh@google.com>
Subject: Re: [PATCH] ext4: use generic names for generic ioctls
Message-ID: <20200806053619.GJ7657@mit.edu>
References: <20200714230909.56349-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200714230909.56349-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Jul 14, 2020 at 04:09:09PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Don't define EXT4_IOC_* aliases to ioctls that already have a generic
> FS_IOC_* name.  These aliases are unnecessary, and they make it unclear
> which ioctls are ext4-specific and which are generic.
> 
> Exception: leave EXT4_IOC_GETVERSION_OLD and EXT4_IOC_SETVERSION_OLD
> as-is for now, since renaming them to FS_IOC_GETVERSION and
> FS_IOC_SETVERSION would probably make them more likely to be confused
> with EXT4_IOC_GETVERSION and EXT4_IOC_SETVERSION which also exist.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
