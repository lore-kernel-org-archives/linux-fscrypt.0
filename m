Return-Path: <SRS0=rtUG=7B=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8793DC433DF
	for <linux-fscrypt@archiver.kernel.org>; Tue, 19 May 2020 14:03:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6DF2C20829
	for <linux-fscrypt@archiver.kernel.org>; Tue, 19 May 2020 14:03:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728775AbgESODL (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 19 May 2020 10:03:11 -0400
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:46684 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727057AbgESODL (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 19 May 2020 10:03:11 -0400
Received: from callcc.thunk.org (pool-100-0-195-244.bstnma.fios.verizon.net [100.0.195.244])
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 04JE2sqw025462
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Tue, 19 May 2020 10:02:54 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
        id 16462420304; Tue, 19 May 2020 10:02:54 -0400 (EDT)
Date:   Tue, 19 May 2020 10:02:53 -0400
From:   "Theodore Y. Ts'o" <tytso@mit.edu>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Daniel Rosenberg <drosen@google.com>
Subject: Re: [PATCH 3/4] fscrypt: support test_dummy_encryption=v2
Message-ID: <20200519140253.GF2396055@mit.edu>
References: <20200512233251.118314-1-ebiggers@kernel.org>
 <20200512233251.118314-4-ebiggers@kernel.org>
 <20200519025355.GC2396055@mit.edu>
 <20200519030205.GB954@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200519030205.GB954@sol.localdomain>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, May 18, 2020 at 08:02:05PM -0700, Eric Biggers wrote:
> 
> Thanks, I'll add that.  I assume you meant "Reviewed-by"?

Yes, thanks.

Reviewed-by: Theodore Ts'o <tytso@mit.edu>


				- Ted
