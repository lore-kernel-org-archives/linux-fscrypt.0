Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Mon, 21 Oct 2019 13:28:12 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20191021202811.GB122863@gmail.com>
References: <20191009234038.224587-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20191009234038.224587-1-ebiggers@kernel.org>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: remove struct fscrypt_ctx
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
To: linux-fscrypt@vger.kernel.org
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Chandan Rajendra <chandan@linux.ibm.com>, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Oct 09, 2019 at 04:40:38PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Now that ext4 and f2fs implement their own post-read workflow that
> supports both fscrypt and fsverity, the fscrypt-only workflow based
> around struct fscrypt_ctx is no longer used.  So remove the unused code.
> 
> This is based on a patch from Chandan Rajendra's "Consolidate FS read
> I/O callbacks code" patchset, but rebased onto the latest kernel, folded
> __fscrypt_decrypt_bio() into fscrypt_decrypt_bio(), cleaned up
> fscrypt_initialize(), and updated the commit message.
> 
> Originally-from: Chandan Rajendra <chandan@linux.ibm.com>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied to fscrypt.git for 5.5.

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
