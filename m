Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793955521;
	b=x8W/hoa5WdYcTdjueFiQdQH8XwTmlfyaAI8+2ITl3cnyiB0PCDCwuihGFua6SLuzGdvN
	 ubgl8jFclmBcrS66aFYWPdvCIFzsXQHmzToBWrbqTDtajK6F7SWFA6+af3ztLnEhWuABY
	 loNhFVHFpZXx8pF7reWMRBrskpBen0OypqvCGCSGaXNGrjAOa8ePzdgnc4Gyr1Y4lPel/
	 jlvwNPo/4qhD+46MxiksTvt2R5kdyQPzTnzNmMGWLJloQAbJmY6BSLji12/VXwty6a3Pg
	 u0/ZaogIrmEQX/Ne83wwg/+sXYCI3Ep8DY0+2bUxdy7eeDwGVf8gYdQzjn/Cq/6zFsw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793955521;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=uY2z+WiMRycCgSzTLuJYpDAs4u+e3hUofoi4yXknU0A=;
	b=zbNnj5AMGnAt+65R8Ue0kTsklqbOJBKOiTDudMyMZaJOTOQTc78UGg8myaVQVPQxsCmQ
	 onP2yGFkZp0Bu+qOCZuMcA6LPH3kkclObc1S2a8OZ7iY4fUfJGKyBNsrU7cHriNb90BAL
	 dOGsXzMKi8b/o89Wj0CWq0Zgeu0ZnB+3H2Rfxg1qwKbDjyERioTIfNWagMRLUAyEEj3Nb
	 mLQL1dkb0YbRRlYwPVT58FwnKOwleMDLbYEIUtcfwALIIxtgV8j052iskJArf7LNPMA5N
	 7hGPzGWFtViXnrBTgsF1q2XGdXCgOrARFb6aOnSKYGnRazjK3fCU4E1Q9Yzc/qjJ7vg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SRZTvbqG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F820606A326;
	Fri,  6 Nov 2026 08:58:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SRZTvbqG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F5321F0089F;
	Fri,  6 Nov 2026 08:58:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793955521;
	bh=uY2z+WiMRycCgSzTLuJYpDAs4u+e3hUofoi4yXknU0A=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=SRZTvbqGRZtPITJdrVmBB6ut8PxEml+amDCfjRlMqLHhHzWnewWetimD2z6K4VKbs
	 2mTZfC7lyqh+0VszDh3wDoklo//2DVSIUh1kGzcDVL534K9089SmsDHGvFC86QqCW5
	 +6mbiyMP7KAy6FFkUWCEnHJyYfZVIOp+XhNUQ55uXVVleMrfzAY9/HDUyHVgBOeRcS
	 sZ7oq7rsRqFZCS0m6pIj3dMMBj/FuKGHFl7NfvoyLxHeLNJJ7ekGB2lG1s3LCEtPwo
	 8RBhMB1NgLF51czy0ADTopSm/wZ92l4M0mztjZ0wFoKc/szcwgOYBN2DQxKN/RqvYs
	 r68lOqDqP7Ynw==
Date: Fri, 6 Nov 2026 09:58:35 +0100
From: Christian Brauner <brauner@kernel.org>
To: Alex Markuze <amarkuze@redhat.com>
Cc: ceph-devel@vger.kernel.org, idryomov@gmail.com, xiubo.li@clyso.com, 
	slava@dubeyko.com, viro@zeniv.linux.org.uk, jack@suse.cz, 
	linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, ebiggers@kernel.org, 
	tytso@mit.edu, jaegeuk@kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v6 1/5] dcache: export d_find_alias_rcu() for modular
 filesystems
Message-ID: <20261106-server-lautlos-hufeisen-0fc0ec477472@brauner>
References: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
 <99467b57d12e5b671246aa5e216ddce3a7dc3923.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <99467b57d12e5b671246aa5e216ddce3a7dc3923.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>

On Sun, Oct 25, 2026 at 06:42:41PM +0000, Alex Markuze wrote:
> CephFS subvolume quarantine needs a dentry alias for its RCU ancestry
> walk without acquiring a dentry reference. d_find_alias_rcu() provides
> that lookup, but is unavailable to a modular Ceph client.
> 
> Export d_find_alias_rcu() to GPL modules. The Ceph quarantine state
> handling patch uses the export with the helper's RCU lifetime rules.
> 
> Signed-off-by: Alex Markuze <amarkuze@redhat.com>
> ---
>  fs/dcache.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 1b1a81f10da67c608704383086c3facb64ee3b3b..13ba553081b33a54fd8d1cac5cbc55d0149e4ad7 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1248,6 +1248,7 @@ struct dentry *d_find_alias_rcu(struct inode *inode)
>  	spin_unlock(&inode->i_lock);
>  	return de;
>  }
> +EXPORT_SYMBOL_GPL(d_find_alias_rcu);

Please use EXPORT_SYMBOL_FOR_MODULES() and restrict this to ceph for now.
