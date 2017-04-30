Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:33810 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165770AbdD3GQf (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 30 Apr 2017 02:16:35 -0400
Date: Sun, 30 Apr 2017 02:16:33 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [v2] fscrypt: Move key structure and constants to uapi
Message-ID: <20170430061633.xb5i54g2ftxbwtij@thunk.org>
References: <20170406231405.153919-1-joerichey94@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170406231405.153919-1-joerichey94@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Joe Richey <joerichey94@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-api@vger.kernel.org, Richard Weinberger <richard.weinberger@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Joe Richey <joerichey@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Apr 06, 2017 at 04:14:05PM -0700, Joe Richey wrote:
> From: Joe Richey <joerichey@google.com>
> 
> This commit exposes the necessary constants and structures for a
> userspace program to pass filesystem encryption keys into the keyring.
> The fscrypt_key structure was already part of the kernel ABI, this
> change just makes it so programs no longer have to redeclare these
> structures (like e4crypt in e2fsprogs currently does).
> 
> Note that we do not expose the other FS_*_KEY_SIZE constants as they are
> not necessary. Only XTS is supported for contents_encryption_mode, so
> currently FS_MAX_KEY_SIZE bytes of key material must always be passed to
> the kernel.
> 
> This commit also removes __packed from fscrypt_key as it does not
> contain any implicit padding and does not refer to an on-disk structure.
> 
> Signed-off-by: Joe Richey <joerichey@google.com>

Thanks, applied.

					- Ted
