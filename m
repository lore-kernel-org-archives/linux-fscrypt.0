Return-Path: <ebiggers3@gmail.com>
Date: Mon, 21 Aug 2017 16:08:21 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
Message-ID: <20170821230821.GB8847@gmail.com>
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9dcef6c6-a758-ea57-0d51-55f33e365931@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9dcef6c6-a758-ea57-0d51-55f33e365931@oracle.com>
To: Anand Jain <anand.jain@oracle.com>
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 21, 2017 at 09:44:11PM +0800, Anand Jain wrote:
> 
> 
> >+fscrypt is not guaranteed to protect confidentiality or authenticity
> >+if an attacker is able to manipulate the filesystem offline prior to
> >+an authorized user later accessing the filesystem.
> 
>  How does fscrypt / Android protect against Evil Maid attack. ?
> 
> Thanks, Anand

As Ted mentioned, it really depends on the type of attack.

If we assume that the attacker can *only* change the contents of disk, then
there is a protection against a specific type of attack.  Android has Verified
Boot, which verifies the integrity and authenticity of the kernel and the
'system' partition: https://source.android.com/security/verifiedboot/

>From there, the vold binary (which has been authenticated using dm-verity) is
able to unwrap the encryption keys (which are authenticated using AES-GCM), then
check that the encrypted directories have the correct encryption policies.  The
filesystem then enforces the one-policy-per-tree constraint, as described in my
proposed documentation:

    Except for those special files, it is forbidden to have unencrypted
    files, or files encrypted with a different encryption policy, in an
    encrypted directory tree.  Attempts to link or rename such a file into
    an encrypted directory will fail with EPERM.  This is also enforced
    during ->lookup() to provide limited protection against offline
    attacks that try to disable or downgrade encryption in known locations
    where applications may later write sensitive data.

So on Android, an "Evil Maid" attacker cannot simply replace an encrypted
directory with an unencrypted one, causing a program to write unencrypted files
to that directory.

_However_, an "Evil Maid" attacker can probably still do other, perhaps much
more effective attacks --- e.g. installing a hardware "key logger", or perhaps
installing a binary into /data in such a way that it gets auto-executed and
compromises the system after the user logs in.  Or they could attack the actual
file contents encryption which is not authenticated.  Or they could mess around
with filesystem metadata on the userdata partition, which is neither encrypted
nor authenticated.

I suppose that dm-integrity could be used to protect against some of those
attacks, but of course it would not protect against hardware key loggers, etc.

Eric
