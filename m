Return-Path: <tytso@thunk.org>
Date: Fri, 5 Jan 2018 21:49:44 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v2 05/11] fscrypt: split fscrypt_dummy_context_enabled()
 into supp/notsupp versions
Message-ID: <20180106024944.GA2404@thunk.org>
References: <20180105184502.48473-1-ebiggers3@gmail.com>
 <20180105184502.48473-6-ebiggers3@gmail.com>
 <20180105204009.GA72343@jaegeuk-macbookpro.roam.corp.google.com>
 <20180105211839.GB44929@gmail.com>
 <20180105213608.GB72343@jaegeuk-macbookpro.roam.corp.google.com>
 <20180105220149.GD44929@gmail.com>
 <20180106003950.GC72343@jaegeuk-macbookpro.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180106003950.GC72343@jaegeuk-macbookpro.roam.corp.google.com>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jan 05, 2018 at 04:39:50PM -0800, Jaegeuk Kim wrote:
> 
> Agreed that dummy'd be easy to go for now tho, doesn't it give any security
> concern at all, even only for ext4 testing purpose? Is there a chance to hack
> the mount option in runtime? BTW, it may be doable to build an encrypt root
> inode having encrypted dentry of lost_found, given dummy_context in mke2fs.
> I'm just curious whether or not it'd be worth to do.

It requires root to manipulate the mount option; and if you don't
trust root, you've got other problems.

The problem is that e2fsck needs to be able to repair a file system
without having access to any of the file system keys.  And so if there
is an orphaned inode (e.g., an inode which is not attached to any
directory), we need to put it somewhere, and that's /lost+found.

I've considered making lost+found a magic directory which isn't
directly linked into the root directory, and have a magic namei
lookup.  There are downsides though; that would mean that the
/lost+found filename has to be magic --- what to do if the user tries
to create a lost+found directory, or rename the magic lost+found
directory.

Ultimately, i decided it wasn't worth the semantic and
implementational complexity, especially since none of the primary use
cases (Android, Chromeos, etc.) needed an encrypted root directory.

      			  	       	  	    - Ted
