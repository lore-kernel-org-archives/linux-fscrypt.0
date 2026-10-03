Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com [115.124.30.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB44E43B3C9;
	Sat,  3 Oct 2026 15:07:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791040079; cv=none; b=KYjxFpznwr67qESttKrBrqqUi8F2iNDgYrQSwl1VK8k8DjW/D7lGLBw+XPWwJgazGSomNgrgzNgUACwX38KkkyPFDQQSdNf0rbkk4OrBPG9/jSbe5FyZkRKlB063w8sSl8Knj8L2GXi3KFIHuIdTtuG4vGzr9sOcVf1irTD2v2o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791040079; c=relaxed/simple;
	bh=Xr6KBVeamBa3rDCgATVlCtpRxU2mHpOdruLeSlGqKu4=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=KlG+ssx7ZeGzXkHcG9x6x9J4eQK1rU4TDjhcUdQ/MhnZJbInFsUYCo+42M711ONECFP64DQ0NuUP+e4auurhDTUfv3OWADDLTUGDMHKCpVi3b8CM7XHRx90p4+hJcl/8DeiGlgePO+XN+Qu7AwkgMNdd8m6kWch0MkhCjrcPwRc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=yHeaTAw+; arc=none smtp.client-ip=115.124.30.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="yHeaTAw+"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1791040064; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=J4ujnQWIKPGnu6N1qQoxV+DlmQRk0Jis6xet+M71/5k=;
	b=yHeaTAw+Dv3nZJyIlKcGlJqGyTYlpw9OEvSdM0+W6MqtRWTE3csWyxBWnGL8xZF3FS6TSO7eSr5mr+kdFrnTY95b2Nt+4WT/KdGxivtqVONB+NONym26GGQXxe3mq2zgM7vQEEmWt3ayeNDBB7cl+ccbdXdK5V0zh85lSuxcKaU=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R581e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037033178;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0XC0gHSu_1791040061;
Received: from 30.251.45.45(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XC0gHSu_1791040061 cluster:ay36)
          by smtp.aliyun-inc.com;
          Sat, 03 Oct 2026 23:07:42 +0800
Message-ID: <100962e8-963b-4332-9aea-abba1ad6d6ad@linux.alibaba.com>
Date: Sat, 3 Oct 2026 23:07:41 +0800
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 7.2.y] ext4: don't enable large folios on encrypted inodes
To: Alberto Garcia <berto@igalia.com>, stable@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>,
 Jan Kara <jack@suse.cz>, Ojaswin Mujoo <ojaswin@linux.ibm.com>,
 Ritesh Harjani <ritesh.list@gmail.com>, Zhang Yi <yi.zhang@huawei.com>,
 Eric Biggers <ebiggers@kernel.org>, linux-ext4@vger.kernel.org,
 linux-fscrypt@vger.kernel.org, regressions@lists.linux.dev
References: <20260925153127.1472301-1-berto@igalia.com>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <20260925153127.1472301-1-berto@igalia.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 2026/9/25 23:31, Alberto Garcia wrote:
> Commit 709f0f1f1bf5 ("ext4: add checks for large folio
> incompatibilities when BS > PS") disables large folios at mount time
> if the "encrypt" feature is set. However, enabling that feature on a
> mounted filesystem circumvents that check, and writing encrypted data
> results in a crash:
>
>   BUG: kernel NULL pointer dereference, address: 0000000000000028
>   Workqueue: ext4-rsv-conversion ext4_end_io_rsv_work
>   RIP: 0010:ext4_finish_bio+0xf7/0x3e0
>   Call Trace:
>    ext4_release_io_end+0x51/0x110
>    ext4_end_io_end+0x4c/0xe0
>    ext4_end_io_rsv_work+0xb3/0x100
>
> Fix this by disabling large folios on encrypted inodes, as is
> already done for inodes that use data journaling.
>
> This affects all kernels between v6.19 and v7.2, but it is not needed
> in v7.3, where the code was significantly refactored.
>
> Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities when BS > PS")
> Signed-off-by: Alberto Garcia <berto@igalia.com>

Looks good, thanks for the fix.

Reviewed-by: Baokun Li <libaokun@linux.alibaba.com>

> ---
> This affects all kernels between v6.19 and v7.2 but only the latter is
> still maintained, so I think that it only needs to be applied there.
>
> This patch has no upstream equivalent: in v7.3 the code was
> significantly refactored and the problem no longer happens, see commit
> b4e409c18c79 ("ext4: Remove fs-layer file contents en/decryption
> code").
>
> To reproduce the bug:
>
> # mkfs.ext4 /dev/vdb
> # mount /dev/vdb /mnt/
> # tune2fs -O encrypt /dev/vdb
> # mkdir /mnt/foo
> # fscrypt setup /mnt
> # fscrypt encrypt /mnt/foo/
> # head -c 20M /dev/urandom > /mnt/foo/data
> # sync
> BUG: kernel NULL pointer dereference, address: 0000000000000028
> Workqueue: ext4-rsv-conversion ext4_end_io_rsv_work
> [...]
>
>  fs/ext4/inode.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index a33629b397b0..32f79f48a9dd 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -5287,7 +5287,8 @@ void ext4_set_inode_mapping_order(struct inode *inode)
>  	if (!min_order && !S_ISREG(inode->i_mode))
>  		return;
>  
> -	if (ext4_test_inode_flag(inode, EXT4_INODE_JOURNAL_DATA))
> +	if (ext4_test_inode_flag(inode, EXT4_INODE_JOURNAL_DATA) ||
> +	    ext4_test_inode_flag(inode, EXT4_INODE_ENCRYPT))
>  		max_order = min_order;
>  
>  	mapping_set_folio_order_range(inode->i_mapping, min_order, max_order);


