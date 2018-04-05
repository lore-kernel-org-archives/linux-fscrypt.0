Return-Path: <tytso@thunk.org>
Date: Thu, 5 Apr 2018 16:50:36 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH V2 07/11] fscrypt_zeroout_range: Encrypt all zeroed
 out blocks of a page
Message-ID: <20180405205036.GA32529@thunk.org>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
 <3388885.zk0F4oSU7q@localhost.localdomain>
 <20180405124745.GA20556@thunk.org>
 <2019099.0S9cVZxUkm@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2019099.0S9cVZxUkm@localhost.localdomain>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Apr 05, 2018 at 06:37:24PM +0530, Chandan Rajendra wrote:
> Sorry, I wasn't clear enough with my explaination. I actually meant to say
> that not all blocks mapped by a page might be dirty and hence only a subset
> of the dirty blocks might need to be written to the disk.

But we only track dirtiness on a per-page level.  That's all the page
cache gives us.  Remember, the function name is ext4_bio_write_page()
or {btrfs,xfs,ext4}_writepage() --- we will always be writing a full
page at a time.

						- Ted
