Return-Path: <SRS0=gUew=LH=thunk.org=tytso@kernel.org>
Date: Fri, 24 Aug 2018 18:45:17 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH 01/10] fs-verity: add setup code, UAPI, and Kconfig
Message-ID: <20180824224517.GF15262@thunk.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-2-ebiggers@kernel.org>
 <1535132549.2855027.1485213752.129E3334@webmail.messagingengine.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535132549.2855027.1485213752.129E3334@webmail.messagingengine.com>
To: Colin Walters <walters@verbum.org>
Cc: Eric Biggers <ebiggers@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Aug 24, 2018 at 01:42:29PM -0400, Colin Walters wrote:
> 
> While I'm not too familiar with the vfs, as far as I can
> tell  from inspection of Linus' git master is that pretty much any change (timestamp, hardlinks) ends up
> calling notify_change() which calls the fs-specific one, and in
> the verity case basically denies everything, right?

That's not correct.  The verity case only denies truncate, because
changing the data of the file would break the Merkle tree checksums.
The metadata of the file is is not made immutable.  So a
verity-protected file can be deleted, renamed, can have hard links,
and the timestamps can be set via utimes(), etc.

Cheers,

    		       	      	  	     - Ted
