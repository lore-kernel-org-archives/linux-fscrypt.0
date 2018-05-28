Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:48588 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751399AbeE1FeR (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 28 May 2018 01:34:17 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4S5YG9J094670
        for <linux-fscrypt@vger.kernel.org>; Mon, 28 May 2018 01:34:16 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2j8874x51w-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-fscrypt@vger.kernel.org>; Mon, 28 May 2018 01:34:16 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-fscrypt@vger.kernel.org> from <chandan@linux.vnet.ibm.com>;
        Mon, 28 May 2018 06:34:12 +0100
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V3 07/12] mpage_readpage[s]: Introduce post process callback parameters
Date: Mon, 28 May 2018 11:05:52 +0530
In-Reply-To: <20180525200121.GA4613@thunk.org>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com> <20180522160110.1161-8-chandan@linux.vnet.ibm.com> <20180525200121.GA4613@thunk.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <4837046.FSMeUsGny4@dhcp-9-109-247-5>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: linux-fscrypt@vger.kernel.org, ebiggers3@gmail.com, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Saturday, May 26, 2018 1:31:21 AM IST Theodore Y. Ts'o wrote:
> On Tue, May 22, 2018 at 09:31:05PM +0530, Chandan Rajendra wrote:
> > This commit introduces a new parameter to mpage_readpage[s]()
> > functions. This parameter contains pointers to functions that can be
> > used to decrypt data read from the backing device. These are stored in
> > the fscrypt_ctx structure and one of these functions is invoked after
> > the read operation is completed.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
> 
> Can you describe more of what you are doing here; specifically, you
> deleted all of fs/ext4/readpage.c --- was this because you moved
> functionality back into fs/mpage.c?  Did you make sure all of the
> local changes in fs/ext4/readpage was moved back to fs/mpage.c?
> 
> If the goal is to refactor code to remove the need for
> fs/ext4/readpage.c, you should probably make that be the first patch
> as a prerequisite patch.  And we then need to make sure we don't
> accidentally break anyone else who might be using fs/mpage.c.  Saying
> a bit more about why you think the refactor is a good thing would also
> be useful.

I will split this patch into two as suggested by you. Also, I will update 
the commit messages.

The patchset was based on next-20180503 tree. You can obtain it from
"https://github.com/chandanr/linux.git ext4-encryption"

-- 
chandan

