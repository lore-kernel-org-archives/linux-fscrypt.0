Return-Path: <david@fromorbit.com>
Date: Fri, 22 Sep 2017 06:48:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/25] fscrypt: add some higher-level helper functions
Message-ID: <20170921204814.GA7716@dastard>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
 <20170921064502.GR10621@dastard>
 <20170921174705.GA29643@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170921174705.GA29643@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Sep 21, 2017 at 10:47:05AM -0700, Eric Biggers wrote:
> Hi Dave,
> 
> On Thu, Sep 21, 2017 at 04:45:02PM +1000, Dave Chinner wrote:
> > fscrypto: clean up include file mess
> > 
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Filesystems have to include different header files based on whether
> > they are compiled with encryption support or not. That's nasty and
> > messy.
> > 
> > Instead, rationalise the headers so we have a single include
> > fscrypt.h and let it decide what internal implementation to include
> > based on the __FS_HAS_ENCRYPTION define. Filesystems set
> > __FS_HAS_ENCRYPTION before including linux/fscrypt.h if they are
> > built with encryption support.
> > 
> > Add guards to prevent fscrypt_supp.h and fscrypt_notsupp.h from
> > being directly included by filesystems.
> 
> This looks good; we probably should have done it that way originally.  This will
> allow us to have the inline functions like fscrypt_prepare_rename() defined in
> fscrypt.h, and then have supp/notsupp versions of __fscrypt_prepare_rename()
> instead --- so common checks like for IS_ENCRYPTED() will be in one place only.

*nod*

> One nit:
> 
> > +#ifdef CONFIG_EXT4_FS_ENCRYPTION
> > +#define __FS_HAS_ENCRYPTION 1
> > +#endif
> > +#include <linux/fscrypt.h>
> 
> How about doing
> 
> 	#define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_EXT4_FS_ENCRYPTION)
> 
> (and likewise for f2fs and ubifs), then checking '#if __FS_HAS_ENCRYPTION'
> rather than '#ifdef __FS_HAS_ENCRYPTION'?

Yeah, that's cleaner. I'll modify it and resend as a standalone
patch.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
