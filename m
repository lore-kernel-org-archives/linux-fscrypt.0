Return-Path: <SRS0=zV7d=VW=gmail.com=baijiaju1990@kernel.org>
Subject: Re: [PATCH] fs: crypto: keyinfo: Fix a possible null-pointer
 dereference in derive_key_aes()
References: <20190724100204.2009-1-baijiaju1990@gmail.com>
 <20190724160711.GB673@sol.localdomain>
 <3d206c43-994e-6134-3f28-b4a500472760@gmail.com>
 <9740973d-6e59-e4df-7097-4e5d0da89235@gmail.com>
 <20190725033951.GA677@sol.localdomain>
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Message-ID: <33ae3693-9792-a793-5e9e-aca845c427a5@gmail.com>
Date: Thu, 25 Jul 2019 11:52:07 +0800
MIME-Version: 1.0
In-Reply-To: <20190725033951.GA677@sol.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
To: tytso@mit.edu, jaegeuk@kernel.org, ebiggers@kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>



On 2019/7/25 11:39, Eric Biggers wrote:
> On Thu, Jul 25, 2019 at 11:33:53AM +0800, Jia-Ju Bai wrote:
>> Sorry, I forgot to send to Eric, so send it again.
>>
>> On 2019/7/25 11:30, Jia-Ju Bai wrote:
>>>
>>> On 2019/7/25 0:07, Eric Biggers wrote:
>>>> [+Cc linux-crypto]
>>>>
>>>> On Wed, Jul 24, 2019 at 06:02:04PM +0800, Jia-Ju Bai wrote:
>>>>> In derive_key_aes(), tfm is assigned to NULL on line 46, and then
>>>>> crypto_free_skcipher(tfm) is executed.
>>>>>
>>>>> crypto_free_skcipher(tfm)
>>>>>       crypto_skcipher_tfm(tfm)
>>>>>           return &tfm->base;
>>>>>
>>>>> Thus, a possible null-pointer dereference may occur.
>>>> This analysis is incorrect because only the address &tfm->base is taken.
>>>> There's no pointer dereference.
>>>>
>>>> In fact all the crypto_free_*() functions are no-ops on NULL
>>>> pointers, and many
>>>> other callers rely on it.  So there's no bug here.
>>> Thanks for the reply :)
>>> I admit that "&tfm->base" is not a null-pointer dereference when tfm is
>>> NULL.
>>> But I still think crypto_free_skcipher(tfm) can cause security problems
>>> when tfm is NULL.
>>>
>>> Looking at the code:
>>>
>>> static inline void crypto_free_skcipher(struct crypto_skcipher *tfm)
>>> {
>>>      crypto_destroy_tfm(tfm, crypto_skcipher_tfm(tfm));
>>> }
>>>
>>> static inline struct crypto_tfm *crypto_skcipher_tfm(
>>>      struct crypto_skcipher *tfm)
>>> {
>>>      return &tfm->base;
>>> }
>>>
>>> void crypto_destroy_tfm(void *mem, struct crypto_tfm *tfm)
>>> {
>>>      struct crypto_alg *alg;
>>>
>>>      if (unlikely(!mem))
>>>          return;
> When the original pointer is NULL, mem == NULL here so crypto_destroy_tfm() is a
> no-op.

I overlooked this if statement, thanks for the pointer.

>
>>> Besides, I also find that some kernel modules check tfm before calling
>>> crypto_free_*(), such as:
>>>
>>> drivers/crypto/vmx/aes_xts.c:
>>>      if (ctx->fallback) {
>>>          crypto_free_skcipher(ctx->fallback);
>>>          ctx->fallback = NULL;
>>>      }
>>>
>>> net/rxrpc/rxkad.c:
>>>      if (conn->cipher)
>>>          crypto_free_skcipher(conn->cipher);
>>>
>>> drivers/crypto/chelsio/chcr_algo.c:
>>>      if (ablkctx->aes_generic)
>>>          crypto_free_cipher(ablkctx->aes_generic);
>>>
>>> net/mac80211/wep.c:
>>>      if (!IS_ERR(local->wep_tx_tfm))
>>>          crypto_free_cipher(local->wep_tx_tfm);
>>>
> Well, people sometimes do that for kfree() too.  But that doesn't mean it's
> needed, or that it's the preferred style (it's not).

Okay.


Best wishes,
Jia-Ju Bai
