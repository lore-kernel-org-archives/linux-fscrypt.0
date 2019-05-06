Return-Path: <SRS0=tmiS=TG=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH 08/13] fscrypt: introduce fscrypt_decrypt_block_inplace()
Date: Mon, 06 May 2019 14:31:58 +0530
In-Reply-To: <20190501224515.43059-9-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org> <20190501224515.43059-9-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <1926821.WNcHRD5IIQ@dhcp-9-109-212-164>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, May 2, 2019 4:15:10 AM IST Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> fscrypt_decrypt_page() behaves very differently depending on whether the
> filesystem set FS_CFLG_OWN_PAGES in its fscrypt_operations.  This makes
> the function difficult to understand and document.  It also makes it so
> that all callers have to provide inode and lblk_num, when fscrypt could
> determine these itself for pagecache pages.
> 
> Therefore, move the FS_CFLG_OWN_PAGES behavior into a new function
> fscrypt_decrypt_block_inplace().
>

Looks good to me,

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>

-- 
chandan
