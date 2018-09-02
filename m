Return-Path: <SRS0=IX7Q=LQ=lixom.net=olof@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20180825041647.GA726@sol.localdomain>
References: <20180824161642.1144-1-ebiggers@kernel.org> <20180824161642.1144-3-ebiggers@kernel.org>
 <2f2382c3-e5e9-f0da-dc89-42dfc7b2b636@huawei.com> <20180825041647.GA726@sol.localdomain>
From: Olof Johansson <olof@lixom.net>
Date: Sat, 1 Sep 2018 19:35:53 -0700
Message-ID: <CAOesGMhGfesVQHHMpqW5r7gMOZccX4RsZZex6y-kfkmuA6K0ow@mail.gmail.com>
Subject: Re: [RFC PATCH 02/10] fs-verity: add data verification hooks for ->readpages()
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: Gao Xiang <gaoxiang25@huawei.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

On Fri, Aug 24, 2018 at 9:16 PM, Eric Biggers <ebiggers@kernel.org> wrote:
> Hi Gao,
>
> On Sat, Aug 25, 2018 at 10:29:26AM +0800, Gao Xiang wrote:
>> Hi,
>>
>> At last, I hope filesystems could select the on-disk position of hash tree and 'struct fsverity_descriptor'
>> rather than fixed in the end of verity files...I think if fs-verity preparing such support and interfaces could be better.....hmmm... :(
>
> In theory it would be a much cleaner design to store verity metadata separately
> from the data.  But the Merkle tree can be very large.  For example, a 1 GB file
> using SHA-512 would have a 16.6 MB Merkle tree.  So the Merkle tree can't be an
> extended attribute, since the xattrs API requires xattrs to be small (<= 64 KB),
> and most filesystems further limit xattr sizes in their on-disk format to as
> little as 4 KB.  Furthermore, even if both of these limits were to be increased,
> the xattrs functions (both the syscalls, and the internal functions that
> filesystems have) are all based around getting/setting the entire xattr value.
>
> Also when used with fscrypt, we want the Merkle tree and fsverity_descriptor to
> be encrypted, so they doesn't leak plaintext hashes.  And we want the Merkle
> tree to be paged into memory, just like the file contents, to take advantage of
> the usual Linux memory management.
>
> What we really need is *streams*, like NTFS has.  But the filesystems we're
> targetting don't support streams, nor does the Linux syscall interface have any
> API for accessing streams, nor does the VFS support them.
>
> Adding streams support to all those things would be a huge multi-year effort,
> controversial, and almost certainly not worth it just for fs-verity.
>
> So simply storing the verity metadata past i_size seems like the best solution
> for now.
>
> That being said, in the future we could pretty easily swap out the calls to
> read_mapping_page() with something else if a particular filesystem wanted to
> store the metadata somewhere else.  We actually even originally had a function
> ->read_metadata_page() in the filesystem's fsverity_operations, but it turned
> out to be unnecessary and I replaced it with directly calling
> read_mapping_page(), but it could be changed back at any time.

What about an xattr not to hold the Merkle tree, but to contain a
suitable reference to a file/inode+offset that contains it (+ toplevel
hash for said tree/file or the descriptor/struct)?

If you also expose said file in the directory structure, things such
as backups might be easier to handle. For where the tree is appended
to the file, you could self-reference.


-Olof
