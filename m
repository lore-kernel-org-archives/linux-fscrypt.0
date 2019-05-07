Return-Path: <linux-block-owner@vger.kernel.org>
Subject: Re: [RFC PATCH 2/4] scsi: ufs: UFS driver v2.1 crypto support
References: <20190506223544.195371-1-satyat@google.com>
 <20190506223544.195371-3-satyat@google.com>
From: Bart Van Assche <bvanassche@acm.org>
Message-ID: <f689f1a4-c507-30fd-0c3e-e6fe6d63b30d@acm.org>
Date: Mon, 6 May 2019 17:39:35 -0700
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
> +/*TODO: worry about endianness and cpu_to_le32 */

Please fix endianness issues before reposting this patch series and
please also make sure that this patch series is sparse-clean.
Instructions for how to use sparse are available at
https://kernelnewbies.org/Sparse.

Thanks,

Bart.
