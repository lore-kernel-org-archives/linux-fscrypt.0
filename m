Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Wed, 20 Feb 2019 10:36:20 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v3 00/18] fscrypt: key management improvements
Message-ID: <20190220183619.GA177939@gmail.com>
References: <20190220065249.32099-1-ebiggers@kernel.org>
 <14023.1550686042@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14023.1550686042@warthog.procyon.org.uk>
Sender: linux-crypto-owner@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Cc: linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>, linux-api@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, keyrings@vger.kernel.org, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi David,

On Wed, Feb 20, 2019 at 06:07:22PM +0000, David Howells wrote:
> I have a couple of patches that add ACLs to keyrings, that you can find at the
> top of the branch here:
> 
> 	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=keys-acl
> 
> I have other patches that allow tags to be used as subjects in the ACL, with a
> container supplying a tag, e.g.:
> 
> 	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/commit/?h=container&id=e0fdc5613a32b9475b025f58e7a2267329b3f3a4
> 
> Might something similar be of use to you here, perhaps specifying a tag
> referring to the blockdev of interest rather than the container?
> 
> David

I don't think so.  The main point of adding keys directly to the filesystem is
that it's generally inappropriate to apply OS-level access control or
process-based visibility restrictions to fscrypt keys given that:

- The unlocked/locked status of files is already filesystem-level.
- The purpose of encryption is orthogonal to OS-level access control.

The ioctl based interface also makes it *much* easier to implement all the
semantics needed for removing fscrypt keys.

I don't see how key ACLs would be appropriate here, except that key ACLs would
allow userspace to opt-in to fixing the denial of service vulnerability where
keyctl_invalidate() only requires Search permission.  But for fscrypt that's
addressed by my proposal too, and is just one of many problems it addresses.

- Eric
