Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Mon, 21 Oct 2019 13:29:00 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20191021202859.GD122863@gmail.com>
References: <20191009234555.226282-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20191009234555.226282-1-ebiggers@kernel.org>
Subject: Re: [f2fs-dev] [PATCH] docs: ioctl-number: document fscrypt ioctl
 numbers
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
Cc: linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Oct 09, 2019 at 04:45:55PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> The 'f' ioctls with numbers 19-26 decimal are currently used for fscrypt
> (a.k.a. ext4/f2fs/ubifs encryption), and up to 39 decimal is reserved
> for future fscrypt use, as per the comment in fs/ext4/ext4.h.  So the
> reserved range is 13-27 hex.
> 
> Document this in ioctl-number.rst.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  Documentation/ioctl/ioctl-number.rst | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/Documentation/ioctl/ioctl-number.rst b/Documentation/ioctl/ioctl-number.rst
> index bef79cd4c6b4d..4ef86433bd677 100644
> --- a/Documentation/ioctl/ioctl-number.rst
> +++ b/Documentation/ioctl/ioctl-number.rst
> @@ -233,6 +233,7 @@ Code  Seq#    Include File                                           Comments
>  'f'   00-0F  fs/ext4/ext4.h                                          conflict!
>  'f'   00-0F  linux/fs.h                                              conflict!
>  'f'   00-0F  fs/ocfs2/ocfs2_fs.h                                     conflict!
> +'f'   13-27  linux/fscrypt.h
>  'f'   81-8F  linux/fsverity.h
>  'g'   00-0F  linux/usb/gadgetfs.h
>  'g'   20-2F  linux/usb/g_printer.h
> -- 

Applied to fscrypt.git for 5.5.

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
