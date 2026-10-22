Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.216.43
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792713117;
	b=bwVXG4dojKoNY+Fp4XneNJpq1yGnuE/l6RaP0qA/5ouol7g3d4G7o8WfApA+zXsQU1ix
	 iovKKyNAxyMXsMyljJDKIsnt2tPxpKEa846mHdE6mmhBTS8bxeI/5OVJ4FZE8ZkDR6YII
	 QHz+z4H3IzsAMilBSr0kNJTS26hNZ/NrZQiCKJRF142InQI2xfsP3j0HDN78R59pXvmTK
	 rmfKhe/lLmbGgejev/0gLoiyTMnlwoeSTEp5x+XtOpzOqy+s6og42U/DgNNr55KGfy6HN
	 2KbTAKW6W7dsBtof3LyJRb5XhyEA9TKaoCsYSpIZwGwlxS/c4+bl0kCgZgYOudPjGNw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792713117;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Content-Transfer-Encoding:Message-Id:References:To:X-Mailer;
	bh=gqwUKq+SQbEEXMaOitIcffWM6vbj1qymXwiYLf985+Q=;
	b=YKeowcDT9fkQ+EP6AikctQ7EheWm5rvuM+3V4MWOS2oxl1eS+0NIE6gww7PuBauzjjBy
	 Fmfpz51qSXqxPzAbIwyIL9Ocm9LkFITLZ2z0RYi8RquBWgjhSVBzPIvUqW2tzVCVLlxB1
	 LH5Iw1JO1bIuafEhX7YdJQcNiv+uS5TK9menO0QQowr2Vctw9bCNhSpRdLzumLyvl/WUC
	 uiXIiyK3jIc2RCsPwyxRRbXWTckp/hwopP5Dp9mUQRqHeIdTh0rvIOdcJ+W6G4xcp43fd
	 7XR8tph2JvzfkaeJoDd4zxken7m4ciY/kUb97NZD1ZHSbrJVTp4mzNMnBCRqnODO7rg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=dilger.ca;
	spf=pass smtp.mailfrom=dilger.ca;
	arc=none smtp.remote-ip=209.85.216.43
