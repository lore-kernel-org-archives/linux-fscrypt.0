Return-Path: <jaegeuk@kernel.org>
Date: Thu, 30 Nov 2017 23:12:42 -0800
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH v2 0/5] f2fs: switch to new fscrypt helper functions
Message-ID: <20171201071242.GA86192@jaegeuk-macbookpro.roam.corp.google.com>
References: <20171129203532.87729-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129203532.87729-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-f2fs-devel@lists.sourceforge.net, Chao Yu <yuchao0@huawei.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Thanks, merged.

On 11/29, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> This series switches f2fs to use the fscrypt helper functions for
> open/link/rename/lookup/setattr introduced in v4.15.
> 
> These patches were originally sent in "[PATCH 00/25] fscrypt: add some
> higher-level helper functions".  I've rebased them onto v4.15-rc1.
> 
> Eric Biggers (5):
>   f2fs: switch to fscrypt_file_open()
>   f2fs: switch to fscrypt_prepare_link()
>   f2fs: switch to fscrypt_prepare_rename()
>   f2fs: switch to fscrypt_prepare_lookup()
>   f2fs: switch to fscrypt_prepare_setattr()
> 
>  fs/f2fs/file.c  | 30 +++++++-----------------------
>  fs/f2fs/namei.c | 54 +++++++++++++-----------------------------------------
>  2 files changed, 20 insertions(+), 64 deletions(-)
> 
> -- 
> 2.15.0.531.g2ccb3012c9-goog
