Return-Path: <SRS0=9x7r=LI=vger.kernel.org=linux-integrity-owner@kernel.org>
Date: Sat, 25 Aug 2018 00:18:28 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 02/10] fs-verity: add data verification hooks for
 ->readpages()
Message-ID: <20180825071827.GD726@sol.localdomain>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-3-ebiggers@kernel.org>
 <2f2382c3-e5e9-f0da-dc89-42dfc7b2b636@huawei.com>
 <20180825041647.GA726@sol.localdomain>
 <21e86199-28a7-4693-aef5-5fc28842535c@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <21e86199-28a7-4693-aef5-5fc28842535c@huawei.com>
Sender: linux-integrity-owner@vger.kernel.org
To: Gao Xiang <gaoxiang25@huawei.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Gao,

On Sat, Aug 25, 2018 at 02:31:16PM +0800, Gao Xiang wrote:
> Hi Eric,
> 
> Thanks for your detailed reply.
> 
> My english is not quite well, I could not type logically and quickly like you and could use some words improperly,
> I just want to express my personal concern, please understand, thanks. :)
> 
> On 2018/8/25 12:16, Eric Biggers wrote:
> > Hi Gao,
> > 
> > On Sat, Aug 25, 2018 at 10:29:26AM +0800, Gao Xiang wrote:
> >> Hi,
> >>
> >> On 2018/8/25 0:16, Eric Biggers wrote:
> >>> +/**
> >>> + * fsverity_verify_page - verify a data page
> >>> + *
> >>> + * Verify a page that has just been read from a file against that file's Merkle
> >>> + * tree.  The page is assumed to be a pagecache page.
> >>> + *
> >>> + * Return: true if the page is valid, else false.
> >>> + */
> >>> +bool fsverity_verify_page(struct page *data_page)
> >>> +{
> >>> +	struct inode *inode = data_page->mapping->host;
> >>> +	const struct fsverity_info *vi = get_fsverity_info(inode);
> >>> +	struct ahash_request *req;
> >>> +	bool valid;
> >>> +
> >>> +	req = ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
> >>> +	if (unlikely(!req))
> >>> +		return false;
> >>> +
> >>> +	valid = verify_page(inode, vi, req, data_page);
> >>> +
> >>> +	ahash_request_free(req);
> >>> +
> >>> +	return valid;
> >>> +}
> >>> +EXPORT_SYMBOL_GPL(fsverity_verify_page);
> >>> +
> >>> +/**
> >>> + * fsverity_verify_bio - verify a 'read' bio that has just completed
> >>> + *
> >>> + * Verify a set of pages that have just been read from a file against that
> >>> + * file's Merkle tree.  The pages are assumed to be pagecache pages.  Pages that
> >>> + * fail verification are set to the Error state.  Verification is skipped for
> >>> + * pages already in the Error state, e.g. due to fscrypt decryption failure.
> >>> + */
> >>> +void fsverity_verify_bio(struct bio *bio)
> >>> +{
> >>> +	struct inode *inode = bio_first_page_all(bio)->mapping->host;
> >>> +	const struct fsverity_info *vi = get_fsverity_info(inode);
> >>> +	struct ahash_request *req;
> >>> +	struct bio_vec *bv;
> >>> +	int i;
> >>> +
> >>> +	req = ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
> >>> +	if (unlikely(!req)) {
> >>> +		bio_for_each_segment_all(bv, bio, i)
> >>> +			SetPageError(bv->bv_page);
> >>> +		return;
> >>> +	}
> >>> +
> >>> +	bio_for_each_segment_all(bv, bio, i) {
> >>> +		struct page *page = bv->bv_page;
> >>> +
> >>> +		if (!PageError(page) && !verify_page(inode, vi, req, page))
> >>> +			SetPageError(page);
> >>> +	}
> >>> +
> >>> +	ahash_request_free(req);
> >>> +}
> >>> +EXPORT_SYMBOL_GPL(fsverity_verify_bio);
> >>
> >> Out of curiosity, I quickly scanned the fs-verity source code and some minor question out there....
> >>
> >> If something is wrong, please point out, thanks in advance...
> >>
> >> My first question is that 'Is there any way to skip to verify pages in a bio?'
> >> I am thinking about
> >> If metadata and data page are mixed in a filesystem of such kind, they could submit together in a bio, but metadata could be unsuitable for such kind of verification.
> >>
> > 
> > Pages below i_size are verified, pages above are not.
> > 
> > With my patches, ext4 and f2fs won't actually submit pages in both areas in the
> > same bio, and they won't call the fs-verity verification function for bios in
> > the data area.  But even if they did, there's also a check in verify_page() that
> 
> I think you mean the hash area?

