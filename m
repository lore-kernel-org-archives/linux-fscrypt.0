Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33618 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdJDTKx (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 4 Oct 2017 15:10:53 -0400
Received: by mail-wr0-f195.google.com with SMTP id z96so7163181wrb.0
        for <linux-fscrypt@vger.kernel.org>; Wed, 04 Oct 2017 12:10:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <607D25F7-8DC9-4B2D-844B-F2359BCD642D@sigma-star.at>
References: <CAFadFHRqVe5SmQBZAaFHt2d6+GY5p1mbE9_G40AApfK29oHh8Q@mail.gmail.com>
 <34D12043-D369-458C-BEEA-B0B7463B3242@sigma-star.at> <CAFadFHQLbHNpQCP6tDsGFOSw7ZsujRaiBzQBbXx7-_QOjZwuPw@mail.gmail.com>
 <607D25F7-8DC9-4B2D-844B-F2359BCD642D@sigma-star.at>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Wed, 4 Oct 2017 21:10:51 +0200
Message-ID: <CAFLxGvyXVHnz9zirg9pQwaLxkvSWqMepKt=n5OHJvg7A6PvqXw@mail.gmail.com>
Subject: Re: Issue with encrypted filenames on UBIFS
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: David Gstir <david@sigma-star.at>
Cc: Nicolas Feignon <nicolas.feignon@mobile-devices.fr>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

David, Nicolas,

On Wed, Oct 4, 2017 at 6:36 PM, David Gstir <david@sigma-star.at> wrote:
> Hi Nicolas,
>
>> On 4 Oct 2017, at 18:14, Nicolas Feignon <nicolas.feignon@mobile-devices.fr> wrote:
>>
>> I was indeed using a hardware crypto accelerator on a Atmel SAMA5D2 platform.
>> It works correctly after removing it. I'll work on a patch.

This class of bug seems to be epidemic.
We should add a self-check.

-- 
Thanks,
//richard
