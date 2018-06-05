Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35852 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751687AbeFEPNh (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Jun 2018 11:13:37 -0400
MIME-Version: 1.0
In-Reply-To: <20180605150751.GA9436@thunk.org>
References: <20180605150751.GA9436@thunk.org>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Tue, 5 Jun 2018 17:13:35 +0200
Message-ID: <CAFLxGvysjYbCpkqbVqD8Q1v3isGnRrNo5KdUn7TgCVt9WxzE2g@mail.gmail.com>
Subject: Re: [GIT PULL] fscrypt updates for 4.18
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Ted,

On Tue, Jun 5, 2018 at 5:07 PM, Theodore Y. Ts'o <tytso@mit.edu> wrote:
> The following changes since commit 75bc37fefc4471e718ba8e651aa74673d4e0a9eb:
>
>   Linux 4.17-rc4 (2018-05-06 16:57:38 -1000)
>
> are available in the Git repository at:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt_for_linus
>
> for you to fetch changes up to 4f2f76f751433908364ccff82f437a57d0e6e9b7:
>
>   ext4: fix fencepost error in check for inode count overflow during resize (2018-05-25 12:51:25 -0400)
>
> ----------------------------------------------------------------
> Add bunch of cleanups, and add support for the Speck128/256
> algorithms.  Yes, Speck is contrversial, but the intention is to use
> them only for the lowest end Android devices, where the alternative
> *really* is no encryption at all for data stored at rest.

Will Android tell me that Speck is being used?

-- 
Thanks,
//richard
