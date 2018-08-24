Return-Path: <SRS0=DrC7=LH=infradead.org=rdunlap@kernel.org>
Subject: Re: [RFC PATCH 01/10] fs-verity: add setup code, UAPI, and Kconfig
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-2-ebiggers@kernel.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <224dccfa-8ce2-8bfd-ffd3-4684b6bc7448@infradead.org>
Date: Fri, 24 Aug 2018 10:28:16 -0700
MIME-Version: 1.0
In-Reply-To: <20180824161642.1144-2-ebiggers@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 08/24/2018 09:16 AM, Eric Biggers wrote:
> +/* ========== Ioctls ========== */
> +
> +struct fsverity_digest {
> +	__u16 digest_algorithm;
> +	__u16 digest_size; /* input/output */
> +	__u8 digest[];
> +};
> +
> +#define FS_IOC_ENABLE_VERITY	_IO('f', 133)
> +#define FS_IOC_MEASURE_VERITY	_IOWR('f', 134, struct fsverity_digest)

Hi,

Please update Documentation/ioctl/ioctl-number.txt also.

thanks,
-- 
~Randy
