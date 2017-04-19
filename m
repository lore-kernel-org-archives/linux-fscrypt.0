Return-Path: <ebiggers3@gmail.com>
Date: Wed, 19 Apr 2017 10:16:33 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: use 32 bytes of encrypted filename
Message-ID: <20170419171633.GB89688@gmail.com>
References: <20170418210642.6039-1-gwendal@chromium.org>
 <20170418230136.GA96152@gmail.com>
 <CAFLxGvwtFQW=NL3NrNHx-vWR3wSUtewnBRy1XzMqRNTV8f5vwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFLxGvwtFQW=NL3NrNHx-vWR3wSUtewnBRy1XzMqRNTV8f5vwQ@mail.gmail.com>
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, kinaba@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 19, 2017 at 03:40:13PM +0200, Richard Weinberger wrote:
> > Strangely, f2fs and ubifs do not use the bytes from the filename at all when
> > trying to find a specific directory entry in this case.  So this patch doesn't
> > really affect them.  This seems unreliable; perhaps we should introduce a
> > function like "fscrypt_name_matches()" which all the filesystems could call?
> > Can any of the f2fs and ubifs developers explain why they don't look at any
> > bytes from the filename?
> 
> Not sure if I understand you correctly, but for long filenames UBIFS
> does a lookup
> by hash/cookie, not by filename.
> 

Well, like I said to Jaegeuk for F2FS, that's what the code does, but _why_?
Like F2FS, it's probably not the case that the hash is sufficient to reliably
identify a directory entry.  Granted, UBIFS does it a lot better than F2FS since
UBIFS uses two 32-bit hashes rather than just one, but it seems the second hash
may be neither necessary nor sufficient to identify a specific directory entry,
and it should be looking at the bytes of ciphertext from the filename instead,
like what ext4 does.  (Provided that is fixed to account for how CTS mode
encryption works.)

- Eric
