Return-Path: <SRS0=vace=W3=huawei.com=yuchao0@kernel.org>
Subject: Re: [PATCH] ext4 crypto: fix to check feature status before get
 policy
References: <20190804095643.7393-1-chao@kernel.org>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <f5186fae-ac58-a5f5-f9dc-b749ade7285d@huawei.com>
Date: Sat, 31 Aug 2019 18:32:28 +0800
MIME-Version: 1.0
In-Reply-To: <20190804095643.7393-1-chao@kernel.org>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org
Cc: Chao Yu <chao@kernel.org>, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

Is this change not necessary? A month has passed...

Thanks,

On 2019/8/4 17:56, Chao Yu wrote:
> From: Chao Yu <yuchao0@huawei.com>
> 
> When getting fscrypto policy via EXT4_IOC_GET_ENCRYPTION_POLICY, if
> encryption feature is off, it's better to return EOPNOTSUPP instead
> of ENODATA, so let's add ext4_has_feature_encrypt() to do the check
> for that.
> 
> Signed-off-by: Chao Yu <yuchao0@huawei.com>
> ---
>  fs/ext4/ioctl.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
> index 442f7ef873fc..bf87835c1237 100644
> --- a/fs/ext4/ioctl.c
> +++ b/fs/ext4/ioctl.c
> @@ -1112,9 +1112,11 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
>  		return -EOPNOTSUPP;
>  #endif
>  	}
> -	case EXT4_IOC_GET_ENCRYPTION_POLICY:
> +	case EXT4_IOC_GET_ENCRYPTION_POLICY: {
> +		if (!ext4_has_feature_encrypt(sb))
> +			return -EOPNOTSUPP;
>  		return fscrypt_ioctl_get_policy(filp, (void __user *)arg);
> -
> +	}
>  	case EXT4_IOC_FSGETXATTR:
>  	{
>  		struct fsxattr fa;
> 
