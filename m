Return-Path: <ebiggers3@gmail.com>
Date: Fri, 8 Dec 2017 13:42:13 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
Message-ID: <20171208214213.GA104193@gmail.com>
References: <20171208013838.105034-1-ebiggers3@gmail.com>
 <CAHmME9ob8eG1yS=jkGHFnYDq+FtiJCP38CKpzUs0Z33R8_0Msw@mail.gmail.com>
 <CAKv+Gu85X5OZWhwQxNrc8RonPL3XdRhzK=JeWcWXLu=8KUsQAg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu85X5OZWhwQxNrc8RonPL3XdRhzK=JeWcWXLu=8KUsQAg@mail.gmail.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, Martin Willi <martin@strongswan.org>, David Gstir <david@sigma-star.at>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Dec 08, 2017 at 07:20:43AM +0000, Ard Biesheuvel wrote:
> On 8 December 2017 at 02:51, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> > Hi Eric,
> >
> > Nice to see more use of ChaCha20. However...
> >
> > Can we skip over the "sort of worse than XTS, but not having _real_
> > authentication sucks anyway in either case, so whatever" and move
> > directly to, "linux finally supports authenticated encryption for disk
> > encryption!"?
> 
> Ehm, it doesn't? This is plain ChaCha20, not any AEAD variant.
> 
> > This would be a big deal and would actually be a
> > noticeable security improvement, instead of a potentially dubious step
> > sidewaysbackish.
> >
> 
> It is actually dubious, given the large scale reuse of IVs with a
> stream cipher. I do suppose though that using an AEAD variant would at
> least catch any attacks involving flipping ciphertext bits resulting
> in plaintext bits being flipped at the same offset (but file updates
> would still be visible in the clear)
> 

It *is* dubious, but it would be a replacement for No Encryption, not a
replacement for AES.  AES would continue to be required on devices that can do
AES fast enough.  This would only be for devices that do not meet the AES
performance bar, so their status quo is No Encryption.  I know, it is fun to
poke holes in bad crypto, but much less interesting to poke holes in "no crypto"
:-)

We can't use authenticated encryption for the same reason we can't use random or
sequential nonces: there is nowhere to store the additional metadata
(authentication tag and nonce) per filesystem block *and* have it updated
atomically with respect to the contents of said block.  Copy-on-write
filesystems such as btrfs or bcachefs can do it.  Traditional filesystems
cannot.  F2FS comes closer than EXT4 since F2FS is based on a log-structured
filesystem, but only partially; for one, it still updates data in-place
sometimes.  This is not a new problem; this is also the reason why we haven't
been able to add AES-GCM support yet.

Authentication aside, the greater problem here is the IV reuse.  Unfortunately
it actually will likely be even worse than we thought originally, because this
would be used on flash storage that does wear leveling, and likely also with
F2FS which often doesn't overwrite data in-place.  So even under the "single
point-in-time permanent offline compromise" threat model it may not be good
enough.  We are going to spend some more time investigating alternatives, but
unfortunately there are not many.

Eric
