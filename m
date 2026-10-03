Received: from out30-113.freemail.mail.aliyun.com (out30-113.freemail.mail.aliyun.com [115.124.30.113])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DA3143F8C6;
	Sat,  3 Oct 2026 15:29:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.113
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791041353; cv=none; b=nw87jnk0qNl5CvjK06PoY0mLW2WXRJU8CMzOIzBiUQZkv7rNsNCQSmYi8bYNgxc7FDbKyJyFlz2Y8Y9rsaxw7zmDlZu7V/0YZrcnr0LRfBDOxT2KpVAFiQ7KvZJ51TnSIGovq7KxYlpExIB/cWm7p8Yq3AE094xSlgSvHObTPMU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791041353; c=relaxed/simple;
	bh=g2u8nppeUzRqm/He3lTIqb2/a/2/YzA4MPCqjDk0468=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=AEA+mjuPr5bO4HIQtcDGiyou33WNJc9oCvdg6uDQCo7YVMykE9Ddjr0LfIFzzRiJyFyp0avSaQ9SP3wQg/T3fsGaEb82VtLzDOeb2vLOOwDX+pO9qhDZSqkVcTs6Pg83kjkYywSGF2F4lj+zB1aRshoRZ2tPRufGsUYMrwFxLck=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=spqUfaNY; arc=none smtp.client-ip=115.124.30.113
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="spqUfaNY"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1791041338; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=dFR+UVbUJO44n8A8WkV8gIl68affmG7x/BkQf1ITU8s=;
	b=spqUfaNYHu9MTF/kWcjuuxKB1urJMGG/j5II5zaiRpkVBhWh6GJ094NlzdwBlCJwTjPjZ4hNyRgZIH42kL/um/f4eJfJ2selVEGbhaA3kA4FjItwyGHGGoNSOA9PbrKCd9UikMVAH+6i0chivkOJk9TXwiVo/gXMSnlH16eo6B8=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037026112;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0XC0i9ye_1791041336;
Received: from 30.251.45.45(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XC0i9ye_1791041336 cluster:ay36)
          by smtp.aliyun-inc.com;
          Sat, 03 Oct 2026 23:28:58 +0800
Message-ID: <ca5783cc-a45f-428c-8fc3-19a02d226cbd@linux.alibaba.com>
Date: Sat, 3 Oct 2026 23:28:56 +0800
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 2/2] ext4: reject encrypted inodes when block size > page
 size
To: Alberto Garcia <berto@igalia.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>,
 Jan Kara <jack@suse.cz>, Ojaswin Mujoo <ojaswin@linux.ibm.com>,
 Ritesh Harjani <ritesh.list@gmail.com>, Zhang Yi <yi.zhang@huawei.com>,
 Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org,
 linux-ext4@vger.kernel.org, stable@vger.kernel.org
References: <cover.1790343958.git.berto@igalia.com>
 <aeb8efa8beb72721fb4b13cffe6eb22c795ec33f.1790343958.git.berto@igalia.com>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <aeb8efa8beb72721fb4b13cffe6eb22c795ec33f.1790343958.git.berto@igalia.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 2026/9/25 22:19, Alberto Garcia wrote:
> Encryption is not supported when a filesystem's block size is larger
> than the page size. ext4_check_large_folio() refuses to mount a
> filesystem like that if the "encrypt" feature is already enabled, and
> ext4_set_context() refuses to create encrypted inodes if the feature
> is enabled after mounting.
>
> However, a corrupted or hand-crafted filesystem can still have
> encrypted inodes even if the "encrypt" feature is not set, and those
> inodes can be unlocked if they're using v1 policies.
>
> Check this in __ext4_iget() and reject them as corrupted.
>
> Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities when BS > PS")
> Suggested-by: Eric Biggers <ebiggers@kernel.org>
> Cc: stable@vger.kernel.org # v6.19+
> Signed-off-by: Alberto Garcia <berto@igalia.com>

Looks good, feel free to add:

Reviewed-by: Baokun Li <libaokun@linux.alibaba.com>

> ---
>  fs/ext4/inode.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 26f0f9714f03..31248fef8bce 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -5671,6 +5671,12 @@ struct inode *__ext4_iget(struct super_block *sb, unsigned long ino,
>  		ret = -EFSCORRUPTED;
>  		goto bad_inode;
>  	}
> +	if (IS_ENCRYPTED(inode) && sb->s_blocksize > PAGE_SIZE) {
> +		ext4_error_inode(inode, function, line, 0,
> +				 "encrypted inode with block size larger than page size");
> +		ret = -EFSCORRUPTED;
> +		goto bad_inode;
> +	}
>  
>  	ext4_set_inode_mapping_order(inode);
>  


