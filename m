Return-Path: <SRS0=mLUp=WJ=mit.edu=tytso@kernel.org>
Date: Mon, 12 Aug 2019 20:49:27 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v8 20/20] fscrypt: document the new ioctls and policy
 version
Message-ID: <20190813004927.GL28705@mit.edu>
References: <20190805162521.90882-1-ebiggers@kernel.org>
 <20190805162521.90882-21-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805162521.90882-21-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, linux-api@vger.kernel.org, Satya Tangirala <satyat@google.com>, Paul Crowley <paulcrowley@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 05, 2019 at 09:25:21AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Update the fscrypt documentation file to catch up to all the latest
> changes, including the new ioctls to manage master encryption keys in
> the filesystem-level keyring and the support for v2 encryption policies.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, thanks!  Feel free to add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>
