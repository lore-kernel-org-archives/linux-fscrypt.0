Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D98664E8DF5;
	Fri, 25 Sep 2026 19:59:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790366365; cv=none; b=EzSKlD4P4I0gYYBmT93Qd2pZpl0Z7GqkhqSHP8cYCRKac0VM4XaZMVuNAJVy9LjP2bT4QawAkmhkTWz9ogm4SNS4xeHO5l3HrH2ebEV7o9k9Y4NUnv7CaxOlFFQcZ0b+I7TJuEMz3n0yVjyZ3NaVp+yJcB2RsVH9CSa4hRpUsEs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790366365; c=relaxed/simple;
	bh=0FQ83vRAkYlWE/9ny/4c1VRIcQ+iRevz5Ab6KyCK7yA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Dz/6SvVMo2mVw/Gu0noXke+LsYK//S7RsWGMZObTC1Jtv8sdQm+wosof8x/L+DxLJqcog4pd49THJPJTIi4hzq4Hob4K83cS4dLAEpQMrpqKOa0wGrViWFRQTTb9fMIFkFpkoDYDnf4Mb4gqEeOaUjeAfQgKBUGaDR+JnRIHQio=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cYTCJv2Z; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cYTCJv2Z"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3CA2B1F000FF;
	Fri, 25 Sep 2026 19:59:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790366363;
	bh=j0n1Su+cgngbLmmkdleAw6u2hJKqkzvmBS356gMf3Bs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=cYTCJv2Zbjg7AuW/SdFXA7Xbyjq6/GdDZqz6mO89wJhKLAxXV0fwMQIJdXyTTgJs8
	 jdZ72fSL96gHOSis6UnZByrfAz8mUtZ4/f48L4HnHdXy5tx7oZMg1urcnLmlj8tzi+
	 8QKkQ3OhVxiT8UPxpTDZ+hGgWzMmShpocswYgM1p5/Kbax2vLgbBeqPFVVGovorRVk
	 p//pNUXEZL86+VLKO0HJ2buWb2Qn9rBWjR0VSc8QQPVNpTVy+Bb6JCvLQgxmOuUzw7
	 iYHSlxp6AfhMykm6gGLKTlzsaa7H+v4tPIU2Kyjvqn3IKVntSmeSGHLPfQaQxoz6c3
	 /985Abyoall7w==
Date: Fri, 25 Sep 2026 12:59:21 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Alberto Garcia <berto@igalia.com>
Cc: Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>, linux-fscrypt@vger.kernel.org,
	linux-ext4@vger.kernel.org
Subject: Re: [PATCH 0/2] ext4: refuse encryption when block size > page size
Message-ID: <20260925195921.GA5511@quark>
References: <cover.1790343958.git.berto@igalia.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1790343958.git.berto@igalia.com>

On Fri, Sep 25, 2026 at 04:19:17PM +0200, Alberto Garcia wrote:
> Hi,
> 
> encryption is not supported when a filesystem's block size is larger
> than the page size. Although the kernel refuses to mount such a
> filesystem if the "encrypt" feature is already set, it is possible to
> enable it on a mounted filesystem with e.g. tune2fs.
> 
> # mkfs.ext4 -b 16384 /dev/vdb
> # mount /dev/vdb /mnt/
> # tune2fs -O encrypt /dev/vdb
> # mkdir /mnt/foo
> # fscrypt setup /mnt
> # fscrypt encrypt /mnt/foo/
> # head -c 20M /dev/urandom > /mnt/foo/data
> # sync
> [  116.014221] EXT4-fs warning (device vdb): ext4_end_bio:360: I/O error 19 writing to inode 19 starting block 130040)
> [  116.014235] EXT4-fs (vdb): failed to convert unwritten extents to written extents -- potential data loss!  (inode 19, error -5)
> [  116.014241] Buffer I/O error on device vdb, logical block 130040
> [...]
> [  116.014264] Buffer I/O error on device vdb, logical block 130049
> [  116.015505] EXT4-fs warning (device vdb): ext4_end_bio:360: I/O error 19 writing to inode 19 starting block 66552)
> [  116.015520] EXT4-fs (vdb): failed to convert unwritten extents to written extents -- potential data loss!  (inode 19, error -5)
> [  116.016451] EXT4-fs warning (device vdb): ext4_end_bio:360: I/O error 19 writing to inode 19 starting block 65784)
> [  116.016459] EXT4-fs (vdb): failed to convert unwritten extents to written extents -- potential data loss!  (inode 19, error -5)
> 
> This affects all kernels starting from v6.19 up to v7.3-rc4.
> 
> Note that this still allows encrypted inodes even when the 'encrypt'
> feature is missing as long as block size <= page size. With v1
> encryption policies they can be used normally.
> 
> There's an additional bug that only affects kernels between v6.19 and
> v7.2 (but not v7.3), which will be dealt with separately.
> 
> Regards,
> 
> Berto
> 
> Alberto Garcia (2):
>   ext4: refuse encryption when block size > page size
>   ext4: reject encrypted inodes when block size > page size
> 
>  fs/ext4/crypto.c | 9 +++++++++
>  fs/ext4/inode.c  | 6 ++++++
>  2 files changed, 15 insertions(+)

Reviewed-by: Eric Biggers <ebiggers@kernel.org>

- Eric
