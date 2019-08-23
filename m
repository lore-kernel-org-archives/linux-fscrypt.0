Return-Path: <SRS0=tO/G=WT=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: Re: [PATCH 6/9] dm crypt: support diskcipher
Date: Fri, 23 Aug 2019 16:18:47 +0900
Message-ID: <002b01d55983$01b40320$051c0960$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190823071848epcas2p3fe4d229d22b14162c354f88a29f366c2@epcas2p3.samsung.com>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>
Cc: "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'  <tytso@mit.edu>,  'Chao Yu'  <chao@kernel.org>,  'Jaegeuk Kim' " <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>'Theodore Ts'o' <tytso@mit.edu>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, "'Ulf Hansson'  <ulf.hansson@linaro.org>, <linux-crypto@vger.kernel.org>," <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.netlinux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Aug 23, 2019 at 01:28:37PM +0900, Herbert Xu wrote:
>
> No.  If you're after total offload then the crypto API is not for
> you.  What we can support is the offloading of encryption/decryption
> over many sectors.
>
> Cheers,

FMP doesn't use encrypt/decrypt of crypto API because it doesn't
expose cipher-text to DRAM.
But, Crypto API has many useful features such as cipher management,
cipher allocation with cipher name, key management and test manager.
All these features are useful for FMP.
FMP has been cerified with FIPS as below by using test vectors and
test manager of Crypto API.
https://csrc.nist.gov/projects/cryptographic-module-validation-program/Certi
ficate/3255
https://csrc.nist.gov/CSRC/media/projects/cryptographic-module-validation-pr
ogram/documents/security-policies/140sp3255.pdf

Can't I use crypto APIs to take advantage of this?
I want to find a good way that FMP can use crypto API.

Thanks
Boojin Kim.
