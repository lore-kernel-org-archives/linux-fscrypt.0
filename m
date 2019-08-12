Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f65.google.com ([209.85.221.65]:34050 "EHLO
        mail-wr1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725774AbfHLHov (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 12 Aug 2019 03:44:51 -0400
Subject: Re: [PATCH v9 3/7] md: dm-crypt: switch to ESSIV crypto API template
References: <20190810094053.7423-1-ard.biesheuvel@linaro.org>
 <20190810094053.7423-4-ard.biesheuvel@linaro.org>
 <8679d2f5-b005-cd89-957e-d79440b78086@gmail.com>
 <CAKv+Gu-ZPPR5xQSR6T4o+8yJvsHY2a3xXZ5zsM_aGS3frVChgQ@mail.gmail.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <82a87cae-8eb7-828c-35c3-fb39a9abe692@gmail.com>
Date: Mon, 12 Aug 2019 09:44:47 +0200
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu-ZPPR5xQSR6T4o+8yJvsHY2a3xXZ5zsM_aGS3frVChgQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 12/08/2019 08:54, Ard Biesheuvel wrote:
> On Mon, 12 Aug 2019 at 09:33, Milan Broz <gmazyland@gmail.com> wrote:
>> Try for example
>> # cryptsetup luksFormat /dev/sdc -c aes-cbc-essiv:sha256 --integrity hmac-sha256 -q -i1
>>
>> It should produce Crypto API string
>>   authenc(hmac(sha256),essiv(cbc(aes),sha256))
>> while it produces
>>   essiv(authenc(hmac(sha256),cbc(aes)),sha256)
>> (and fails).
>>
> 
> No. I don't know why it fails, but the latter is actually the correct
> string. The essiv template is instantiated either as a skcipher or as
> an aead, and it encapsulates the entire transformation. (This is
> necessary considering that the IV is passed via the AAD and so the
> ESSIV handling needs to touch that as well)

Hm. Constructing these strings seems to be more confusing than dmcrypt mode combinations :-)

But you are right, I actually tried the former string (authenc(hmac(sha256),essiv(cbc(aes),sha256)))
and it worked, but I guess the authenticated IV (AAD) was actually the input to IV (plain sector number)
not the output of ESSIV? Do I understand it correctly now?

Milan
