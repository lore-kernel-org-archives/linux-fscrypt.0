Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792603361;
	b=JnjRQ7+eOEH1S5e7GyvBtmVRp3QxTe5I0eKnxie6xNazUKRX4e8Bu4CKOAg4cX/mLY7p
	 G8HtbtmH/z4U9+Vvq209dJQxBdARO/XdUyVqvaHtzEN9z684WLNc6uB8TXofaIaTX82Aj
	 7p2sKuh7k3IIPccxJHzEJUwba3zmQ5xSLXqSq2VA12/dLVaJ2WQ9ELQIOqg5VAtgBOCE4
	 FLoG+1unQPvGXhSKmk7/yeZc8PjjEBhYFE8OeS/J+Ef7yZOk3KI/HkQoy08V0X1FBQJUu
	 Xg1Vd9KHAmBJV/KShUgH5LzL0vlLxKMB7zBROruKW9sFl8d5sbcP6o5HUKxN1cUh5NQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792603361;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=6LqR1VzY/7CZkjbT+gr5Y/FfDEr1ngYlH55EfU+izAs=;
	b=5as2pPlyBny93kQ8AdWgsor0GKesQFOMDM+OvyKN5FrEcVIrc1An76ABmwJLO5+9pPgp
	 AUL0+G5OX4lya6OB9+jXt50XtM3bSLvm8/dzWayNFvOzwKRJmnSxD/SCQIWzwxPb4eUuU
	 vS4e65Z7fgoxoNfvyNvigFJPP7wMxxXjF1pT4BsFxPHVwcF/vgI5NyiohwEOOGWSdtzl+
	 MPjh4phWaSPtpuhKvEFQL8rq4Ih1gUs4EcEsQ009tgzPClKS+dyCbC35cEVntdZaL+P/O
	 8R+3rBDfKUgbFzCdKI4IMkcXlu1KxroJ0k4NiYyPMcQWdJqI9lxQZlvGFdd+10gBWmQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S2rfc6jT;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13BFA606A31A;
	Wed, 21 Oct 2026 17:22:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S2rfc6jT
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 618E31F000C1;
	Wed, 21 Oct 2026 17:22:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792603360;
	bh=6LqR1VzY/7CZkjbT+gr5Y/FfDEr1ngYlH55EfU+izAs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=S2rfc6jTzi8rSn5ViYwDylfdCtbgIUsR9cMsl9JPmwcE2o7Shl124XcgoFdplNgUY
	 GPvn7lOpmXk24mnVbuwXKEJuoFlSkh9CvOFLtv5Ydqnj9mLrVWdw1Uqer20V+Vrtt5
	 70XBFTECdp07cRSdQvmKfaI9QNVcBMF9mAkdZVVh7Xyo3nhizBiuY0NaKiJbWLeQZc
	 aG32N70AkZbF7TJUtzdJ5POtdgwYYyuBAEHVfC5AKiwK5hRb2cDDX1VPHZKoXJm6JK
	 Owymr1kikulFhtwki7qcAxVGdjCwRSzwBQQLe2ZDGFPeIPNjWsjEXcIpfrgJ3Nix0Y
	 1wOHycLudZl5g==
Date: Wed, 21 Oct 2026 10:22:38 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Alex Markuze <amarkuze@redhat.com>
Cc: ceph-devel@vger.kernel.org, idryomov@gmail.com, xiubo.li@clyso.com,
	slava@dubeyko.com, viro@zeniv.linux.org.uk, brauner@kernel.org,
	jack@suse.cz, linux-fsdevel@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, tytso@mit.edu, jaegeuk@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 5/5] ceph: fail quarantined subvolume access with
 EACCES
Message-ID: <20261021172238.GD1879@quark>
References: <cover.1792527529.git.amarkuze@redhat.com>
 <345a4e8317cde90293b0d4ee9d8a3edfd229e204.1792527529.git.amarkuze@redhat.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <345a4e8317cde90293b0d4ee9d8a3edfd229e204.1792527529.git.amarkuze@redhat.com>

On Tue, Oct 20, 2026 at 08:26:50PM +0000, Alex Markuze wrote:
> +/*
> + * fscrypt can cache the decrypted target in ->i_link, allowing the VFS to
> + * bypass this callback. Checking those cache hits needs separate fscrypt
> + * support; this check covers only accesses that reach ->get_link().
> + */
>  static const char *ceph_encrypted_get_link(struct dentry *dentry,
>  					   struct inode *inode,
>  					   struct delayed_call *done)
>  {
>  	struct ceph_inode_info *ci = ceph_inode(inode);
> +	int err;
>  
>  	if (!dentry)
>  		return ERR_PTR(-ECHILD);
> +	err = ceph_symlink_revalidate(inode);
> +	if (err)
> +		return ERR_PTR(err);
>  
>  	return fscrypt_get_symlink(inode, ci->i_symlink, i_size_read(inode),
>  				   done);

The function comment seems out of sync with the actual code, as the
actual code disables the symlink target caching.

>  	case FS_IOC_GET_ENCRYPTION_POLICY:
>  		ret = vet_mds_for_fscrypt(file);
> +		if (ret)
> +			return ret;
> +		ret = ceph_quarantine_revalidate(inode);
>  		if (ret)
>  			return ret;
>  		return fscrypt_ioctl_get_policy(file, (void __user *)arg);
>  
>  	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
>  		ret = vet_mds_for_fscrypt(file);
> +		if (ret)
> +			return ret;
> +		ret = ceph_quarantine_revalidate(inode);
>  		if (ret)
>  			return ret;
>  		return fscrypt_ioctl_get_policy_ex(file, (void __user *)arg);
> @@ -429,6 +439,9 @@ long ceph_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  
>  	case FS_IOC_GET_ENCRYPTION_NONCE:
>  		ret = vet_mds_for_fscrypt(file);
> +		if (ret)
> +			return ret;
> +		ret = ceph_quarantine_revalidate(inode);
>  		if (ret)
>  			return ret;
>  		return fscrypt_ioctl_get_nonce(file, (void __user *)arg);

Can you clarify why FS_IOC_SET_ENCRYPTION_POLICY doesn't need this too?

- Eric
