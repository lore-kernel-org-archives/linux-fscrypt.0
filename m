Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:49314 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725883AbfEFLd5 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 May 2019 07:33:57 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x46BWiBV025895
        for <linux-fscrypt@vger.kernel.org>; Mon, 6 May 2019 07:33:56 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2sah6tqgy1-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-fscrypt@vger.kernel.org>; Mon, 06 May 2019 07:33:56 -0400
Received: from localhost
        by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-fscrypt@vger.kernel.org> from <chandan@linux.ibm.com>;
        Mon, 6 May 2019 12:33:53 +0100
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH 13/13] ext4: encrypt only up to last block in ext4_bio_write_page()
Date: Mon, 06 May 2019 14:42:14 +0530
In-Reply-To: <20190501224515.43059-14-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org> <20190501224515.43059-14-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <5247310.83GBoLVoWW@dhcp-9-109-212-164>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, May 2, 2019 4:15:15 AM IST Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> As an optimization, don't encrypt blocks fully beyond i_size, since
> those definitely won't need to be written out.  Also add a comment.
> 
> This is in preparation for allowing encryption on ext4 filesystems with
> blocksize != PAGE_SIZE.
> 
> This is based on work by Chandan Rajendra.
>

Looks good to me,

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>

-- 
chandan
