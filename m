Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:37694 "EHLO
        bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727489AbfCNXPO (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 14 Mar 2019 19:15:14 -0400
Message-ID: <1552605311.2571.6.camel@HansenPartnership.com>
Subject: Re: [PATCH 4/4] ubifs: Implement new mount option,
 fscrypt_key_required
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 14 Mar 2019 16:15:11 -0700
In-Reply-To: <20190314171559.27584-5-richard@nod.at>
References: <CAJfpegvX4ANfso-Jn1zaB+m4Q_0eK9i-+MCJ+sTH5QzD3PZFMQ@mail.gmail.com>
         <20190314171559.27584-1-richard@nod.at>
         <20190314171559.27584-5-richard@nod.at>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Richard Weinberger <richard@nod.at>, linux-mtd@lists.infradead.org
Cc: linux-fscrypt@vger.kernel.org, jaegeuk@kernel.org, tytso@mit.edu, linux-unionfs@vger.kernel.org, miklos@szeredi.hu, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, paullawrence@google.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, 2019-03-14 at 18:15 +0100, Richard Weinberger wrote:
> Usually fscrypt allows limited access to encrypted files even
> if no key is available.
> Encrypted filenames are shown and based on this names users
> can unlink and move files.

Shouldn't they be able to read/write and create as well (all with the
ciphertext name and contents, of course) ... otherwise how does backup
of encrypted files by admin without the key ever work?

James
