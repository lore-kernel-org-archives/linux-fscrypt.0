Return-Path: <SRS0=6daa=WI=huawei.com=yuchao0@kernel.org>
Subject: Re: [PATCH 6/6] f2fs: use EFSCORRUPTED in
 f2fs_get_verity_descriptor()
References: <20190811213557.1970-1-ebiggers@kernel.org>
 <20190811213557.1970-7-ebiggers@kernel.org>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <41cd4406-9f81-94de-ce49-54d1b9442130@huawei.com>
Date: Mon, 12 Aug 2019 20:26:30 +0800
MIME-Version: 1.0
In-Reply-To: <20190811213557.1970-7-ebiggers@kernel.org>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On 2019/8/12 5:35, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> EFSCORRUPTED is now defined in f2fs.h, so use it instead of EUCLEAN.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Chao Yu <yuchao0@huawei.com>

Thanks,
