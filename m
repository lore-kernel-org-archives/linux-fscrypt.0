Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pf1-f193.google.com ([209.85.210.193]:40690 "EHLO
        mail-pf1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726381AbfEGBXk (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 May 2019 21:23:40 -0400
Subject: Re: [RFC PATCH 3/4] fscrypt: wire up fscrypt to use blk-crypto
References: <20190506223544.195371-1-satyat@google.com>
 <20190506223544.195371-4-satyat@google.com>
From: Bart Van Assche <bvanassche@acm.org>
Message-ID: <daa7c452-0f73-67e7-7a9a-55499372cc0d@acm.org>
Date: Mon, 6 May 2019 18:23:35 -0700
MIME-Version: 1.0
In-Reply-To: <20190506223544.195371-4-satyat@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Satya Tangirala <satyat@google.com>, linux-block@vger.kernel.org, linux-scsi@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Parshuram Raju Thombare <pthombar@cadence.com>, Ladvine D Almeida <ladvine.dalmeida@synopsys.com>, Barani Muthukumaran <bmuthuku@qti.qualcomm.com>, Kuohong Wang <kuohong.wang@mediatek.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 5/6/19 3:35 PM, Satya Tangirala wrote:
[ ... ]
> diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
> index 7da276159593..d6d65c88a629 100644
> --- a/fs/crypto/fscrypt_private.h
> +++ b/fs/crypto/fscrypt_private.h
> @@ -49,6 +49,16 @@ struct fscrypt_symlink_data {
>  	char encrypted_path[1];
>  } __packed;
>  
> +/* Master key referenced by FS_POLICY_FLAG_DIRECT_KEY policy */
> +struct fscrypt_master_key {
> +	struct hlist_node mk_node;
> +	refcount_t mk_refcount;
> +	const struct fscrypt_mode *mk_mode;
> +	struct crypto_skcipher *mk_ctfm;
> +	u8 mk_descriptor[FS_KEY_DESCRIPTOR_SIZE];
> +	u8 mk_raw[FS_MAX_KEY_SIZE];
> +};
> [ ... ]
> -/* Master key referenced by FS_POLICY_FLAG_DIRECT_KEY policy */
> -struct fscrypt_master_key {
> -	struct hlist_node mk_node;
> -	refcount_t mk_refcount;
> -	const struct fscrypt_mode *mk_mode;
> -	struct crypto_skcipher *mk_ctfm;
> -	u8 mk_descriptor[FS_KEY_DESCRIPTOR_SIZE];
> -	u8 mk_raw[FS_MAX_KEY_SIZE];
> -};

How about introducing the file fs/crypto/fscrypt_private.h in patch 2/4
such that the fscrypt_master_key definition does not have to be moved
around?

Thanks,

Bart.
