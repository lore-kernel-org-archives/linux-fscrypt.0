Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:60382 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726236AbfEFXyh (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 May 2019 19:54:37 -0400
Subject: Re: [RFC PATCH 1/4] block: Block Layer changes for Inline Encryption
 Support
References: <20190506223544.195371-1-satyat@google.com>
 <20190506223544.195371-2-satyat@google.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <ec036543-e318-c143-d5ef-dabfa2b077b9@infradead.org>
Date: Mon, 6 May 2019 16:54:30 -0700
MIME-Version: 1.0
In-Reply-To: <20190506223544.195371-2-satyat@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Satya Tangirala <satyat@google.com>, linux-block@vger.kernel.org, linux-scsi@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Parshuram Raju Thombare <pthombar@cadence.com>, Ladvine D Almeida <ladvine.dalmeida@synopsys.com>, Barani Muthukumaran <bmuthuku@qti.qualcomm.com>, Kuohong Wang <kuohong.wang@mediatek.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 5/6/19 3:35 PM, Satya Tangirala wrote:
> diff --git a/block/Kconfig b/block/Kconfig
> index 028bc085dac8..65213769d2a2 100644
> --- a/block/Kconfig
> +++ b/block/Kconfig
> @@ -187,6 +187,22 @@ config BLK_SED_OPAL
>  	Enabling this option enables users to setup/unlock/lock
>  	Locking ranges for SED devices using the Opal protocol.
>  
> +config BLK_CRYPT_CTX
> +	bool
> +
> +config BLK_KEYSLOT_MANAGER
> +	bool
> +
> +config BLK_CRYPTO
> +	bool "Enable encryption in block layer"
> +	select BLK_CRYPT_CTX
> +	select BLK_KEYSLOT_MANAGER
> +	help
> +	Build the blk-crypto subsystem.
> +	Enabling this lets the block layer handle encryption,
> +	so users can take advantage of inline encryption
> +	hardware if present.

Last 4 lines should be indented with 1 tab + 2 spaces, please.


-- 
~Randy
