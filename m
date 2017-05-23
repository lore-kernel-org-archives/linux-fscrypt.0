Return-Path: <ebiggers3@gmail.com>
Date: Tue, 23 May 2017 12:00:41 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v4] fscrypt: Add support for AES-128-CBC
Message-ID: <20170523190041.GA132828@gmail.com>
References: <20170517180850.GA91213@gmail.com>
 <20170523051120.15698-1-david@sigma-star.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170523051120.15698-1-david@sigma-star.at>
To: David Gstir <david@sigma-star.at>
Cc: tytso@mit.edu, jaegeuk@kernel.org, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Daniel Walter <dwalter@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi David,

On Tue, May 23, 2017 at 07:11:20AM +0200, David Gstir wrote:
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

Overall this looks good now; you can add

Reviewed-by: Eric Biggers <ebiggers@google.com>

I did notice a couple minor improvements that can be made, though:

>  
> +	if (crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
> +		res = init_essiv_generator(crypt_info, raw_key, keysize);
> +		if (res) {
> +			pr_debug("%s: error %d (inode %lu) allocating essiv tfm\n",
> +				 __func__, res, inode->i_ino);
> +			goto out;
> +		}
> +	}

Since the ESSIV generator is only needed for contents encryption, it should only
be initialized when both 'S_ISREG(inode->i_mode) && crypt_info->ci_data_mode ==
FS_ENCRYPTION_MODE_AES_128_CBC'.  Otherwise ->ci_essiv_tfm will be allocated for
directories and symlinks too, then never used.

> +static int init_essiv_generator(struct fscrypt_info *ci, const u8 *raw_key,
> +				int keysize)
> +{
> +	int err;
> +	struct crypto_cipher *essiv_tfm;
> +	u8 salt[SHA256_DIGEST_SIZE];
> +
> +	if (WARN_ON_ONCE(keysize > sizeof(salt)))
> +		return -EINVAL;
> +

The 'keysize > sizeof(salt)' check is now pointless and should be removed, since
we decided not to key the ESSIV cipher with 'keysize' bytes, but rather with
sizeof(salt) bytes.  So this function is compatible with any 'keysize', not just
keysize <= sizeof(salt).

You should also consider how it should be made possible to test these new
encryption modes in xfstests.  Currently, while the "set_encpolicy" xfs_io
command allows specifying different encryption modes and flags, in general the
tests in the "encrypt" group are hardcoded to use AES_256_XTS and AES_256_CTS.
Similarly, those modes are also used with the test_dummy_encryption mount
option, which causes all new files to be automatically encrypted, and is used by
the "encrypt" config for kvm-xfstests and gce-xfstests (currently ext4-specific,
but other filesystems could support it too).

Eric
