Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF837C433ED
	for <linux-fscrypt@archiver.kernel.org>; Thu,  8 Apr 2021 01:06:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6F87861245
	for <linux-fscrypt@archiver.kernel.org>; Thu,  8 Apr 2021 01:06:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229529AbhDHBG7 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 7 Apr 2021 21:06:59 -0400
Received: from mail.kernel.org ([198.145.29.99]:47426 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229497AbhDHBG7 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 7 Apr 2021 21:06:59 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id CD9DA61245;
        Thu,  8 Apr 2021 01:06:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1617844004;
        bh=sFYllywBCpJE30mUO1rJNe8qpCVkCAmq3GQyi4xsvzQ=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=NvJlMfTdn62PEJbvV9dwqvsUS9TJZfL2oJZTbcw3zrztW3eiBzNfKaaN/VrMZ8O5p
         Hvpw3RUwWJNBHcdPhHaiLJz2iFVGokP7g00VAb2cOosdNbz1Gerum/7l7iSqNOUtgq
         5thSnMSOaAKbBMdUTrw5FAHB8bDCj53BtvevWUJ8OZgqpBuyot4ifHh7y/tLN8pMlc
         SGcheGTwtkscMcsJ1Qbj+Giut+gx4t+X8aBTlLDdlJm3764dhAomZJYnKrqK4PJIyY
         EB2rvtTHvkSFszZL/PZZYE6OI4hV7bK215zJvGiInGob7jgYqYCV5o47GQjLDPIVb4
         ObDPsz+5bNBqw==
Date:   Wed, 7 Apr 2021 18:06:42 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     ceph-devel@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [RFC PATCH v5 02/19] fscrypt: export fscrypt_base64_encode and
 fscrypt_base64_decode
Message-ID: <YG5XIg0mGK708iiG@gmail.com>
References: <20210326173227.96363-1-jlayton@kernel.org>
 <20210326173227.96363-3-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210326173227.96363-3-jlayton@kernel.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, Mar 26, 2021 at 01:32:10PM -0400, Jeff Layton wrote:
> Ceph will need to base64-encode some encrypted filenames, so make
> these routines, and FSCRYPT_BASE64_CHARS available to modules.
> 
> Signed-off-by: Jeff Layton <jlayton@kernel.org>

It would be helpful to have a quick explanation here about *why* ceph has to do
base64 encoding/decoding itself.

- Eric
