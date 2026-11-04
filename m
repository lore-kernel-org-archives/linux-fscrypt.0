Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821890;
	b=UixCXPfD3a8MzPNgHmWKH8w1fEjyLnT7BDY6pQxFizMvlOo5uzzIwniMQ2YM42rd3ZI1
	 YNKoYkm/je/W8ZrpvexOSZf+8QRs7HX90AiPvBG77QXlXPuqfJAosfr2kbHKYX2qkOHzu
	 EiLVGzuWtrU14UHDOSb4MN03A1u2kRSgUcBUizQnQfFSm81uPqaztfl72PmyHdTY3DG0l
	 PP0LwjGHiOI4JM8ggF4ZCXRMX0DmjEGBndNMVNPUyv9WLSOGjWDOsAU0WyDItt5ISC/8h
	 Rywyf/XiAjEUV2VZZVYjqTdXbqbzdAHdx2gU34MoTiYY8/dhd0zJqHGraCN8M+AjELQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821890;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=IxJxKooA4bVxA5wejStOMx/9yIbFrchATEfWkVqBn/o=;
	b=JZHcS6Wu1oz8fj3xfnkhOG2j6GzkxT4Mh8uNMQA29nC0c0G3fUyWKQ34BaWqBmxMvhfE
	 QCAXZzQdGVMJ1e2P4GFVwD4t4cX3bysp2saW7P7Q9NVCPFl2+w+JSURoRdJWUIfR/aDT0
	 +49x05QKbak39xrpq1VYNCBAfG3OrRdZvTCTL7gaG2BPlfTp0FU8Uzk9iN7atREdO1a/d
	 4MARd0kmpIm30nz7qv/ocmxMr6gmCnvBxmD6v68Qn/RgAJYHM+Ukx91UYTVQmqwnw1vGe
	 Qz52LCp+n96+CSs8uHUxw9ud919gIaNPIn8F7W/MVxT26vm4rOPTfgFXS62iggvN4ww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iqZRpGOh;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B730606BA01;
	Wed,  4 Nov 2026 19:51:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iqZRpGOh
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 785F91F00919;
	Wed,  4 Nov 2026 19:51:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821890;
	bh=IxJxKooA4bVxA5wejStOMx/9yIbFrchATEfWkVqBn/o=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=iqZRpGOhGtUs1PfmlyQP7y/lEokp4FAva4HbJMTTyYoOynnqg1n+IPWs/gTfvoYPu
	 6C7Jh2CGKstiFuxPtRwU7xc2tPT1Y77q44CaiTo3wzeTNc0Ds6TT0Bc7yzNzq5Qoci
	 XXl8H+h/jN3otpgbP57kV8m0MWIAg4vOIYQNBBAo1cTpgiYpAgqKdvXT/iv7REKQXf
	 tr4Dp4w275xo/lZ+kYwZsZx+aFW7uh0oroETGxi2nh5n+obHY2bt81LgLV3Tjy7ioj
	 OhxYCvnGf2psWNlLgR4056h0ce/kt+47KVErf3+wTjtozfGszV9UXROo9tgTqSsyFg
	 qkF29iNh0lQ4w==
Date: Wed, 4 Nov 2026 11:51:27 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: linux-fscrypt@vger.kernel.org, jaegeuk@kernel.org, tytso@mit.edu,
	linux-ext4@vger.kernel.org, adilger.kernel@dilger.ca, jack@suse.cz,
	yi.zhang@huawei.com, ojaswin@linux.ibm.com, ritesh.list@gmail.com,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/4] fscrypt: Cap data units at the page size
Message-ID: <20261104195127.GA1971@quark>
References: <20261103153132.4154855-1-libaokun@linux.alibaba.com>
 <20261103153132.4154855-2-libaokun@linux.alibaba.com>
 <20261103224006.GC2281@quark>
 <922240f9-8233-4466-a787-2f7ddba7c490@linux.alibaba.com>
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
In-Reply-To: <922240f9-8233-4466-a787-2f7ddba7c490@linux.alibaba.com>

On Wed, Nov 04, 2026 at 10:31:46AM +0800, Baokun Li wrote:
> What I had in mind before was to keep the default as min(bs, PS) and
> allow DU > PS only when explicitly specified, which seemed to give
> better compatibility.  Cross-machine or cross-page-size cases seem
> uncommon, and existing machines have probably already avoided them by
> specifying a 4K or smaller DU.
> 
> Keeping the existing default semantics and returning an error in the
> LBS case for the user to specify seems feasible.  But then
> test_dummy_encryption and the xfstests cases that use the default would
> need to specify the DU explicitly, otherwise the LBS + encrypt test
> coverage would drop a lot.  That is, in the kernel or the tests we
> always have to set a default DU size.
> 
> If you confirm that we should take the route where LBS requires an
> explicit data unit size and the default is rejected, I can adapt the
> kernel and xfstests in v2.  Or should we go back to the more compatible
> DU > page size approach?

It will indeed be annoying to have to explicitly specify the data unit
size, but I don't see a better solution for now, given the complexity of
supporting data unit sizes larger than the page size.  I think making
the on-disk format needing PAGE_SIZE to interpret is a no-go.

I suppose that in theory, how FS_IOC_SET_ENCRYPTION_POLICY handles
log2_data_unit_size=0 could be changed: it could start actually writing
log2_data_unit_size=12 to disk (rather than writing 0 which means the
filesystem block size).  I think that can still lead to problems,
though.  For one FS_IOC_GET_ENCRYPTION_POLICY would return something
different from what was set.

Regarding xfstests, take a look at how common/verity adds $FSV_BLOCKSIZE
to all 'fsverity enable' commands by default, to select some Merkle tree
block size that the filesystem supports.  Something similar could be
done with fscrypt.  Yes, this won't work with v1 encryption policies,
but v1 policies are obsolete.  Most of the xfstests that use v1 policies
should just be updated to use v2 instead.  The btrfs folks were working
on that earlier, since they're not planning to support v1 at all.

- Eric
