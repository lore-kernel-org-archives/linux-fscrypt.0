Return-Path: <SRS0=A8Az=WR=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: Re: [PATCH 6/9] dm crypt: support diskcipher
Date: Wed, 21 Aug 2019 16:57:41 +0900
Message-ID: <001b01d557f6$1c49fd40$54ddf7c0$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190821075742epcas2p4b9104e8249067c048d4050f2888da0a9@epcas2p4.samsung.com>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>
Cc: "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'  <tytso@mit.edu>,  'Chao Yu'  <chao@kernel.org>,  'Jaegeuk Kim' " <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>'Theodore Ts'o' <tytso@mit.edu>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, "'Ulf Hansson'  <ulf.hansson@linaro.org>, <linux-crypto@vger.kernel.org>," <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.netlinux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Aug 21, 2019 at 09:35:36AM +0200, Herbert Xu Herbert wrote:

> I agree.  Please take a look at the recent ESSIV patches on
> linux-crypto and build multi-block operations on top of them
> which can then be implemented by the hardware.
>
> Cheers,

Can you tell me which patch you mentioned? Is this?
https://patches.linaro.org/project/linux-crypto/list/?series=22762
