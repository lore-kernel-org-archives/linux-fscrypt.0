Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.sigma-star.at ([95.130.255.111]:45996 "EHLO
        mail.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2998237AbdDZLsN (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 26 Apr 2017 07:48:13 -0400
Subject: Re: [PATCH] ubifs: Return -ENOKEY from rename if encryption keys are
 missing
References: <1493070381-20075-1-git-send-email-richard@nod.at>
 <20170425175442.GB41477@google.com>
From: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
Message-ID: <1f759fee-337f-903a-0eb0-5b364cd35e6f@sigma-star.at>
Date: Wed, 26 Apr 2017 13:48:10 +0200
MIME-Version: 1.0
In-Reply-To: <20170425175442.GB41477@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>, Richard Weinberger <richard@nod.at>
Cc: linux-mtd@lists.infradead.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, david@sigma-star.at
List-ID: <linux-fscrypt@vger.kernel.org>

On 04/25/2017 07:54 PM, Eric Biggers wrote:
> Did you test that this change actually does anything?  Unlike ext4 and f2fs,
> ubifs calls fscrypt_setup_filename() from its rename methods rather than through
> a helper function ${FS}_find_entry().  Therefore it's able to pass in lookup=0,
> which means that the key is required.  So it should already be failing with
> ENOKEY.  You can verify this by running xfstests generic/419.

Actually, running xfstests was how this cropped up in the first place.

The UBIFS rename and xrename functions allready call
fscrypt_setup_filename with lookup=0, however there are other tests
before that call and moving them around causes generic/419 to fail
at a different place where EPERM was expected.

Therefore I concluded that the safest way to fix this might be to
simply copy the way the checks are handled in ext4.

With recent xfstests + UBIFS support patch, after applying this patch,
generic/419 passes.


David
