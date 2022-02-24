Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 680D6C433EF
	for <linux-fscrypt@archiver.kernel.org>; Thu, 24 Feb 2022 01:36:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229611AbiBXBhF (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 23 Feb 2022 20:37:05 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50506 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229563AbiBXBhE (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 23 Feb 2022 20:37:04 -0500
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 998B51D3;
        Wed, 23 Feb 2022 17:36:33 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 139AB60ED2;
        Thu, 24 Feb 2022 01:26:20 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 458E4C340E7;
        Thu, 24 Feb 2022 01:26:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1645665979;
        bh=8LDaM4Jy5ejD/wY59B/RpUu2ht19fRLgDsVinlKVkz8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=eoAVUn1fHYOdBWEUVuQXREhDK/0DHFrXmXjXifC8G4q8K8O7UC0WBstBt+H2QGX25
         H8n77lvmTP/SCtZrse9ESioB7fzeJtocPDcnqcNTKYPhAiB6fBajXw37PHELsQeS6Z
         1npEVBrlVVdePpm+5zXRAT/U8GLW9Q1nw1uw5QQTyndn7xFGfxf9Tf96k6nn4viJBe
         5m3LCrlEHkAmmEjc2u+GrZc5SgveF6GFxdzE8baaa0Af9L3PhnLO1y7a4XzJGAWOEz
         uJmclobZFzbazQEm4SluQosfJu7Cv+7HNoOrUQ73XcfhZDFBNOlTP1uF8p0EcF0FiO
         a2nPv3A4zJr7g==
Date:   Wed, 23 Feb 2022 17:26:17 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     Mimi Zohar <zohar@linux.ibm.com>
Cc:     linux-integrity@vger.kernel.org,
        Stefan Berger <stefanb@linux.ibm.com>,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 3/8] fs-verity: define a function to return the
 integrity protected file digest
Message-ID: <YhbeuQpGuDxEmi9o@sol.localdomain>
References: <20220211214310.119257-1-zohar@linux.ibm.com>
 <20220211214310.119257-4-zohar@linux.ibm.com>
 <YhbKYZcWxmi4auJU@sol.localdomain>
 <f322ae351dde71b92d7d4037d78190c7338ca710.camel@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f322ae351dde71b92d7d4037d78190c7338ca710.camel@linux.ibm.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Feb 23, 2022 at 08:21:01PM -0500, Mimi Zohar wrote:
> On Wed, 2022-02-23 at 15:59 -0800, Eric Biggers wrote:
> > On Fri, Feb 11, 2022 at 04:43:05PM -0500, Mimi Zohar wrote:
> > > +/**
> > > + * fsverity_get_digest() - get a verity file's digest
> > > + * @inode: inode to get digest of
> > > + * @digest: (out) pointer to the digest
> > > + * @alg: (out) pointer to the hash algorithm enumeration
> > > + *
> > > + * Return the file hash algorithm and digest of an fsverity protected file.
> > > + *
> > > + * Return: 0 on success, -errno on failure
> > > + */
> > > +int fsverity_get_digest(struct inode *inode,
> > > +			u8 digest[FS_VERITY_MAX_DIGEST_SIZE],
> > > +			enum hash_algo *alg)
> > > +{
> > > +	const struct fsverity_info *vi;
> > > +	const struct fsverity_hash_alg *hash_alg;
> > > +	int i;
> > > +
> > > +	vi = fsverity_get_info(inode);
> > > +	if (!vi)
> > > +		return -ENODATA; /* not a verity file */
> > 
> > Sorry for the slow reviews; I'm taking a look again now.  One question about
> > something I missed earlier: is the file guaranteed to have been opened before
> > this is called?  fsverity_get_info() only returns a non-NULL value if the file
> > has been opened at least once since the inode has been loaded into memory.  If
> > the inode has just been loaded into memory without being opened, for example due
> > to a call to stat(), then fsverity_get_info() will return NULL.
> > 
> > If the file is guaranteed to have been opened, then the code is fine, but the
> > comment for fsverity_get_digest() perhaps should be updated to mention this
> > assumption, given that it takes a struct inode rather than a struct file.
> > 
> > If the file is *not* guaranteed to have been opened, then it would be necessary
> > to make fsverity_get_digest() call ensure_verity_info() to set up the
> > fsverity_info.
> 
> Yes, fsverity_get_digest() is called as a result of a syscall - open,
> execve, mmap, etc.   
> Refer to the LSM hooks security_bprm_check() and security_mmap_file().
> ima_file_check() is called directly in do_open().

stat() is a syscall too, so the question is not whether this is being called as
a result of a syscall, but rather whether it's only being called while the file
is open (or at least previously opened).  Is the answer to that "yes"?

- Eric
