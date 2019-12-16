Return-Path: <SRS0=L+wG=2G=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7D95C43603
	for <linux-fscrypt@archiver.kernel.org>; Mon, 16 Dec 2019 17:26:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 82F4B206EC
	for <linux-fscrypt@archiver.kernel.org>; Mon, 16 Dec 2019 17:26:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1576517197;
	bh=N3qFLV2LDkxyvoYKKqock2ovTvx6G6uwbVdBAc1uAok=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=CxgIYCCL+6ftOeosO2CzxOigD5iDjKzF8GzESYfyxHWXkNMocOE+DFHEeGAMIWvW5
	 AfeKUpQ14tANg99uPEtQN34WE6IM3pw33SWS1d7mEMUuDDSZyUhDD+LsxwO02snXq8
	 WhrXI7sxTR5Iv3I+faS8dpkwE2oW9WBMEyWKzi+4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726275AbfLPR0h (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 16 Dec 2019 12:26:37 -0500
Received: from mail.kernel.org ([198.145.29.99]:60536 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725805AbfLPR0h (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 16 Dec 2019 12:26:37 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 950F5206E0;
        Mon, 16 Dec 2019 17:26:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1576517196;
        bh=N3qFLV2LDkxyvoYKKqock2ovTvx6G6uwbVdBAc1uAok=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=VGnRAU6LTyCTwCoZkEc9in5+W1klzHWAdkwHqA7LigElpK7kBA2f4w0F4pN/6Wjk/
         hiuj1LJpFHxFgXxpUdPOlWF/Tywmf1L4Jv1ioWEI5rMeKHPLPLQTa74er00MQAwGXW
         g8TweBHwOTOMyT2b5YtBb1Zs0lAZ50ezLxHkEnmE=
Date:   Mon, 16 Dec 2019 09:26:35 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     Theodore Ts'o <tytso@mit.edu>
Cc:     linux-fscrypt@vger.kernel.org
Subject: Re: [xfstests-bld PATCH] kernel-configs: enable CONFIG_CRYPTO_ESSIV
 in 5.4 configs
Message-ID: <20191216172632.GC139479@gmail.com>
References: <20191202232340.243744-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191202232340.243744-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Dec 02, 2019 at 03:23:40PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> On kernel 5.5 and later, CONFIG_CRYPTO_ESSIV is needed for one of the
> fscrypt tests (generic/549) to run.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  kernel-configs/i386-config-5.4   | 1 +
>  kernel-configs/x86_64-config-5.4 | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/kernel-configs/i386-config-5.4 b/kernel-configs/i386-config-5.4
> index 195211e..3495a0d 100644
> --- a/kernel-configs/i386-config-5.4
> +++ b/kernel-configs/i386-config-5.4
> @@ -170,6 +170,7 @@ CONFIG_IMA_APPRAISE=y
>  CONFIG_EVM=y
>  # CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
>  CONFIG_CRYPTO_ADIANTUM=y
> +CONFIG_CRYPTO_ESSIV=y
>  CONFIG_CRYPTO_CRC32C_INTEL=y
>  CONFIG_CRYPTO_CRC32_PCLMUL=y
>  CONFIG_CRYPTO_AES_NI_INTEL=y
> diff --git a/kernel-configs/x86_64-config-5.4 b/kernel-configs/x86_64-config-5.4
> index 9a6baaa..e8d2b68 100644
> --- a/kernel-configs/x86_64-config-5.4
> +++ b/kernel-configs/x86_64-config-5.4
> @@ -177,6 +177,7 @@ CONFIG_IMA_APPRAISE=y
>  CONFIG_EVM=y
>  # CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
>  CONFIG_CRYPTO_ADIANTUM=y
> +CONFIG_CRYPTO_ESSIV=y
>  CONFIG_CRYPTO_CRC32C_INTEL=y
>  CONFIG_CRYPTO_CRC32_PCLMUL=y
>  CONFIG_CRYPTO_AES_NI_INTEL=y
> -- 

Ping.  Ted, can you apply this?

- Eric
