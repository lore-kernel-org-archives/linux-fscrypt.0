Return-Path: <SRS0=509s=L5=thunk.org=tytso@kernel.org>
Date: Sat, 15 Sep 2018 11:27:03 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH 01/10] fs-verity: add setup code, UAPI, and Kconfig
Message-ID: <20180915152703.GA9979@thunk.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-2-ebiggers@kernel.org>
 <1535132549.2855027.1485213752.129E3334@webmail.messagingengine.com>
 <20180825044852.GB726@sol.localdomain>
 <1536930930.1003187.1508104496.6465C44D@webmail.messagingengine.com>
 <20180914162142.GA734@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180914162142.GA734@sol.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Colin Walters <walters@verbum.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Sep 14, 2018 at 09:21:43AM -0700, Eric Biggers wrote:
> > 
> > Now AIUI, Zip files have an internal header that contains e.g. the size and
> > indexes into the internal files.  So if someone added random data to the end
> > of a zip file, nothing is going to end up actually reading it.
> 
> After the verity bit is enabled, the verity metadata is not visible to
> userspace.  Yes, that means i_size is adjusted too.  Also all contents
> modifications are denied, including appends.

One of this reasons why this is important is that ZIP files *also*
have an central directory at the end.  And in the case of the APK
files, there is an in-band signature block which is located at at the
end of the last file and the central directory, which can be located
by starting at the end of the file, finding the length of the central
directory, and then backing up to find the signature block.

    	 	       	    		- Ted
