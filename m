Return-Path: <ebiggers3@gmail.com>
Date: Fri, 21 Apr 2017 11:53:59 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: use 32 bytes of encrypted filename
Message-ID: <20170421185359.GC12755@gmail.com>
References: <20170418210642.6039-1-gwendal@chromium.org>
 <20170418230136.GA96152@gmail.com>
 <20170419001005.GA143911@gmail.com>
 <20170419014209.GB12215@jaegeuk.local>
 <20170419040138.GA563@zzz>
 <20170419204448.GA1021@jaegeuk.local>
 <20170421074402.GA7459@zzz>
 <CAMHSBOWCf4gy9ApNvuyYMWUr-UAZscTArS=x3aAD4ohSgMq3_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMHSBOWCf4gy9ApNvuyYMWUr-UAZscTArS=x3aAD4ohSgMq3_g@mail.gmail.com>
To: Gwendal Grignou <gwendal@chromium.org>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Ryo Hashimoto <hashimoto@chromium.org>, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-mtd@lists.infradead.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Kazuhiro Inaba <kinaba@chromium.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Gwendal,

On Fri, Apr 21, 2017 at 10:21:16AM -0700, Gwendal Grignou wrote:
> >
> > In any case, I guess that unless there are other ideas we can do these patches:
> >
> > 1.) f2fs patch to start checking the name, as above
> > 2.) patch to start encoding last 32 bytes of the name (or second-to-last CTS
> >     block, I haven't decided yet) rather than last 16 bytes, changing
> >     fs/crypto/, fs/ext4/, and fs/f2fs/
> 
> Using second-to-last CTS block is CTS-CBC specific. If we use another
> method to encode filename (I am thinking of HEH,
> http://www.mail-archive.com/linux-crypto@vger.kernel.org/msg21826.html)
> that may not work anymore.
> We don't have to use the last 32 bytes: using for instance the last 24
> should be good enough, the escape rate will be 1/2^64 instead 1/2^128.
> 

The thing is, even using the last N bytes is depending on the encryption
algorithm.  The only way to make it work for arbitrary algorithms would be to
use a cryptographic hash like SHA-256 --- which actually seems to have been the
original design, but apparently it got changed at some point.  (I guess so that
hashes wouldn't have to be computed in so many places, and taking advantage of
the encryption should be sufficient.)

HEH is not a problem because it's a strong pseudorandom permutation, so any
choice of bytes from the ciphertext is equally good for it.

We can always change this later if different algorithms are added, or even make
different algorithms choose different bytes.

So I think I'm leaning towards making it use the second-to-last block, rather
than the last 32 bytes.

Eric
