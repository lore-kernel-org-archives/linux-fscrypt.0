Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f67.google.com ([209.85.221.67]:37457 "EHLO
        mail-wr1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725945AbfHPI0Y (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 16 Aug 2019 04:26:24 -0400
Subject: Re: [PATCH v12 0/4] crypto: switch to crypto API for ESSIV generation
References: <20190815192858.28125-1-ard.biesheuvel@linaro.org>
 <1463bca3-77dc-42be-7624-e8eaf5cfbf32@gmail.com>
 <CAKv+Gu9CtMMAjtjfR=uuB-+x0Lhy8gnme2HhExckW+eVZ8B_Ow@mail.gmail.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <d509ce52-1ae1-f785-fe5a-7d5a0e2bc8d0@gmail.com>
Date: Fri, 16 Aug 2019 10:26:20 +0200
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu9CtMMAjtjfR=uuB-+x0Lhy8gnme2HhExckW+eVZ8B_Ow@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 16/08/2019 10:18, Ard Biesheuvel wrote:
> On Fri, 16 Aug 2019 at 10:29, Milan Broz <gmazyland@gmail.com> wrote:
>>
>> Hi Ard,
>>
>> On 15/08/2019 21:28, Ard Biesheuvel wrote:
>>> Changes since v10:
>>> - Drop patches against fscrypt and dm-crypt - these will be routed via the
>>>   respective maintainer trees during the next cycle
>>
>> I tested the previous dm-crypt patches (I also try to keep them in my kernel.org tree),
>> it works and looks fine to me (and I like the final cleanup :)
>>
>> Once all maintainers are happy with the current state, I think it should go to
>> the next release (5.4; IMO both ESSIV API and dm-crypt changes).
>> Maybe you could keep sending dm-crypt patches in the end of the series (to help testing it)?
>>
> 
> OK. But we'll need to coordinate a bit so that the first patch (the
> one that introduces the template) is available in both branches,
> otherwise ESSIV will be broken in the dm branch until it hits another
> branch (-next or mainline) that also contains cryptodev.

Yes, I know. I'll ask Mike what is his preference here...
For now, it should appear at least in the cryptodev tree :)

...
 
> Any idea about the status of the EBOIV patch?

It is in the queue for 5.4 (should be in linux-next already), I guess 5.4 target is ok here.

https://git.kernel.org/pub/scm/linux/kernel/git/device-mapper/linux-dm.git/log/?h=dm-5.4

Milan
