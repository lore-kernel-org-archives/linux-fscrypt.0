Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3E99C433EF
	for <linux-fscrypt@archiver.kernel.org>; Wed,  8 Sep 2021 23:48:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9BF0061157
	for <linux-fscrypt@archiver.kernel.org>; Wed,  8 Sep 2021 23:48:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S241914AbhIHXuH (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 8 Sep 2021 19:50:07 -0400
Received: from mail.kernel.org ([198.145.29.99]:55230 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S233834AbhIHXuG (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 8 Sep 2021 19:50:06 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id CF8C861059;
        Wed,  8 Sep 2021 23:48:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1631144937;
        bh=lYQ28perVqGvF3p17JwlyE6LtcpBMcm5f4oJOPqmjME=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=GlrnoYPx1CjC1F0w6ssG0zELgfpn2iD/24uh8Da344uvJIGO0Rc2xZ03bDZ7fvrIv
         7YnXVdE8RDNXzOnoxefKOqidjqT7+S0ziWyrfePbOcLRASt3OWF8Pd6rODTTePX8HL
         dCaf5BWDQ5SG4wBSnB16YI8313xOXM3Bx25UbB4bO2LlO81s1K//Lm/58mDwkZAYxW
         cRzQ3+OdrPyOZ9B47WtQPMGJak2FJ0k20/sCBtUiaWQHNkCn2OoSdNdUPKT00+tpMU
         ZeAOyx9it9THXcwUISXRGpyIKPwJfbK/4ctjObJkRpj5Bh44CD5+Py2XdE9GeXaf3p
         bMezROn6t6jtg==
Date:   Wed, 8 Sep 2021 16:48:56 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Aleksander Adamowski <olo@fb.com>
Cc:     "linux-fscrypt@vger.kernel.org" <linux-fscrypt@vger.kernel.org>
Subject: Re: [fsverity-utils PATCH v2] Implement PKCS#11 opaque keys support
 through OpenSSL pkcs11 engine
Message-ID: <YTlL6Josq+79r/ia@gmail.com>
References: <20210828013037.2250639-1-olo@fb.com>
 <YTk806ahPPcuz9gl@gmail.com>
 <SA1PR15MB48240CCB6C38535A022ACADBDDD49@SA1PR15MB4824.namprd15.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SA1PR15MB48240CCB6C38535A022ACADBDDD49@SA1PR15MB4824.namprd15.prod.outlook.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Sep 08, 2021 at 11:32:29PM +0000, Aleksander Adamowski wrote:
> On Wednesday, September 8, 2021 3:44 PM, Eric Biggers wrote:
> > Sorry, I didn't notice that you had already sent out a new version of this
> > patch.  Is this version intended to address all my comments?  Some of the
> > comments I made don't seem to have been fully addressed.
> 
> Hi!
> 
> Yes, the patch was intended to address all of your previous comment.
> 
> I went over it to double check and noticed that I somehow left one OPENSSL_IS_BORINGSSL ifdef in programs/cmd_sign.c.
> 
> I will remove it in V3. As far as I can tell, all of your other comments are already addressed, unless I'm still missing something?

Regarding struct libfsverity_signature_params, I wrote "Please write a comment
that clearly explains which parameters must be specified and when.".

Also I mentioned "The !OPENSSL_IS_BORINGSSL case no longer returns an error if
sig_params->keyfile or sig_params->certfile is unset".  That wasn't addressed
for sig_params->certfile.

- Eric
