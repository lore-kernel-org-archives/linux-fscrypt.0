Return-Path: <SRS0=rtUG=7B=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D61A5C433E2
	for <linux-fscrypt@archiver.kernel.org>; Tue, 19 May 2020 11:13:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BE4BF207D3
	for <linux-fscrypt@archiver.kernel.org>; Tue, 19 May 2020 11:13:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726595AbgESLNo (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 19 May 2020 07:13:44 -0400
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:49137 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726505AbgESLNm (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 19 May 2020 07:13:42 -0400
Received: from callcc.thunk.org (pool-100-0-195-244.bstnma.fios.verizon.net [100.0.195.244])
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 04JBDLpS006587
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Tue, 19 May 2020 07:13:22 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
        id 5513F420304; Tue, 19 May 2020 07:13:21 -0400 (EDT)
Date:   Tue, 19 May 2020 07:13:21 -0400
From:   "Theodore Y. Ts'o" <tytso@mit.edu>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     linux-fscrypt@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org,
        linux-mmc@vger.kernel.org, Satya Tangirala <satyat@google.com>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Paul Crowley <paulcrowley@google.com>
Subject: Re: [PATCH] fscrypt: add support for IV_INO_LBLK_32 policies
Message-ID: <20200519111321.GE2396055@mit.edu>
References: <20200515204141.251098-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200515204141.251098-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, May 15, 2020 at 01:41:41PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> The eMMC inline crypto standard will only specify 32 DUN bits (a.k.a. IV
> bits), unlike UFS's 64.  IV_INO_LBLK_64 is therefore not applicable, but
> an encryption format which uses one key per policy and permits the
> moving of encrypted file contents (as f2fs's garbage collector requires)
> is still desirable.
> 
> To support such hardware, add a new encryption format IV_INO_LBLK_32
> that makes the best use of the 32 bits: the IV is set to
> 'SipHash-2-4(inode_number) + file_logical_block_number mod 2^32', where
> the SipHash key is derived from the fscrypt master key.  We hash only
> the inode number and not also the block number, because we need to
> maintain contiguity of DUNs to merge bios.
> 
> Unlike with IV_INO_LBLK_64, with this format IV reuse is possible; this
> is unavoidable given the size of the DUN.  This means this format should
> only be used where the requirements of the first paragraph apply.
> However, the hash spreads out the IVs in the whole usable range, and the
> use of a keyed hash makes it difficult for an attacker to determine
> which files use which IVs.
> 
> Besides the above differences, this flag works like IV_INO_LBLK_64 in
> that on ext4 it is only allowed if the stable_inodes feature has been
> enabled to prevent inode numbers and the filesystem UUID from changing.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Theodore Ts'o <tytso@mit.edu>

I kind of wish we had Kunit tests with test vectors, but that's for
another commit I think.

					- Ted



