Return-Path: <ebiggers3@gmail.com>
Date: Mon, 21 Aug 2017 19:55:45 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
Message-ID: <20170822025545.GA3577@zzz.localdomain>
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9a86b7af-5e07-9b6f-958a-bd72ab28926e@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9a86b7af-5e07-9b6f-958a-bd72ab28926e@oracle.com>
To: Anand Jain <anand.jain@oracle.com>
Cc: linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Aug 22, 2017 at 10:22:30AM +0800, Anand Jain wrote:
> 
> Hi Eric,
> 
>   How about a section on the threat model specific to the file-name ?
> 
>   (Sorry if I am missing something).
> 
> Thanks, Anand

It's already mentioned that filenames are encrypted: "fscrypt protects the
confidentiality of file contents and filenames in the event of a single
point-in-time permanent offline compromise of the block device content."
There's not much more to it than that; all the other points in the "Threat
model" section (offline manipulations, timing attacks, access control, key
eviction, etc.) are essentially the same between contents and filenames
encryption.

Eric
