Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from b.ns.miles-group.at ([95.130.255.144]:44725 "EHLO radon.swed.at"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933464AbdEOOj0 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 15 May 2017 10:39:26 -0400
From: Richard Weinberger <richard@nod.at>
Subject: Question on fscrypt_d_revalidate() and fstest generic/429
Message-ID: <e2d845a3-a863-1506-a0de-576049c84e81@nod.at>
Date: Mon, 15 May 2017 16:39:23 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, David Gstir <david@sigma-star.at>, David Oberhollenzer <david.oberhollenzer@sigma-star.at>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi!

on UBIFS, fstest generic/429 fails due to -ENFILE because the internal orphan
list reaches the maximum size.
When you unlink a file, the inode goes into the orphan list, in UBIFS' evict() function
it is being removed later. So, only unlinked but used inodes should stay in that list.

If a directory is encrypted, evict() is not being called although the inode has no
users anymore.
It turned out evict() is not being called because fscrypt's fscrypt_d_revalidate()
function.
When I omit fscrypt_set_d_op() in UBIFS code, the test works just fine.

Can it be that fscrypt_d_revalidate() misses the case of i_nlink being 0?
It seem to treat unlinked inodes as already gone and they stay.

The following change makes the problem go away here:

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 6d6eca394d4d..d0c19838e513 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -327,6 +327,7 @@ EXPORT_SYMBOL(fscrypt_decrypt_page);
 static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 {
        struct dentry *dir;
+       struct inode *inode = d_inode(dentry);
        int dir_has_key, cached_with_key;

        if (flags & LOOKUP_RCU)
@@ -359,6 +360,10 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
                        (!cached_with_key && dir_has_key) ||
                        (cached_with_key && !dir_has_key))
                return 0;
+
+       if (!inode || inode->i_nlink == 0)
+               return 0;
+
        return 1;
 }

Does this change make sense? TBH, I'm not really an expert in this area and it is also
not clear to me why you don't see these issue on ext4 or f2fs.
Maybe UBIFS' limitations kick in much earlier. ;-)

Thanks,
//richard
