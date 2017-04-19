Return-Path: <richard.weinberger@gmail.com>
MIME-Version: 1.0
In-Reply-To: <20170418230136.GA96152@gmail.com>
References: <20170418210642.6039-1-gwendal@chromium.org> <20170418230136.GA96152@gmail.com>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Wed, 19 Apr 2017 15:40:13 +0200
Message-ID: <CAFLxGvwtFQW=NL3NrNHx-vWR3wSUtewnBRy1XzMqRNTV8f5vwQ@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: use 32 bytes of encrypted filename
Content-Type: text/plain; charset=UTF-8
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, kinaba@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

Eric,

On Wed, Apr 19, 2017 at 1:01 AM, Eric Biggers <ebiggers3@gmail.com> wrote:
> +Cc linux-f2fs-devel@lists.sourceforge.net
> +Cc linux-mtd@lists.infradead.org (for ubifs)
>
> Hi Gwendal,
>
> On Tue, Apr 18, 2017 at 02:06:42PM -0700, Gwendal Grignou wrote:
>> If we use only 16 bytes, due to how CBC works, if the names have the
>> same beginning, their last ciphertext block (16 bytes) may be identical.
>>
>> It happens when two file names share the first 16k bytes and both have
>> length withn 16 * n + 13 and 16 * n + 16.
>>
>> Instead use 32 bytes to build the filenames from encrypted data when
>> directory is scrambled.
>
> Just some background for people who may be unfamiliar with what's going on here
> (and it may be useful to include some of this in the patch description):
>
> When accessing files without access to the key, userspace needs to operate on a
> filename derived from the ciphertext filename, which contains arbitrary bytes.
>
> But since it's supported to use filenames up to FILENAME_MAX (255 bytes) in
> length when using encryption, we can't always base-64 encode the filename, since
> that may make it too long.
>
> The way this is solved currently is that for filenames with ciphertext length
> greater than 32 bytes, the filesystem provides an 8-byte "cookie" (split into
> 'hash' and 'minor_hash'), which along with the last 16 bytes of the filename
> ciphertext is base-64 encoded into a fixed-length name.  The filesystem returns
> this on readdir.  Then, when a lookup is done, the filesystem translates this
> info back into a specific directory entry.
>
> Since ext4 directory entries do not contain a hash field, ext4 relies only on
> the 16 bytes of ciphertext to distinguish collisions within a directory block.
> Unfortunately, this is broken because with the encryption mode used for
> filenames (CTS), the ciphertext of the last 16-byte block depends only on the
> plaintext up to and including the *second to last* block, not up to the last
> block.  This causes long filenames that differ just near the end to collide.
>
> We could fix this by using the second to last block of ciphertext rather than
> the last one.  However, using the last *two* blocks as you're proposing should
> be fine too.
>
> Of course we could also hash the filename's ciphertext with SHA-256 or
> something, but it's nice to take advantage of the encryption mode, and not have
> to do yet another hash.
>
> I am not too worried about changing the way encrypted filenames are presented,
> since applications are not supposed to rely on this.  (Though we probably should
> be doing something to catch broken applications, like encoding the filenames
> slightly differently after each reboot...)
>
> Strangely, f2fs and ubifs do not use the bytes from the filename at all when
> trying to find a specific directory entry in this case.  So this patch doesn't
> really affect them.  This seems unreliable; perhaps we should introduce a
> function like "fscrypt_name_matches()" which all the filesystems could call?
> Can any of the f2fs and ubifs developers explain why they don't look at any
> bytes from the filename?

Not sure if I understand you correctly, but for long filenames UBIFS
does a lookup
by hash/cookie, not by filename.

-- 
Thanks,
//richard
