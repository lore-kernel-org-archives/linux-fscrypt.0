Return-Path: <SRS0=83vM=DH=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32110C4741F
	for <linux-fscrypt@archiver.kernel.org>; Wed, 30 Sep 2020 16:21:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D661920789
	for <linux-fscrypt@archiver.kernel.org>; Wed, 30 Sep 2020 16:21:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1601482910;
	bh=fc2MQgtyhZVgDuNC95sDElARHHOPrqS99KW9/WzAx/c=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=KTUSpPIvo92fCmi9yWGynuGWlmU/qAhakEQDH1HCEDEctCgFMEzDTxHaqVcgsNOfE
	 mp2bUaVU0zNa81t+omYtu0acOJ98CkzjlLFe3R+Vt7Ovs2hOYcYdXx4q5hGicAbOgf
	 LKICatkwqIlOaFLAMJ/VKebCClyXNC7iw72du0hc=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730833AbgI3QVr (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 30 Sep 2020 12:21:47 -0400
Received: from mail.kernel.org ([198.145.29.99]:49226 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726335AbgI3QVr (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 30 Sep 2020 12:21:47 -0400
Received: from sol.localdomain (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 888B420759;
        Wed, 30 Sep 2020 16:21:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1601482906;
        bh=fc2MQgtyhZVgDuNC95sDElARHHOPrqS99KW9/WzAx/c=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=cJa/tlusUC1XgARIIBy6NTLK/30IaUELrZPlmste+48wK+dQLcZGyPTR9g6v8rs7r
         YcSbcfgnBkYVZhJK5uHNw3ciozw76jesgIJ+dMUSK6pSO4dMpHyPc3HScFYZV+Xacz
         stndei2IMEVzVhIN/lxV1TXdrRHxExJbJG3oMIfQ=
Date:   Wed, 30 Sep 2020 09:21:44 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Mauro Carvalho Chehab <mchehab+huawei@kernel.org>
Cc:     Linux Doc Mailing List <linux-doc@vger.kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4 35/52] docs: fs: fscrypt.rst: get rid of :c:type: tags
Message-ID: <20200930162144.GA9698@sol.localdomain>
References: <cover.1601467849.git.mchehab+huawei@kernel.org>
 <689d790237b64fc7d81fcf97ac303cc1dbdd33d4.1601467849.git.mchehab+huawei@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <689d790237b64fc7d81fcf97ac303cc1dbdd33d4.1601467849.git.mchehab+huawei@kernel.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Sep 30, 2020 at 03:24:58PM +0200, Mauro Carvalho Chehab wrote:
> The :c:type: tag has problems with Sphinx 3.x, as structs
> there should be declared with c:struct.
> 
> So, remove them, relying at automarkup.py extension to
> convert them into cross-references.
> 
> Signed-off-by: Mauro Carvalho Chehab <mchehab+huawei@kernel.org>

What does this patch series apply to?  Cover letter says next-20200922, but it
doesn't apply.

It's very difficult to review patches without any way to apply them.

- Eric
