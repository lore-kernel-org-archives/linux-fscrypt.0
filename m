Return-Path: <SRS0=nTNb=WY=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: Re: [PATCH 5/9] block: support diskcipher
Date: Wed, 28 Aug 2019 11:20:53 +0900
Message-ID: <009301d55d47$38606400$a9212c00$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190828022055epcas2p25525077d0a5a3fa5a2027bac06a10bc1@epcas2p2.samsung.com>
To: "'Theodore Y. Ts'o'" <tytso@mit.edu>
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'  <tytso@mit.edu>,  'Chao Yu'  <chao@kernel.org>,  'Jaegeuk Kim' " <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, "'Ulf Hansson'  <ulf.hansson@linaro.org>, <linux-crypto@vger.kernel.org>," <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.netlinux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Aug 27, 2019 at 05:33:33PM +0900, boojin.kim wrote:
>
> Hi Boojin,
>
> I think the important thing to realize here is that there are a large
> number of hardware devices for which the keyslot manager *is* needed.
> And from the upstream kernel's perspective, supporting two different
> schemes for supporting the inline encryption feature is more
> complexity than just supporting one which is general enough to support
> a wider variety of hardware devices.
>
> If you want somethig which is only good for the hardware platform you
> are charged to support, that's fine if it's only going to be in a
> Samsung-specific kernel.  But if your goal is to get something that
> works upstream, especially if it requires changes in core layers of
> the kernel, it's important that it's general enough to support most,
> if not all, if the hardware devices in the industry.
>
> Regards,

I understood your reply.
But, Please consider the diskcipher isn't just for FMP. 
The UFS in Samsung SoC also has UFS ICE. This UFS ICE can be registered 
as an algorithm of diskcipher like FMP.

Following is my opinion to introduce diskcipher.
I think the common feature of ICE like FMP and UFS ICE, 
is 'exposing cipher text to storage".
And, Crypto test is also important for ICE.  Diskcipher supports
the common feature of ICE. 
I think specific functions for each ICE such as the key control of UFS ICE
and the writing crypto table of FMP can be processed at algorithm level.

Thanks for your reply.
Boojin Kim.
