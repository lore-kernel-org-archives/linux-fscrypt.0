Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:20136 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727308AbfHSNby (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 19 Aug 2019 09:31:54 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7JDTnF8137974
        for <linux-fscrypt@vger.kernel.org>; Mon, 19 Aug 2019 09:31:53 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2ufu10chcq-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-fscrypt@vger.kernel.org>; Mon, 19 Aug 2019 09:31:52 -0400
Received: from localhost
        by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-fscrypt@vger.kernel.org> from <chandan@linux.ibm.com>;
        Mon, 19 Aug 2019 14:31:50 +0100
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [f2fs-dev] [PATCH V4 5/8] f2fs: Use read_callbacks for decrypting file data
Date: Mon, 19 Aug 2019 19:03:23 +0530
In-Reply-To: <bb3dc624-1249-2418-f9da-93da8c11e7f5@kernel.org>
References: <20190816061804.14840-1-chandan@linux.ibm.com> <20190816061804.14840-6-chandan@linux.ibm.com> <bb3dc624-1249-2418-f9da-93da8c11e7f5@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <20104514.oSSJcvNEEM@localhost.localdomain>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chao Yu <chao@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, hch@infradead.org, tytso@mit.edu, ebiggers@kernel.org, adilger.kernel@dilger.ca, chandanrmail@gmail.com, jaegeuk@kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sunday, August 18, 2019 7:15:42 PM IST Chao Yu wrote:
> Hi Chandan,
> 
> On 2019-8-16 14:18, Chandan Rajendra wrote:
> > F2FS has a copy of "post read processing" code using which encrypted
> > file data is decrypted. This commit replaces it to make use of the
> > generic read_callbacks facility.
> 
> I remember that previously Jaegeuk had mentioned f2fs will support compression
> later, and it needs to reuse 'post read processing' fwk.
> 
> There is very initial version of compression feature in below link:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/chao/linux.git/log/?h=compression
> 
> So my concern is how can we uplift the most common parts of this fwk into vfs,
> and meanwhile keeping the ability and flexibility when introducing private
> feature/step in specified filesytem(now f2fs)?
> 
> According to current f2fs compression's requirement, maybe we can expand to
> 
> - support callback to let filesystem set the function for the flow in
> decompression/verity/decryption step.
> - support to use individual/common workqueue according the parameter.
> 
> Any thoughts?
>

Hi,

F2FS can be made to use fscrypt's queue for decryption and hence can reuse
"read callbacks" code for decrypting data.

For decompression, we could have a STEP_MISC where we invoke a FS provided
callback function for FS specific post read processing? 

Something like the following can be implemented in read_callbacks(),
	  case STEP_MISC:
		  if (ctx->enabled_steps & (1 << STEP_MISC)) {
			  /*
			    ctx->fs_misc() must process bio in a workqueue
			    and later invoke read_callbacks() with
			    bio->bi_private's value as an argument.
			  */
			  ctx->fs_misc(ctx->bio);
			  return;
		  }
		  ctx->cur_step++;

The fs_misc() callback can be passed in by the filesystem when invoking
read_callbacks_setup_bio().

-- 
chandan
