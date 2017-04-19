Return-Path: <jaegeuk@kernel.org>
Date: Wed, 19 Apr 2017 13:44:48 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: use 32 bytes of encrypted filename
Message-ID: <20170419204448.GA1021@jaegeuk.local>
References: <20170418210642.6039-1-gwendal@chromium.org>
 <20170418230136.GA96152@gmail.com>
 <20170419001005.GA143911@gmail.com>
 <20170419014209.GB12215@jaegeuk.local>
 <20170419040138.GA563@zzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419040138.GA563@zzz>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, ebiggers@google.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-mtd@lists.infradead.org, tytso@mit.edu, linux-ext4@vger.kernel.org, kinaba@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 04/18, Eric Biggers wrote:
> On Tue, Apr 18, 2017 at 06:42:09PM -0700, Jaegeuk Kim wrote:
> > Hi Eric,
> > 
> > On 04/18, Eric Biggers wrote:
> > > On Tue, Apr 18, 2017 at 04:01:36PM -0700, Eric Biggers wrote:
> > > > 
> > > > Strangely, f2fs and ubifs do not use the bytes from the filename at all when
> > > > trying to find a specific directory entry in this case.  So this patch doesn't
> > > > really affect them.  This seems unreliable; perhaps we should introduce a
> > > > function like "fscrypt_name_matches()" which all the filesystems could call?
> > > > Can any of the f2fs and ubifs developers explain why they don't look at any
> > > > bytes from the filename?
> > > > 
> > 
> > The fscrypt_setup_filename sets fname->hash in the bigname case, but doesn't
> > give fname->disk_name. If it's not such the bigname case, we check its name
> > since fname->hash is zero.
> > 
> 
> Yes, that's what it does now.  The question is, in the "bigname" case why
> doesn't f2fs check the 16 bytes of ciphertext in fname->crypto_buf too?  f2fs
> doesn't even use 'minor_hash'; it can't possibly be the case that there are
> never any collisions of a 32-bit hash in a directory, can it?
> 
> I actually tested it, and it definitely happens if you put a lot of files in an
> encrypted directory on f2fs.  An example with 100000 files:
> 
> # seq -f "edir/abcdefghijklmnopqrstuvwxyz012345%.0f" 100000 | xargs touch
> # find edir -type f | xargs stat -c %i | sort | uniq | wc -l
> 100000
> # sync
> # echo 3 > /proc/sys/vm/drop_caches
> # keyctl new_session
> # find edir -type f | xargs stat -c %i | sort | uniq | wc -l
> 99999
> 
> So when I tried accessing the encrypted directory without the key, two dentries
> showed the same inode, due to a hash collision.

Thank you for sharing more details. I could reproduce this issue and reach out
to what you mentioned. In order to resolve this, I wrote a patch for f2fs first
to act like ext4 for easy backports. Then, I expect a global fscrypt function
is easily able to clean them up.

Thanks,

>From 63ca24a64fb1625dac9740a2183fd8966388e185 Mon Sep 17 00:00:00 2001
From: Jaegeuk Kim <jaegeuk@kernel.org>
Date: Wed, 19 Apr 2017 10:49:21 -0700
Subject: [PATCH] f2fs: check entire encrypted bigname when finding a dentry

If user has no key under an encrypted dir, fscrypt gives digested dentries.
Previously, when looking up a dentry, f2fs only checks its hash value with
first 4 bytes of the digested dentry, which didn't handle hash collisions fully.
This patch enhances to check entire dentry bytes likewise ext4.

Eric reported how to reproduce this issue by:

 # seq -f "edir/abcdefghijklmnopqrstuvwxyz012345%.0f" 100000 | xargs touch
 # find edir -type f | xargs stat -c %i | sort | uniq | wc -l
100000
 # sync
 # echo 3 > /proc/sys/vm/drop_caches
 # keyctl new_session
 # find edir -type f | xargs stat -c %i | sort | uniq | wc -l
99999

Cc: <stable@vger.kernel.org>
Reported-by: Eric Biggers <ebiggers@google.com>
Signed-off-by: Jaegeuk Kim <jaegeuk@kernel.org>
---
 fs/f2fs/dir.c | 28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index c143dffcae6e..007c3b4adc85 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -130,19 +130,29 @@ struct f2fs_dir_entry *find_target_dentry(struct fscrypt_name *fname,
 			continue;
 		}
 
-		/* encrypted case */
+		if (de->hash_code != namehash)
+			goto not_match;
+
 		de_name.name = d->filename[bit_pos];
 		de_name.len = le16_to_cpu(de->name_len);
 
-		/* show encrypted name */
-		if (fname->hash) {
-			if (de->hash_code == cpu_to_le32(fname->hash))
-				goto found;
-		} else if (de_name.len == name->len &&
-			de->hash_code == namehash &&
-			!memcmp(de_name.name, name->name, name->len))
+#ifdef CONFIG_F2FS_FS_ENCRYPTION
+		if (unlikely(!name->name)) {
+			if (fname->usr_fname->name[0] == '_') {
+				if (de_name.len >= 16 &&
+					!memcmp(de_name.name + de_name.len - 16,
+						fname->crypto_buf.name + 8, 16))
+					goto found;
+				goto not_match;
+			}
+			name->name = fname->crypto_buf.name;
+			name->len = fname->crypto_buf.len;
+		}
+#endif
+		if (de_name.len == name->len &&
+				!memcmp(de_name.name, name->name, name->len))
 			goto found;
-
+not_match:
 		if (max_slots && max_len > *max_slots)
 			*max_slots = max_len;
 		max_len = 0;
-- 
2.11.0
