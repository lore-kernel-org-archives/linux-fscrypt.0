Return-Path: <richard@nod.at>
Subject: Re: [PATCH] fscrypt: use 32 bytes of encrypted filename
References: <20170418210642.6039-1-gwendal@chromium.org>
 <CAFLxGvz+kODD+8s9aPw_DeYtf3Gjv0aQBC=UfoBFx3Wn2b=wxQ@mail.gmail.com>
 <20170419170940.GA89688@gmail.com>
From: Richard Weinberger <richard@nod.at>
Message-ID: <bdda413c-1452-9e55-53ff-34eb17ef4c3b@nod.at>
Date: Wed, 19 Apr 2017 19:12:01 +0200
MIME-Version: 1.0
In-Reply-To: <20170419170940.GA89688@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Gwendal Grignou <gwendal@chromium.org>, Theodore Ts'o <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, kinaba@chromium.org, hashimoto@chromium.org, David Oberhollenzer <david.oberhollenzer@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

Eric,

Am 19.04.2017 um 19:09 schrieb Eric Biggers:
> Hi Richard,
> 
> On Wed, Apr 19, 2017 at 03:37:42PM +0200, Richard Weinberger wrote:
>>>
>>> Tested only on ext4.
>>
>> I hope you classify this patch as RFC then.
>> We'll have problems when you just develop and test for ext4. :-)
>>
> 
> It's a little difficult for people to test stuff on UBIFS without a turn-key
> solution like kvm-xfstests where they can just run something like
> 'kvm-xfstests -c ext4,f2fs,ubifs -g encrypt'.
> 
> I did post patches to add UBIFS support to xfstests and kvm-xfstests a few
> months ago; maybe you're interested in taking them over and working to get them
> merged?

I assigned this talk already to David.
He can tell what the status is.

>>> diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
>>> index c4a389a6027b..14b2a2335a32 100644
>>> --- a/fs/ext4/namei.c
>>> +++ b/fs/ext4/namei.c
>>> @@ -1257,8 +1257,8 @@ static inline int ext4_match(struct ext4_filename *fname,
>>>                         int ret;
>>>                         if (de->name_len < 16)
>>>                                 return 0;
>>> -                       ret = memcmp(de->name + de->name_len - 16,
>>> -                                    fname->crypto_buf.name + 8, 16);
>>> +                       ret = memcmp(de->name + de->name_len - 32,
>>> +                                    fname->crypto_buf.name + 8, 32);
>>>                         return (ret == 0) ? 1 : 0;
>>>                 }
>>>                 name = fname->crypto_buf.name;
>>
>> Can the code still be able to read filenames which have been encrypted
>> using the "old" scheme?
>>
> 
> The patch only changes the presentation of long encrypted filenames when
> accessed without the key.  It doesn't change how filenames are encrypted.

Thanks for pointing this out.

Thanks,
//richard
