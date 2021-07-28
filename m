Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC34BC4338F
	for <linux-fscrypt@archiver.kernel.org>; Wed, 28 Jul 2021 14:32:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B6A5960F5E
	for <linux-fscrypt@archiver.kernel.org>; Wed, 28 Jul 2021 14:32:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235480AbhG1OcP (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 28 Jul 2021 10:32:15 -0400
Received: from smtp-out1.suse.de ([195.135.220.28]:39362 "EHLO
        smtp-out1.suse.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235405AbhG1OcP (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 28 Jul 2021 10:32:15 -0400
Received: from relay2.suse.de (relay2.suse.de [149.44.160.134])
        by smtp-out1.suse.de (Postfix) with ESMTP id 3DC8022307;
        Wed, 28 Jul 2021 14:32:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1627482732;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=xOYNM5gi0iTVS8nzgQd/fnnIhJ4MjXFXi0+RdDpaT6s=;
        b=oPHRjAqgiZpxcgoayTxgHJ4ProRWmxoPzEsImtHp+zkf0sJxO27HGATJSw+ITpL2mxZ4Ht
        znWSPLTgHZcEmgHDkFQVXi8NDGu+H4WmJrVioG3Mu0gegFwbPvOf+t818jBM1qmlJ+BHML
        hAn7YOrSfx6xEh4QRkTm1Gyt85G56MA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1627482732;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=xOYNM5gi0iTVS8nzgQd/fnnIhJ4MjXFXi0+RdDpaT6s=;
        b=p+zrkEVPfCkahtsZ2X3S1rp1vLggQq+UOxMoi1phe/M4Ku9P8Mt4ghkuHv0BqRDt9Ukxx+
        fUDNfBSseXrCmvCg==
Received: from ds.suse.cz (ds.suse.cz [10.100.12.205])
        by relay2.suse.de (Postfix) with ESMTP id 328D4A3B81;
        Wed, 28 Jul 2021 14:32:12 +0000 (UTC)
Received: by ds.suse.cz (Postfix, from userid 10065)
        id 3A50CDA8A7; Wed, 28 Jul 2021 16:29:27 +0200 (CEST)
Date:   Wed, 28 Jul 2021 16:29:27 +0200
From:   David Sterba <dsterba@suse.cz>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     Boris Burkov <boris@bur.io>, linux-btrfs@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, kernel-team@fb.com
Subject: Re: [PATCH v6 2/3] btrfs: initial fsverity support
Message-ID: <20210728142927.GK5047@twin.jikos.cz>
Reply-To: dsterba@suse.cz
Mail-Followup-To: dsterba@suse.cz, Eric Biggers <ebiggers@kernel.org>,
        Boris Burkov <boris@bur.io>, linux-btrfs@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, kernel-team@fb.com
References: <cover.1625083099.git.boris@bur.io>
 <797d6524e4e6386fc343cd5d0bcdd53878a6593e.1625083099.git.boris@bur.io>
 <YOsFyCA1QIKlgHFh@quark.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <YOsFyCA1QIKlgHFh@quark.localdomain>
User-Agent: Mutt/1.5.23.1-rc1 (2014-03-12)
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Sun, Jul 11, 2021 at 09:52:56AM -0500, Eric Biggers wrote:
> On Wed, Jun 30, 2021 at 01:01:49PM -0700, Boris Burkov wrote:
> > Add support for fsverity in btrfs. To support the generic interface in
> > fs/verity, we add two new item types in the fs tree for inodes with
> > verity enabled. One stores the per-file verity descriptor and btrfs
> > verity item and the other stores the Merkle tree data itself.
> > 
> > Verity checking is done in end_page_read just before a page is marked
> > uptodate. This naturally handles a variety of edge cases like holes,
> > preallocated extents, and inline extents. Some care needs to be taken to
> > not try to verity pages past the end of the file, which are accessed by
> > the generic buffered file reading code under some circumstances like
> > reading to the end of the last page and trying to read again. Direct IO
> > on a verity file falls back to buffered reads.
> > 
> > Verity relies on PageChecked for the Merkle tree data itself to avoid
> > re-walking up shared paths in the tree. For this reason, we need to
> > cache the Merkle tree data. Since the file is immutable after verity is
> > turned on, we can cache it at an index past EOF.
> > 
> > Use the new inode ro_flags to store verity on the inode item, so that we
> > can enable verity on a file, then rollback to an older kernel and still
> > mount the file system and read the file. Since we can't safely write the
> > file anymore without ruining the invariants of the Merkle tree, we mark
> > a ro_compat flag on the file system when a file has verity enabled.
> > 
> > Reported-by: kernel test robot <lkp@intel.com>
> > Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> > Co-developed-by: Chris Mason <clm@fb.com>
> > Signed-off-by: Chris Mason <clm@fb.com>
> > Signed-off-by: Boris Burkov <boris@bur.io>
> 
> Generally looks good, feel free to add:
> 
> Acked-by: Eric Biggers <ebiggers@google.com>
> 
> A few minor comments below:

Thanks for the comments. Lots of them are minor fixups, I can do that
when applying the patch. There are some questions that I'll leave to
Boris to answer, I don't think they'd prevent merging the patches now
and fixing up later.
