Return-Path: <SRS0=XJak=XZ=sandeen.net=sandeen@kernel.org>
Subject: Re: [PATCH v3 0/9] xfsprogs: support fscrypt API additions in xfs_io
References: <20190928000243.77634-1-ebiggers@kernel.org>
From: Eric Sandeen <sandeen@sandeen.net>
Message-ID: <70b5c936-7dfc-9296-63f2-47d31b32815e@sandeen.net>
Date: Mon, 30 Sep 2019 14:29:28 -0500
MIME-Version: 1.0
In-Reply-To: <20190928000243.77634-1-ebiggers@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>, linux-xfs@vger.kernel.org
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>



On 9/27/19 7:02 PM, Eric Biggers wrote:
> Hello,
> 
> This patchset updates xfs_io to support the new fscrypt ioctls that were
> merged for 5.4 (https://git.kernel.org/torvalds/c/734d1ed83e1f9b7b).
> 
> New commands are added to wrap the new ioctls to manage filesystem
> encryption keys: 'add_enckey', 'rm_enckey', and 'enckey_status'.  Also,
> the existing 'get_encpolicy' and 'set_encpolicy' commands are updated to
> support getting/setting v2 encryption policies.
> 
> The purpose of all this is to allow xfstests to test these new APIs.
> 
> Note: currently only ext4, f2fs, and ubifs support encryption.  But I
> was told previously that since the fscrypt API is generic and may be
> supported by XFS in the future, the command-line wrappers for the
> fscrypt ioctls should be in xfs_io rather than in xfstests directly
> (https://marc.info/?l=fstests&m=147976255831951&w=2).
> 
> This patchset applies to the latest "for-next" branch of xfsprogs
> (commit ac8b6c380865).  It can also be retrieved from tag
> "fscrypt-key-mgmt-improvements_2019-09-27" of
> https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/xfsprogs-dev.git
> 
> Changes v2 => v3:
> - Generate the encryption modes for 'help set_encpolicy'.
> - Mention '-a' in all relevant places in the help for rm_enckey.
> - Mark strings for translation.

Thanks for the updates.

For the whole series,

Reviewed-by: Eric Sandeen <sandeen@redhat.com>
