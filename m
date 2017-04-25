Return-Path: <richard.weinberger@gmail.com>
MIME-Version: 1.0
In-Reply-To: <20170424170013.85175-6-ebiggers3@gmail.com>
References: <20170424170013.85175-1-ebiggers3@gmail.com> <20170424170013.85175-6-ebiggers3@gmail.com>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Tue, 25 Apr 2017 15:37:56 +0200
Message-ID: <CAFLxGvxdanXJhzioJmgvr3mzSkS=Bxfh1bbtAn1L+t6CoSaHcA@mail.gmail.com>
Subject: Re: [PATCH 5/6] f2fs: switch to using fscrypt_match_name()
Content-Type: text/plain; charset=UTF-8
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Ryo Hashimoto <hashimoto@chromium.org>, Gwendal Grignou <gwendal@chromium.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, Kazuhiro Inaba <kinaba@chromium.org>, David Gstir <david@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

Eric, Jaegeuk,


On Mon, Apr 24, 2017 at 7:00 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
> Switch f2fs directory searches to use the fscrypt_match_name() helper
> function.  There should be no functional change.

> -#ifdef CONFIG_F2FS_FS_ENCRYPTION
> -               if (unlikely(!name->name)) {
> -                       if (fname->usr_fname->name[0] == '_') {
> -                               if (de_name.len > 32 &&
> -                                       !memcmp(de_name.name + ((de_name.len - 17) & ~15),
> -                                               fname->crypto_buf.name + 8, 16))
> -                                       goto found;
> -                               goto not_match;
> -                       }
> -                       name->name = fname->crypto_buf.name;
> -                       name->len = fname->crypto_buf.len;
> -               }

Sorry if this is a stupid question, but why do you have to compare hashes _and_
the last few bytes of the bigname?
A lookup via bigname gives you two 32bits hash values, and there I'd assume that
this is sufficient for a collisions free lookup. Especially since an
resumed readdir()
with a 64bits cookie has to work too on your filesystem.

-- 
Thanks,
//richard
