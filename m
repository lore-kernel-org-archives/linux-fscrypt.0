Return-Path: <anand.jain@oracle.com>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9a86b7af-5e07-9b6f-958a-bd72ab28926e@oracle.com>
 <20170822025545.GA3577@zzz.localdomain>
From: Anand Jain <anand.jain@oracle.com>
Message-ID: <7d4a9f66-7473-2e36-09bb-79d7885301bd@oracle.com>
Date: Tue, 22 Aug 2017 23:33:51 +0800
MIME-Version: 1.0
In-Reply-To: <20170822025545.GA3577@zzz.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>



On 08/22/2017 10:55 AM, Eric Biggers wrote:
> On Tue, Aug 22, 2017 at 10:22:30AM +0800, Anand Jain wrote:
>>
>> Hi Eric,
>>
>>    How about a section on the threat model specific to the file-name ?
>>
>>    (Sorry if I am missing something).
>>
>> Thanks, Anand
> 
> It's already mentioned that filenames are encrypted: "fscrypt protects the
> confidentiality of file contents and filenames in the event of a single
> point-in-time permanent offline compromise of the block device content."
> There's not much more to it than that; all the other points in the "Threat
> model" section (offline manipulations, timing attacks, access control, key
> eviction, etc.) are essentially the same between contents and filenames
> encryption.

  Do you think if application does not keep the sensitive information in 
the file-name, would that remove the file-name from the list of items 
that should be protected ?

Thanks, Anand
