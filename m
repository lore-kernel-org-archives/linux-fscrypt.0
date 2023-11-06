Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B212AC41535
	for <linux-fscrypt@archiver.kernel.org>; Mon,  6 Nov 2023 13:14:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232241AbjKFNOA (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 6 Nov 2023 08:14:00 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41948 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232215AbjKFNN7 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 Nov 2023 08:13:59 -0500
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 78153BD
        for <linux-fscrypt@vger.kernel.org>; Mon,  6 Nov 2023 05:13:56 -0800 (PST)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DEFBDC433C9;
        Mon,  6 Nov 2023 13:13:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
        s=korg; t=1699276436;
        bh=jib3nlXXOJPPw2DXKyxxbrm/aDUxQJnX61OAVBigBOo=;
        h=Date:From:To:Subject:From;
        b=sgJ+GlAzXtkwZcOlQuXI3Tw5MtM7175Bzx8O79zEC7Mqyy+bbBVOYggjXq30dXYOI
         MMFN/NFXpJ6IiOTMCwUqxrt6pka5nLqx4qM20YUofES3FmWtjpYLh7g9H7EOYPibEV
         DQii7nkpUXl1jRLyoMM4D84zwZl0RlwsMMw+34CU=
Date:   Mon, 6 Nov 2023 08:13:53 -0500
From:   Konstantin Ryabitsev <konstantin@linuxfoundation.org>
To:     linux-fscrypt@vger.kernel.org
Subject: PSA: migrating linux-fscrypt to new vger infrastructure
Message-ID: <20231106-vague-tested-dragon-bdf3d4@nitro>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Good day!

I plan to migrate the linux-fscrypt@vger.kernel.org list to the new
infrastructure this week. We're still doing it list-by-list to make sure that
we don't run into scaling issues with the new infra.

The migration will be performed live and should not require any downtime.
There will be no changes to how anyone interacts with the list after
migration is completed, so no action is required on anyone's part.

Please let me know if you have any concerns.

Best wishes,
-K
