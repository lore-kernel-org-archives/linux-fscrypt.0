Return-Path: <SRS0=D2TC=TD=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH 03/13] fscrypt: rename fscrypt_do_page_crypto() to fscrypt_crypt_block()
Date: Thu, 02 May 2019 21:13:47 +0530
In-Reply-To: <20190501224515.43059-4-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org> <20190501224515.43059-4-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <3498805.PsyZfXou4z@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, May 2, 2019 4:15:05 AM IST Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> fscrypt_do_page_crypto() only does a single encryption or decryption
> operation, with a single logical block number (single IV).  So it
> actually operates on a filesystem block, not a "page" per se.  To
> reflect this, rename it to fscrypt_crypt_block().
>

Looks good to me,

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>

-- 
chandan
