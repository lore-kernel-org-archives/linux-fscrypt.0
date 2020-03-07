Return-Path: <SRS0=Js7+=4Y=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4FC0C10F00
	for <linux-fscrypt@archiver.kernel.org>; Sat,  7 Mar 2020 03:49:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 96DFF2072D
	for <linux-fscrypt@archiver.kernel.org>; Sat,  7 Mar 2020 03:49:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726859AbgCGDs5 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 6 Mar 2020 22:48:57 -0500
Received: from zeniv.linux.org.uk ([195.92.253.2]:43782 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726769AbgCGDs5 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 6 Mar 2020 22:48:57 -0500
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92.3 #3 (Red Hat Linux))
        id 1jAQSI-006ea4-7q; Sat, 07 Mar 2020 03:48:50 +0000
Date:   Sat, 7 Mar 2020 03:48:50 +0000
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
Subject: Re: [PATCH v8 2/8] fs: Add standard casefolding support
Message-ID: <20200307034850.GH23230@ZenIV.linux.org.uk>
References: <20200307023611.204708-1-drosen@google.com>
 <20200307023611.204708-3-drosen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200307023611.204708-3-drosen@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, Mar 06, 2020 at 06:36:05PM -0800, Daniel Rosenberg wrote:

> +/**
> + * generic_ci_d_hash - generic implementation of d_hash for casefolding
> + * @dentry: Entry whose name we are hashing
> + * @len: length of str
> + * @qstr: name of the dentry, safely paired with len
> + * @str: qstr to set hash of
> + *
> + * This performs a case insensitive hash of the given str.
> + * If casefolding is not required, it leaves the hash unchanged.
> + */
> +int generic_ci_d_hash(const struct dentry *dentry, struct qstr *str)
> +{
> +	const struct inode *inode = READ_ONCE(dentry->d_inode);
> +	struct super_block *sb = dentry->d_sb;
> +	const struct unicode_map *um = sb->s_encoding;
> +	char small_name[DNAME_INLINE_LEN];
> +	struct qstr entry = QSTR_INIT(str->name, str->len);
> +	int ret = 0;
> +
> +	if (!inode || !needs_casefold(inode))
> +		return 0;
> +
> +	if (make_name_stable(um, dentry, &entry, small_name))
> +		goto err;
> +	ret = utf8_casefold_hash(um, dentry, &entry);
> +	if (ret < 0)
> +		goto err;
> +
> +	return 0;
> +err:
> +	if (sb_has_enc_strict_mode(sb))
> +		ret = -EINVAL;
> +	else
> +		ret = 0;
> +	return ret;
> +}

	Have you even tested that?  Could you tell me where does the calculated
hash go?  And just what is it doing trying to check if the name we are about to
look up in directory specified by 'dentry' might be pointing to dentry->d_iname?
