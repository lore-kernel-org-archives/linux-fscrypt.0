Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f67.google.com ([209.85.221.67]:45518 "EHLO
        mail-wr1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726952AbfFTNO4 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 20 Jun 2019 09:14:56 -0400
Subject: Re: [PATCH v3 0/6] crypto: switch to crypto API for ESSIV generation
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <459f5760-3a1c-719d-2b44-824ba6283dd7@gmail.com>
 <CAKv+Gu9jk8KxWykTcKeh6k0HUb47wgx7iZYuwwN8AUyErFLXxA@mail.gmail.com>
 <075cddec-1603-4a23-17c4-c766b4bd9086@gmail.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <6a45dfa5-e383-d8a3-ebf1-abdc43c95ebd@gmail.com>
Date: Thu, 20 Jun 2019 15:14:52 +0200
MIME-Version: 1.0
In-Reply-To: <075cddec-1603-4a23-17c4-c766b4bd9086@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Milan Broz <gmazyland@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 20/06/2019 14:09, Milan Broz wrote:
> On 20/06/2019 13:54, Ard Biesheuvel wrote:
>> On Thu, 20 Jun 2019 at 13:22, Milan Broz <gmazyland@gmail.com> wrote:
>>>
>>> On 19/06/2019 18:29, Ard Biesheuvel wrote:
>>>> This series creates an ESSIV template that produces a skcipher or AEAD
>>>> transform based on a tuple of the form '<skcipher>,<cipher>,<shash>'
>>>> (or '<aead>,<cipher>,<shash>' for the AEAD case). It exposes the
>>>> encapsulated sync or async skcipher/aead by passing through all operations,
>>>> while using the cipher/shash pair to transform the input IV into an ESSIV
>>>> output IV.
>>>>
>>>> This matches what both users of ESSIV in the kernel do, and so it is proposed
>>>> as a replacement for those, in patches #2 and #4.
>>>>
>>>> This code has been tested using the fscrypt test suggested by Eric
>>>> (generic/549), as well as the mode-test script suggested by Milan for
>>>> the dm-crypt case. I also tested the aead case in a virtual machine,
>>>> but it definitely needs some wider testing from the dm-crypt experts.
>>>>
>>>> Changes since v2:
>>>> - fixed a couple of bugs that snuck in after I'd done the bulk of my
>>>>   testing
>>>> - some cosmetic tweaks to the ESSIV template skcipher setkey function
>>>>   to align it with the aead one
>>>> - add a test case for essiv(cbc(aes),aes,sha256)
>>>> - add an accelerated implementation for arm64 that combines the IV
>>>>   derivation and the actual en/decryption in a single asm routine
>>>
>>> I run tests for the whole patchset, including some older scripts and seems
>>> it works for dm-crypt now.
>>>
>>
>> Thanks Milan, that is really helpful.
>>
>> Does this include configurations that combine authenc with essiv?
> 
> Hm, seems that we are missing these in luks2-integrity-test. I'll add them there.
> 
> I also used this older test
> https://gitlab.com/omos/dm-crypt-test-scripts/blob/master/root/test_dmintegrity.sh
> 
> (just aes-gcm-random need to be commented out, we never supported this format, it was
> written for some devel version)
> 
> But seems ESSIV is there tested only without AEAD composition...
> 
> So yes, this AEAD part need more testing.

And unfortunately it does not work - it returns EIO on sectors where it should not be data corruption.

I added few lines with length-preserving mode with ESSIV + AEAD, please could you run luks2-integrity-test
in cryptsetup upstream?

This patch adds the tests:
https://gitlab.com/cryptsetup/cryptsetup/commit/4c74ff5e5ae328cb61b44bf99f98d08ffee3366a

It is ok on mainline kernel, fails with the patchset:

# ./luks2-integrity-test 
[aes-cbc-essiv:sha256:hmac-sha256:128:512][FORMAT][ACTIVATE]sha256sum: /dev/mapper/dmi_test: Input/output error
[FAIL]
 Expecting ee501705a084cd0ab6f4a28014bcf62b8bfa3434de00b82743c50b3abf06232c got .

FAILED backtrace:
77 ./luks2-integrity-test
112 intformat ./luks2-integrity-test
127 main ./luks2-integrity-test

Milan
