Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 452B0390C85;
	Mon,  3 Aug 2026 08:01:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.156.1
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785744085; cv=none; b=dFVPUbZGh+EoFG8iweAd9tqI7+SKL++Zntu/sBVjEy3kZX3KelWOfk3CU9NHWYrvxjTxIIjEFE5/DBiA07rFxB0q2cbCQPTqAzAG4WsBT/VNuIfSyVoiL6k4JkuFwn4FmiU5Xg4QhkHLDBmJOSxD8EueaIqDtMzVyFVNxQMKXrA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785744085; c=relaxed/simple;
	bh=oX0ZyXAkCAcvQ22lCDHo+CwdEB9Y13OwMAkfuo895Ds=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=bxYzUmDgYaW5ObUXV8alyx+KA7kv/JnO9sBh8mdT8xjU9a+CPwlMPkbGTx2l12OaIYL1eOd9QKFK1XOT3QB/NfHFQR2l78UQUa0KpgzA6zFAyHPqyq0vK64PZcMuwbODo1a8nLdUW+uiVqOsMcjt2EWQ4NrTyOPP8uqqgBBd42w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.ibm.com; spf=pass smtp.mailfrom=linux.ibm.com; dkim=pass (2048-bit key) header.d=ibm.com header.i=@ibm.com header.b=ntxNSd3s; arc=none smtp.client-ip=148.163.156.1
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.ibm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ibm.com header.i=@ibm.com header.b="ntxNSd3s"
Received: from pps.filterd (m0360083.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 672LlobN223138;
	Mon, 3 Aug 2026 08:00:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pp1; bh=42GWTB
	3NcWvfnxOcbHiWBnLyZbnmaKmM6GdZWBW/MQQ=; b=ntxNSd3srOGc1zVxxBbWO8
	7mn4FSrXiO3OSMowQOqK778MVXYYSyhRQYeBPpglCDX5RDWrHCxlVpdfeI07rjvx
	xCoPAj5Ql1H0LhhOFOYb8ffPPSdVXVzvDHIPO6tOGwKv4gGd4ApwAQmsXwzSYLsA
	91CYLEZVV5/NejjSQIQd/lFy4l2L7ua1++9MZHb9L5peyIW+AUidJByy6toFR+Ec
	dpE4VOPvqE+1Owmp76Z5P77CnFCywuGYVpJCi8EPyV/QRbTC+kxtOCd5UhmijGpF
	rrE11E9KaXRDPPRKvFrDFN9zvtRuUCwG96z9VJye4COpv+RXl63H+V33mpCGD1BQ
	==
Received: from ppma22.wdc07v.mail.ibm.com (5c.69.3da9.ip4.static.sl-reverse.com [169.61.105.92])
	by mx0a-001b2d01.pphosted.com (PPS) with ESMTPS id 4fs8a3qk58-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 03 Aug 2026 08:00:58 +0000 (GMT)
Received: from pps.filterd (ppma22.wdc07v.mail.ibm.com [127.0.0.1])
	by ppma22.wdc07v.mail.ibm.com (8.18.1.7/8.18.1.7) with ESMTP id 6737uOg8001363;
	Mon, 3 Aug 2026 08:00:57 GMT
Received: from smtprelay07.fra02v.mail.ibm.com ([9.218.2.229])
	by ppma22.wdc07v.mail.ibm.com (PPS) with ESMTPS id 4fsugvvet9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 03 Aug 2026 08:00:56 +0000 (GMT)
Received: from smtpav04.fra02v.mail.ibm.com (smtpav04.fra02v.mail.ibm.com [10.20.54.103])
	by smtprelay07.fra02v.mail.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 67380s2C35193334
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 3 Aug 2026 08:00:54 GMT
Received: from smtpav04.fra02v.mail.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B091D20040;
	Mon,  3 Aug 2026 08:00:54 +0000 (GMT)
Received: from smtpav04.fra02v.mail.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A8F0E2004D;
	Mon,  3 Aug 2026 08:00:50 +0000 (GMT)
Received: from [9.39.27.127] (unknown [9.39.27.127])
	by smtpav04.fra02v.mail.ibm.com (Postfix) with ESMTP;
	Mon,  3 Aug 2026 08:00:50 +0000 (GMT)
Message-ID: <17e787ea-7e0b-4887-b736-4e2f3dbeb245@linux.ibm.com>
Date: Mon, 3 Aug 2026 13:30:48 +0530
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] ext4: don't enable DAX on new encrypted files
Content-Language: en-GB
To: Eric Biggers <ebiggers@kernel.org>, linux-ext4@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>,
        Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
        Ojaswin Mujoo <ojaswin@linux.ibm.com>,
        Ritesh Harjani
 <ritesh.list@gmail.com>,
        Zhang Yi <yi.zhang@huawei.com>, Ira Weiny <iweiny@kernel.org>,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org
