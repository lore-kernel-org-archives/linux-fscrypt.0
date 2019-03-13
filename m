Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:55162 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726263AbfCMW0N (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 13 Mar 2019 18:26:13 -0400
Date: Wed, 13 Mar 2019 15:26:11 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: overlayfs vs. fscrypt
Message-ID: <20190313222610.GF10169@gmail.com>
References: <4603533.ZIfxmiEf7K@blindfold>
 <4066872.KGdO14EQMx@blindfold>
 <CAOQ4uxhqQKzriL0An4Tvzc1E_LffL-z9q1otOW_RdD1ZdKWP3Q@mail.gmail.com>
 <15244624.W7e5yEypHC@blindfold>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <15244624.W7e5yEypHC@blindfold>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Cc: Amir Goldstein <amir73il@gmail.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Lawrence <paullawrence@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Mar 13, 2019 at 09:33:10PM +0100, Richard Weinberger wrote:
> Am Mittwoch, 13. M�rz 2019, 15:26:54 CET schrieb Amir Goldstein:
> > IMO, the best thing for UBIFS to do would be to modify fscrypt to support
> > opting out of the revalidate behavior, IWO, sanitize your hack to an API.
> 
> Given the WTF/s rate this thread has, this might me a good option.
> Actually people already asked me how to disable this feature because
> they saw no use of it.
> Being able to delete encrypted files looks good on the feature list but in
> reality it has very few users but causes confusion, IMHO.
> 
> I propose a new fscrypt_operations flag, FS_CFLG_NO_CRYPT_FNAMES.
> If this flag is set, a) fscrypt_setup_filename() will return -EPERM if
> no key is found.
> And b) __fscrypt_prepare_lookup() will not attach fscrypt_d_ops to the dentry.
> 
> Eric, what do you think?
> 
> Thanks,
> //richard
> 

What specifically is wrong with supporting the ciphertext "view" of encrypted
directories, and why do you want to opt UBIFS out of it specifically but not
ext4 and f2fs?  (The fscrypt_operations are per-filesystem type, not
per-filesystem instance, so I assume that's what you had in mind.)  Note that we
can't unconditionally remove it because people need it to delete files without
the key.  We could add a mount option to disable it, but why exactly?

By the way, I suggest that people read Documentation/filesystems/fscrypt.rst for
more information about what fscrypt is supposed to do, as there seems to be a
lot of misconceptions.

- Eric
