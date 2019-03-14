Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from lilium.sigma-star.at ([109.75.188.150]:53354 "EHLO
        lilium.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727159AbfCNR2N (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 14 Mar 2019 13:28:13 -0400
From: Richard Weinberger <richard@nod.at>
Subject: [RFC] fscrypt_key_required mount option
Date: Thu, 14 Mar 2019 18:15:55 +0100
Message-Id: <20190314171559.27584-1-richard@nod.at>
In-Reply-To: <CAJfpegvX4ANfso-Jn1zaB+m4Q_0eK9i-+MCJ+sTH5QzD3PZFMQ@mail.gmail.com>
References: <CAJfpegvX4ANfso-Jn1zaB+m4Q_0eK9i-+MCJ+sTH5QzD3PZFMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org
Cc: linux-fscrypt@vger.kernel.org, jaegeuk@kernel.org, tytso@mit.edu, linux-unionfs@vger.kernel.org, miklos@szeredi.hu, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, paullawrence@google.com
List-ID: <linux-fscrypt@vger.kernel.org>

This series is an RFC, it outlines how an filesystem, in this case UBIFS,
could implement a mount option to disable filesystem operations on encrypted
files where no key is present.
The desired byproduct is that in this case ->d_revalidate() is not needed
anymore and VFS folks are in less fear about the dcache implications.

Thanks,
//richard

[PATCH 1/4] fscrypt: Implement FS_CFLG_OWN_D_OPS
[PATCH 2/4] fscrypt: Export fscrypt_d_ops
[PATCH 3/4] ubifs: Simplify fscrypt_get_encryption_info() error
[PATCH 4/4] ubifs: Implement new mount option, fscrypt_key_required
