Received: from out199-18.us.a.mail.aliyun.com (out199-18.us.a.mail.aliyun.com [47.90.199.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5A6536164D;
	Sat,  3 Oct 2026 15:17:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=47.90.199.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791040649; cv=none; b=ustooKAm8zxCWWhd8Vw2fGPVecYJaYB7d155wazIKcYSM1ZgDry2rKJoGaKzqlMrHGXxUESmp3baVtwuXPgL0p3niyRon5US+wMkUhnJeP5TpJleYI+6aUXooumz7PFfAamDSjhZcTcegzZ7YzjTkuGcTT0XzJoldmipaHt+c6E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791040649; c=relaxed/simple;
	bh=7CUIaXQGOdVvSDNwFXltqVc8zG+cARTFKk1Iegy2EEQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=aWVk0xsvdx2VQ+v/VhgKVSy8Gvjdk+IP2RHP/cFFNbs0BlxxDZXjMLpbNtCuVeeFGFlZJUdz2P3cULt6DPwELEBm0oWgt9nmjwK3J++D9ntN6oxaLV29AM1BjQZXFfNJbC5O1Mw350dyNEr95iNEYvb45D8rLF8jagN8YuVRCHQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=qkDQJZBh; arc=none smtp.client-ip=47.90.199.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="qkDQJZBh"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1791040631; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=f/Obgq91HGYF81m0Pl+5UwR5aUZWKDjwqKAF0zBy1MQ=;
	b=qkDQJZBhP7lriqcwpIZGesxPJ6fcu2S+98w6WgQKhfzFaBGQBusKP6GfRKQBfKS2MAx4tAYn7Tz2tQGPVR36Q8LeykgbkFH/t9lqpDl3QRlPR3h3O/Rq4ozWvf21gBZj9bUzlpW6WhT8NTkXU39iltvwgoZhmp+8C5f8UZxCtTg=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R691e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033032089153;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0XC0hoT6_1791040629;
Received: from 30.251.45.45(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XC0hoT6_1791040629 cluster:ay36)
          by smtp.aliyun-inc.com;
          Sat, 03 Oct 2026 23:17:10 +0800
Message-ID: <b21f0217-7f80-46bc-bc77-69ee50f5d1dc@linux.alibaba.com>
Date: Sat, 3 Oct 2026 23:17:09 +0800
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/2] ext4: refuse encryption when block size > page size
To: Alberto Garcia <berto@igalia.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>,
 Jan Kara <jack@suse.cz>, Ojaswin Mujoo <ojaswin@linux.ibm.com>,
 Ritesh Harjani <ritesh.list@gmail.com>, Zhang Yi <yi.zhang@huawei.com>,
 Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org,
 linux-ext4@vger.kernel.org, stable@vger.kernel.org
References: <cover.1790343958.git.berto@igalia.com>
 <093b40e9df29fc102907092f4ff73461f4cfcbfd.1790343958.git.berto@igalia.com>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <093b40e9df29fc102907092f4ff73461f4cfcbfd.1790343958.git.berto@igalia.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 2026/9/25 22:19, Alberto Garcia wrote:
> Encryption is not supported when a filesystem's block size is larger
> than the page size, and commit 709f0f1f1bf5 ("ext4: add checks for
> large folio incompatibilities when BS > PS") added a check to refuse
> mounting such a filesystem.
>
> However, it is also possible to enable the "encrypt" feature on a
> filesystem that is already mounted (with tune2fs -O encrypt). Once
> that happens it won't be possible to mount the filesystem again in
> the future, but there is nothing preventing the user from setting an
> encryption policy while the filesystem is still mounted.
>
> Fix this by refusing to set an fscrypt context in ext4_set_context()
> when the block size is larger than the page size.
>
> Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities when BS > PS")
> Cc: stable@vger.kernel.org # v6.19+
> Signed-off-by: Alberto Garcia <berto@igalia.com>


Thanks for the patch, feel free to add:

Reviewed-by: Baokun Li <libaokun@linux.alibaba.com>

> ---
>  fs/ext4/crypto.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
> index 1a0fccb084ef..318b2eaea741 100644
> --- a/fs/ext4/crypto.c
> +++ b/fs/ext4/crypto.c
> @@ -156,6 +156,15 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>  	if (ext4_test_inode_flag(inode, EXT4_INODE_DAX))
>  		return -EOPNOTSUPP;
>  
> +	/*
> +	 * Encryption is not supported when the block size is larger
> +	 * than the page size.  This is rejected at mount time by
> +	 * ext4_check_large_folio(), and this check here is for the case
> +	 * when the 'encrypt' feature is enabled on a mounted filesystem.
> +	 */
> +	if (inode->i_sb->s_blocksize > PAGE_SIZE)
> +		return -EOPNOTSUPP;
> +
>  	res = ext4_convert_inline_data(inode);
>  	if (res)
>  		return res;


