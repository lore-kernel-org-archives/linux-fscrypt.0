Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792865070;
	b=IQ63jmZ7vm1YDs7aAibvVPTpdKpQrVDftb1Lae14olCfMJxbBZ4ml4tZN6CnmdtS88o0
	 CuzHbo9OOoOxCbsUy5d8YEKzLmcB9n+WhF9pm3BS72AMtSVCay5es1JvumWpUlZlfK8yN
	 pNKMfSr2h8/PacCHNXRMbLDtA+2twcer8LWBjO0ATm6elzWJW/U2seJj0icjpfGd8RZjc
	 3w59pJmvkApXWUHomEqVR6xav4k2NpZxT6FwUe2lw6UD0grvmj6U0GFppxBe38gvyoth9
	 2+jLYom1R01smI18BnQJ3VzmES4sBiUGFE/WscR6XA4tcnVRnvVdnpU7T7qpbpH3vZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792865070;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To;
	bh=WuFaVsQnEsxjjfPV6MVWqOly4eWoNzk8KL77FptK4VI=;
	b=3ls2INl+c+rabpNcXM/lycfzHz5kcT+he6XGeCcJoQuns4rC8csQ2X0RPul/AHB0ZCTg
	 VU3575u5lBEH5V9fZcIX0Cm5vCCgCPiQFbGNzdR8QdHFqXziVvUJ4MOJJ+OKmEOrEOw3u
	 XX2PUh0VvosVwhuk/os5Z57bazSw2/0uyJGQO+qJ1vnFJhXTF77c3RQr7Qd5jz2OrC9kH
	 SNpq8fLQaA1vM0+q53EVXgiXGIW/f0wvvkGL3jRM729+5o2dVk5vSYAINSK1LVmhkJItf
	 7g6UZM8qjDbrlzUbdouCUD6ci4XpveB9JeYJbFMq8H71uY5UQIA3cli090NcZ7iuYVw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=l+d5gCXu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D927606A31A;
	Sat, 24 Oct 2026 18:04:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=l+d5gCXu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8089B1F01828;
	Sat, 24 Oct 2026 18:04:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792865069;
	bh=WuFaVsQnEsxjjfPV6MVWqOly4eWoNzk8KL77FptK4VI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=l+d5gCXulhz+B8QplBmZeI8wBVDt1VEUkCDs1SRtqNbvNdJlj9oe07deSdY9j7WaG
	 uK1udjb5jH4Bc7Jyw0kkqo9PxSwRzmXY63xDu/mPDFT3AWWX85Z1fTMQ83AbIwX4J1
	 vJCgCD73rsmp/jDehZkxwHAGwLaIdMWK3FtwzGznauJgGACrtortNRElwWhqUzDMBs
	 AT9ZCPbGxIRRhs1ydSq+aYgZc61EqNRVV7+RedVwrE9R70VCkH08smNVx9iJQNvoyN
	 +7fDm8rVLUPdB1zcV1P3UiWfdpn92Tq0kDcz3OVOuhbnHroMI0xvow72K1/uELskhp
	 sO/LI5RNmcvpQ==
Date: Sat, 24 Oct 2026 11:04:28 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: linux-fscrypt@vger.kernel.org, tytso@mit.edu, jaegeuk@kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH v4] fscrypt: Fix missing barrier in
 fscrypt_find_mode_key()
Message-ID: <20261024180428.GB2553@quark>
References: <20261024104350.2257313-1-libaokun@linux.alibaba.com>
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
Content-Transfer-Encoding: 8bit
In-Reply-To: <20261024104350.2257313-1-libaokun@linux.alibaba.com>

On Sat, Oct 24, 2026 at 06:43:50PM +0800, Baokun Li wrote:
> fscrypt_find_mode_key() walks an RCU list and hands out a per-mode
> key without an acquire:
> 
>   setup task
>   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>   setup_per_mode_enc_key()
>    ├─ fscrypt_prepare_key()
>    │  └─ fscrypt_prepare_inline_crypt_key()
>    │     └─ blk_crypto_start_using_key()
>    │        └─ blk_crypto_fallback_start_using_mode()
>    │           ├─ init profile, keyslots, tfms[]
>    │           └─ smp_store_release(tfms_inited[mode])  # init order
>    └─ list_add_tail_rcu(&new_node->link, ...)  # release -> finder
> 
>   finding task (later submits the I/O itself)
>   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>   fscrypt_find_mode_key()
>    ├─ list_for_each_entry_rcu(node, ...)
>    └─ return &node->key                 # no acquire, chain breaks
>   ...
>   blk_crypto_fallback_bio_prep()        # WRITE path
>    ├─ tfms_inited[mode]                 # addr-dep, reads true
>    ├─ blk_crypto_fallback_profile       # no dependency
>    ├─ blk_crypto_keyslots               # no dependency
>    └─ slotp->tfms[mode]                 # no dependency
> 
> RCU publishes the node and the key reachable from it, so
> tfms_inited[mode] reads true through the address dependency.  The
> independent fallback globals are not covered by it and can be read as
> uninitialized.
> 
> On a weakly ordered machine, a WRITE bio can crash in
> blk_crypto_get_keyslot() or crypto_sync_skcipher_setkey().
> 
> Other tasks reach the key through fscrypt_inode_info's
> cmpxchg_release()/smp_load_acquire(), which is already ordered after
> the list walk; only the finding task's own later I/O was not.
> 
> Fix this by upgrading the control dependency to an acquire with
> smp_acquire__after_ctrl_dep() once a matching entry has been found.
> 
> Fixes: dd015b566d50 ("fscrypt: Fix key setup in edge case with multiple data unit sizes")
> Cc: stable@vger.kernel.org
> Suggested-by: Eric Biggers <ebiggers@kernel.org>
> Link: https://lore.kernel.org/r/20261014161153.GC322435@quark
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
> ---
> Changes since v3:
>  * Update commit message and comments as suggested by Eric.

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

Thanks!

- Eric
