Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:36980 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726273AbfBUSia (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 21 Feb 2019 13:38:30 -0500
Date: Thu, 21 Feb 2019 10:38:28 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 00/10] Consolidate Post read processing code
Message-ID: <20190221183827.GA140206@gmail.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com>
 <20190220004107.GI12177@gmail.com>
 <2420837.hecoV8S9Z6@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2420837.hecoV8S9Z6@localhost.localdomain>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chandan Rajendra <chandan@linux.ibm.com>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Feb 21, 2019 at 07:02:03PM +0530, Chandan Rajendra wrote:
> On Wednesday, February 20, 2019 6:11:07 AM IST Eric Biggers wrote:
> > On Mon, Feb 18, 2019 at 03:34:23PM +0530, Chandan Rajendra wrote:
> > > Based on the reviews provided for this patchset, I
> > > will change F2FS to use mpage_readpage[s] and post the next version of
> > > this patchset to linux-fsdevel mailing list.
> > 
> > Is that really possible?  F2FS has other functionality in its ->readpages(),
> > such as support for filesystems that use multiple block devices.
> > 
> 
> Hmm. I didn't know that. Thanks for pointing that out. I will read up that
> code and if it isn't really possible to get F2FS to use mpage_readpage[s](),
> then I would limit the patchset to Ext4.
> 

But we can make F2FS use the shared bio_post_read functions even if it can't use
mpage_readpage[s](), right?

- Eric
