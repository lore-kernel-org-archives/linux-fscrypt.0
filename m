Return-Path: <linux-block-owner@vger.kernel.org>
Subject: Re: [RFC PATCH 4/4] f2fs: Wire up f2fs to use inline encryption via
 fscrypt
References: <20190506223544.195371-1-satyat@google.com>
 <20190506223544.195371-5-satyat@google.com>
From: Bart Van Assche <bvanassche@acm.org>
Message-ID: <58ca036a-7635-9b6f-d778-c89802a50129@acm.org>
Date: Mon, 6 May 2019 18:25:42 -0700
MIME-Version: 1.0
In-Reply-To: <20190506223544.195371-5-satyat@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-block-owner@vger.kernel.org
To: Satya Tangirala <satyat@google.com>, linux-block@vger.kernel.org, linux-scsi@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Parshuram Raju Thombare <pthombar@cadence.com>, Ladvine D Almeida <ladvine.dalmeida@synopsys.com>, Barani Muthukumaran <bmuthuku@qti.qualcomm.com>, Kuohong Wang <kuohong.wang@mediatek.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 5/6/19 3:35 PM, Satya Tangirala wrote:
> +static inline u64 hw_crypt_dun(struct inode *inode, struct page *page)
> +{
> +	return (((u64)inode->i_ino) << 32) | (page->index & 0xFFFFFFFF);
> +}

How about using lower_32_bits() instead of "& 0xFFFFFFFF"?

Thanks,

Bart.
