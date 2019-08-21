Return-Path: <dm-devel-bounces@redhat.com>
Date: Wed, 21 Aug 2019 17:21:09 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Message-ID: <20190821072109.GA22686@gondor.apana.org.au>
References: <CGME20190821064230epcas2p1ad7301f2b1331bcab3126e6e37c0e272@epcas2p1.samsung.com>
	<004201d557eb$9b0a4410$d11ecc30$@samsung.com>
	<cc484ef6-aacc-7864-0e6d-313b2e1c5d92@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <cc484ef6-aacc-7864-0e6d-313b2e1c5d92@gmail.com>
Subject: Re: [dm-devel] [PATCH 6/9] dm crypt: support diskcipher
List-Unsubscribe: <https://www.redhat.com/mailman/options/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
To: Milan Broz <gmazyland@gmail.com>
Cc: 'Jens Axboe' <axboe@kernel.dk>, 'Jaehoon Chung' <jh80.chung@samsung.com>, 'Ulf Hansson' <ulf.hansson@linaro.org>, "'Theodore Y. Ts'o'" <tytso@mit.edu>, 'Mike Snitzer' <snitzer@redhat.com>, "boojin.kim" <boojin.kim@samsung.com>, 'Chao Yu' <chao@kernel.org>, linux-mmc@vger.kernel.org, linux-kernel@vger.kernel.org, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Eric Biggers' <ebiggers@kernel.org>, dm-devel@redhat.com, 'Kukjin Kim' <kgene@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>, linux-crypto@vger.kernel.org, 'Jaegeuk Kim' <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, "'David S. Miller'" <davem@davemloft.net>, 'Alasdair Kergon' <agk@redhat.com>
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
> just implement proper crypto API module that accelerates particular cipher.

I agree.  Please take a look at the recent ESSIV patches on
linux-crypto and build multi-block operations on top of them
which can then be implemented by the hardware.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
