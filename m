Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:35950 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726694AbeHZVAY (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 26 Aug 2018 17:00:24 -0400
Date: Sun, 26 Aug 2018 10:17:14 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 01/10] fs-verity: add setup code, UAPI, and Kconfig
Message-ID: <20180826171713.GB728@sol.localdomain>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-2-ebiggers@kernel.org>
 <815EEE5D-D90F-4E97-A33E-D33D868B962B@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <815EEE5D-D90F-4E97-A33E-D33D868B962B@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chuck,

On Sun, Aug 26, 2018 at 12:22:08PM -0400, Chuck Lever wrote:
> Hi Eric-
> 
> Context: I'm working on IMA support for NFSv4, and would like to
> use fs-verity (or some Merkle tree-like mechanism) eventually to
> help address the performance impacts of using IMA with large NFS
> files.
> 
> 
> > On Aug 24, 2018, at 12:16 PM, Eric Biggers <ebiggers@kernel.org> wrote:
> > 
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > fs-verity is a filesystem feature that provides efficient, transparent
> > integrity verification and authentication of read-only files.  It uses a
> > dm-verity like mechanism at the file level: a Merkle tree hidden past
> > the end of the file is used to verify any block in the file in
> > log(filesize) time.  It is implemented mainly by helper functions in
> > fs/verity/ that will be shared by multiple filesystems.
> 
> This description suggests that the only way fs-verity can work is
> by placing the Merkle tree data after EOF. Further, this organi-
> zation is exposed to user space, making it a fixed part of the
> fs-verity kernel/user space API.
> 
> Remote filesystems -- esp. NFS -- would prefer to manage the Merkle
> tree data in other ways. The NFSv4 protocol, for example, supports
> named streams (as some other filesystems do), and could store the
> Merkle trees in those. Or, a new pNFS layout type could be con-
> structed where Merkle trees are stored separately from a file's
> content -- perhaps even on a separate file server.
> 
> File servers can store this data as the servers' local filesystems
> require.
> 
> Sharing how the Merkle tree is created and used is sensible, but
> IMHO the filesystem implementations should be allowed to store this
> tree however they find convenient. The Merkle trees should be
> exposed via a clean API, not as part of the file's content.
> 

There has also been discussion with this on the thread for patch 02/10.
"A Merkle tree hidden past the end of the file" describes how ext4 and f2fs are
proposed to implement it, and it describes the file format expected by
FS_IOC_ENABLE_VERITY.  But, at FS_IOC_ENABLE_VERITY time, a filesystem could
copy the verity metadata to somewhere else if it wanted, e.g. into a file
stream, and then truncate the file to its original size.

Afterwards, fs-verity doesn't really care where the metadata is stored.
Currently it does actually assume it's beyond EOF since it calls
read_mapping_page() directly, but that could be replaced at any time with
indirection via a method fsverity_operations.read_metadata_page().
We actually had such a method originally, but it turned out to be unnecessary
for ext4 and f2fs, so I had dropped it for now.

I will make this clearer in the next revision of the patchset, and maybe even
consider reintroducing ->read_metadata_page() to make it clear that filesystems
don't necessarily have to store the metadata beyond EOF.

Thanks,

- Eric
