Return-Path: <richard.weinberger@gmail.com>
MIME-Version: 1.0
In-Reply-To: <20170426234300.54741-1-ebiggers3@gmail.com>
References: <20170426234300.54741-1-ebiggers3@gmail.com>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Thu, 27 Apr 2017 09:37:18 +0200
Message-ID: <CAFLxGvzEr94f90QzQFucc3bCrv56fyVtd4ryQ062ot5FUovqFQ@mail.gmail.com>
Subject: Re: [PATCH] MAINTAINERS: fscrypt: update mailing list, patchwork, and git
Content-Type: text/plain; charset=UTF-8
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Eric,

On Thu, Apr 27, 2017 at 1:43 AM, Eric Biggers <ebiggers3@gmail.com> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
> Now that there has been a dedicated mailing list, patchwork project, and
> git repository set up for filesystem encryption, update the MAINTAINERS
> file accordingly.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  MAINTAINERS | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 38d3e4ed7208..22b509fb1c5e 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5365,10 +5365,12 @@ F:      Documentation/filesystems/caching/
>  F:     fs/fscache/
>  F:     include/linux/fscache*.h
>
> -FS-CRYPTO: FILE SYSTEM LEVEL ENCRYPTION SUPPORT
> +FSCRYPT: FILE SYSTEM LEVEL ENCRYPTION SUPPORT
>  M:     Theodore Y. Ts'o <tytso@mit.edu>
>  M:     Jaegeuk Kim <jaegeuk@kernel.org>

IMHO we should also add such an entry, to match reality:

R:      Eric Biggers <ebiggers@google.com>

-- 
Thanks,
//richard
