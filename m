Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60E82C43334
	for <linux-fscrypt@archiver.kernel.org>; Fri, 10 Jun 2022 00:09:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232136AbiFJAJo (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 9 Jun 2022 20:09:44 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38050 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231631AbiFJAJo (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 9 Jun 2022 20:09:44 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 38C7226ACBA
        for <linux-fscrypt@vger.kernel.org>; Thu,  9 Jun 2022 17:09:43 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id C529760ADF
        for <linux-fscrypt@vger.kernel.org>; Fri, 10 Jun 2022 00:09:42 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 10066C34115;
        Fri, 10 Jun 2022 00:09:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1654819782;
        bh=be4MWjmbJ7yRw9cz3jZ+Vd/j0/6926lF7iSj4I6xIKY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=dhl50Y149J/pGNaUNz+joyvZTpL1HKshaipYB0szXH3hhpDE4ND7j+c9jEkBdVW8+
         PWj5bzgX6iojKqYeXeWNFsZBE4y5SpWx+n9ouAHo2ueZyog7njoYcWAAtkDR/BdtSN
         MLcdtbZvwNKIJrLmlkXu5WV4/L0s4bPyWWldBsq4ntHts/6hrjqbzWGM5PBXt7uEkj
         YOluX0bwYu4dW8AplbOzC/xjyCjTzagDccMDKIR97OiBpWelOGV3gN/HYgA4V7V3zs
         Qs8EAZXOT4LNEaaR1iW2Pa3PCU8ZSkWw7gkZpu9Zrw0hUrpMgFz3qA5EiwWHIgN70+
         bpMN/3V4tvyKg==
Date:   Thu, 9 Jun 2022 17:09:40 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     James Simmons <jsimmons@infradead.org>
Cc:     Andreas Dilger <adilger@whamcloud.com>, NeilBrown <neilb@suse.de>,
        linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH 00/18] lustre: sync with OpenSFS tree June 8, 2022
Message-ID: <YqKLxOWVo2ZfEsJd@sol.localdomain>
References: <1654777994-29806-1-git-send-email-jsimmons@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1654777994-29806-1-git-send-email-jsimmons@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Jun 09, 2022 at 08:32:56AM -0400, James Simmons wrote:
> Sync with the new work coming in for 2.16 development branch.
> Hold back the LU-15189 work since it introduced a regression
> that has an outstanding fix.

Is there a reason why this was sent to me and the linux-fscrypt list?

- Eric
