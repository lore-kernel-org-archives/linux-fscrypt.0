Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57988 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727982AbeK2AvB (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 28 Nov 2018 19:51:01 -0500
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wASDmrOf097433
        for <linux-fscrypt@vger.kernel.org>; Wed, 28 Nov 2018 08:49:18 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2p1t4qdjq5-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-fscrypt@vger.kernel.org>; Wed, 28 Nov 2018 08:49:17 -0500
Received: from localhost
        by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-fscrypt@vger.kernel.org> from <chandan@linux.vnet.ibm.com>;
        Wed, 28 Nov 2018 13:49:15 -0000
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/7] ext4: use IS_VERITY() to check inode's fsverity status
Date: Wed, 28 Nov 2018 19:19:16 +0530
In-Reply-To: <20181126173615.GB22888@thunk.org>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com> <20181119052324.31456-6-chandan@linux.vnet.ibm.com> <20181126173615.GB22888@thunk.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2147521.jaMCgNecB2@localhost.localdomain>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, ebiggers@kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Monday, November 26, 2018 11:06:15 PM IST Theodore Y. Ts'o wrote:
> On Mon, Nov 19, 2018 at 10:53:22AM +0530, Chandan Rajendra wrote:
> > This commit now uses IS_VERITY() macro to check if fsverity is
> > enabled on an inode.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
> 
> This patch causes a massive number of fsverity tests.  I suspect it's
> due to a mismatch between the ext4's inode flags as opposed to the VFS
> inode's flags.  I'll take a closer look in the next day or two.
> 
> Cheers,
> 
> 						- Ted
> 
> 

Hi Ted,

I have fixed the problem. I will check the fix once again tomorrow and execute
the tests. I will be able to post the patches by end of tomorrow.

I will take a look at the commits that you have added at
git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git test-working
tomorrow.

-- 
chandan
