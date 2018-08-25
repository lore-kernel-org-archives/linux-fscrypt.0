Return-Path: <SRS0=J7B4=LI=huawei.com=gaoxiang25@kernel.org>
Subject: Re: [RFC PATCH 02/10] fs-verity: add data verification hooks for
 ->readpages()
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-3-ebiggers@kernel.org>
 <2f2382c3-e5e9-f0da-dc89-42dfc7b2b636@huawei.com>
 <20180825041647.GA726@sol.localdomain>
 <21e86199-28a7-4693-aef5-5fc28842535c@huawei.com>
 <20180825071827.GD726@sol.localdomain>
From: Gao Xiang <gaoxiang25@huawei.com>
Message-ID: <c907ad1d-c7c8-714a-0e59-373c1df3afe8@huawei.com>
Date: Sat, 25 Aug 2018 15:43:43 +0800
MIME-Version: 1.0
In-Reply-To: <20180825071827.GD726@sol.localdomain>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On 2018/8/25 15:18, Eric Biggers wrote:
> We do have to be very careful here, but the same restriction already exists with
> fscrypt which both f2fs and ext4 already support too.  With fscrypt, each page
> is decrypted with the key from page->mapping->host->i_crypt_info and the
> initialization vector from page->index.  With fs-verity, each page is verified
> using the Merkle tree state from page->mapping->host->i_verify_info and the
> block location from page->index.  So, they are very similar.
> 
> On f2fs, any pages submitted via META_MAPPING just skip both fscrypt and
> fs-verity since the "meta_inode" doesn't have either feature enabled.  That's
> done intentionally, so that garbage collection can move the blocks on-disk.
> Regular reads aren't done via META_MAPPING.
> 

I think you deal with the existed cases quite well, I was just thinking about EROFS... :)

> I don't know of any plan to use fs-verity on Android's system partition or to
> replace dm-verity on the system partition.  The use cases so far have been
> verifying files on /data, like APK files.
> 
> So I don't think you need to support fs-verity in EROFS.
> 

Thanks for your information about fs-verity, that is quite useful for us
Actually, I was worrying about that these months...  :)

> Re: the compression, I don't see how it would be much of a problem (even if you
> did need or want to add fs-verity support).  Assuming that the verification is
> done over the uncompressed version of the data, you wouldn't verify the pages
> directly from the bio's page list since those would contain compressed data.
> But even without fs-verity you'd need to decompress the data into pagecache
> pages... so you could just call fsverity_verify_page() on each of those
> decompressed pages before unlocking them and setting them Uptodate.  You don't
> *have* to call fsverity_verify_bio() to do the verification; it's just a helper
> for the case where the list of pages to verify happens to be in a completed bio.
> 

I haven't look into all patches, I will look into that carefully if I finish my current job.
It is wonderful to have such a helper --- fsverity_verify_page :)

I have no other problem currently, and look forward for your final implementation.

Best Regards,
Gao Xiang

> - Eric
