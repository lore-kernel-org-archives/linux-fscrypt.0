Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Chandan Rajendra <chandan@linux.ibm.com>
Date: Mon, 06 May 2019 13:54:45 +0530
In-Reply-To: <20190501224515.43059-5-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org>
 <20190501224515.43059-5-ebiggers@kernel.org>
MIME-Version: 1.0
Message-Id: <4366146.XrkeSAOiMl@dhcp-9-109-212-164>
Subject: Re: [f2fs-dev] [PATCH 04/13] fscrypt: clean up some BUG_ON()s in
 block encryption/decryption
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, May 2, 2019 4:15:06 AM IST Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Replace some BUG_ON()s with WARN_ON_ONCE() and returning an error code,
> and move the check for len divisible by FS_CRYPTO_BLOCK_SIZE into
> fscrypt_crypt_block() so that it's done for both encryption and
> decryption, not just encryption.

Looks good to me,

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>

-- 
chandan





_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
