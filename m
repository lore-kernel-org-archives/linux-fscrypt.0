Return-Path: <SRS0=tmiS=TG=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH 07/13] fscrypt: handle blocksize < PAGE_SIZE in fscrypt_zeroout_range()
Date: Mon, 06 May 2019 14:12:57 +0530
In-Reply-To: <20190501224515.43059-8-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org> <20190501224515.43059-8-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <6183530.UoL3poR4K9@dhcp-9-109-212-164>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, May 2, 2019 4:15:09 AM IST Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Adjust fscrypt_zeroout_range() to encrypt a block at a time rather than
> a page at a time, so that it works when blocksize < PAGE_SIZE.
> 
> This isn't optimized for performance, but then again this function
> already wasn't optimized for performance.  As a future optimization, we
> could submit much larger bios here.
> 
> This is in preparation for allowing encryption on ext4 filesystems with
> blocksize != PAGE_SIZE.
> 
> This is based on work by Chandan Rajendra.


Looks good to me,

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>

-- 
chandan
