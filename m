Return-Path: <SRS0=MIPo=WT=gondor.apana.org.au=herbert@kernel.org>
Date: Fri, 23 Aug 2019 14:27:02 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/9] dm crypt: support diskcipher
Message-ID: <20190823042702.GA17034@gondor.apana.org.au>
References: <CGME20190823042038epcas2p2000738f3ca7f5f3d92ea1c32de2bcf99@epcas2p2.samsung.com>
 <017901d5596a$1df3a590$59daf0b0$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <017901d5596a$1df3a590$59daf0b0$@samsung.com>
To: "boojin.kim" <boojin.kim@samsung.com>
Cc: "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'" <tytso@mit.edu>, 'Chao Yu' <chao@kernel.org>, 'Jaegeuk Kim' <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, 'Ulf Hansson' <ulf.hansson@linaro.org>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Aug 23, 2019 at 01:20:37PM +0900, boojin.kim wrote:
>
> If yes, I think the following API needs to be added to skcipher:  
> - _set(): BIO submitter (dm-crypt, f2fs, ext4) sets cipher to BIO.
> - _mergeable(): Block layer checks if two BIOs have the same cipher.
> - _get(): Storage driver gets cipher from BIO.
> - _set_crypt(): Storage driver gets crypto information from cipher and 
> writes it on the descriptor of Storage controller.
> Is it acceptable to skcipher ?

No.  If you're after total offload then the crypto API is not for
you.  What we can support is the offloading of encryption/decryption
over many sectors.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
