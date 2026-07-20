Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3751F381AFC;
	Mon, 20 Jul 2026 17:46:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569596; cv=none; b=Mj8KEfIlz6FYMg54QaDl/hIkzGJyOx5ufLgwXbajMq5klMhvZuP2WvALVP3bQ19xGHkY7NHOXAb7XJHdoESfrOP9Uxj3CxTPygPEp09i2+3XR8/KI5eHAsf6no9eCpAC3OCUqpVfrok2Tsejyvy/ZdshaN1Tu0hQOmTqbl4wfe4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569596; c=relaxed/simple;
	bh=JEVlNj4X9Gmu8sEAJ6Rz14EbWLVHWFQcBLYw4DpOmL4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=vE5+tVNfoVQbnJ4XdBnC4uhZ3oJUlwv8EpRb69Aa5jEn4IxPoBMy9RdiFJELXmpNRn4xF5cw0oIPfA7ws72Ybua/8wTnAdOQYzOxmlZrOOvBYdmBeHjeMprYtTugfNlMSnXj8HrQkIfn1yB+Sjj5+ZhUEh8ng/HYLFjmgo6wm/U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Irc6Ag3p; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Irc6Ag3p"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1BCD51F000E9;
	Mon, 20 Jul 2026 17:46:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784569588;
	bh=T+oQx5zRk0RramzKmWugrGHNe9r+whhPX6H9rrwLW9E=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Irc6Ag3p6Ou0huppQ3OOCKCCobwstUzjtQ9fK7JN8D1iuY5sfGRJOdlXfQMU6h4sE
	 TlV5CgB5vVRjiYthr5OR3PADT3awQQTqqkPx4Mu2jHnRjawjK0bkL0dNFODi2ACIeN
	 km8/l4duw2F1XhT7TOObevKb6eSPOuUAitwRa6ii02HxHqYNJhgHSQdWzKwfw6fNSL
	 EyD38PZUZ3fIDrbm5zDQTOzZv/TLvhLe6EPOuxAdxALFG3ZM9/TJfWbtGgjn/hAEsX
	 Rx1p6VoVy28eFyh8R6/ZRGaTtl5JBw6M6Rx90RNUS2FqvWYzGf37RlqNYcXgffmVpb
	 5nH0U2OIuHS8Q==
Date: Mon, 20 Jul 2026 10:46:26 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Add missing superblock check in
 find_or_insert_direct_key()
Message-ID: <20260720174626.GD1865@quark>
References: <20260719033120.122120-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260719033120.122120-1-ebiggers@kernel.org>

On Sat, Jul 18, 2026 at 08:31:20PM -0700, Eric Biggers wrote:
> The legacy 'fscrypt_direct_keys' table caches master keys that are used
> by v1 encryption policies that have FSCRYPT_POLICY_FLAG_DIRECT_KEY.
> It's just a global table for all filesystems (since the keys can be
> provided by the legacy process-subscribed keyrings mechanism, which
> makes it difficult to reuse super_block::s_master_keys).
> 
> The entries in it ('struct fscrypt_direct_key') do contain a super_block
> pointer, though, for passing to fscrypt_destroy_inline_crypt_key() when
> the last inode that references the key is evicted.
> 
> However, when finding the fscrypt_direct_key for an inode, we weren't
> actually comparing the super_block pointer.  As a result, inodes with
> different super_blocks could point to the same fscrypt_direct_key.  That
> could extend the lifetime of a fscrypt_direct_key beyond the
> super_block it points to, causing a use-after-free later.
> 
> Fix this by creating distinct fscrypt_direct_key structs for distinct
> super_block structs.
> 
> Note that this problem doesn't exist in the v2 policy equivalent
> ("per-mode keys"), since the data structures there are per super_block.
> 
> Fixes: 22e9947a4b2b ("fscrypt: stop holding extra request_queue references")
> Cc: stable@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-current

- Eric
