Return-Path: <SRS0=tmiS=TG=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH 09/13] fscrypt: support decrypting multiple filesystem blocks per page
Date: Mon, 06 May 2019 14:39:22 +0530
In-Reply-To: <20190501224515.43059-10-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org> <20190501224515.43059-10-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2349515.8nsl4jZa1H@dhcp-9-109-212-164>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, May 2, 2019 4:15:11 AM IST Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Rename fscrypt_decrypt_page() to fscrypt_decrypt_pagecache_blocks() and
> redefine its behavior to decrypt all filesystem blocks in the given
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
