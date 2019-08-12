Return-Path: <SRS0=c04+=WI=mit.edu=tytso@kernel.org>
Date: Mon, 12 Aug 2019 18:53:51 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v8 08/20] fscrypt: rename keyinfo.c to keysetup.c
Message-ID: <20190812225351.GG28705@mit.edu>
References: <20190805162521.90882-1-ebiggers@kernel.org>
 <20190805162521.90882-9-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805162521.90882-9-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, linux-api@vger.kernel.org, Satya Tangirala <satyat@google.com>, Paul Crowley <paulcrowley@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 05, 2019 at 09:25:09AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Rename keyinfo.c to keysetup.c since this better describes what the file
> does (sets up the key), and it matches the new file keysetup_v1.c.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, you can add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>
