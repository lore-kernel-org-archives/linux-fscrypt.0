Return-Path: <richard@nod.at>
Subject: Re: Question on fscrypt_d_revalidate() and fstest generic/429
References: <e2d845a3-a863-1506-a0de-576049c84e81@nod.at>
 <20170515194553.GA20264@gmail.com>
 <489e1437-990f-3e88-d426-b47b82441009@nod.at>
 <20170515235035.GO390@ZenIV.linux.org.uk>
From: Richard Weinberger <richard@nod.at>
Message-ID: <450be703-3e1a-8b2c-d6e6-03054c6a969b@nod.at>
Date: Tue, 16 May 2017 13:22:44 +0200
MIME-Version: 1.0
In-Reply-To: <20170515235035.GO390@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, David Gstir <david@sigma-star.at>, David Oberhollenzer <david.oberhollenzer@sigma-star.at>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Al,

Am 16.05.2017 um 01:50 schrieb Al Viro:
> On Mon, May 15, 2017 at 09:51:03PM +0200, Richard Weinberger wrote:
> 
>>> I doubt it's the right solution to make fscrypt_d_revalidate() look at
>>> ->i_nlink, since ->d_revalidate() is meant to validate the filename, not the
>>> inode.  I think there is probably a VFS bug that is causing the dentries to not
>>> be freed.
>>
>> Not sure. Al? :-)
> 
> What's to tell VFS that they are garbage?  If your code doesn't do it,
> VFS has no way to know.  And I certainly agree that using ->d_revalidate()
> to trigger their unhashing is a bloody odd design; take it up with whoever
> had come up with it...

Not sure whether I understood your answer.
What is the preferred way to inform VFS that the dentry is no longer valid?

Thanks,
//richard
