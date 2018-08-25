Return-Path: <SRS0=J7B4=LI=huawei.com=gaoxiang25@kernel.org>
Subject: Re: [f2fs-dev] [RFC PATCH 02/10] fs-verity: add data verification
 hooks for ->readpages()
From: Gao Xiang <gaoxiang25@huawei.com>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-3-ebiggers@kernel.org>
 <2f2382c3-e5e9-f0da-dc89-42dfc7b2b636@huawei.com>
 <20180825034544.GA5281@thunk.org>
 <cb646950-94ea-9b28-80f1-3c840ad85581@huawei.com>
 <20180825050621.GA25031@thunk.org>
 <faf1fe45-e325-bae4-e60d-871f0b7b41b0@huawei.com>
Message-ID: <22b235b0-8615-5947-bcae-78f4d492d28a@huawei.com>
Date: Sat, 25 Aug 2018 15:55:18 +0800
MIME-Version: 1.0
In-Reply-To: <faf1fe45-e325-bae4-e60d-871f0b7b41b0@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ted,

Please ignore the following email, Eric has replied to me. :)
I need to dig into these fs-verity patches later and best wishes to fs-verity.

Thanks,
Gao Xiang

On 2018/8/25 15:33, Gao Xiang wrote:
> Hi Ted,
> 
> Thanks for your detailed reply. Sorry about my english, the words could not be logical.
> 
> Tiny pieces in B-tree to compose a page is too far from us too, and you are right,
> fs-verity is complete for >99% cases for the existed file system, and no need to worry about currently.
> 
> As I mentioned in reply to Eric, I am actually curious about the Google fs-verity roadmap
> for the future Android, I need to analyze if it is only limited to APKs for the read-write partitions
> and not to replace dm-verity in the near future since fs-verity has some conflicts
> to EROFS I am working on I mentioned in the email to Eric.
> 
> I think it is more than just to handle FILE_MAPPING and bio-strict for compression use.
> 
> On 2018/8/25 13:06, Theodore Y. Ts'o wrote:
>> But I'd suggest worrying about it when such a file system
>> comes out of the woodwork, and someone is willing to do the work to
>> integrate fserity in that file system.
>>
> Yes, we are now handling partial page due to compression use.
> 
> fs could submit bios in pages from different mapping(FILE_MAPPING[compress in-place and no caching
> compressed page to reduce extra memory overhead] or META_MAPPING [for caching compressed page]) and
> they could be decompressed into many full pages and (possible) a partial page (in-place or out-of-place).
> 
> so in principle, since we have BIO_MAX_PAGES limitation, a filemap page could be Uptodate
> after two bios is ended and decompressed. and other runtime limitations could also divide a bio into two bios for encoded cases.
> 
> Therefore, I think in that case we could not just consider FILE_MAPPING and one bio, and as you said `In
> that case, it could call fsverity after assembling the page in the page cache.' should be done in this way.
> 
>> Well, the userspace interface for instantiating a fs-verity file is
>> that it writes the file data with the fs-verity metadata (which
>> consists of the Merkle tree with a fs-verity header at the end of the
>> file).  The program (which might be a package manager such as dpkg or
>> rpm) would then call an ioctl which would cause the file system to
>> read the fs-verity header and make only the file data visible, and the
>> file system would the verify the data as it is read into the page
>> cache.
> Thanks for your reply again, I think fs-verity is good enough for now.
> However, I need to think over about fs-verity itself more... :(
> 
> Thanks,
> Gao Xiang
