Return-Path: <ebiggers3@gmail.com>
Date: Thu, 13 Jul 2017 15:58:38 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 1/6] fscrypt: add v2 encryption context and policy
Message-ID: <20170713225838.GA73286@gmail.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-2-ebiggers3@gmail.com>
 <20170713222944.GA23111@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170713222944.GA23111@google.com>
To: Michael Halcrow <mhalcrow@google.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Michael,

On Thu, Jul 13, 2017 at 03:29:44PM -0700, Michael Halcrow wrote:
> On Wed, Jul 12, 2017 at 02:00:30PM -0700, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Currently, the fscrypt_context (i.e. the encryption xattr) does not
> > contain a cryptographically secure identifier for the master key's
> > payload.  Therefore it's not possible to verify that the correct key was
> > supplied, which is problematic in multi-user scenarios.  To make this
> > possible, define a new fscrypt_context version (v2) which includes a
> > key_hash field, and allow userspace to opt-in to it when setting an
> > encryption policy by setting fscrypt_policy.version to 2.  For now just
> > zero the new field; a later patch will start setting it for real.
> 
> The main concern that comes to mind is potentially blowing past the
> inline xattr size limit and allocating a new inode block.  The
> security benefit probably outweighs that concern in this case.
> 

The way it adds up now for ext4 is:

128 bytes for base inode
+ 32 bytes for i_extra fields
+ 4 bytes for in-inode xattrs header
+ 20 bytes for encryption xattr header + name
+ 28 bytes for encryption xattr value
----------------------------------
= 212 bytes total.

By adding the 16-byte 'key_hash' field it grows to 228 bytes total.  So it still
fits in a 256-byte inode, though it's getting closer to the limit.  We could
save 8 bytes by instead using the design where master_key_descriptor is extended
to 16 bytes and redefined as a cryptographically secure hash.  But as noted,
that has some significant disadvantages.

Also note that we don't really have to worry about leaving space for a SELinux
xattr anymore because with 256-byte inodes + encryption the SELinux xattr is
already being written to an external block, given that it requires about 52-62
bytes (at least when using Android's SELinux policy; different SELinux policies
may use different values), and 212 + 52 > 256.  So if someone wants both xattrs
in-inode they need to use 512-byte inodes already.

Eric
