Return-Path: <SRS0=Mq6R=34=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72F49C2BA83
	for <linux-fscrypt@archiver.kernel.org>; Sat,  8 Feb 2020 02:12:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 499A0206DB
	for <linux-fscrypt@archiver.kernel.org>; Sat,  8 Feb 2020 02:12:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727113AbgBHCM0 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 7 Feb 2020 21:12:26 -0500
Received: from zeniv.linux.org.uk ([195.92.253.2]:52510 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726743AbgBHCM0 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 7 Feb 2020 21:12:26 -0500
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92.3 #3 (Red Hat Linux))
        id 1j0FbU-0098pV-DJ; Sat, 08 Feb 2020 02:12:16 +0000
Date:   Sat, 8 Feb 2020 02:12:16 +0000
From:   Al Viro <viro@zeniv.linux.org.uk>
To:     Daniel Rosenberg <drosen@google.com>
Cc:     Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>,
        linux-f2fs-devel@lists.sourceforge.net,
        Eric Biggers <ebiggers@kernel.org>,
        linux-fscrypt@vger.kernel.org, Richard Weinberger <richard@nod.at>,
        linux-mtd@lists.infradead.org,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Gabriel Krisman Bertazi <krisman@collabora.com>,
        kernel-team@android.com
Subject: Re: [PATCH v7 2/8] fs: Add standard casefolding support
Message-ID: <20200208021216.GE23230@ZenIV.linux.org.uk>
References: <20200208013552.241832-1-drosen@google.com>
 <20200208013552.241832-3-drosen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200208013552.241832-3-drosen@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, Feb 07, 2020 at 05:35:46PM -0800, Daniel Rosenberg wrote:

> +int generic_ci_d_compare(const struct dentry *dentry, unsigned int len,
> +			  const char *str, const struct qstr *name)
> +{
> +	const struct dentry *parent = READ_ONCE(dentry->d_parent);
> +	const struct inode *inode = READ_ONCE(parent->d_inode);
> +	const struct super_block *sb = dentry->d_sb;
> +	const struct unicode_map *um = sb->s_encoding;
> +	struct qstr entry = QSTR_INIT(str, len);
> +	int ret;
> +
> +	if (!inode || !needs_casefold(inode))
> +		goto fallback;
> +
> +	ret = utf8_strncasecmp(um, name, &entry);

Again, is that safe in case when the contents of the string str points to
keeps changing under you?
