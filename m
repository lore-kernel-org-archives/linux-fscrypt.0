Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:33826 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165770AbdD3GQt (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 30 Apr 2017 02:16:49 -0400
Date: Sun, 30 Apr 2017 02:16:46 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [v2] fscrypt: Remove __packed from fscrypt_policy
Message-ID: <20170430061646.6ereidy5rk4wzso5@thunk.org>
References: <20170406231428.154187-1-joerichey94@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170406231428.154187-1-joerichey94@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Joe Richey <joerichey94@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-api@vger.kernel.org, Richard Weinberger <richard.weinberger@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Joe Richey <joerichey@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Apr 06, 2017 at 04:14:28PM -0700, Joe Richey wrote:
> From: Joe Richey <joerichey@google.com>
> 
> This commit removes __packed from fscrypt_policy as it does not contain
> any implicit padding and does not refer to an on-disk structure. Even
> though this is a change to a UAPI file, no users will be broken as the
> structure doesn't change.
> 
> Signed-off-by: Joe Richey <joerichey@google.com>

Thanks, applied.

					- Ted
