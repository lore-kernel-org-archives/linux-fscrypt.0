Return-Path: <SRS0=Z22n=DA=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E88DC4727D
	for <linux-fscrypt@archiver.kernel.org>; Wed, 23 Sep 2020 06:25:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DC37B221F0
	for <linux-fscrypt@archiver.kernel.org>; Wed, 23 Sep 2020 06:25:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600842310;
	bh=EH8hBpeiETHC+h9j5rcOQFLvuMpOSGcVeSqcrnJIr+M=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=1r/SKVSsrSOCrIswZJ8xEQFS1gH1lPFYh94rRWsQkv/XaOICeyZ1VFNuo3qk0b/yZ
	 QflVj6BdW7ytQVreqWTq18i9fU051ai0UiEr+HnxK3nspLvqCj5Y1OB0SX/nEKQBJ+
	 kWqLLJx8XEu+OHu4zskmWBa6FifiKf3FXWCYEzeo=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726876AbgIWGZF (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 23 Sep 2020 02:25:05 -0400
Received: from mail.kernel.org ([198.145.29.99]:38192 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726853AbgIWGY7 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 23 Sep 2020 02:24:59 -0400
Received: from sol.localdomain (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 425FC21D43;
        Wed, 23 Sep 2020 06:24:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600842298;
        bh=EH8hBpeiETHC+h9j5rcOQFLvuMpOSGcVeSqcrnJIr+M=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=o9hZFORZJfS43AD9qs/eouYS9H2lmfwPF3ydoBftcuORWrWFA+Oosf8DKY1mk3Zm3
         cIZCITTnRgEk6JhC/F6wZsXxGJPNPdgYJYJhHDaphw687jIKp1UHYaNhlwigfbmU7Y
         swkdL+l/hvzPy8OCNZxj+GedL3eT8qcF1ZOoGSNU=
Date:   Tue, 22 Sep 2020 23:24:56 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Daniel Rosenberg <drosen@google.com>
Cc:     "Theodore Y . Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Chao Yu <chao@kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Richard Weinberger <richard@nod.at>,
        linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mtd@lists.infradead.org,
        Gabriel Krisman Bertazi <krisman@collabora.com>,
        kernel-team@android.com
Subject: Re: [PATCH 5/5] f2fs: Handle casefolding with Encryption
Message-ID: <20200923062456.GF9538@sol.localdomain>
References: <20200923010151.69506-1-drosen@google.com>
 <20200923010151.69506-6-drosen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200923010151.69506-6-drosen@google.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Sep 23, 2020 at 01:01:51AM +0000, Daniel Rosenberg wrote:
> Expand f2fs's casefolding support to include encrypted directories.  To
> index casefolded+encrypted directories, we use the SipHash of the
> casefolded name, keyed by a key derived from the directory's fscrypt
> master key.  This ensures that the dirhash doesn't leak information
> about the plaintext filenames.
> 
> Encryption keys are unavailable during roll-forward recovery, so we
> can't compute the dirhash when recovering a new dentry in an encrypted +
> casefolded directory.  To avoid having to force a checkpoint when a new
> file is fsync'ed, store the dirhash on-disk appended to i_name.
> 
> This patch incorporates work by Eric Biggers <ebiggers@google.com>
> and Jaegeuk Kim <jaegeuk@kernel.org>.
> 
> Co-developed-by: Eric Biggers <ebiggers@google.com>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> Signed-off-by: Daniel Rosenberg <drosen@google.com>
> ---

Generally looks good.  If it's needed, you can add:

Reviewed-by: Eric Biggers <ebiggers@google.com>

(Though, some may claim I can't give Reviewed-by since this patch already has my
Co-developed-by.)

One comment below, though:

> @@ -218,9 +219,28 @@ static bool f2fs_match_ci_name(const struct inode *dir, const struct qstr *name,
>  {
>  	const struct super_block *sb = dir->i_sb;
>  	const struct unicode_map *um = sb->s_encoding;
> +	struct fscrypt_str decrypted_name = FSTR_INIT(NULL, de_name_len);
>  	struct qstr entry = QSTR_INIT(de_name, de_name_len);
>  	int res;
>  
> +	if (IS_ENCRYPTED(dir)) {
> +		const struct fscrypt_str encrypted_name =
> +			FSTR_INIT((u8 *)de_name, de_name_len);
> +
> +		if (WARN_ON_ONCE(!fscrypt_has_encryption_key(dir)))
> +			return false;
> +
> +		decrypted_name.name = kmalloc(de_name_len, GFP_KERNEL);
> +		if (!decrypted_name.name)
> +			return false;
> +		res = fscrypt_fname_disk_to_usr(dir, 0, 0, &encrypted_name,
> +						&decrypted_name);
> +		if (res < 0)
> +			goto out;

We probably should be passing up errors from here to f2fs_match_name(), then to
f2fs_find_target_dentry(), then to f2fs_find_in_inline_dir() or find_in_block().

Ignoring the filename may be okay if fscrypt_fname_disk_to_usr() returns
-EUCLEAN, indicating that it's invalid.  However, if the error is -ENOMEM,
either from the kmalloc() or from fscrypt_fname_disk_to_usr(), then the caller
should receive an error rather than the filename being ignored.

- Eric
