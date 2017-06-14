Return-Path: <chao@kernel.org>
Subject: Re: [f2fs-dev] [PATCH 2/3] f2fs: require key for truncate(2) of
 encrypted file
References: <20170613234755.111167-1-ebiggers3@gmail.com>
 <20170613234755.111167-3-ebiggers3@gmail.com>
From: Chao Yu <chao@kernel.org>
Message-ID: <e558657c-d383-4528-9be0-8c2d1ab8344c@kernel.org>
Date: Wed, 14 Jun 2017 20:44:19 +0800
MIME-Version: 1.0
In-Reply-To: <20170613234755.111167-3-ebiggers3@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 2017/6/14 7:47, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Currently, filesystems allow truncate(2) on an encrypted file without
> the encryption key.  However, it's impossible to correctly handle the
> case where the size being truncated to is not a multiple of the
> filesystem block size, because that would require decrypting the final
> block, zeroing the part beyond i_size, then encrypting the block.
> 
> As other modifications to encrypted file contents are prohibited without
> the key, just prohibit truncate(2) as well, making it fail with ENOKEY.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Chao Yu <yuchao0@huawei.com>

Thanks,
