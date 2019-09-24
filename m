Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Message-ID: <1569322670.16730.28.camel@mtkswgap22>
From: Stanley Chu <stanley.chu@mediatek.com>
Date: Tue, 24 Sep 2019 18:57:50 +0800
In-Reply-To: <20190821075714.65140-3-satyat@google.com>
References: <20190821075714.65140-1-satyat@google.com>
 <20190821075714.65140-3-satyat@google.com>
MIME-Version: 1.0
Subject: Re: [f2fs-dev] [PATCH v4 2/8] block: Add encryption context to
 struct bio
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Satya Tangirala <satyat@google.com>
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Kim Boojin <boojin.kim@samsung.com>, Kuohong Wang =?UTF-8?Q?=28=E7=8E=8B=E5=9C=8B=E9=B4=BB=29?= <kuohong.wang@mediatek.com>, Barani Muthukumaran <bmuthuku@qti.qualcomm.com>, "linux-f2fs-devel@lists.sourceforge.net" <linux-f2fs-devel@lists.sourceforge.net>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-fscrypt@vger.kernel.org" <linux-fscrypt@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Satya,

On Wed, 2019-08-21 at 15:57 +0800, Satya Tangirala wrote:
> @@ -827,16 +839,31 @@ bool blk_rq_merge_ok(struct request *rq, struct bio *bio)
>  	if (rq->ioprio != bio_prio(bio))
>  		return false;
>  
> +	/* Only merge if the crypt contexts are compatible */
> +	if (!bio_crypt_ctx_compatible(bio, rq->bio))
> +		return false;
> +

Since bio_crypt_ctx_compatible() lacks of consideration of inode, I am
not sure if here may lead to incorrect merge decision, especially for
f2fs which does not allow merging different files.

Thanks,
Stanley



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
