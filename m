Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:38435 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752498AbeFEUWx (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Jun 2018 16:22:53 -0400
MIME-Version: 1.0
References: <20180605150751.GA9436@thunk.org>
In-Reply-To: <20180605150751.GA9436@thunk.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 5 Jun 2018 13:22:41 -0700
Message-ID: <CA+55aFxt4968GaU_q+e+D5KhGLGOjvHoZwRF0FKn_mHe4zx=Wg@mail.gmail.com>
Subject: Re: [GIT PULL] fscrypt updates for 4.18
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Theodore Ts'o <tytso@mit.edu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jun 5, 2018 at 8:07 AM Theodore Y. Ts'o <tytso@mit.edu> wrote:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt_for_linus

That tag actually points to the same commit as the 'ext4_for_linus'
tag pointed to.

You have the tag *message* for fscrypt, but then the commit it points
to has nothing to do with fscrypt.

I think you tagged the wrong branch.

(This can also be seen in the diffstat and the shortlog - they are
describing the ext4 changes).

                Linus
