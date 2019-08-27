Return-Path: <SRS0=h/2y=WX=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: Re: [PATCH 5/9] block: support diskcipher
Date: Tue, 27 Aug 2019 17:33:33 +0900
Message-ID: <03b201d55cb2$1d4d31b0$57e79510$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190827083334epcas2p115d479190b9a72c886f66569add78203@epcas2p1.samsung.com>
To: 'Satya Tangirala' <satyat@google.com>
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'  <tytso@mit.edu>,  'Chao Yu'  <chao@kernel.org>,  'Jaegeuk Kim' " <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>'Theodore Ts'o' <tytso@mit.edu>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, "'Ulf Hansson'  <ulf.hansson@linaro.org>, <linux-crypto@vger.kernel.org>," <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.netlinux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Aug 21, 2019 at 5:10 AM Satya Tangirala <satyat@kernel.dk> wrote:
> 
> Hi Boojin,
>
> We're very keen to make sure that our approach to inline encryption can
> work with diverse hardware, including Samsung's FMP hardware; if you
> can see any issues with using our approach with your hardware please
> let us know.
>
> We understand that a possible concern for getting FMP working with our
> patch series for Inline Encryption Support at
>
>
https://lore.kernel.org/linux-block/20190821075714.65140-1-satyat@google.com
/
>
> is that unlike some inline encryption hardware (and also unlike the JEDEC
> UFS v2.1 spec), FMP doesn't have the concept of a limited number of
> keyslots - to address that difference we have a "passthrough keyslot
> manager", which we put up on top of our patch series for inline encryption
> support at
>
> https://android-review.googlesource.com/c/kernel/common/+/980137/2
>
> Setting up a passthrough keyslot manager in the request queue of a
> device allows the device to receive a bio's encryption context as-is with
> the bio, which is what FMP would prefer. Are there any issues with
> using the passthrough keyslot manager for FMP?
>
> Thanks!
> Satya

Dear Satya.
Keyslot manager is a good solution for ICE. And probably no issue for FMP.
But, I think it's complicated for FMP because FMP doesn't need
any keyslot control.
Crypto API that FMP's using is simply, stable, and supports test. 
FMP has been mass producing and certificating using crypto APIs
for several years. 
So I wants to keep  our current crypto API solution.
But, I'm looking at your patch.  And I will keep examining at your patch
because our goal is to run the FMP on the mainline kernel.

Thanks for your reply.
Boojin Kim.
