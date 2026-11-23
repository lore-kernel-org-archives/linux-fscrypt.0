Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795426934;
	b=Uh+ZBJJx6BjP+WUdPYzRYZoiU3prbX2nSaQ0pp7Xe3WjX5/pjOngNTeCYSOcZKK+Na01
	 WeYXjClPtkhnC+cIwAbVfQOw2ZMXvKz/H+C8JK5oILd8zvJNqjMiFvReudIRcLtKTPXid
	 ipm5jAAYwrDDe8PMBOT+5ifpFkwevHicsivSXXsGRxwxW7vsYIe6MjC7KZVPBY0KRPZSH
	 2dEO2ZANdB7u2VAbIwOBhoq4lsuhibprcl7j5wmW8bKQ1jULZy0kSxSKpj0Y69Oe8oL1I
	 6iNLJIBbXwRAEGqn+K9K7EK9Ef36/17kOxd5/UuyIbdO5MQ+iVK5ozKh/Q1vXC8ybhg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795426934;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 Mail-Followup-To:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=FxTobsfCxRYvTDQx8sjXtNySJlBxYXFSYwqfbK6HcX4=;
	b=lLUb89KikRzVBWGiM9bWAIaldU66kjobDWUnTf974hrPvxbt/8rI4QmjX7FzvIMc7uid
	 H4Q/vC9QuZjVb8Qy9yw2g8mZJOxS/bRtxh1+JtVhUjcFxsm5w9wr/DUQhSwCfrpYDqgIp
	 ltNLXI0kP0G6WUQU9WBPS9dWeJT91YQu5HTSfzmIpAY4L8/xUf0KTzSAJZk02oHzxUvby
	 E4E/eU5k3kkaeAaiT+TR3SR3yhMY4HTg0pCjgpvXB5KSG9H0NSer2UEy1v3IWVce/wwdF
	 Xtjqn87dt0bpwlvUPb44hly3zlotd2QqMW/C/CwCW9/z35wYblfmwud+ZY2m2AULhUw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="nMW5cnc/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1661D606A687;
	Mon, 23 Nov 2026 09:42:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nMW5cnc/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A45F81F000C0;
	Mon, 23 Nov 2026 09:42:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795426933;
	bh=FxTobsfCxRYvTDQx8sjXtNySJlBxYXFSYwqfbK6HcX4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=nMW5cnc/NvQHD7Fvd7JMUVH4nVd0RekCqwGvZVjrrlJD6Eq3TzZHYyNySVIkxSqV/
	 M5ftvQn6i+TW3rsFQM/ZU2+QCnlk1jGTKQs+4Y8W/UcJSImkbCLZbrqOAxFlLIlbcQ
	 Z/nDrVSMPVqUe+ThqOY1h+slyt6DB0UG/nCog2lIw2R77fObhwBaIzlTF7T8eHAVwh
	 O2k0iNQczR0Ls+EPKX0ZObqyphdoUkg7FiDYQ4/Curt8sUHOAp1WwDQ6wtvlmEBQ0g
	 29Rj3OcYzYEsAV+9m3+XXXGMavqOE944HjlIvjI9InJr6MTtgidI01ZVJ+RJaJ5cTb
	 VodgTT9NiFXzQ==
Date: Mon, 23 Nov 2026 17:41:56 +0800
From: Zorro Lang <zlang@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	ebiggers@kernel.org, jaegeuk@kernel.org, tytso@mit.edu, linux-ext4@vger.kernel.org, 
	adilger.kernel@dilger.ca, jack@suse.cz, yi.zhang@huawei.com, ojaswin@linux.ibm.com, 
	ritesh.list@gmail.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] common/encrypt: support block sizes larger than the page
 size
Message-ID: <awQHLSS4hFskH0Us@zlang-mailbox>
Mail-Followup-To: Baokun Li <libaokun@linux.alibaba.com>, 
	fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, ebiggers@kernel.org, 
	jaegeuk@kernel.org, tytso@mit.edu, linux-ext4@vger.kernel.org, 
	adilger.kernel@dilger.ca, jack@suse.cz, yi.zhang@huawei.com, ojaswin@linux.ibm.com, 
	ritesh.list@gmail.com, linux-kernel@vger.kernel.org
References: <20261103160906.188544-1-libaokun@linux.alibaba.com>
 <awHJso_ELIgRjbdg@zlang-mailbox>
 <a5ad29d3-eb4d-479d-af48-b679fe8b5d23@linux.alibaba.com>
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
In-Reply-To: <a5ad29d3-eb4d-479d-af48-b679fe8b5d23@linux.alibaba.com>

On Mon, Nov 23, 2026 at 11:39:19AM +0800, Baokun Li wrote:
> Hi Zorro,
> 
> Thank you for your review!
> 
> On 2026/11/22 01:04, Zorro Lang wrote:
> > On Wed, Nov 04, 2026 at 12:09:06AM +0800, Baokun Li wrote:
> >> +	#
> >> +	# If the test requires a v2 policy, don't probe with a v1 policy:
> >> +	# v1 policies are not supported when the block size exceeds the page
> >> +	# size.  _require_encryption_policy_support() will check for the
> >> +	# requested policy version below.
> >> +	if [ "$policy_version" -le 1 ]; then
> >> +		mkdir $SCRATCH_MNT/tmpdir
> >> +		if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \
> >> +			grep -Eq 'Inappropriate ioctl for device|Operation not supported'
> >> +		then
> >> +			_notrun "kernel does not support $FSTYP encryption"
> >> +		fi
> >> +		rmdir $SCRATCH_MNT/tmpdir
> >> +
> >> +		# v1 policies use the block size as their data unit size,
> >> +		# which doesn't work if the block size exceeds the page size.
> >> +		_require_v1_encryption_support
> > 
> > How about do _require_v1_encryption_support at first:
> > 
> >   if [ "$policy_version" -le 1 ]; then
> >       _require_v1_encryption_support
> >       mkdir $SCRATCH_MNT/tmpdir
> >       if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \
> > 
> > In that case, if block_size > page_size, we can directly skip the test
> > with an explicit reason, avoids a redundant mkdir/rmdir and ioctl call.
> > 
> 
> Yes, this can avoid some unnecessary operations.
> 
> 
> >>  # FS QA Test No. ext4/309
> >>  #
> >>  # Verify that file contents encryption works on a filesystem with a block size
> >> -# larger than the page size.  fscrypt uses the block size as the data unit size
> >> -# by default, so this tests data units that span multiple pages, both for the
> >> -# writeback path and for the on-disk ciphertext.
> >> +# larger than the page size.  fscrypt uses min(block size, page size) as the
> >> +# default data unit size, so this tests 4K data units on a 32K-block
> > 
> > Does ext4/309 hardcode 32k ?
> > 
> 
> No, that's actually just an example using a block size of 32k; I'll
> rephrase that.

Great, thanks!

> 
> Additionally, the final plan has not been fully confirmed yet. I am
> still working on the details with Eric. It is expected that all v1 use
> cases will be converted to v2 later, and in the testing process, the
> data unit size will be explicitly specified. Please refer to:
> 
>   https://lore.kernel.org/r/20261104195127.GA1971@quark

Thanks Baokun, good to know you're working on it with Eric Biggers. As the
kernel patch is still under reviewing, please ping the fstests list when
it's ready, in case I miss it :-D

Thanks,
Zorro

> 
> 
> Cheers,
> Baokun
> 
> 
