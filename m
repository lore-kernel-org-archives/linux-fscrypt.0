Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD1C6C433E6
	for <linux-fscrypt@archiver.kernel.org>; Mon,  4 Jan 2021 22:21:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B691422519
	for <linux-fscrypt@archiver.kernel.org>; Mon,  4 Jan 2021 22:21:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726687AbhADWVV (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 4 Jan 2021 17:21:21 -0500
Received: from mail.kernel.org ([198.145.29.99]:45898 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726026AbhADWVV (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 4 Jan 2021 17:21:21 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id DA9BA22513;
        Mon,  4 Jan 2021 22:20:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1609798841;
        bh=NPEdMZ+d/qTgqDyyo/6zPi69bvufgrchjXGTLMaZlP0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=MAzfwUcLYRgensQDf3eQfRYhYAi4qfyiOpyUafkPns2TK9eTnVBwZg2iLWutoLJqs
         5BRxgvgxUfPmPFt6UIyQ9kY9pAMpsLMnGNU2VQ1EbdEggdDltua55J73G2SZJYBRy2
         BJhzaX+3+J6W8qiZVVoTggHYCUqrjwMerzxP5cygSi+ct2SY0jwArBcHTTyCoOmTT2
         CXDj9yktaUWCMcJMx0oEYZoBVzWB2RDR/0vRxFRCNRAZVe1O1kH/R2XjxhaHYbgbcM
         Ej5Bsm+w609olzOnN4nY+R92Bnj8Ifjrl75XsW6TLYJadLyHH0iGRypsvvuOD5LNmr
         0X930II45Br8A==
Date:   Mon, 4 Jan 2021 14:20:39 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     Stephan =?iso-8859-1?Q?M=FCller?= <smueller@chronox.de>
Cc:     herbert@gondor.apana.org.au, mathew.j.martineau@linux.intel.com,
        dhowells@redhat.com, linux-crypto@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
        keyrings@vger.kernel.org
Subject: Re: [PATCH 0/5] Add KDF implementations to crypto API
Message-ID: <X/OUt7+wGGEPkWh8@sol.localdomain>
References: <4616980.31r3eYUQgx@positron.chronox.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4616980.31r3eYUQgx@positron.chronox.de>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Jan 04, 2021 at 10:45:57PM +0100, Stephan Müller wrote:
> The HKDF addition is used to replace the implementation in the filesystem
> crypto extension. This code was tested by using an EXT4 encrypted file
> system that was created and contains files written to by the current
> implementation. Using the new implementation a successful read of the
> existing files was possible and new files / directories were created
> and read successfully. These newly added file system objects could be
> successfully read using the current code. Yet if there is a test suite
> to validate whether the invokcation of the HKDF calculates the same
> result as the existing implementation, I would be happy to validate
> the implementation accordingly.

See https://www.kernel.org/doc/html/latest/filesystems/fscrypt.html#tests
for how to run the fscrypt tests.  'kvm-xfstests -c ext4 generic/582' should be
enough for this, though you could run all the tests if you want.

- Eric
