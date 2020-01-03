Return-Path: <SRS0=g9fr=2Y=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6218BC2D0C2
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 16:46:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3326D2072C
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 16:46:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1578069989;
	bh=ZOD+GqzkVuTHOS6C3Rl28U7LUU9+JZEftu8qXbGZ5po=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=Ob1Q6mWiduAifW7qSkTnm0otBicV4G8vkb4nt5gw307UIE/wj/5/LefjHdftEEwBD
	 nZ0U1P8aDOF39mP/KnZukrcpryAysI9wTIJYqop0OiMHUywPglKxAQzX7bWBh3BHzF
	 D8yscxe56Ttd8b0V0vvlHUYnSeUVNSmNx6w0EOf0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727952AbgACQq2 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 3 Jan 2020 11:46:28 -0500
Received: from mail.kernel.org ([198.145.29.99]:60022 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727912AbgACQq2 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 3 Jan 2020 11:46:28 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id ECDE3206E6;
        Fri,  3 Jan 2020 16:46:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1578069988;
        bh=ZOD+GqzkVuTHOS6C3Rl28U7LUU9+JZEftu8qXbGZ5po=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=G8PqknC0mihmVKoPyedRSgw6LJL5DY8cB3kO7POi4DQYUY+6nzDPmn21Ig7BiOKUe
         0LWTpUhR9GKCzXiD/mXOx+tX2edMh8MArwNMbvFE3uvHtQEOUvDB+ko5yiYdhf5AqL
         WZKXN7JTX7vGKC/I1TYGRNKIXd60rRv3Fy12RYe4=
Date:   Fri, 3 Jan 2020 08:46:26 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     fstests@vger.kernel.org, Eryu Guan <guaneryu@gmail.com>
Cc:     linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>
Subject: Re: [PATCH v2 0/5] xfstests: verify ciphertext of IV_INO_LBLK_64
 encryption policies
Message-ID: <20200103164626.GA19521@gmail.com>
References: <20191202230155.99071-1-ebiggers@kernel.org>
 <20191209181826.GC149190@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191209181826.GC149190@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Dec 09, 2019 at 10:18:27AM -0800, Eric Biggers wrote:
> On Mon, Dec 02, 2019 at 03:01:50PM -0800, Eric Biggers wrote:
> > Hello,
> > 
> > This series adds an xfstest which tests that the encryption for
> > IV_INO_LBLK_64 encryption policies is being done correctly.
> > 
> > IV_INO_LBLK_64 is a new fscrypt policy flag which modifies the
> > encryption to be optimized for inline encryption hardware compliant with
> > the UFS v2.1 standard or the upcoming version of the eMMC standard.  For
> > more information, see the kernel patchset:
> > https://lore.kernel.org/linux-fscrypt/20191024215438.138489-1-ebiggers@kernel.org/T/#u
> > 
> > The kernel patches have been merged into mainline and will be in v5.5.
> > 
> > In addition to the latest kernel, to run on ext4 this test also needs a
> > version of e2fsprogs built from the master branch, in order to get
> > support for formatting the filesystem with '-O stable_inodes'.
> > 
> > As usual, the test will skip itself if the prerequisites aren't met.
> > 
> > No real changes since v1; just rebased onto the latest xfstests master
> > branch and updated the cover letter.
> > 
> > Eric Biggers (5):
> >   fscrypt-crypt-util: create key_and_iv_params structure
> >   fscrypt-crypt-util: add HKDF context constants
> >   common/encrypt: create named variables for UAPI constants
> >   common/encrypt: support verifying ciphertext of IV_INO_LBLK_64
> >     policies
> >   generic: verify ciphertext of IV_INO_LBLK_64 encryption policies
> > 
> >  common/encrypt           | 126 +++++++++++++++++++++++++-------
> >  src/fscrypt-crypt-util.c | 151 ++++++++++++++++++++++++++++-----------
> >  tests/generic/805        |  43 +++++++++++
> >  tests/generic/805.out    |   6 ++
> >  tests/generic/group      |   1 +
> >  5 files changed, 259 insertions(+), 68 deletions(-)
> >  create mode 100644 tests/generic/805
> >  create mode 100644 tests/generic/805.out
> > 
> 
> Ping.  Does anyone want to take a look at this?  Satya?
> 

Eryu, can you review and consider applying this series?  It doesn't look like
anyone else is going to formally review it.

Thanks,

- Eric
