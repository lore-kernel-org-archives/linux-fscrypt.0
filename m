Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Thu, 1 Aug 2019 11:46:47 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190801184646.GB223822@gmail.com>
References: <20190726224141.14044-1-ebiggers@kernel.org>
 <20190726224141.14044-8-ebiggers@kernel.org>
 <20190728192417.GG6088@mit.edu> <20190729195827.GF169027@gmail.com>
 <20190731183802.GA687@sol.localdomain>
 <20190731233843.GA2769@mit.edu>
 <20190801011140.GB687@sol.localdomain>
 <20190801053108.GD2769@mit.edu> <20190801183554.GA223822@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190801183554.GA223822@gmail.com>
Subject: Re: [f2fs-dev] [PATCH v7 07/16] fscrypt: add
 FS_IOC_REMOVE_ENCRYPTION_KEY ioctl
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: "Theodore Y. Ts'o" <tytso@mit.edu>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-api@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Satya Tangirala <satyat@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Aug 01, 2019 at 11:35:56AM -0700, Eric Biggers wrote:
> 
> "fscrypt lock" actually doesn't exist yet; it's a missing feature.  My patch to
> the fscrypt tool adds it.  So we get to decide on the semantics.  We don't want
> to require root, though; so for v2 policy keys, the real semantics have to be
> that "fscrypt lock" registers the key for the user, and "fscrypt unlock"
> unregisters it for the user.
> 

I meant the other way around, of course: "fscrypt unlock" registers the key for
the user, and "fscrypt lock" unregisters it for the user.

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
