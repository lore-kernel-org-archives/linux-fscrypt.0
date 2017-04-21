Return-Path: <gwendal@google.com>
MIME-Version: 1.0
Sender: gwendal@google.com
In-Reply-To: <20170421074402.GA7459@zzz>
References: <20170418210642.6039-1-gwendal@chromium.org> <20170418230136.GA96152@gmail.com>
 <20170419001005.GA143911@gmail.com> <20170419014209.GB12215@jaegeuk.local>
 <20170419040138.GA563@zzz> <20170419204448.GA1021@jaegeuk.local> <20170421074402.GA7459@zzz>
From: Gwendal Grignou <gwendal@chromium.org>
Date: Fri, 21 Apr 2017 10:21:16 -0700
Message-ID: <CAMHSBOWCf4gy9ApNvuyYMWUr-UAZscTArS=x3aAD4ohSgMq3_g@mail.gmail.com>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: use 32 bytes of encrypted filename
Content-Type: text/plain; charset=UTF-8
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Ryo Hashimoto <hashimoto@chromium.org>, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-mtd@lists.infradead.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Kazuhiro Inaba <kinaba@chromium.org>
List-ID: <linux-fscrypt@vger.kernel.org>

>
> In any case, I guess that unless there are other ideas we can do these patches:
>
> 1.) f2fs patch to start checking the name, as above
> 2.) patch to start encoding last 32 bytes of the name (or second-to-last CTS
>     block, I haven't decided yet) rather than last 16 bytes, changing
>     fs/crypto/, fs/ext4/, and fs/f2fs/

Using second-to-last CTS block is CTS-CBC specific. If we use another
method to encode filename (I am thinking of HEH,
http://www.mail-archive.com/linux-crypto@vger.kernel.org/msg21826.html)
that may not work anymore.
We don't have to use the last 32 bytes: using for instance the last 24
should be good enough, the escape rate will be 1/2^64 instead 1/2^128.

Gwendal.

> 3.) cleanup patches to introduce helper function and switch ext4 and f2fs to it
>
> (1) and (2) will be backported.
>
> UBIFS can be changed to use the helper function later if needed.  It's not as
> important for it to be backported there since UBIFS does the "double hashing",
> and UBIFS encryption was just added in 4.10 anyway.
>
> I can try to put together the full series when I have time.  It probably would
> make sense for it to go through the fscrypt tree, given the dependencies.
>
> Eric
