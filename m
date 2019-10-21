Return-Path: <SRS0=zM1H=YO=mit.edu=tytso@kernel.org>
Date: Mon, 21 Oct 2019 15:30:19 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [xfstests-bld PATCH] test-appliance: add ext4/encrypt_1k test
 config
Message-ID: <20191021193019.GI27850@mit.edu>
References: <20191016221552.299566-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191016221552.299566-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, Chandan Rajendra <chandan@linux.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Oct 16, 2019 at 03:15:52PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add a test configuration to allow testing ext4 encryption with 1k
> blocks, which kernel patches have been proposed to support.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
