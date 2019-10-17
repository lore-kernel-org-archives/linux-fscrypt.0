Return-Path: <SRS0=Ff6O=YK=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH 0/2] ext4: support encryption with blocksize != PAGE_SIZE
Date: Thu, 17 Oct 2019 11:44:58 +0530
In-Reply-To: <20191016221142.298754-1-ebiggers@kernel.org>
References: <20191016221142.298754-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2830996.s4omRzobaj@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thursday, October 17, 2019 3:41 AM Eric Biggers wrote: 
> Hello,
> 
> This patchset makes ext4 support encryption on filesystems where the
> filesystem block size is not equal to PAGE_SIZE.  This allows e.g.
> PowerPC systems to use ext4 encryption.
> 
> Most of the work for this was already done in prior kernel releases; now
> the only part missing is decryption support in block_read_full_page().
> Chandan Rajendra has proposed a patchset "Consolidate FS read I/O
> callbacks code" [1] to address this and do various other things like
> make ext4 use mpage_readpages() again, and make ext4 and f2fs share more
> code.  But it doesn't seem to be going anywhere.
> 
> Therefore, I propose we simply add decryption support to
> block_read_full_page() for now.  This is a fairly small change, and it
> gets ext4 encryption with subpage-sized blocks working.
> 
> Note: to keep things simple I'm just allocating the work object from the
> bi_end_io function with GFP_ATOMIC.  But if people think it's necessary,
> it could be changed to use preallocation like the page-based read path.
> 
> Tested with 'gce-xfstests -c ext4/encrypt_1k -g auto', using the new
> "encrypt_1k" config I created.  All tests pass except for those that
> already fail or are excluded with the encrypt or 1k configs, and 2 tests
> that try to create 1023-byte symlinks which fails since encrypted
> symlinks are limited to blocksize-3 bytes.  Also ran the dedicated
> encryption tests using 'kvm-xfstests -c ext4/1k -g encrypt'; all pass,
> including the on-disk ciphertext verification tests.
> 
> [1] https://lkml.kernel.org/linux-fsdevel/20190910155115.28550-1-chandan@linux.ibm.com/T/#u
>

Hi Eric,

Thanks a lot for doing this.

The changes seem to be good. I have started test runs on my ppc64le guest and
I will reply with the test results once they complete.

-- 
chandan
