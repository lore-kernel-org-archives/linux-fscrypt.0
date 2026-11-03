Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793720744;
	b=JK+Mrxo4vxOSbeUkC60h9i1Aa7u0MVE+5BgZ5ITECBIANK6FPkW9NISDTG3OUbuLsoJh
	 QhOa46q4LHfEN8bg0/cd0v2G0jjhAK+1lcIMtsQX22bs/CnmNfUblybGW6Aq3ST5rKzhy
	 8DsrWTtjk9MLL95DItElcvMZ02OS36rgLd5uljxqMb3Sc6lhWMLJ/N+2HPKufCTAtokPj
	 a5HflCCsmPLhCK8bjuvgbswqNCqYa6hWvX7u5BJd5nN3CfsN98MhSYddrmb/ukW0ZkPyf
	 k2gn+dgYrgpZJKoDI14D0iPyYGaB7VZ8IK2Ri8vrIJcrdwYuaFbakD1v4i5fHccm1Bg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793720744;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=O+VIe5Sva4ZfVt7FvpSwqSi7jWwmAVD5CxLUb/JvQHc=;
	b=ZR9R4mQSwoC2it7v4T7yzr04JLy+Zy/I4tio+cybnl6g+WrIFo24glInCU9dA//saWKR
	 opgAPQN+uoHU2RZX/iHr8CvAC4RLxYmXfcB8BwqM7yHRXa94G1Rv2mIweECWqhHrRhK8E
	 iO/tAwlULaamj5OfHQwNpykvc8lRJMAO2UW9lsDg1pLQ9e/xRYXPCTXiFvi4i8V5bXNOw
	 PzAtFCaXAgsCcboLxoASI3A6cbiKh6erOOkmq/pr6FTcQJccVIMNwcKKMLffhTB/IIwzl
	 pZ8ESq2jFkzyEL9Jzrkg53HDKFbxUGB0gfZf8YYyWycsc4GQnZGusmLtVgsC4fh6HKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Y/O57+wr";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C0CA3606A324;
	Tue,  3 Nov 2026 15:45:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Y/O57+wr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B52E51F000C1;
	Tue,  3 Nov 2026 15:45:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793720743;
	bh=O+VIe5Sva4ZfVt7FvpSwqSi7jWwmAVD5CxLUb/JvQHc=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=Y/O57+wr1nQHWP9m3PK90OidszGkTi5nWNB3mYE+w4+vcxQ4j3YELiKD7ldz87Whb
	 qY2pWsar4oIAlatlOVA3WKhDQWeXvH6IFjDbzLbLZ2popDJk6L/nvnGrL3+v7vaHOW
	 VmQLjg6aSt6pxZon/+XM6gr8k3VUxgeQER2qGx9ia75V1KNR686bf2YuYs0g7EqndE
	 Z/KZ4UL6MMgOjDrQLS1jBfOyue5mmtfwaL6sbOm6R6DoabaZFlgYCFr99Nnasf4nY4
	 yG8XWzbQn6gWmQjnfTfBaRFwiF1qL1S8vAGp1BJ+cWJL+Qxgyili8GbBOovmUIzqkz
	 FY9HABvV4glig==
Message-ID: <sashiko-outbox-195647@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 2/4] fscrypt: Validate the test_dummy_encryption policy
 for new inodes
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>, linux-fscrypt@vger.kernel.org
Cc: ebiggers@kernel.org, jaegeuk@kernel.org, tytso@mit.edu, linux-ext4@vger.kernel.org, adilger.kernel@dilger.ca, jack@suse.cz, yi.zhang@huawei.com, ojaswin@linux.ibm.com, ritesh.list@gmail.com
In-Reply-To: <20261103153132.4154855-3-libaokun@linux.alibaba.com>
References: <20261103153132.4154855-1-libaokun@linux.alibaba.com>
 <20261103153132.4154855-3-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Tue, 03 Nov 2026 15:45:42 +0000
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

Thank you for your contribution! Sashiko AI review found 1 potential issue(=
s) to consider:
- [Medium] fscrypt: missed S_CASEFOLD check in fscrypt_prepare_new_inode()
--

commit fa704dc171d6c1edb5f7cea48ff46447da451c52
Author: Baokun Li <libaokun@linux.alibaba.com>

fscrypt: Validate the test_dummy_encryption policy for new inodes

This commit validates the test_dummy_encryption policy in
fscrypt_prepare_new_inode() when creating a new inode in an unencrypted
directory so that unsupported policies are rejected before being applied.

> diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
> index a77b889d7578c..497ba67ec6fed 100644
> --- a/fs/crypto/keysetup.c
> +++ b/fs/crypto/keysetup.c
> @@ -763,6 +763,14 @@ int fscrypt_prepare_new_inode(struct inode *dir, str=
uct inode *inode,
>  	    !S_ISLNK(inode->i_mode))
>  		return 0;
> =20
> +	/*
> +	 * A policy inherited from an encrypted directory was validated
> +	 * when the directory's key was set up.  The test dummy policy was
> +	 * not, so check it here.
> +	 */
> +	if (!IS_ENCRYPTED(dir) && !fscrypt_supported_policy(policy, inode))
> +		return -EINVAL;

[Severity: Medium]
Does fscrypt_supported_policy(policy, inode) miss the casefold check when
creating a new subdirectory inside an unencrypted, casefolded directory with
test_dummy_encryption=3Dv1?

When fscrypt_prepare_new_inode() is called by __ext4_new_inode() or
f2fs_new_inode(), only inode->i_mode and inode->i_blkbits are set on the new
inode. The filesystem has not yet inherited the casefold flag from dir or s=
et
S_CASEFOLD on inode->i_flags, which is why fscrypt_prepare_new_inode() chec=
ks
IS_CASEFOLDED(dir) && S_ISDIR(inode->i_mode) just below:

	return fscrypt_setup_encryption_info(inode, policy, nonce,
					     IS_CASEFOLDED(dir) &&
					     S_ISDIR(inode->i_mode));

However, fscrypt_supported_policy() -> fscrypt_supported_v1_policy() checks
IS_CASEFOLDED(inode):

	if (IS_CASEFOLDED(inode)) {
		/* With v1, there's no way to derive dirhash keys. */
		fscrypt_warn(inode,
			     "v1 policies can't be used on casefolded directories");
		return false;
	}

Since IS_CASEFOLDED(inode) is still false at this point, creating a
subdirectory in an unencrypted casefolded directory under
test_dummy_encryption=3Dv1 passes validation and creates a v1-encrypted,
casefolded directory without an initialized dirhash key, triggering
WARN_ON_ONCE(!ci->ci_dirhash_key_initialized) in fscrypt_fname_siphash() on
subsequent lookups or creations.

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261103153132.4154=
855-1-libaokun@linux.alibaba.com?part=3D2
