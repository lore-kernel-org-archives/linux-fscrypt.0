Return-Path: <SRS0=DXB5=ZF=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D80CBC432C3
	for <linux-fscrypt@archiver.kernel.org>; Wed, 13 Nov 2019 20:20:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6A1E4206F0
	for <linux-fscrypt@archiver.kernel.org>; Wed, 13 Nov 2019 20:20:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1573676432;
	bh=/lqrjW/pn3WHkfsTZg1madMY7TYvVOk19QgXgKLRxDc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=Odi3QrEmC9JT2JT30N6diux2VdiSATYUHvht/eWADvXBPIt2O0XtIBDwLf+FE8wmD
	 xuf5vjY0EF1COs8KRfBnx/QUEhSkTVuK35MmsKGKx/Vd7b8rMwO+fLYGo+ZPy9DbAB
	 6uxXzhv2/lOWFHqMBsshW25AIggsxljV+O8Mi1GA=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726210AbfKMUUb (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 13 Nov 2019 15:20:31 -0500
Received: from mail.kernel.org ([198.145.29.99]:49466 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726179AbfKMUUb (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 13 Nov 2019 15:20:31 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id ED3B1206EF;
        Wed, 13 Nov 2019 20:20:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1573676431;
        bh=/lqrjW/pn3WHkfsTZg1madMY7TYvVOk19QgXgKLRxDc=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=wFDEg7TtVMd+mogcu4QvSikB8pCMLL6azG1RBdmMTMRHJWE+I+RkyC8kier70EeA+
         YhhotBOkCzPRNSLXgWRPX0XHp7hn9kdAY0jZzZOWpmltpdaRufbiNvdzEqrqb1c+Kk
         jgW3uy3nC/PSuLFzUniKazSIhj1GrgtCQg/x+Je8=
Date:   Wed, 13 Nov 2019 12:20:28 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-api@vger.kernel.org,
        David Howells <dhowells@redhat.com>,
        Theodore Ts'o <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Victor Hsieh <victorhsieh@google.com>
Subject: Re: [PATCH 0/4] statx: expose the fs-verity bit
Message-ID: <20191113202027.GG221701@gmail.com>
Mail-Followup-To: linux-fscrypt@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-api@vger.kernel.org,
        David Howells <dhowells@redhat.com>, Theodore Ts'o <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Victor Hsieh <victorhsieh@google.com>
References: <20191029204141.145309-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191029204141.145309-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Oct 29, 2019 at 01:41:37PM -0700, Eric Biggers wrote:
> This patchset exposes the verity bit (a.k.a. FS_VERITY_FL) via statx().
> 
> This is useful because it allows applications to check whether a file is
> a verity file without opening it.  Opening a verity file can be
> expensive because the fsverity_info is set up on open, which involves
> parsing metadata and optionally verifying a cryptographic signature.
> 
> This is analogous to how various other bits are exposed through both
> FS_IOC_GETFLAGS and statx(), e.g. the encrypt bit.
> 
> This patchset applies to v5.4-rc5.
> 
> Eric Biggers (4):
>   statx: define STATX_ATTR_VERITY
>   ext4: support STATX_ATTR_VERITY
>   f2fs: support STATX_ATTR_VERITY
>   docs: fs-verity: mention statx() support
> 
>  Documentation/filesystems/fsverity.rst | 8 ++++++++
>  fs/ext4/inode.c                        | 5 ++++-
>  fs/f2fs/file.c                         | 5 ++++-
>  include/linux/stat.h                   | 3 ++-
>  include/uapi/linux/stat.h              | 2 +-
>  5 files changed, 19 insertions(+), 4 deletions(-)

Applied to fscrypt.git#fsverity for 5.5.

- Eric
