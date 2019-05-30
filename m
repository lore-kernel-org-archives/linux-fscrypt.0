Return-Path: <SRS0=8W07=T6=vger.kernel.org=linux-integrity-owner@kernel.org>
Date: Thu, 30 May 2019 11:54:15 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v3 00/15] fs-verity: read-only file-based authenticity
 protection
Message-ID: <20190530185414.GD70051@gmail.com>
References: <20190523161811.6259-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523161811.6259-1-ebiggers@kernel.org>
Sender: linux-integrity-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, linux-api@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-integrity@vger.kernel.org, linux-ext4@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, May 23, 2019 at 09:17:56AM -0700, Eric Biggers wrote:
> Hello,
> 
> This is a redesigned version of the fs-verity patchset, implementing
> Ted's suggestion to build the Merkle tree in the kernel
> (https://lore.kernel.org/linux-fsdevel/20190207031101.GA7387@mit.edu/).

Does anyone have any comments on this patchset?

- Eric
