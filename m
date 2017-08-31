Return-Path: <ebiggers3@gmail.com>
Date: Thu, 31 Aug 2017 11:10:15 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
Message-ID: <20170831181015.GC5023@gmail.com>
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9a86b7af-5e07-9b6f-958a-bd72ab28926e@oracle.com>
 <20170822025545.GA3577@zzz.localdomain>
 <7d4a9f66-7473-2e36-09bb-79d7885301bd@oracle.com>
 <20170822170720.GA9587@gmail.com>
 <9e3f608d-5410-b8f7-cdf0-93045be7a995@oracle.com>
 <20170828142225.5qr5sasarjqps64m@thunk.org>
 <93100bd1-d4f7-3e4f-0e4a-6f8bb2787b6f@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <93100bd1-d4f7-3e4f-0e4a-6f8bb2787b6f@oracle.com>
To: Anand Jain <anand.jain@oracle.com>
Cc: Theodore Ts'o <tytso@mit.edu>, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Anand,

On Tue, Aug 29, 2017 at 11:54:47AM +0800, Anand Jain wrote:
> 
>  BTRFS has an experimental fscrypt implementation[1] which does not
> include the file-name encryption part it should be included but as
> an optional since not all uses cases saves sensitive information in
> the file-name. OR even if the attacker is able to identify a file
> called secrete.txt and break it then its still points at the
> weakness of the file-data encryption. Can we say that ? apparently
> from the discussion here it seems the answer is yes.
> 

Filenames by themselves can be sensitive information, since a filename can serve
as a strong indicator of what a file is.  For example, a filename could be used
as evidence that a person had access to a certain document.

> >Hence, making the encryption of the filenames optional doesn't just to
> >make life easier for backup/restore isn't a compelling argument, since
> >the backup/restore program is going to have to have special case
> >handling for fscrypt protected file systems *anyway*.
> 
>  fscrypt backup and restore does not work even without file-name
> encryption because the Extended Attribute needs special ioctl in the
> fscrypt (I did rise this objection before).
> 
>  But its entirely possible to create a string based encryption
> metadata which can be updated/retrieved using the legacy backup
> tools such as
> 
>   rsync --xattrs
> 
>  That will be a design for fscryptv2 probably..
> 
>  OR I mean to say possible optional file-name encryption is not the
> ground reason for the encrypted backup and restore challenge.
> 

This was already discussed.  You cannot simply add and remove the encryption
xattr from random files and directories; what happens to all the open file
descriptors, memory maps, pagecache pages, dcache entries, etc.?  Are the
existing contents and directory entries supposed to be left unencrypted, or are
they supposed to be already encrypted, or is the filesystem supposed to
automatically encrypt them when the xattr is set?  What about when the xattr is
removed?  Again, you're of course free to propose a design which takes into
account all of this and makes the argument for adding an xattr-based API, but I
haven't seen it yet.

Eric
