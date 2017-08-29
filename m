Return-Path: <anand.jain@oracle.com>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9a86b7af-5e07-9b6f-958a-bd72ab28926e@oracle.com>
 <20170822025545.GA3577@zzz.localdomain>
 <7d4a9f66-7473-2e36-09bb-79d7885301bd@oracle.com>
 <20170822170720.GA9587@gmail.com>
 <9e3f608d-5410-b8f7-cdf0-93045be7a995@oracle.com>
 <20170828142225.5qr5sasarjqps64m@thunk.org>
From: Anand Jain <anand.jain@oracle.com>
Message-ID: <93100bd1-d4f7-3e4f-0e4a-6f8bb2787b6f@oracle.com>
Date: Tue, 29 Aug 2017 11:54:47 +0800
MIME-Version: 1.0
In-Reply-To: <20170828142225.5qr5sasarjqps64m@thunk.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Theodore Ts'o <tytso@mit.edu>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>




>>> If *no* applications care whether the filenames are encrypted or not, sure.
>>> But are you absolutely sure that no applications care?  How do you know?  And what
>>> is the advantage of not encrypting the filenames anyway?  It is better to
>>> encrypt by default.
>>>
>>   File-name is a kind of File-system semantic and altering based on the on
>> the user key context does not guarantee the system will be compatible with
>> all their legacy applications.
> 
> In theory we could make it optional whether or not file names are
> encrypted.  But that means extra complexity, and extra complexity
> means potential bugs and vulnerabilities --- both potential
> implementation bugs, vulnerabilities caused by users getting confused
> by how they configure the system settings.  So in general with
> security systems it's better to limit the complexity to the bare
> minimum.

  That's right from the dev perspective. But for every security fix 
there is a convenience that is being sacrificed by the user. Providing a 
security fix even if there is no threat just adds pain to the 
user/solution and nothing else. Of course it all depends on the use case.


  BTRFS has an experimental fscrypt implementation[1] which does not 
include the file-name encryption part it should be included but as an 
optional since not all uses cases saves sensitive information in the 
file-name. OR even if the attacker is able to identify a file called 
secrete.txt and break it then its still points at the weakness of the 
file-data encryption. Can we say that ? apparently from the discussion 
here it seems the answer is yes.

  [1]
    Kernel: https://github.com/asj/linux-btrfs-fscryptv1



> The only case which you've come up with in terms of potential
> vulnerabilities is backup and restore, and backup and restore is
> complicated for a number of numbers, since you need to be able to
> backup and restore not just the file name and the encrypted data
> blocks, but also the encrypted per-file key.

>  So getting this right
> will almost certainly require that the backup/restore software be
> fscrypt aware.

  Not necessarily, as below..

> Hence, making the encryption of the filenames optional doesn't just to
> make life easier for backup/restore isn't a compelling argument, since
> the backup/restore program is going to have to have special case
> handling for fscrypt protected file systems *anyway*.

  fscrypt backup and restore does not work even without file-name 
encryption because the Extended Attribute needs special ioctl in the 
fscrypt (I did rise this objection before).

  But its entirely possible to create a string based encryption metadata 
which can be updated/retrieved using the legacy backup tools such as

   rsync --xattrs

  That will be a design for fscryptv2 probably..

  OR I mean to say possible optional file-name encryption is not the 
ground reason for the encrypted backup and restore challenge.

Thanks, Anand

> Cheers,
> 
> 					- Ted
