Return-Path: <SRS0=cslw=CR=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3028BC43461
	for <linux-fscrypt@archiver.kernel.org>; Tue,  8 Sep 2020 05:43:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E11E7218AC
	for <linux-fscrypt@archiver.kernel.org>; Tue,  8 Sep 2020 05:43:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1599543791;
	bh=T7Mw+MUEHs1QCqcbZGtLRjANkil8s9gIVXZkt0RgM04=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=wbpulobgY8boGO8Yu7ZLicYd2QoceIoWDk4Jgn8tKTL8gAekzlOD7C2EVVJ1DbfEu
	 er/tZIcvyyT3ZSlE6h071C/1xeGwkegsedRjsmF8GgUBIJVDzwhvBvffLDDjIgbOUN
	 0brDGKE8MGOLdq45TbA73PcR6ABlY84vdK5nkDxo=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728645AbgIHFnL (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 8 Sep 2020 01:43:11 -0400
Received: from mail.kernel.org ([198.145.29.99]:43088 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728587AbgIHFnG (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 8 Sep 2020 01:43:06 -0400
Received: from sol.localdomain (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id EE93021897;
        Tue,  8 Sep 2020 05:43:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1599543786;
        bh=T7Mw+MUEHs1QCqcbZGtLRjANkil8s9gIVXZkt0RgM04=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=oOFM/dlnu0MqF6fWS58GxlPwWhzyYwhjwNY2KcHGJKlf77jBbJRnyaCl2YObdyAp7
         0ElkFMjy1VwN6X2bLDBRk14yh36n5w0pwdL2wer8E2h5L20v4S/IZI+4uV8fRJfyj7
         CqXcrnIYQfJHF4D7QSrtmzHdQnOOCzvAh+m/ARFA=
Date:   Mon, 7 Sep 2020 22:43:04 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     ceph-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-fscrypt@vger.kernel.org
Subject: Re: [RFC PATCH v2 18/18] ceph: create symlinks with encrypted and
 base64-encoded targets
Message-ID: <20200908054304.GO68127@sol.localdomain>
References: <20200904160537.76663-1-jlayton@kernel.org>
 <20200904160537.76663-19-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200904160537.76663-19-jlayton@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, Sep 04, 2020 at 12:05:37PM -0400, Jeff Layton wrote:
> +static const char *ceph_encrypted_get_link(struct dentry *dentry, struct inode *inode,
> +					   struct delayed_call *done)
> +{
> +	struct ceph_inode_info *ci = ceph_inode(inode);
> +
> +	if (inode->i_link)
> +		return inode->i_link;

Checking ->i_link here is unnecessary since the VFS already does it before
calling inode_operations::get_link().  It's also wrong since it's missing
READ_ONCE() to handle ->i_link being set concurrently.

- Eric
