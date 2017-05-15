Return-Path: <viro@ftp.linux.org.uk>
Date: Tue, 16 May 2017 00:50:36 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Question on fscrypt_d_revalidate() and fstest generic/429
Message-ID: <20170515235035.GO390@ZenIV.linux.org.uk>
References: <e2d845a3-a863-1506-a0de-576049c84e81@nod.at>
 <20170515194553.GA20264@gmail.com>
 <489e1437-990f-3e88-d426-b47b82441009@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <489e1437-990f-3e88-d426-b47b82441009@nod.at>
Sender: Al Viro <viro@ftp.linux.org.uk>
To: Richard Weinberger <richard@nod.at>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, David Gstir <david@sigma-star.at>, David Oberhollenzer <david.oberhollenzer@sigma-star.at>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 15, 2017 at 09:51:03PM +0200, Richard Weinberger wrote:

> > I doubt it's the right solution to make fscrypt_d_revalidate() look at
> > ->i_nlink, since ->d_revalidate() is meant to validate the filename, not the
> > inode.  I think there is probably a VFS bug that is causing the dentries to not
> > be freed.
> 
> Not sure. Al? :-)

What's to tell VFS that they are garbage?  If your code doesn't do it,
VFS has no way to know.  And I certainly agree that using ->d_revalidate()
to trigger their unhashing is a bloody odd design; take it up with whoever
had come up with it...
