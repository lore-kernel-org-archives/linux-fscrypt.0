Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from lithops.sigma-star.at ([195.201.40.130]:41950 "EHLO
        lithops.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725868AbfCMMro (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 13 Mar 2019 08:47:44 -0400
From: Richard Weinberger <richard@nod.at>
Subject: Re: overlayfs vs. fscrypt
Date: Wed, 13 Mar 2019 13:47:40 +0100
Message-ID: <1852545.qrIQg0rEWx@blindfold>
In-Reply-To: <CAJfpegsy31D+=VJ+By2a9TLCvZJwvAUpb+_bJ5JVTsmsbZJTKQ@mail.gmail.com>
References: <4603533.ZIfxmiEf7K@blindfold> <CAJfpegsy31D+=VJ+By2a9TLCvZJwvAUpb+_bJ5JVTsmsbZJTKQ@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-kernel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Am Mittwoch, 13. M�rz 2019, 13:36:02 CET schrieb Miklos Szeredi: 
> I don't get it.  Does fscrypt try to check permissions via
> ->d_revalidate?  Why is it not doing that via ->permission()?

Please let me explain. Suppose we have a fscrypto directory /mnt and
I *don't* have the key.

When reading the directory contents of /mnt will return an encrypted filename.
e.g.
# ls /mnt
+mcQ46ne5Y8U6JMV9Wdq2C

As soon I load my key the real name is shown and I can read the file contents too.
That's why fscrypt has ->d_revalidate(). It checks for the key, if the key is
still not here -> stay with the old encrypted name. If the key is present
-> reveal the real name.

Same happens on the other direction if I unlink my key from the keyring.

> >
> > 2. Teach overlayfs to deal with a upper that has ->d_revalidate().
> > Given the complexity of overlayfs I'm not sure how feasible this is.
> > But I'm no overlayfs expert, maybe I miss something.
> 
> I don't think it would be too complex.  But first I'd like to
> understand exactly why fscrypt is (ab) using d_revalidate().

I hope my answer makes things more clear.

Thanks,
//richard
