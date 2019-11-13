Return-Path: <SRS0=DXB5=ZF=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 680C2C432C3
	for <linux-fscrypt@archiver.kernel.org>; Wed, 13 Nov 2019 20:35:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 11742206F4
	for <linux-fscrypt@archiver.kernel.org>; Wed, 13 Nov 2019 20:35:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1573677356;
	bh=F7ZEXH3Tifjy9sGUrwh8Fhs+H6mYs1GYZonZpiJuwEo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=isyeFmURv77b7l0WiDCbu5tYNYoFMXAeRWxA2/C40Fi8k38YePC5Z5QQWsxbBC1b2
	 nWT20v/G1bED+EfLcny9JP1T1J8KVWvIY6zVJ/FvYlanm+TepVWcriM0gWK4c9fPVi
	 2Kve81p/wfQ0yZWkl/MRGJ9HE8U8TmqPiHEHVZV4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726516AbfKMUfz (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 13 Nov 2019 15:35:55 -0500
Received: from mail.kernel.org ([198.145.29.99]:53674 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726162AbfKMUfy (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 13 Nov 2019 15:35:54 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D1D53206F0;
        Wed, 13 Nov 2019 20:35:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1573677354;
        bh=F7ZEXH3Tifjy9sGUrwh8Fhs+H6mYs1GYZonZpiJuwEo=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=cN+5BXj91Btq6Ry/bO1VhiaNdo4x1+Lt3QDXuQLQyXlsCVgrWNJGKLW3Zy0M3qYgf
         kZYrGKdT5NAbCuJckqXAScixPVqWmbN98LNs2qdXXxKYYq+xhab0ygSaprMlJrUDjc
         2Rl8cQmt+I9y4p/mks0qpzDMku7DMTI2kzVonDxM=
Date:   Wed, 13 Nov 2019 12:35:51 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     David Howells <dhowells@redhat.com>,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        keyrings@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>,
        Ondrej Mosnacek <omosnace@redhat.com>,
        linux-f2fs-devel@lists.sourceforge.net,
        Paul Lawrence <paullawrence@google.com>,
        linux-mtd@lists.infradead.org, Ondrej Kozina <okozina@redhat.com>,
        Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org,
        Paul Crowley <paulcrowley@google.com>
Subject: Re: [PATCH] fscrypt: support passing a keyring key to
 FS_IOC_ADD_ENCRYPTION_KEY
Message-ID: <20191113203550.GI221701@gmail.com>
Mail-Followup-To: David Howells <dhowells@redhat.com>,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        keyrings@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        "Theodore Y . Ts'o" <tytso@mit.edu>,
        Ondrej Mosnacek <omosnace@redhat.com>,
        linux-f2fs-devel@lists.sourceforge.net,
        Paul Lawrence <paullawrence@google.com>,
        linux-mtd@lists.infradead.org, Ondrej Kozina <okozina@redhat.com>,
        Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org,
        Paul Crowley <paulcrowley@google.com>
References: <20191107001259.115018-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191107001259.115018-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Nov 06, 2019 at 04:12:59PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Extend the FS_IOC_ADD_ENCRYPTION_KEY ioctl to allow the raw key to be
> specified by a Linux keyring key, rather than specified directly.
> 
> This is useful because fscrypt keys belong to a particular filesystem
> instance, so they are destroyed when that filesystem is unmounted.
> Usually this is desired.  But in some cases, userspace may need to
> unmount and re-mount the filesystem while keeping the keys, e.g. during
> a system update.  This requires keeping the keys somewhere else too.
> 
> The keys could be kept in memory in a userspace daemon.  But depending
> on the security architecture and assumptions, it can be preferable to
> keep them only in kernel memory, where they are unreadable by userspace.
> 
> We also can't solve this by going back to the original fscrypt API
> (where for each file, the master key was looked up in the process's
> keyring hierarchy) because that caused lots of problems of its own.
> 
> Therefore, add the ability for FS_IOC_ADD_ENCRYPTION_KEY to accept a
> Linux keyring key.  This solves the problem by allowing userspace to (if
> needed) save the keys securely in a Linux keyring for re-provisioning,
> while still using the new fscrypt key management ioctls.
> 
> This is analogous to how dm-crypt accepts a Linux keyring key, but the
> key is then stored internally in the dm-crypt data structures rather
> than being looked up again each time the dm-crypt device is accessed.
> 
> Use a custom key type "fscrypt-provisioning" rather than one of the
> existing key types such as "logon".  This is strongly desired because it
> enforces that these keys are only usable for a particular purpose: for
> fscrypt as input to a particular KDF.  Otherwise, the keys could also be
> passed to any kernel API that accepts a "logon" key with any service
> prefix, e.g. dm-crypt, UBIFS, or (recently proposed) AF_ALG.  This would
> risk leaking information about the raw key despite it ostensibly being
> unreadable.  Of course, this mistake has already been made for multiple
> kernel APIs; but since this is a new API, let's do it right.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

David and Jarkko, are you okay with this patch from a keyrings subsystem
perspective?

- Eric
