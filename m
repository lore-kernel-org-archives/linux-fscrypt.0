Return-Path: <SRS0=3z2P=WQ=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V4 5/8] f2fs: Use read_callbacks for decrypting file data
Date: Tue, 20 Aug 2019 10:35:29 +0530
In-Reply-To: <20190816061804.14840-6-chandan@linux.ibm.com>
References: <20190816061804.14840-1-chandan@linux.ibm.com> <20190816061804.14840-6-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <1652707.8YmLLlegLt@localhost.localdomain>
To: tytso@mit.edu, ebiggers@kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, chandanrmail@gmail.com, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Friday, August 16, 2019 11:48 AM Chandan Rajendra wrote:
> F2FS has a copy of "post read processing" code using which encrypted
> file data is decrypted. This commit replaces it to make use of the
> generic read_callbacks facility.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>

Hi Eric and Ted,

Looks like F2FS requires a lot more flexiblity than what can be offered by
read callbacks i.e.

1. F2FS wants to make use of its own workqueue for decryption, verity and
   decompression.
2. F2FS' decompression code is not an FS independent entity like fscrypt and
   fsverity. Hence they would need Filesystem specific callback functions to
   be invoked from "read callbacks". 

Hence I would suggest that we should drop F2FS changes made in this
patchset. Please let me know your thoughts on this.

-- 
chandan
