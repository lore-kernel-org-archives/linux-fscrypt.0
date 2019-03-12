Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:32814 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726263AbfCLGeZ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 12 Mar 2019 02:34:25 -0400
Date: Mon, 11 Mar 2019 23:34:23 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Update fscrypt git URL for linux-next
Message-ID: <20190312063422.GA9123@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Stephen, we've updated the location of the fscrypt git tree:

Old URL: git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git
New URL: git://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git

Branch is still "master".

MAINTAINERS in mainline has already been updated accordingly.

Can you make sure to update the URL for linux-next too?

Thanks!

- Eric
