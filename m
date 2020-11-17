Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91E5FC63798
	for <linux-fscrypt@archiver.kernel.org>; Tue, 17 Nov 2020 17:36:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 411482466D
	for <linux-fscrypt@archiver.kernel.org>; Tue, 17 Nov 2020 17:36:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729525AbgKQRfl (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 17 Nov 2020 12:35:41 -0500
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:56908 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1729476AbgKQRfl (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 17 Nov 2020 12:35:41 -0500
Received: from callcc.thunk.org (pool-72-74-133-215.bstnma.fios.verizon.net [72.74.133.215])
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 0AHHYlsB000862
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Tue, 17 Nov 2020 12:34:47 -0500
Received: by callcc.thunk.org (Postfix, from userid 15806)
        id 30CB5420107; Tue, 17 Nov 2020 12:34:47 -0500 (EST)
Date:   Tue, 17 Nov 2020 12:34:47 -0500
From:   "Theodore Y. Ts'o" <tytso@mit.edu>
To:     Jaegeuk Kim <jaegeuk@kernel.org>
Cc:     Daniel Rosenberg <drosen@google.com>,
        Eric Biggers <ebiggers@kernel.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Chao Yu <chao@kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Richard Weinberger <richard@nod.at>,
        linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mtd@lists.infradead.org,
        Gabriel Krisman Bertazi <krisman@collabora.com>,
        kernel-team@android.com
Subject: Re: [PATCH v2 2/3] fscrypt: Have filesystems handle their d_ops
Message-ID: <20201117173447.GF445084@mit.edu>
References: <20201117040315.28548-1-drosen@google.com>
 <20201117040315.28548-3-drosen@google.com>
 <20201117140326.GA445084@mit.edu>
 <20201117170411.GC1636127@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201117170411.GC1636127@google.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Nov 17, 2020 at 09:04:11AM -0800, Jaegeuk Kim wrote:
> 
> I'd like to pick this patch series in f2fs/dev for -next, so please let me know
> if you have any concern.

No concern for me as far as ext4 is concerned, thanks!

   	       	     	    	 - Ted
