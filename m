Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from lithops.sigma-star.at ([195.201.40.130]:49404 "EHLO
        lithops.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726691AbfCMUdO (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 13 Mar 2019 16:33:14 -0400
From: Richard Weinberger <richard@nod.at>
Subject: Re: overlayfs vs. fscrypt
Date: Wed, 13 Mar 2019 21:33:10 +0100
Message-ID: <15244624.W7e5yEypHC@blindfold>
In-Reply-To: <CAOQ4uxhqQKzriL0An4Tvzc1E_LffL-z9q1otOW_RdD1ZdKWP3Q@mail.gmail.com>
References: <4603533.ZIfxmiEf7K@blindfold> <4066872.KGdO14EQMx@blindfold> <CAOQ4uxhqQKzriL0An4Tvzc1E_LffL-z9q1otOW_RdD1ZdKWP3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Amir Goldstein <amir73il@gmail.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Lawrence <paullawrence@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Am Mittwoch, 13. M�rz 2019, 15:26:54 CET schrieb Amir Goldstein:
> IMO, the best thing for UBIFS to do would be to modify fscrypt to support
> opting out of the revalidate behavior, IWO, sanitize your hack to an API.

Given the WTF/s rate this thread has, this might me a good option.
Actually people already asked me how to disable this feature because
they saw no use of it.
Being able to delete encrypted files looks good on the feature list but in
reality it has very few users but causes confusion, IMHO.

I propose a new fscrypt_operations flag, FS_CFLG_NO_CRYPT_FNAMES.
If this flag is set, a) fscrypt_setup_filename() will return -EPERM if
no key is found.
And b) __fscrypt_prepare_lookup() will not attach fscrypt_d_ops to the dentry.

Eric, what do you think?

Thanks,
//richard