References: <20260730175212.36923-1-ebiggers@kernel.org>
From: Disha Goel <disgoel@linux.ibm.com>
In-Reply-To: <20260730175212.36923-1-ebiggers@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
X-Proofpoint-Reinject: loops=2 maxloops=12
X-Authority-Analysis: v=2.4 cv=E6P9Y6dl c=1 sm=1 tr=0 ts=6a704aba cx=c_pps
 a=5BHTudwdYE3Te8bg5FgnPg==:117 a=5BHTudwdYE3Te8bg5FgnPg==:17
 a=IkcTkHD0fZMA:10 a=Sv0fKeRqtYgA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=RnoormkPH1_aCDwRdu11:22 a=iQ6ETzBq9ecOQQE5vZCe:22 a=VwQbUJbxAAAA:8
 a=VnNF1IyMAAAA:8 a=ovQU41l7dhj9IMd-MlgA:9 a=QEXdDO2ut3YA:10
X-Proofpoint-ORIG-GUID: b79nUqRkScouH3xfu6JhLmjGCmnklbvZ
X-Proofpoint-GUID: 2z1O-lX0C4CUH2UlfhrSL0VakxhqMogu
X-Proofpoint-Spam-Info: AW1haW4tMjYwODAzMDA2OCBTYWx0ZWRfXw8ABikuV8BfK
 XcS1/+zYfb6uAovv5Gnb1404YgLMKDzde8Z32ZevKrf1U62vCAyYqtGRfRZgpxsoyP2XsCUm6cp
 u/fIMno0CQFf/iACaphhSCfd6eMYBa4=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODAzMDA2OCBTYWx0ZWRfX/F1Yo/aj7dgw
 i0p6jkjgIMCtPlgxwtqcTrOZODsGZT3rS4LQ15Wk94jN/k84vL9B5vL7i1EYqcbiR4+PuD8TFhB
 wKJYkDkCC3sVi5OK0nNqINSJt3a8OsXI8Kagjo7KMbEJ6SXACYNRUPaH88tESWbLOQqnL6u6eCo
 cYIdE4ZhZnlJaduJo/Ao6XrqSDVgwQXpkTCQnh3fGFeHK5wK/H2B0xedA3h6q2HW2QvBjoSSm32
 1EDoGR9Nmju+BI56FGlS44UV35x5+w0ipFtDXqs+Ymh8s0kv2b1la9nkKElCOEquJMHARh3LMTl
 zEM+6oKKK1cEHF6Lq0nIDF5XabLMUW4mJLjucb9eOJSAMpaqgxFtPL+lJYqNnlP9o1uiO69rU+3
 zw+uYuAdSNBLcg4PkIwlpvxn3GIcb2dVxel0KUGS6pSH1nORxxrwHfMisoCLgiKxA1MARE6/r72
 Xwl2RN83Q4yzhNwf7eA==
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1143,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-02_06,2026-07-30_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 bulkscore=0 clxscore=1011 lowpriorityscore=0 priorityscore=1501
 suspectscore=0 adultscore=0 spamscore=0 malwarescore=0 impostorscore=0
 phishscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608030068

On 30/07/26 11:22 pm, Eric Biggers wrote:
> Currently, when a new encrypted regular file is created, the call to
> ext4_set_inode_flags(inode, init=true) in __ext4_new_inode() is made
> before EXT4_INODE_ENCRYPT is set.  As a result, it can set S_DAX if the
> filesystem is mounted with "-o dax=always".
> 
> EXT4_INODE_ENCRYPT then actually gets set a bit later in
> __ext4_new_inode(), when it calls fscrypt_set_context() which calls
> ext4_set_context().  ext4_set_context() sets EXT4_INODE_ENCRYPT and
> calls ext4_set_inode_flags(inode, init=false) to set S_ENCRYPTED too.
> 
> This was intended to clear S_DAX as well.  However, this was broken by
> commit 043546e46dc7 ("fs/ext4: Only change S_DAX on inode load").  This
> causes data written to the file to bypass encryption, also causing
> xfstests failures such as generic/548 (when "-o dax=always" is used).
> 
> Fix this by simplifying the flow by making __ext4_new_inode() set
> EXT4_INODE_ENCRYPT earlier.  This makes it take effect in
> ext4_set_inode_flags(inode, init=true), making S_DAX never be set.
> 
> Similarly, make EXT4_STATE_MAY_INLINE_DATA never be set in the first
> place on new encrypted inodes.  Then it doesn't need to be cleared.
> 
> As a result of these simplifications, ext4_set_context() no longer needs
> to change inode flags or state when 'handle != NULL'.  Remove that too.
> 
> Reported-by: Disha Goel <disgoel@linux.ibm.com>
> Reported-by: Ojaswin Mujoo <ojaswin@linux.ibm.com>
> Closes: https://lore.kernel.org/r/20260723085648.1500357-1-ojaswin@linux.ibm.com
> Fixes: 043546e46dc7 ("fs/ext4: Only change S_DAX on inode load")
> Cc: stable@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>

