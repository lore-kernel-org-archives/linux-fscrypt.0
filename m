Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60640 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725782AbfICS6d (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 3 Sep 2019 14:58:33 -0400
Date: Tue, 3 Sep 2019 14:58:28 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [PATCH v13 6/6] md: dm-crypt: omit parsing of the encapsulated
 cipher
Message-ID: <20190903185827.GD13472@redhat.com>
References: <20190819141738.1231-1-ard.biesheuvel@linaro.org>
 <20190819141738.1231-7-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190819141738.1231-7-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, dm-devel@redhat.com, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 19 2019 at 10:17am -0400,
Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:

> Only the ESSIV IV generation mode used to use cc->cipher so it could
> instantiate the bare cipher used to encrypt the IV. However, this is
> now taken care of by the ESSIV template, and so no users of cc->cipher
> remain. So remove it altogether.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Acked-by: Mike Snitzer <snitzer@redhat.com>

Might be wise to bump the dm-crypt target's version number (from
{1, 19, 0} to {1, 20, 0}) at the end of this patch too though...

But again, Herbert please feel free to pull this into your 5.4 branch.

Thanks,
Mike
