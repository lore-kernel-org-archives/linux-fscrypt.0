Return-Path: <SRS0=vlGn=Q3=redhat.com=dhowells@kernel.org>
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20190220065249.32099-1-ebiggers@kernel.org>
References: <20190220065249.32099-1-ebiggers@kernel.org>
Subject: Re: [RFC PATCH v3 00/18] fscrypt: key management improvements
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <14022.1550686042.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Feb 2019 18:07:22 +0000
Message-ID: <14023.1550686042@warthog.procyon.org.uk>
To: Eric Biggers <ebiggers@kernel.org>
Cc: dhowells@redhat.com, linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>, linux-api@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, keyrings@vger.kernel.org, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

I have a couple of patches that add ACLs to keyrings, that you can find at=
 the
top of the branch here:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log=
/?h=3Dkeys-acl

I have other patches that allow tags to be used as subjects in the ACL, wi=
th a
container supplying a tag, e.g.:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/com=
mit/?h=3Dcontainer&id=3De0fdc5613a32b9475b025f58e7a2267329b3f3a4

Might something similar be of use to you here, perhaps specifying a tag
referring to the blockdev of interest rather than the container?

David
