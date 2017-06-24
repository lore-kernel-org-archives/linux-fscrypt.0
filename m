Return-Path: <tytso@thunk.org>
Date: Fri, 23 Jun 2017 20:09:57 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v5] fscrypt: Add support for AES-128-CBC
Message-ID: <20170624000956.s3kpirtcz44ss36z@thunk.org>
References: <5565BD72-986F-4338-8562-6B5F9FB72110@sigma-star.at>
 <20170619072758.8608-1-david@sigma-star.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170619072758.8608-1-david@sigma-star.at>
To: David Gstir <david@sigma-star.at>
Cc: jaegeuk@kernel.org, ebiggers3@gmail.com, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Daniel Walter <dwalter@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jun 19, 2017 at 09:27:58AM +0200, David Gstir wrote:
> From: Daniel Walter <dwalter@sigma-star.at>
> 
> fscrypt provides facilities to use different encryption algorithms which
> are selectable by userspace when setting the encryption policy. Currently,
> only AES-256-XTS for file contents and AES-256-CBC-CTS for file names are
> implemented. This is a clear case of kernel offers the mechanism and
> userspace selects a policy. Similar to what dm-crypt and ecryptfs have.
> 
> This patch adds support for using AES-128-CBC for file contents and
> AES-128-CBC-CTS for file name encryption. To mitigate watermarking
> attacks, IVs are generated using the ESSIV algorithm. While AES-CBC is
> actually slightly less secure than AES-XTS from a security point of view,
> there is more widespread hardware support. Using AES-CBC gives us the
> acceptable performance while still providing a moderate level of security
> for persistent storage.
> 
> Especially low-powered embedded devices with crypto accelerators such as
> CAAM or CESA often only support AES-CBC. Since using AES-CBC over AES-XTS
> is basically thought of a last resort, we use AES-128-CBC over AES-256-CBC
> since it has less encryption rounds and yields noticeable better
> performance starting from a file size of just a few kB.
> 
> Signed-off-by: Daniel Walter <dwalter@sigma-star.at>
> [david@sigma-star.at: addressed review comments]
> Signed-off-by: David Gstir <david@sigma-star.at>
> Reviewed-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
