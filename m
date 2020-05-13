Return-Path: <SRS0=Vtbb=63=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B431C2D0F6
	for <linux-fscrypt@archiver.kernel.org>; Wed, 13 May 2020 03:07:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C2BFD23127
	for <linux-fscrypt@archiver.kernel.org>; Wed, 13 May 2020 03:07:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1589339226;
	bh=mf0A77JO/o1Mk6zUTHq9K+pvz3bYpz5zIclotccg+Fo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=BTSMGcF1zPI35CXk6+OLY82X5RdUyoWUcFHaT3Kv4a/KEN/MCfW9l18J5oPVjWhXU
	 hFM/qf1TtXGiRWpgo079lAQbwG5RxvPQTPyiNfE88+ULrM8SLFSFKqVGRfL0MZKmaj
	 M+jwcnuNZBHl1pxHJ01DcbFzpAVvKliRU+vMvu/0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726032AbgEMDHG (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 12 May 2020 23:07:06 -0400
Received: from mail.kernel.org ([198.145.29.99]:42612 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725898AbgEMDHG (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 12 May 2020 23:07:06 -0400
Received: from localhost (unknown [104.132.1.66])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A843D2176D;
        Wed, 13 May 2020 03:07:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1589339225;
        bh=mf0A77JO/o1Mk6zUTHq9K+pvz3bYpz5zIclotccg+Fo=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=yoPvoPvrtTgr0s5g4gLXEiIOsQf1dxfj/oBrrGa+nwoA6dE2mGMBtdWeohFt+yKvn
         4KlSpBlNspt1Pg1OVOViCkzUUafX+woN5Q0mQkMWH2ysQ77USKFxfJNTgDaMtkx6hS
         UGIOguCPrp8uo1y+tI6zLJ6p8n4VHZjG9dmJvNI0=
Date:   Tue, 12 May 2020 20:07:05 -0700
From:   Jaegeuk Kim <jaegeuk@kernel.org>
To:     "Theodore Y. Ts'o" <tytso@mit.edu>
Cc:     Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        Daniel Rosenberg <drosen@google.com>
Subject: Re: [PATCH 2/4] fscrypt: add fscrypt_add_test_dummy_key()
Message-ID: <20200513030705.GB108075@google.com>
References: <20200512233251.118314-1-ebiggers@kernel.org>
 <20200512233251.118314-3-ebiggers@kernel.org>
 <20200513005538.GF1596452@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200513005538.GF1596452@mit.edu>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On 05/12, Theodore Y. Ts'o wrote:
> On Tue, May 12, 2020 at 04:32:49PM -0700, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Currently, the test_dummy_encryption mount option (which is used for
> > encryption I/O testing with xfstests) uses v1 encryption policies, and
> > it relies on userspace inserting a test key into the session keyring.
> > 
> > We need test_dummy_encryption to support v2 encryption policies too.
> > Requiring userspace to add the test key doesn't work well with v2
> > policies, since v2 policies only support the filesystem keyring (not the
> > session keyring), and keys in the filesystem keyring are lost when the
> > filesystem is unmounted.  Hooking all test code that unmounts and
> > re-mounts the filesystem would be difficult.
> > 
> > Instead, let's make the filesystem automatically add the test key to its
> > keyring when test_dummy_encryption is enabled.
> > 
> > That puts the responsibility for choosing the test key on the kernel.
> > We could just hard-code a key.  But out of paranoia, let's first try
> > using a per-boot random key, to prevent this code from being misused.
> > A per-boot key will work as long as no one expects dummy-encrypted files
> > to remain accessible after a reboot.  (gce-xfstests doesn't.)
> > 
> > Therefore, this patch adds a function fscrypt_add_test_dummy_key() which
> > implements the above.  The next patch will use it.
> > 
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> 
> Reviewed-by: Theodore Ts'o <tytso@mit.edu>

Reviewed-by: Jaegeuk Kim <jaegeuk@kernel.org>
