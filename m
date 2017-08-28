Return-Path: <tytso@thunk.org>
Date: Mon, 28 Aug 2017 10:22:25 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
Message-ID: <20170828142225.5qr5sasarjqps64m@thunk.org>
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9a86b7af-5e07-9b6f-958a-bd72ab28926e@oracle.com>
 <20170822025545.GA3577@zzz.localdomain>
 <7d4a9f66-7473-2e36-09bb-79d7885301bd@oracle.com>
 <20170822170720.GA9587@gmail.com>
 <9e3f608d-5410-b8f7-cdf0-93045be7a995@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e3f608d-5410-b8f7-cdf0-93045be7a995@oracle.com>
To: Anand Jain <anand.jain@oracle.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 28, 2017 at 08:18:46PM +0800, Anand Jain wrote:
> > If *no* applications care whether the filenames are encrypted or not, sure.
> > But are you absolutely sure that no applications care?  How do you know?  And what
> > is the advantage of not encrypting the filenames anyway?  It is better to
> > encrypt by default.
> > 
>  File-name is a kind of File-system semantic and altering based on the on
> the user key context does not guarantee the system will be compatible with
> all their legacy applications.

In theory we could make it optional whether or not file names are
encrypted.  But that means extra complexity, and extra complexity
means potential bugs and vulnerabilities --- both potential
implementation bugs, vulnerabilities caused by users getting confused
by how they configure the system settings.  So in general with
security systems it's better to limit the complexity to the bare
minimum.

The only case which you've come up with in terms of potential
vulnerabilities is backup and restore, and backup and restore is
complicated for a number of numbers, since you need to be able to
backup and restore not just the file name and the encrypted data
blocks, but also the encrypted per-file key.  So getting this right
will almost certainly require that the backup/restore software be
fscrypt aware.

Hence, making the encryption of the filenames optional doesn't just to
make life easier for backup/restore isn't a compelling argument, since
the backup/restore program is going to have to have special case
handling for fscrypt protected file systems *anyway*.

Cheers,

					- Ted