Received: from mail-pj1-f43.google.com (mail-pj1-f43.google.com [209.85.216.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66983606A31F
	for <linux-fscrypt@vger.kernel.org>; Thu, 22 Oct 2026 23:51:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 66983606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=dilger.ca
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dilger.ca
Received: by mail-pj1-f43.google.com with SMTP id 98e67ed59e1d1-3ac77270fbfso190182a91.2
        for <linux-fscrypt@vger.kernel.org>; Thu, 22 Oct 2026 16:51:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dilger-ca.20251104.gappssmtp.com; s=20251104; t=1792713109; x=1793317909; darn=vger.kernel.org;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:content-type:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=gqwUKq+SQbEEXMaOitIcffWM6vbj1qymXwiYLf985+Q=;
        b=P1bPMEgREGhmxP/g/CEHjUAjIs8MHA4kGQc2dxe6T2f3Y72wenVgP8JFneWvTvLFwn
         ZKUYp+4ytRzTNfk0T9wDs21qhWm5oIV2Jf1oM9Rc5XfvolX00Oh6YLo4fgAnXH6ITL5N
         U9+T6GRJfMe9+4j7VLUHsU6mfL7fYX/D3eeOMnxfyK/8tvLIp0ghOKUCY9hLoBqUwr1R
         pdAty9V12zbNzsytcWjb3yWl3S7AIvIyhMPrq4/ngBqUpLBQhd9d2sitkuvtiP640Elo
         FT80vhtZCGxOHW3yWnCzv3nzSfc9NYWz7Cmi9mDtzuxNaGdEgLjtKiKYmhHJ+LjdFvuy
         3yjw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792713109; x=1793317909;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:content-type:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gqwUKq+SQbEEXMaOitIcffWM6vbj1qymXwiYLf985+Q=;
        b=r3ekgZKE3qAJaP2M9HqxLmglhhm4s51Vt5xmNcjLTF913+5g4j/VKfH8hT/9IT9GGX
         ymJBUbnIGiWrd2GnxO40wC23J6qqMymgoytkwiHyFjBvVDgb+YEMTlBSraYhLronBhz9
         pP/lxXoDU2C9TdIZr9xMrjUmt385qfcx2Rr7/5is6AdEQLPQJAfgRYWEy6Xn5T9o4D7v
         etcI7mJwOA5+NJZ2upGwKG4sdFOpiGsGm16nsGARpi6BcD/KZi6dg+NS925Pr7TJAigv
         X7eGq3xmjpZ1kXJLXAKLHu+Gx+ATRmTlBA8VpcArvc9nLiz0VxkoS9qD7ri8RG763CRe
         vW1Q==
X-Forwarded-Encrypted: i=1; AKwUvBzX06tdMxbFdoNwf94CfDXeWElwV+OHUViFMUKfvy1ALCRVccQw8bwYPSzftf+1uYmj+s1NY2aEnr9FFK3g@vger.kernel.org
X-Gm-Message-State: AFq9FYJm2Bcw0v3O25oTJEKuRMf/7ILLrhXTrLQf3P0YpMG653gn/kHk
	nctP6EP+Z+vCiH2rjFC7LfunQvhUzuRnKkpCmSkNTkAQnKKNmcx6OVBQhGfTcZ+Yqbg=
X-Gm-Gg: AYBFou0bLuw/XMOgMfSNqSXoLrIoGJIVgKprBMk4FHlOGYvDjR6Up1MO2gcOzoTIa+2
	XkF2dC2UvELZIjoYhGsKBKhKTpR/9qtDf24iQY+zxITaR+UffCNLM1PEGIAfOMZdEesaO35gBqC
	fZ4FkWvxCoVwOLuCE74PzMhK3mCi5N49zk0v0lPWYJWC6muL9FtAO0E3nV7ByFLoN7vh3g6pQbV
	JKWxXH3ibYwJuZZiSi1IoS/t5plNEnXilBZLRw1muHBSNg3VgpbKxrDG/lO3Oc48xHJZRV0lbmL
	ZO1m24YirsIDW5VDPSVwZCnTMRLbuZ9Ab2VYwtktBjZVrL7Ouqi+qUajB4ZBa2L7BYR9t3GG25T
	SYBpToNJqzrxmbDErJ4l5r8Xg09zfDxHOrKijxJiOdhcZ9X4xZNU/3EEdwqsjCJl6QXGd90iLCF
	pZ/DDFkWzCe4HuWmlmvdJvI7Chc3FmLfU5quyG3BeSMdiYU3YvfptKgN9WDAhDpc8fX+0q+fhx9
	cbqIwsqq0iJYaoQf58j4xp4Z0AS0g3Hvne9ySZn6JcmgfFTIh0SF5kOsh2/Cikj/szkWZzCO7KU
	hWtOTg0B6mfTm1g=
X-Received: by 2002:a17:90b:1c0e:b0:3a4:ba6e:65c9 with SMTP id 98e67ed59e1d1-3adce4a5020mr298916a91.59.1792713108702;
        Thu, 22 Oct 2026 16:51:48 -0700 (PDT)
Received: from smtpclient.apple ([199.7.158.231])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3ada4890c56sm6439266a91.2.2026.10.22.16.51.45
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2026 16:51:48 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.700.51.1.3\))
Subject: Re: [PATCH 00/13] block, ext4: allow encryption with a block size
 larger than the page size
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20261022220454.GC1383716@google.com>
Date: Thu, 22 Oct 2026 17:51:30 -0600
Cc: Baokun Li <libaokun@linux.alibaba.com>,
 linux-ext4@vger.kernel.org,
 linux-fscrypt@vger.kernel.org,
 linux-block@vger.kernel.org,
 linux-fsdevel@vger.kernel.org,
 linux-xfs@vger.kernel.org,
 jaegeuk@kernel.org,
 axboe@kernel.dk,
 hch@lst.de,
 djwong@kernel.org,
 brauner@kernel.org,
 tytso@mit.edu,
 berto@igalia.com,
 jack@suse.cz,
 yi.zhang@huawei.com,
 ojaswin@linux.ibm.com,
 ritesh.list@gmail.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <A4A31F65-8CED-40AB-9C5A-68ADE6A9BDE0@dilger.ca>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261015185325.GG2170687@google.com>
 <625e5190-d43e-4a2b-9296-da15c52d1a9a@linux.alibaba.com>
 <20261022220454.GC1383716@google.com>
To: Eric Biggers <ebiggers@kernel.org>
X-Mailer: Apple Mail (2.3864.700.51.1.3)

