Return-Path: <linux-block-owner@vger.kernel.org>
Subject: Re: [RFC PATCH 2/4] scsi: ufs: UFS driver v2.1 crypto support
References: <20190506223544.195371-1-satyat@google.com>
 <20190506223544.195371-3-satyat@google.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <9ca9b288-4fc1-030a-3898-8ec632113c44@infradead.org>
Date: Mon, 6 May 2019 16:51:20 -0700
MIME-Version: 1.0
In-Reply-To: <20190506223544.195371-3-satyat@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-block-owner@vger.kernel.org
To: Satya Tangirala <satyat@google.com>, linux-block@vger.kernel.org, linux-scsi@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Parshuram Raju Thombare <pthombar@cadence.com>, Ladvine D Almeida <ladvine.dalmeida@synopsys.com>, Barani Muthukumaran <bmuthuku@qti.qualcomm.com>, Kuohong Wang <kuohong.wang@mediatek.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 5/6/19 3:35 PM, Satya Tangirala wrote:
> diff --git a/drivers/scsi/ufs/Kconfig b/drivers/scsi/ufs/Kconfig
> index 6db37cf306b0..c14f445a2522 100644
> --- a/drivers/scsi/ufs/Kconfig
> +++ b/drivers/scsi/ufs/Kconfig
> @@ -135,3 +135,13 @@ config SCSI_UFS_BSG
>  
>  	  Select this if you need a bsg device node for your UFS controller.
>  	  If unsure, say N.
> +
> +config SCSI_UFS_CRYPTO
> +	bool "UFS Crypto Engine Support"
> +	depends on SCSI_UFSHCD && BLK_KEYSLOT_MANAGER
> +	help
> +	Enable Crypto Engine Support in UFS.
> +	Enabling this makes it possible for the kernel to use the crypto
> +	capabilities of the UFS device (if present) to perform crypto
> +	operations on data being transferred into/out of the device.

	                        (maybe:)     to/from the device.
> +

Help text should be indented with 1 tab + 2 spaces, please.

-- 
~Randy
