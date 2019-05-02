Return-Path: <SRS0=NQ5k=TC=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH 02/13] fscrypt: remove the "write" part of struct fscrypt_ctx
Date: Thu, 02 May 2019 20:41:26 +0530
In-Reply-To: <20190501224515.43059-3-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org> <20190501224515.43059-3-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <3076347.dZPG85aNpo@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, May 2, 2019 4:15:04 AM IST Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Now that fscrypt_ctx is not used for writes, remove the 'w' fields.
>

Looks good to me,

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>

-- 
chandan
