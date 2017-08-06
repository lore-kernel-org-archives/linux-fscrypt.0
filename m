Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34084 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751338AbdHFTjY (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 6 Aug 2017 15:39:24 -0400
MIME-Version: 1.0
In-Reply-To: <20170806192703.5xelufkwd2a4jkha@thunk.org>
References: <20170806192703.5xelufkwd2a4jkha@thunk.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 6 Aug 2017 12:39:23 -0700
Message-ID: <CA+55aFz+_-KRuOHRrOaaTYGcUgWtn4aFm=C4sUCtGRs8BBgJMw@mail.gmail.com>
Subject: Re: [GIT PULL] ext4 bug fixes for 4.13
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Theodore Ts'o <tytso@mit.edu>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Aug 6, 2017 at 12:27 PM, Theodore Ts'o <tytso@mit.edu> wrote:
>
> A large number of ext4 bug fixes and cleanups for v4.13

A couple of these appear to be neither cleanups nor fixes. And a lot
of them appear to be very recent.

I've pulled this, but if I hear about problems, ext4 is going to be on
my shit-list, and you'd better be a *lot* more careful about pull
requests. Because this is not ok.

                    Linus
