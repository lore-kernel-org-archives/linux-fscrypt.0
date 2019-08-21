Return-Path: <SRS0=A8Az=WR=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: Re: [PATCH 6/9] dm crypt: support diskcipher
Date: Wed, 21 Aug 2019 16:54:32 +0900
Message-ID: <001a01d557f5$ab0a4a40$011edec0$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190821075432epcas2p3758bf7b07f209fb4094d79bf46c8f4e9@epcas2p3.samsung.com>
To: 'Mike Snitzer' <snitzer@redhat.com>
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'  <tytso@mit.edu>,  'Chao Yu'  <chao@kernel.org>,  'Jaegeuk Kim' " <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>'Theodore Ts'o' <tytso@mit.edu>, dm-devel@redhat.com, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, "'Ulf Hansson'  <ulf.hansson@linaro.org>, <linux-crypto@vger.kernel.org>," <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.netlinux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Aug 21, 2019 at 09:13:36AM +0200, Milan Broz wrote: 
>
> NACK.
> 
> The whole principle of dm-crypt target is that it NEVER EVER submits
> plaintext data down the stack in bio.
> 
> If you want to do some lower/higher layer encryption, use key management
> on a different layer.
> So here, just setup encryption for fs, do not stack it with dm-crypt.
> 
> Also, dm-crypt is software-independent solution
> (software-based full disk encryption), it must not depend on
> any underlying hardware.
> Hardware can be of course used used for acceleration, but then
> just implement proper crypto API module that accelerates particular
cipher.

I'm sorry for breaking the basic rules of dm-crypt. 
But, if I want to use the H/W crypto accelerator running in storage
controller,
I have to drop plaintext to bio.
I think the "proper crypto API module" that you mentioned is diskcipher
because diskcipher isn't only for FMP.
Diskcipher is a crypto API that supports encryption on storage controllers.

Thanks
Boojin Kim
