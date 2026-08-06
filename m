Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu [18.9.28.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EA5F471CF6
	for <linux-fscrypt@vger.kernel.org>; Thu,  6 Aug 2026 15:01:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=18.9.28.11
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786028508; cv=none; b=lsiiiBjNEoEqS1uQsD0gb/n1iw4ojYNRN0CgfepiR50I1rVYR8A881bjm+eapYpHtpXpFLI0yMUt5qNkYdr8c7qIjB9BdbD15voAJTFcYycpJwuJs4MF8UqSgLb+7IHZPGrBabUuaT6Ct1kiC46W3LNLpTimBWjo5zQRc70fZu8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786028508; c=relaxed/simple;
	bh=1F+s8SEdiA99bvxPBcBimiaP4vyZM9KKTDcXYWCH1zg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=UJfp2yOVGuNMJfka8H6BwXRciAcZAdqeLIlEGq9D/Bg2UFV3CUooG88+N0LqPTS9JFehdeLWW2T8Q93hwNh48/w26Npj94MYkoBfS8JfdKj7/v1DTUJIoT+AGdqA5NBHPMTzXSOoGh2+7IC793VdEt29KeClOwzaxZ4gr7mUwhc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=mit.edu; spf=pass smtp.mailfrom=mit.edu; dkim=pass (2048-bit key) header.d=mit.edu header.i=@mit.edu header.b=DbzyeMAR; arc=none smtp.client-ip=18.9.28.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=mit.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mit.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mit.edu header.i=@mit.edu header.b="DbzyeMAR"
Received: from trampoline.thunk.org (pool-173-48-113-153.bstnma.fios.verizon.net [173.48.113.153])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 676F16A7011300
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 6 Aug 2026 11:01:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mit.edu; s=outgoing;
	t=1786028469; bh=IzPBUvQIuZi3PLpQyvgw2WNIxHKSrXJSrYlozVvzxvI=;
	h=From:Subject:Date:Message-ID:MIME-Version:Content-Type;
	b=DbzyeMARH5bX2e6PdjhAX7U5fO7JfJ0/pA/He4uxAErLsztANEgbZPd1ZV0X9+Kgo
	 8QCIoIDN/P00haWth7bMBue71T2CTkhU13KWiWm//dfohFSYvh6PT5areig5mZZgpZ
	 2PyTQopBBV8k51HMP8mcgWmUxx/zdkd7Mghz6+B5U9KhHgP5/yfD5lAhdJomA1ZBQK
	 O33tQz1hRPt3GxhuPiDNfjc5PxY/3Pm3yrha/UUfJzBrKYQouQzabC3VjHaUHwfIiK
	 3in+w/j8nMHT9s9sD9oxJZ3Ln7Ro2rmAeiYEUBKyKbQnfGs7b0wnvn+B2RtRAGa7Ud
	 2R/DGli40PI3w==
Received: by trampoline.thunk.org (Postfix, from userid 15806)
	id 08A952E3F0F; Thu, 06 Aug 2026 11:01:06 -0400 (EDT)
From: "Theodore Ts'o" <tytso@mit.edu>
To: linux-ext4@vger.kernel.org, Eric Biggers <ebiggers@kernel.org>
Cc: "Theodore Ts'o" <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>,
        Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
        Ojaswin Mujoo <ojaswin@linux.ibm.com>,
        Ritesh Harjani <ritesh.list@gmail.com>, Zhang Yi <yi.zhang@huawei.com>,
        Ira Weiny <iweiny@kernel.org>, linux-fscrypt@vger.kernel.org,
        linux-kernel@vger.kernel.org, Disha Goel <disgoel@linux.ibm.com>,
        stable@vger.kernel.org
Subject: Re: [PATCH] ext4: don't enable DAX on new encrypted files
Date: Thu,  6 Aug 2026 11:00:56 -0400
Message-ID: <178602814512.965683.11993377254644330464.b4-ty@b4>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260730175212.36923-1-ebiggers@kernel.org>
References: <20260730175212.36923-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


On Thu, 30 Jul 2026 10:52:12 -0700, Eric Biggers wrote:
> Currently, when a new encrypted regular file is created, the call to
> ext4_set_inode_flags(inode, init=true) in __ext4_new_inode() is made
> before EXT4_INODE_ENCRYPT is set.  As a result, it can set S_DAX if the
> filesystem is mounted with "-o dax=always".
> 
> EXT4_INODE_ENCRYPT then actually gets set a bit later in
> __ext4_new_inode(), when it calls fscrypt_set_context() which calls
> ext4_set_context().  ext4_set_context() sets EXT4_INODE_ENCRYPT and
> calls ext4_set_inode_flags(inode, init=false) to set S_ENCRYPTED too.
> 
> [...]

Applied, thanks!

[1/1] ext4: don't enable DAX on new encrypted files
      commit: da32af420d6d466e247c43ac0b829edeac7ae0ad

Best regards,
-- 
Theodore Ts'o <tytso@mit.edu>
