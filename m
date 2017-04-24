Return-Path: <richard.weinberger@gmail.com>
MIME-Version: 1.0
In-Reply-To: <f415bfef-12d9-6444-9e94-9ae3e3363cfb@nod.at>
References: <20170418210642.6039-1-gwendal@chromium.org> <20170418230136.GA96152@gmail.com>
 <CAFLxGvwtFQW=NL3NrNHx-vWR3wSUtewnBRy1XzMqRNTV8f5vwQ@mail.gmail.com>
 <20170419171633.GB89688@gmail.com> <f415bfef-12d9-6444-9e94-9ae3e3363cfb@nod.at>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Mon, 24 Apr 2017 23:19:00 +0200
Message-ID: <CAFLxGvwuiZ+5zPnQJ6bXKhWHs5jPA=0c5+3Vq5EZn_AsrgzeGg@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: use 32 bytes of encrypted filename
Content-Type: text/plain; charset=UTF-8
To: Richard Weinberger <richard@nod.at>
Cc: Eric Biggers <ebiggers3@gmail.com>, Gwendal Grignou <gwendal@chromium.org>, Ryo Hashimoto <hashimoto@chromium.org>, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Kazuhiro Inaba <kinaba@chromium.org>, David Gstir <david@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

Eric,

On Wed, Apr 19, 2017 at 7:21 PM, Richard Weinberger <richard@nod.at> wrote:
>> Well, like I said to Jaegeuk for F2FS, that's what the code does, but _why_?
>> Like F2FS, it's probably not the case that the hash is sufficient to reliably
>> identify a directory entry.  Granted, UBIFS does it a lot better than F2FS since
>> UBIFS uses two 32-bit hashes rather than just one, but it seems the second hash
>> may be neither necessary nor sufficient to identify a specific directory entry,
>> and it should be looking at the bytes of ciphertext from the filename instead,
>> like what ext4 does.  (Provided that is fixed to account for how CTS mode
>> encryption works.)
>
> Let me dig into this, maybe I made a boo boo.
> The idea was looking up by the filename hash and resolving
> possible collisions using the secondary hash.

In ubifs_lookup() we handle two cases:
1. lookup of a bigname, both fscrypt_name->hash and ->minor_hash are valid.
    ->hash is r5(diskname) and ->minor_hash is the secondary hash, AKA cookie.
   UBIFS fed this hashes in ubifs_readdir() to fscrypt.
2. lookup of a non-bigname, in this case we compute r5(diskname) and
use the diskname
    itself for lookups.

So, in case 1 we avoid collisions by using a 64bit key and in case 2 by using
the 32bit key plus a linear search and memcmp() of diskname.

-- 
Thanks,
//richard
