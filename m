Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA4A1C433EF
	for <linux-fscrypt@archiver.kernel.org>; Sat, 26 Feb 2022 20:14:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229437AbiBZUOg (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 26 Feb 2022 15:14:36 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56668 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229436AbiBZUOf (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 26 Feb 2022 15:14:35 -0500
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:e::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 496BF55BC6;
        Sat, 26 Feb 2022 12:14:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
        MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=jxSlVaBmXz/dVNo8icv8AU6oobDK34V/whJUepgdojM=; b=aW03886MhAt0oh4a2AME0c7m5U
        QWT37fnD7HG/48pZXDm6TSh+J/O2AFiZxqmsNgHN+GUYLsNwmIq1iAsshrpdcP/On6qXjX2SwjVYn
        CYYr5dFJzsH5onQ7aV9YzCgOoKx/rKqSQTeHiHVPjInbSkBUjuAIP1DBD7VvITIAYkty7UckNCKpn
        8pqy+DQ1rIi6w7Dka+0C8tgEDq8G33N9oRcAUjuf7+s+BH/b0otja3bWgII5qrGAlxtRf1JfHzcyk
        7hkRlsl660Q/7RqS6rZpyfiYZMGofaIB7oSTWWYfTCNU68t1Pw1DG2Pohr/PMrNc8/R7W+NhP464p
        V0Zqq9SQ==;
Received: from mcgrof by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1nO3Rj-008Tvl-BV; Sat, 26 Feb 2022 20:13:39 +0000
Date:   Sat, 26 Feb 2022 12:13:39 -0800
From:   Luis Chamberlain <mcgrof@kernel.org>
To:     Meng Tang <tangmeng@uniontech.com>
Cc:     keescook@chromium.org, yzaikin@google.com, guoren@kernel.org,
        nickhu@andestech.com, green.hu@gmail.com, deanbo422@gmail.com,
        ebiggers@kernel.org, tytso@mit.edu, wad@chromium.org,
        john.johansen@canonical.com, jmorris@namei.org, serge@hallyn.com,
        linux-csky@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v3 2/2] fs/proc: Optimize arrays defined by struct
 ctl_path
Message-ID: <YhqJ8yqcjKJqHfcR@bombadil.infradead.org>
References: <20220224133217.1755-1-tangmeng@uniontech.com>
 <20220224133217.1755-2-tangmeng@uniontech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220224133217.1755-2-tangmeng@uniontech.com>
Sender: Luis Chamberlain <mcgrof@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Feb 24, 2022 at 09:32:17PM +0800, Meng Tang wrote:
> Previously, arrays defined by struct ctl_path is terminated
> with an empty one. When we actually only register one ctl_path,
> we've gone from 8 bytes to 16 bytes.
> 
> The optimization has been implemented in the previous patch,
> here to remove unnecessary terminate ctl_path with an empty one.
> 
> Signed-off-by: Meng Tang <tangmeng@uniontech.com>

If these things are built-in, can you verify you're saving bytes
with size before and after the patch?

I wonder if having something like DECLARE_SYSCTL_PATH_ONE() would make
this nicer on the eyes, and also useful for the other changes you
are making. Do you have many other single path entries you are changing
later?

  Luis
