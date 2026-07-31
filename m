Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9235F3EB10F;
	Fri, 31 Jul 2026 12:16:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.156.1
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785500167; cv=none; b=Co/PpmIwLduwXIr+h2BcFV4h62QzfYRMv1joVpvI9X1ED7POncPvxCcf01BtKUmTK3XlrrrnQRXNbnetySvAlpBpQEBFOrYUhOWUOP1Cy927qED5j8L+l5wpBToBYeJbmwH8JBfPhktGOVWNhAVdMN7FbNfRzvVFfM4vjWLQkJI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785500167; c=relaxed/simple;
	bh=UZ/Sln7YYeVyoGMNPMtP4Lomz1r5uacMZnllJTsyPsI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lb7ctk/rSOTjo2bh+Sv1gycTmjctgu6e3Hw4+ezcaSsBMoFRofXjQwrIUE/IIBLsT1Gn3ejSdp10CD0R7LZ2WMadmxmZ3qBsJ7p5wTPCykJEBXfeBRRsAXYWE5IAeeNz0QL8mIT+/LrYPdXPunKHUQ7IP0Y7rugpo89onJMk9Oo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.ibm.com; spf=pass smtp.mailfrom=linux.ibm.com; dkim=pass (2048-bit key) header.d=ibm.com header.i=@ibm.com header.b=Gn/bsPY0; arc=none smtp.client-ip=148.163.156.1
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.ibm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ibm.com header.i=@ibm.com header.b="Gn/bsPY0"
Received: from pps.filterd (m0356517.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 66VBm3PW1766156;
	Fri, 31 Jul 2026 12:15:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=cc
	:content-type:date:from:in-reply-to:message-id:mime-version
	:references:subject:to; s=pp1; bh=/87/IHsO3lCniDuKp/DLkggwQfj3jV
	AVmfXdYpPtzFc=; b=Gn/bsPY0ovYFMUw3VVaoZqRCa0EQTjyuEIVSwcj4L58/tg
	XesYGSK6SiqNLEnEcCIo4e/mF2FeqbWgqYtpqZWfAApNXRImFosOU1myM5y+jwV4
	JRk3A67OPPUy9AFrzyIKR2h4zLSGHGIGKHl3lfKV+TgQymV6AUiyBtLUydIqYU1m
	Wx1KpXW3TI1s65+H3NK5h1KlpKb7BbZ97gozhp7lUF0YYaToZAtTflaTyW7Gw+m+
	fD0NppEdH1HAFaTUI+JpJCFsrpogQYV6W373D7Hz5Q0OKeYGBzuwB3JqgGjJoz0z
	mKKLkxDs5WYcE5SlBrQ61+c5SXtBYQdrNei9h+6g==
Received: from ppma11.dal12v.mail.ibm.com (db.9e.1632.ip4.static.sl-reverse.com [50.22.158.219])
	by mx0a-001b2d01.pphosted.com (PPS) with ESMTPS id 4fmv0y4xyn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 31 Jul 2026 12:15:44 +0000 (GMT)
Received: from pps.filterd (ppma11.dal12v.mail.ibm.com [127.0.0.1])
	by ppma11.dal12v.mail.ibm.com (8.18.1.7/8.18.1.7) with ESMTP id 66VCBIGM004182;
	Fri, 31 Jul 2026 12:15:43 GMT
Received: from smtprelay02.fra02v.mail.ibm.com ([9.218.2.226])
	by ppma11.dal12v.mail.ibm.com (PPS) with ESMTPS id 4fna5yfhqc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 31 Jul 2026 12:15:43 +0000 (GMT)
Received: from smtpav02.fra02v.mail.ibm.com (smtpav02.fra02v.mail.ibm.com [10.20.54.101])
	by smtprelay02.fra02v.mail.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 66VCFfDZ50659690
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 31 Jul 2026 12:15:42 GMT
Received: from smtpav02.fra02v.mail.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D422520040;
	Fri, 31 Jul 2026 12:15:41 +0000 (GMT)
Received: from smtpav02.fra02v.mail.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AD0B220043;
	Fri, 31 Jul 2026 12:15:38 +0000 (GMT)
Received: from li-dc0c254c-257c-11b2-a85c-98b6c1322444.ibm.com (unknown [9.124.209.143])
	by smtpav02.fra02v.mail.ibm.com (Postfix) with ESMTPS;
	Fri, 31 Jul 2026 12:15:38 +0000 (GMT)
Date: Fri, 31 Jul 2026 17:45:36 +0530
From: Ojaswin Mujoo <ojaswin@linux.ibm.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
        Ritesh Harjani <ritesh.list@gmail.com>, Zhang Yi <yi.zhang@huawei.com>,
        Ira Weiny <iweiny@kernel.org>, linux-fscrypt@vger.kernel.org,
        linux-kernel@vger.kernel.org, Disha Goel <disgoel@linux.ibm.com>,
        stable@vger.kernel.org
Subject: Re: [PATCH] ext4: don't enable DAX on new encrypted files
Message-ID: <amyR6P_-WWTTEaup@li-dc0c254c-257c-11b2-a85c-98b6c1322444.ibm.com>
References: <20260730175212.36923-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260730175212.36923-1-ebiggers@kernel.org>
X-TM-AS-GCONF: 00
X-Proofpoint-Reinject: loops=2 maxloops=12
X-Proofpoint-GUID: bccxDvmbbCb-mKgYT23BOSSyFOxDXzJB
X-Proofpoint-ORIG-GUID: Ot_mZbCNqSbCXoOm5AaZzsZw9FrqX67p
X-Proofpoint-Spam-Info: AW1haW4tMjYwNzMxMDA5MCBTYWx0ZWRfX3N6ybJvhltjk
 ZI2wdTtDI5uQHN2auZKUC8d9M+/uvrLn735JTo+7KXdPfZYF5mArslIHKI+4Rw6XNAXFcaa4F1F
 7aLdajaIhgJbpO/5OmWzBRXsEge1eDQ=
X-Authority-Analysis: v=2.4 cv=dYuwG3Xe c=1 sm=1 tr=0 ts=6a6c91f1 cx=c_pps
 a=aDMHemPKRhS1OARIsFnwRA==:117 a=aDMHemPKRhS1OARIsFnwRA==:17
 a=kj9zAlcOel0A:10 a=RAioF0-LDSMA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=RnoormkPH1_aCDwRdu11:22 a=U7nrCbtTmkRpXpFmAIza:22 a=VwQbUJbxAAAA:8
 a=VnNF1IyMAAAA:8 a=YVDjClEEQ8ZDZGE1TyEA:9 a=CjuIK1q_8ugA:10
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwNzMxMDA5MCBTYWx0ZWRfXyUqgvVFRdKYA
 d343G5j8wQ83dtQ14sShNsDtdVayxmWF9lRwBFG83OPG2mLEmyOLChdy0GECMATBClmm5lPEy2A
 SXACKUkXdYcI3ODhMKefFB1jPO6okYqEvgGBz9YtKTFeXhsNbV5mInWv9tA3w+59B5ggeGOJrMX
 3b5U7BG3dl6sMtIB/re9tLJvE10DPVqo+QQW/rfXT1XyrCyiweIfKb8M76S15k6Th48Dxa/rPKN
 bxShmq7U2Me1pHbH1A552Mxsk54lW5S17biCtZquj52BDyje8R536eiucl2xK6e2Cv3JIXy6y4y
 b7eOEECwjbviMklGOfyRdlGa/q9ibGstQ7DJjNG2xtnYeFdOokdCkBnN3KMtbxBc9X+AM227YXW
 IOqpzpEHDqi4/qFFc+ScMv5S1IXdmBy6SXnd7q3qoWPX/t/JlID90GVPjezQvZQICYl+yhJgFNq
 z2Tc/1ROnJFWNdSvaRg==
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1143,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-07-31_04,2026-07-30_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 priorityscore=1501 impostorscore=0 clxscore=1011 phishscore=0 malwarescore=0
 spamscore=0 lowpriorityscore=0 bulkscore=0 suspectscore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2607310090

On Thu, Jul 30, 2026 at 10:52:12AM -0700, Eric Biggers wrote:
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

Hey Eric, looks good and it passes all the failing tests in my dax
setup.

Feel free to add:

Reviewed-by: Ojaswin Mujoo <ojaswin@linux.ibm.com>

Regards,
ojaswin

> ---
>  fs/ext4/crypto.c | 40 ++++++++++++++++++++--------------------
>  fs/ext4/ialloc.c |  4 ++++
>  2 files changed, 24 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
> index f41f320f4437..3971986de028 100644
> --- a/fs/ext4/crypto.c
> +++ b/fs/ext4/crypto.c
> @@ -144,7 +144,13 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>  	if (inode->i_ino == EXT4_ROOT_INO)
>  		return -EPERM;
>  
> -	if (WARN_ON_ONCE(IS_DAX(inode) && i_size_read(inode)))
> +	/*
> +	 * For new encrypted inodes, S_DAX is never set in the first place.
> +	 *
> +	 * For existing inodes, this is called only on empty directories.  ext4
> +	 * never sets S_DAX on directories.
> +	 */
> +	if (WARN_ON_ONCE(IS_DAX(inode)))
>  		return -EINVAL;
>  
>  	if (ext4_test_inode_flag(inode, EXT4_INODE_DAX))
> @@ -163,6 +169,14 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>  	 */
>  
>  	if (handle) {
> +		/*
> +		 * __ext4_new_inode() should have already set the encrypt flag
> +		 * on the inode and avoided enabling inline data.
> +		 */
> +		if (WARN_ON_ONCE(!IS_ENCRYPTED(inode)))
> +			return -EINVAL;
> +		if (WARN_ON_ONCE(ext4_test_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA)))
> +			return -EINVAL;
>  		/*
>  		 * Since the inode is new it is ok to pass the
>  		 * XATTR_CREATE flag. This is necessary to match the
> @@ -170,21 +184,10 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>  		 * function with the credits allocated for the new
>  		 * inode.
>  		 */
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
>  	}
>  
>  	res = dquot_initialize(inode);
> @@ -205,10 +208,7 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>  				    ctx, len, 0);
>  	if (!res) {
>  		ext4_set_inode_flag(inode, EXT4_INODE_ENCRYPT);
> -		/*
> -		 * Update inode->i_flags - S_ENCRYPTED will be enabled,
> -		 * S_DAX may be disabled
> -		 */
> +		/* Update inode->i_flags to set S_ENCRYPTED. */
>  		ext4_set_inode_flags(inode, false);
>  		res = ext4_mark_inode_dirty(handle, inode);
>  		if (res)
> diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
> index a40cb27f8116..a5831fc536db 100644
> --- a/fs/ext4/ialloc.c
> +++ b/fs/ext4/ialloc.c
> @@ -997,6 +997,8 @@ struct inode *__ext4_new_inode(struct mnt_idmap *idmap,
>  		err = fscrypt_prepare_new_inode(dir, inode, &encrypt);
>  		if (err)
>  			goto out;
> +		if (encrypt)
> +			i_flags |= EXT4_ENCRYPT_FL;
>  	}
>  
>  	err = dquot_initialize(inode);
> @@ -1306,6 +1308,8 @@ struct inode *__ext4_new_inode(struct mnt_idmap *idmap,
>  	ei->i_extra_isize = sbi->s_want_extra_isize;
>  	ei->i_inline_off = 0;
>  	if (ext4_has_feature_inline_data(sb) &&
> +	    /* Encrypted inodes cannot have inline data */
> +	    !(ei->i_flags & EXT4_ENCRYPT_FL) &&
>  	    (!(ei->i_flags & (EXT4_DAX_FL|EXT4_EA_INODE_FL)) || S_ISDIR(mode)))
>  		ext4_set_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA);
>  	ret = inode;
> 
> base-commit: f5098b6bae761e346ebcd9da7f95622c04733cff
> -- 
> 2.55.0
> 