On Oct 22, 2026, at 16:04, Eric Biggers <ebiggers@kernel.org> wrote:
>=20
> On Fri, Oct 23, 2026 at 12:30:39AM +0800, Baokun Li wrote:
>> Hi Eric, Thank you for your feedback!
>> On 2026/10/16 02:53, Eric Biggers wrote:
>>> On Mon, Oct 12, 2026 at 01:09:45AM +0800, Baokun Li wrote:
>>>> Motivation
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>=20
>>>> ext4 supports a block size larger than the page size (LBS), e.g. a =
32k
>>>> block size on a machine with 4k pages [1].  Encryption, however, is
>>>> still refused on such a filesystem: file contents used to be =
encrypted
>>>> page by page in the fs-layer path, which cannot handle a folio that
>>>> covers several data units, so the checks that refuse encryption =
with
>>>> such a block size stayed in place.
>>>>=20
>>>> Since commit 5acc6f649a68 ("fscrypt: Always use blk-crypto for
>>>> contents on block-based filesystems") file contents are always
>>>> encrypted through blk-crypto.  Inline encryption hardware can =
already
>>>> en/decrypt a data unit that spans several pages, but the fallback =
and
>>>> the block layer cannot carry such a data unit:
>>>>=20
>>>>  1. blk-crypto-fallback en/decrypts a data unit with the bio_vecs =
of
>>>>     a single page-clamped segment, so a larger data unit fails with
>>>>     BLK_STS_INVAL;
>>>>  2. the block layer requires every bio_vec of an encrypted bio to =
be
>>>>     data unit aligned, and splits such a bio without rounding the
>>>>     split size down to the data unit size;
>>>>  3. iomap cuts the direct I/O bios of an encrypted file only at the
>>>>     logical block size of the device, so a bio can end in the =
middle
>>>>     of a data unit.
>>>>=20
>>>> This series adds the missing pieces on all three layers, removes =
the
>>>> refusals, and enables large folios for encrypted files on the way.
>>>>=20
>>>> [1]: =
https://lore.kernel.org/all/20251121090654.631996-1-libaokun@huaweicloud.c=
om
>>> A high-level question: most of the complexity in this series is to
>>> support crypto_data_unit_size > PAGE_SIZE, despite the actual goal =
being
>>> to support fs_block_size > PAGE_SIZE.  It's left unstated that the
>>> default of crypto_data_unit_size =3D=3D fs_block_size is used.  =
However,
>>> ext4 and f2fs already support crypto_data_unit_size < fs_block_size.
>>>=20
>>> Would leaving the crypto_data_unit_size at e.g. 4 KiB while =
increasing
>>> fs_block_size be a simpler way to achieve the goal of this series?
>>=20
>> I initially followed the LBS approach of lifting the page-size
>> restriction, keeping the existing default crypto_data_unit_size
>> equal to fs_block_size. I had not considered using sub-block DUs.
>>=20
>> After your reply, I implemented a variant using min(bs, PS) for
>> new default v2 policies, recording a smaller DU explicitly on disk.
>> This avoids patches 3-6 and the per-bvec alignment relaxation in
>> patch 10, and is indeed much simpler.
>>=20
>> Both variants retain large-folio support and showed similar gains,
>> about twice their respective 4K-block controls. Although 32K DUs =
reduced
>> decryption calls eightfold, I did not observe a consistent additional
>> throughput benefit, or CPU savings at matched bandwidth, in the =
tested
>> workloads.
>>=20
>>> Or do you feel that would be incomplete, and you'd indeed like to
>>> support crypto_data_unit_size =3D fs_block_size > PAGE_SIZE?
>>=20
>> However, keeping DU =3D bs has a compatibility advantage for existing
>> encrypted filesystems.
>>=20
>> For example, a 64K-block filesystem created with a default v2 policy
>> on a 64K-page machine uses 64K DUs. Supporting DU > PAGE_SIZE would
>> allow a 4K-page machine to use that format without re-encryption,
>> assuming the other policy and backend requirements are met.
>>=20
>> This also covers otherwise-supported legacy v1 policies, which cannot
>> encode smaller DUs.
>>=20
>> Explicit 4K v2 DUs can also be portable across page sizes, but
>> choosing a smaller DU for new files does not make existing large-DU
>> ciphertext readable on a smaller-page machine. I have not yet tested
>> the cross-page-size migration.
>>=20
>> If you think supporting DU =3D bs > PS makes this series too broad,
>> I can use the simpler sub-block version in the next revision and
>> develop larger-DU support separately.
>>=20
>> Looking forward to hearing your thoughts.
>=20
> I think I prefer the simpler version for now.  If someone wants to
> create encrypted files on a 64K block size filesystem on a 64K =
PAGE_SIZE
> system that are also readable on a 4K PAGE_SIZE system, for now they =
can
> just set crypto_data_unit_size =3D 4K.  v1 policies were deprecated 7
> years ago, so they shouldn't really factor into considerations here.
>=20
> Note also that setting crypto_data_unit_size too high can break write
> atomicity as well as compatibility with inline encryption hardware.
>=20
> (Also, the more common use case these days is that someone is
> *increasing* their page size, not decreasing it.)
>=20
> I understand there's been a trend to lift limitations like these and
> make every size work on every system.  But the large crypto data unit
> sizes are difficult to implement correctly, and the proposed
> implementation slows down common cases that matter.  Let's focus on
> fs_block_size > PAGE_SIZE by itself first.

For Lustre fscrypt we just *always* use 4096-byte fscrypt blocks.

That ensures that x86 and aarch64-64k (or other) clients can read
and write fscrypt files in a compatible manner.  I don't _think_
there is any performance advantage to be had from doing fscrypt in
64k chunks, and this would also keep the ext4 filesystem compatible
between aarch64-64k and x86 clients in the (less common) case it is
mounted on a different host.

Cheers, Andreas





