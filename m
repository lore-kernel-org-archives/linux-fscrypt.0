Return-Path: <SRS0=StmZ=YP=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93B81CA9EA0
	for <linux-fscrypt@archiver.kernel.org>; Tue, 22 Oct 2019 13:30:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6B5A621872
	for <linux-fscrypt@archiver.kernel.org>; Tue, 22 Oct 2019 13:30:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732042AbfJVNa2 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 22 Oct 2019 09:30:28 -0400
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:57480 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1730981AbfJVNa2 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 22 Oct 2019 09:30:28 -0400
Received: from callcc.thunk.org (guestnat-104-133-0-98.corp.google.com [104.133.0.98] (may be forged))
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x9MDU3no022015
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Tue, 22 Oct 2019 09:30:04 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
        id E1AD6420456; Tue, 22 Oct 2019 09:30:01 -0400 (EDT)
Date:   Tue, 22 Oct 2019 09:30:01 -0400
From:   "Theodore Y. Ts'o" <tytso@mit.edu>
To:     Dave Chinner <david@fromorbit.com>, linux-fscrypt@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, Satya Tangirala <satyat@google.com>,
        Paul Crowley <paulcrowley@google.com>,
        Paul Lawrence <paullawrence@google.com>,
        Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH 1/3] fscrypt: add support for inline-encryption-optimized
 policies
Message-ID: <20191022133001.GA23268@mit.edu>
References: <20191021230355.23136-1-ebiggers@kernel.org>
 <20191021230355.23136-2-ebiggers@kernel.org>
 <20191022052712.GA2083@dread.disaster.area>
 <20191022060004.GA333751@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191022060004.GA333751@sol.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Oct 21, 2019 at 11:00:04PM -0700, Eric Biggers wrote:
> That won't work because we need consecutive file blocks to have consecutive IVs
> as often as possible.  The crypto support in the UFS and EMMC standards takes
> only a single 64-bit "data unit number" (DUN) per request, which the hardware
> uses as the first 64 bits of the IV and automatically increments for each data
> unit (i.e. for each filesystem block, in this case).

It seems very likely that for systems that are using UFS and eMMC
(which are overwhelming lower-end devices --- e.g., embedded and
mobile handsets) 32-bit inode and logical block numbers will be just
fine.

If and when we actually get inline crypto support for server-class
systems, hopefully they will support 128-bit DUN's, and/or they will
have sufficiently fast key load times such that we can use per-file
keying.

> An alternative which would work nicely on ext4 and xfs (if xfs supported
> fscrypt) would be to pass the physical block number as the DUN.  However, that
> wouldn't work at all on f2fs because f2fs moves data blocks around.  And since
> most people who want to use this are using f2fs, f2fs support is essential.

And that is something fscrypt supports already, so if people really
did want to use 64-bit logical block numbers, they could do that, at
the cost of giving up the ability to shrink the file system (which XFS
doesn't support anyway....)

							- Ted