Yes, I meant the hash area.

> > skips the verification if the page is above i_size.
> >
> 
> I think it could not be as simple as you said for all cases.
> 
> If some fs submits contiguous access with different MAPPING (something like
> mixed FILE_MAPPING and META_MAPPING), their page->index are actually
> unreliable(could be logical page index for FILE_MAPPING,and physical page
> index for META_MAPPING), and data are organized by design in multi bios for a
> fs-specific use (such as compresssion).
> 
> You couldn't do such verification `if the page is above i_size' and it could
> be hard to integrate somehow.

We do have to be very careful here, but the same restriction already exists with
fscrypt which both f2fs and ext4 already support too.  With fscrypt, each page
is decrypted with the key from page->mapping->host->i_crypt_info and the
initialization vector from page->index.  With fs-verity, each page is verified
using the Merkle tree state from page->mapping->host->i_verify_info and the
block location from page->index.  So, they are very similar.

On f2fs, any pages submitted via META_MAPPING just skip both fscrypt and
fs-verity since the "meta_inode" doesn't have either feature enabled.  That's
done intentionally, so that garbage collection can move the blocks on-disk.
Regular reads aren't done via META_MAPPING.

> 
> >> The second question is related to the first question --- 'Is there any way to verify a partial page?'
> >> Take scalability into consideration, some files could be totally inlined or partially inlined in metadata.
> >> Is there any way to deal with them in per-file approach? at least --- support for the interface?
> > 
> > Well, one problem is that inline data has its own separate I/O path; see
> > ext4_readpage_inline() and f2fs_read_inline_data().  So it would be a large
> > effort to support features like encryption and verity which require
> > postprocessing after reads, and probably not worthwhile especially for verity
> > which is primarily intended for large files.
> 
> Yes, for the current user ext4 and f2fs, it is absolutely wonderful.
> 
> 
> I have to admit I am curious about Google fs-verity roadmap for the future Android
> (I have to identify whether it is designed to replace dm-verity, currently I think is no)
> 
> since it is very important whether our EROFS should support fs-verity or not in the near future...
> 
> 
> I could give some EROFS use case if you have some time to discuss.
> 
> EROFS uses a more aggressive inline approach, which means it not only inline data for small files.
> It is designed to inline the last page, which are reasonable small (eg. only a few byte) to inline for all files, eg.
> 
>                                                                  IN FILE_MAPPING
> IN META_MAPPING                                                  blk-aligned
> +--------------------------------------|                         +--------+--------+     +----------+.......+
> |inode A+inlined-last data.. inode B...|                         | page 0 | page 1 | ... | page n-1 . page n.
> +--------------------------------------+                         +--------+--------+     +----------+.......+
>          |------------------------------------------------------------------------------------------|\
> 
> In priciple, this approach could be also used for read-write file systems to save more storage space.
> I think it is still easy for uncompressed file if you do the zero padding as you said below.
> 
> But if considering _compression_.....especially compression in VLE, I think it should not rely on `bio' directly, because,
> 1) endio with compressed data rather than FILE_MAPPING plain data, these pages which could from META_MAPPING
> (for caching compressed page on purpose) or FILE_MAPPING(for decompressing in-place to save redundant META_MAPPING memory).
> 
> I think it should be decompress at first and then fs-verity, but there could be more filepages other than compresssed pages joined
> (eg. 128kb->32kb, we submit 8 pages but decompress end with 32 pages), it should not be the original bio any more...
> (actually I think it is not the bio concept anymore...)
> 
> 2) EROFS VLE is more complicated, we could end a bio with a compressed page but decompress a partial file page, eg.
>     +-------------------+--------------------+
> ... | compressed page X |compressed page X+1 |
>     +-------------------|--------------------+
>             end of bio Y/     bio Y+1
>                  \      |      /
>                   +-------------------------+
>                   |   plain data (file page)|
>                   +-------------------------+
> which means a bio could only decompress partial data of a page, the page could be Uptodate by two bios rather than one,
> I have no idea how to fs-verity like this...
> 
> `it could call fsverity after assembling the page in the page cache.` as Ted said in that case.
> 

I don't know of any plan to use fs-verity on Android's system partition or to
replace dm-verity on the system partition.  The use cases so far have been
verifying files on /data, like APK files.

So I don't think you need to support fs-verity in EROFS.

Re: the compression, I don't see how it would be much of a problem (even if you
did need or want to add fs-verity support).  Assuming that the verification is
done over the uncompressed version of the data, you wouldn't verify the pages
directly from the bio's page list since those would contain compressed data.
But even without fs-verity you'd need to decompress the data into pagecache
pages... so you could just call fsverity_verify_page() on each of those
decompressed pages before unlocking them and setting them Uptodate.  You don't
*have* to call fsverity_verify_bio() to do the verification; it's just a helper
for the case where the list of pages to verify happens to be in a completed bio.

> > 
> > A somewhat separate question is whether the zero padding to a block boundary
> > after i_size, before the Merkle tree begins, is needed.  The answer is yes,
> > since mixing data and metadata in the same page would cause problems.  First,
> > userspace would be able to mmap the page and see some of the metadata rather
> > than zeroes.  That's not a huge problem, but it breaks the standard behavior.
> > Second, any page containing data cannot be set Uptodate until it's been
> > verified.  So, a special case would be needed to handle reading the part of the
> > metadata that's located in a data page.
> 
> Yes, after I just thinked over, I think there should be a zero padding to a block boundary
> as you said due to Uptodate and mmap scenerio if you directly use its inode(file) mapping for verification.
> 
> 
> > 
> >> At last, I hope filesystems could select the on-disk position of hash tree and 'struct fsverity_descriptor'
> >> rather than fixed in the end of verity files...I think if fs-verity preparing such support and interfaces could be better.....hmmm... :(
> > 
> > In theory it would be a much cleaner design to store verity metadata separately
> > from the data.  But the Merkle tree can be very large.  For example, a 1 GB file
> > using SHA-512 would have a 16.6 MB Merkle tree.  So the Merkle tree can't be an
> > extended attribute, since the xattrs API requires xattrs to be small (<= 64 KB),
> > and most filesystems further limit xattr sizes in their on-disk format to as
> > little as 4 KB.  Furthermore, even if both of these limits were to be increased,
> > the xattrs functions (both the syscalls, and the internal functions that
> > filesystems have) are all based around getting/setting the entire xattr value.
> > 
> > Also when used with fscrypt, we want the Merkle tree and fsverity_descriptor to
> > be encrypted, so they doesn't leak plaintext hashes.  And we want the Merkle
> > tree to be paged into memory, just like the file contents, to take advantage of
> > the usual Linux memory management.
> > 
> > What we really need is *streams*, like NTFS has.  But the filesystems we're
> > targetting don't support streams, nor does the Linux syscall interface have any
> > API for accessing streams, nor does the VFS support them.
> > 
> > Adding streams support to all those things would be a huge multi-year effort,
> > controversial, and almost certainly not worth it just for fs-verity.
> > 
> > So simply storing the verity metadata past i_size seems like the best solution
> > for now.
> > 
> > That being said, in the future we could pretty easily swap out the calls to
> > read_mapping_page() with something else if a particular filesystem wanted to
> > store the metadata somewhere else.  We actually even originally had a function
> > ->read_metadata_page() in the filesystem's fsverity_operations, but it turned
> > out to be unnecessary and I replaced it with directly calling
> > read_mapping_page(), but it could be changed back at any time.
> 
> OK, I got it.
> 
> I have to look into that and think over again. Thanks for your reply again in the end. :)
> 
> Thanks,
> Gao Xiang
> 

- Eric
