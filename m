Return-Path: <SRS0=tmiS=TG=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH 06/13] fscrypt: support encrypting multiple filesystem blocks per page
Date: Mon, 06 May 2019 14:08:21 +0530
In-Reply-To: <20190501224515.43059-7-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org> <20190501224515.43059-7-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2173142.gu81EOElhA@dhcp-9-109-212-164>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, May 2, 2019 4:15:08 AM IST Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Rename fscrypt_encrypt_page() to fscrypt_encrypt_pagecache_blocks() and
> redefine its behavior to encrypt all filesystem blocks from the given
> region of the given page, rather than assuming that the region consists
> of just one filesystem block.  Also remove the 'inode' and 'lblk_num'
> parameters, since they can be retrieved from the page as it's already
> assumed to be a pagecache page.
> 
> This is in preparation for allowing encryption on ext4 filesystems with
> blocksize != PAGE_SIZE.
> 
> This is based on work by Chandan Rajendra.

Looks good to me,

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>

-- 
chandan
