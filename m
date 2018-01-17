Return-Path: <richard.weinberger@gmail.com>
MIME-Version: 1.0
In-Reply-To: <2774377.VZm18AqBqi@blindfold>
References: <20171129204317.91205-1-ebiggers3@gmail.com> <20180105183744.GA44929@gmail.com>
 <2774377.VZm18AqBqi@blindfold>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Wed, 17 Jan 2018 22:12:27 +0100
Message-ID: <CAFLxGvzGeMkm_1HhcFDe4twTGsVHaXvjoM6GezxtCNW+NZw84Q@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] ubifs: switch to new fscrypt helper functions
Content-Type: text/plain; charset="UTF-8"
To: Richard Weinberger <richard@nod.at>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, linux-mtd@lists.infradead.org, Adrian Hunter <adrian.hunter@intel.com>, Artem Bityutskiy <dedekind1@gmail.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jan 5, 2018 at 11:11 PM, Richard Weinberger <richard@nod.at> wrote:
> Eric,
>
> Am Freitag, 5. Januar 2018, 19:37:44 CET schrieb Eric Biggers:
>> On Wed, Nov 29, 2017 at 12:43:12PM -0800, Eric Biggers wrote:
>> > From: Eric Biggers <ebiggers@google.com>
>> >
>> > This series switches ubifs to use the fscrypt helper functions for
>> > open/link/rename/lookup/setattr introduced in v4.15.
>> >
>> > These patches were originally sent in "[PATCH 00/25] fscrypt: add some
>> > higher-level helper functions".  I've rebased them onto v4.15-rc1.
>> >
>> > Eric Biggers (5):
>> >   ubifs: switch to fscrypt_file_open()
>> >   ubifs: switch to fscrypt_prepare_link()
>> >   ubifs: switch to fscrypt_prepare_rename()
>> >   ubifs: switch to fscrypt_prepare_lookup()
>> >   ubifs: switch to fscrypt_prepare_setattr()
>> >
>> >  fs/ubifs/dir.c  | 43 +++++++++++++------------------------------
>> >  fs/ubifs/file.c | 41 ++++-------------------------------------
>> >  2 files changed, 17 insertions(+), 67 deletions(-)
>>
>> Richard, can you take these for UBIFS for v4.16?
>
> Yes. Thanks a lot for cleaning this up.

FYI, this series has merge conflicts with other fscrypt related
changes that went via Ted into fs/ubifs.

-- 
Thanks,
//richard
