Return-Path: <SRS0=cslw=CR=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 915A7C43461
	for <linux-fscrypt@archiver.kernel.org>; Tue,  8 Sep 2020 16:42:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4753C206E7
	for <linux-fscrypt@archiver.kernel.org>; Tue,  8 Sep 2020 16:42:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1599583342;
	bh=zqEJfVUqeIO7gcyXpU/RQrWv768uPLWmdl436rYkjNc=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=QWQe6e+lmfgNX0cc84krpkI372esvqiSRrHxq7Ye0EKTSkSjbFRH/87E3xtdOvi92
	 WlBmYyXKt4TcytKREdscq42KSJ9LlqBP0jf6sldUCzemVc42aph6LjlMFCWCBhuD1i
	 PgdZQw57Aev8M8KhwCMUQoYqpwzn14fVXR5OtkiY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731983AbgIHQgp (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 8 Sep 2020 12:36:45 -0400
Received: from mail.kernel.org ([198.145.29.99]:33930 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732020AbgIHQbi (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 8 Sep 2020 12:31:38 -0400
Received: from tleilax.poochiereds.net (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 2522821532;
        Tue,  8 Sep 2020 12:09:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1599566955;
        bh=zqEJfVUqeIO7gcyXpU/RQrWv768uPLWmdl436rYkjNc=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=r9MkgzRhGCgNzfrsZE+kpQFUDyFuFOrz2OR0FWyHBwTO4LxMOkcSNzC3d7+5tPFiJ
         1dy/zgm27I9gPVSxdDLb5x7mtq0x55XpOtkZQkWfXLkyILImR/J06QW8FDa4VegxBc
         G9G5UKPR47OUmugugGbU3Y9WaSyowIwN9Wb6Dh+4=
Message-ID: <b71271c9573032c74eca352fdf4a9db2d2fbec3e.camel@kernel.org>
Subject: Re: [RFC PATCH v2 00/18] ceph+fscrypt: context, filename and
 symlink support
From:   Jeff Layton <jlayton@kernel.org>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     ceph-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-fscrypt@vger.kernel.org
Date:   Tue, 08 Sep 2020 08:09:14 -0400
In-Reply-To: <20200908055446.GP68127@sol.localdomain>
References: <20200904160537.76663-1-jlayton@kernel.org>
         <20200908055446.GP68127@sol.localdomain>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.36.5 (3.36.5-1.fc32) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, 2020-09-07 at 22:54 -0700, Eric Biggers wrote:
> On Fri, Sep 04, 2020 at 12:05:19PM -0400, Jeff Layton wrote:
> > This is a second posting of the ceph+fscrypt integration work that I've
> > been experimenting with. The main change with this patch is that I've
> > based this on top of Eric's fscrypt-pending set. That necessitated a
> > change to allocate inodes much earlier than we have traditionally, prior
> > to sending an RPC instead of waiting on the reply.
> 
> FWIW, if possible you should create a git tag or branch for your patchset.
> While just the mailed patches work fine for *me* for this particular patchset,
> other people may not be able to figure out what the patchset applies to.
> (In particular, it depends on another patchset:
> https://lkml.kernel.org/r/20200824061712.195654-1-ebiggers@kernel.org)
> 

I've tagged this out as 'ceph-fscrypt-rfc.2' in my kernel.org tree (the
first posting is ceph-fscrypt-rfc.1).

Note that this also is layered on top of David Howell's fscache rework,
and the work I've done to adapt cephfs to that.

> > Note that this just covers the crypto contexts and filenames. I've also
> > added a patch to encrypt symlink contents as well, but it doesn't seem to
> > be working correctly.
> 
> What about symlink encryption isn't working correctly?

What I was seeing is that after unmounting and mounting, the symlink
contents would be gibberish when read by readlink(). I confirmed that
the same crypttext that came out of fscrypt_encrypt_symlink() was being
fed into fscrypt_get_symlink(), but the result from that came back as
gibberish.

I need to do a bit more troubleshooting, but I now wonder if it's due to
the context handling being wrong when dummy encryption is enabled. I'll
have a look at that soon.

Thanks for the review so far!
-- 
Jeff Layton <jlayton@kernel.org>