I have tested on a -o dax=always ext4 filesystem on ppc64le with the 
following xfstests configuration. All failing encryption tests in the
generic group now pass.

MOUNT_OPTIONS="-o block_validity,dax"
MKFS_OPTIONS="-b 65536"

Feel free to add
Tested-by: Disha Goel <disgoel@linux.ibm.com>

> ---
>   fs/ext4/crypto.c | 40 ++++++++++++++++++++--------------------
>   fs/ext4/ialloc.c |  4 ++++
>   2 files changed, 24 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
> index f41f320f4437..3971986de028 100644
> --- a/fs/ext4/crypto.c
> +++ b/fs/ext4/crypto.c
> @@ -144,7 +144,13 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>   	if (inode->i_ino == EXT4_ROOT_INO)
>   		return -EPERM;
>   
> -	if (WARN_ON_ONCE(IS_DAX(inode) && i_size_read(inode)))
> +	/*
> +	 * For new encrypted inodes, S_DAX is never set in the first place.
> +	 *
> +	 * For existing inodes, this is called only on empty directories.  ext4
> +	 * never sets S_DAX on directories.
> +	 */
> +	if (WARN_ON_ONCE(IS_DAX(inode)))
>   		return -EINVAL;
>   
>   	if (ext4_test_inode_flag(inode, EXT4_INODE_DAX))
> @@ -163,6 +169,14 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>   	 */
>   
>   	if (handle) {
> +		/*
> +		 * __ext4_new_inode() should have already set the encrypt flag
> +		 * on the inode and avoided enabling inline data.
> +		 */
> +		if (WARN_ON_ONCE(!IS_ENCRYPTED(inode)))
> +			return -EINVAL;
> +		if (WARN_ON_ONCE(ext4_test_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA)))
> +			return -EINVAL;
>   		/*
>   		 * Since the inode is new it is ok to pass the
>   		 * XATTR_CREATE flag. This is necessary to match the
> @@ -170,21 +184,10 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>   		 * function with the credits allocated for the new
>   		 * inode.
>   		 */
> -		res = ext4_xattr_set_handle(handle, inode,
> -					    EXT4_XATTR_INDEX_ENCRYPTION,
> -					    EXT4_XATTR_NAME_ENCRYPTION_CONTEXT,
> -					    ctx, len, XATTR_CREATE);
> -		if (!res) {
> -			ext4_set_inode_flag(inode, EXT4_INODE_ENCRYPT);
> -			ext4_clear_inode_state(inode,
> -					EXT4_STATE_MAY_INLINE_DATA);
> -			/*
> -			 * Update inode->i_flags - S_ENCRYPTED will be enabled,
> -			 * S_DAX may be disabled
> -			 */
> -			ext4_set_inode_flags(inode, false);
> -		}
> -		return res;
> +		return ext4_xattr_set_handle(handle, inode,
> +					     EXT4_XATTR_INDEX_ENCRYPTION,
> +					     EXT4_XATTR_NAME_ENCRYPTION_CONTEXT,
> +					     ctx, len, XATTR_CREATE);
>   	}
>   
>   	res = dquot_initialize(inode);
> @@ -205,10 +208,7 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>   				    ctx, len, 0);
>   	if (!res) {
>   		ext4_set_inode_flag(inode, EXT4_INODE_ENCRYPT);
> -		/*
> -		 * Update inode->i_flags - S_ENCRYPTED will be enabled,
> -		 * S_DAX may be disabled
> -		 */
> +		/* Update inode->i_flags to set S_ENCRYPTED. */
>   		ext4_set_inode_flags(inode, false);
>   		res = ext4_mark_inode_dirty(handle, inode);
>   		if (res)
> diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
> index a40cb27f8116..a5831fc536db 100644
> --- a/fs/ext4/ialloc.c
> +++ b/fs/ext4/ialloc.c
> @@ -997,6 +997,8 @@ struct inode *__ext4_new_inode(struct mnt_idmap *idmap,
>   		err = fscrypt_prepare_new_inode(dir, inode, &encrypt);
>   		if (err)
>   			goto out;
> +		if (encrypt)
> +			i_flags |= EXT4_ENCRYPT_FL;
>   	}
>   
>   	err = dquot_initialize(inode);
> @@ -1306,6 +1308,8 @@ struct inode *__ext4_new_inode(struct mnt_idmap *idmap,
>   	ei->i_extra_isize = sbi->s_want_extra_isize;
>   	ei->i_inline_off = 0;
>   	if (ext4_has_feature_inline_data(sb) &&
> +	    /* Encrypted inodes cannot have inline data */
> +	    !(ei->i_flags & EXT4_ENCRYPT_FL) &&
>   	    (!(ei->i_flags & (EXT4_DAX_FL|EXT4_EA_INODE_FL)) || S_ISDIR(mode)))
>   		ext4_set_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA);
>   	ret = inode;
> 
> base-commit: f5098b6bae761e346ebcd9da7f95622c04733cff

-- 
Regards,
Disha

