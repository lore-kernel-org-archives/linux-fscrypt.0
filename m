Return-Path: <SRS0=NQ5k=TC=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH 01/13] fscrypt: simplify bounce page handling
Date: Thu, 02 May 2019 20:40:34 +0530
In-Reply-To: <20190501224515.43059-2-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org> <20190501224515.43059-2-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <3273903.Njs8gtEjer@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, May 2, 2019 4:15:03 AM IST Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Currently, bounce page handling for writes to encrypted files is
> unnecessarily complicated.  A fscrypt_ctx is allocated along with each
> bounce page, page_private(bounce_page) points to this fscrypt_ctx, and
> fscrypt_ctx::w::control_page points to the original pagecache page.
> 
> However, because writes don't use the fscrypt_ctx for anything else,
> there's no reason why page_private(bounce_page) can't just point to the
> original pagecache page directly.
> 
> Therefore, this patch makes this change.  In the process, it also cleans
> up the API exposed to filesystems that allows testing whether a page is
> a bounce page, getting the pagecache page from a bounce page, and
> freeing a bounce page.

Looks good to me,

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>

-- 
chandan
