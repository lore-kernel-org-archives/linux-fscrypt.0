Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Mon, 29 Jul 2019 16:14:45 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Message-ID: <20190729201445.GA16445@mit.edu>
References: <20190726224141.14044-1-ebiggers@kernel.org>
 <20190726224141.14044-7-ebiggers@kernel.org>
 <20190728185003.GF6088@mit.edu> <20190729194644.GE169027@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190729194644.GE169027@gmail.com>
Subject: Re: [f2fs-dev] [PATCH v7 06/16] fscrypt: add
 FS_IOC_ADD_ENCRYPTION_KEY ioctl
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
To: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-api@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Satya Tangirala <satyat@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jul 29, 2019 at 12:46:45PM -0700, Eric Biggers wrote:
> > For that matter, we could just add a new ioctl which returns the file
> > system's keyring id.  That way an application program won't have to
> > try to figure out what a file's underlying sb->s_id happens to be.
> > (Especially if things like overlayfs are involved.)
> 
> Keep in mind that the new ioctls (FS_IOC_ADD_ENCRYPTION_KEY,
> FS_IOC_REMOVE_ENCRYPTION_KEY, FS_IOC_GET_ENCRYPTION_KEY_STATUS) don't take the
> keyring ID as a parameter, since it's already known from the filesystem the
> ioctl is executed on.  So there actually isn't much that can be done with the
> keyring ID.  But sure, if it's needed later we can add an API to get it.

Yeah, I was thinking about for testing/debugging purposes so that we
could use keyctl to examine the per-file system keyring and see what
keys are attached to a file system.  This is only going to be usable
by root, so I guess we can just try to figure it out by going through
/proc/keys and searching by sb->s_id.  If there are ambiguities that
make this hard to do, we can add an interface to make this easier.

     	       	      	     - Ted


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
