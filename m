Return-Path: <linux-fsdevel-owner@vger.kernel.org>
From: Michael Halcrow <mhalcrow@google.com>
Subject: [RFC PATCH 2/4] dm-crypt: Skip encryption of file system-encrypted blocks
Date: Wed, 14 Jun 2017 16:40:38 -0700
Message-Id: <20170614234040.4326-3-mhalcrow@google.com>
In-Reply-To: <20170614234040.4326-1-mhalcrow@google.com>
References: <20170614234040.4326-1-mhalcrow@google.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Michael Halcrow <mhalcrow@google.com>, "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, dm-devel@redhat.com, linux-ext4@vger.kernel.org, Tyler Hicks <tyler.hicks@canonical.com>
List-ID: <linux-fscrypt@vger.kernel.org>

File systems can encrypt some of their data blocks with their own
encryption keys, and for those blocks another round of encryption at
the dm-crypt layer may be redundant, depending on the keys being used.

This patch enables dm-crypt to observe the REQ_NOENCRYPT flag as an
indicator that a bio request should bypass the dm-crypt encryption
queue.

By default dm-crypt will ignore this request flag from the file
system.  The user must set the allow_encrypt_override option to enable
this functionality.  Once the dm-crypt has been used with the
allow_encrypt_override option for any given block device, it must
continue to be used with the option to avoid the possibility of data
corruption.

Signed-off-by: Michael Halcrow <mhalcrow@google.com>
---
 drivers/md/dm-crypt.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index ebf9e72d479b..14ca8a6de3d9 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -125,7 +125,8 @@ struct iv_tcw_private {
  * and encrypts / decrypts at the same time.
  */
 enum flags { DM_CRYPT_SUSPENDED, DM_CRYPT_KEY_VALID,
-	     DM_CRYPT_SAME_CPU, DM_CRYPT_NO_OFFLOAD };
+	     DM_CRYPT_SAME_CPU, DM_CRYPT_NO_OFFLOAD,
+	     DM_CRYPT_ENCRYPT_OVERRIDE };
 
 enum cipher_flags {
 	CRYPT_MODE_INTEGRITY_AEAD,	/* Use authenticated mode for cihper */
@@ -2572,6 +2573,8 @@ static int crypt_ctr_optional(struct dm_target *ti, unsigned int argc, char **ar
 			cc->sector_shift = __ffs(cc->sector_size) - SECTOR_SHIFT;
 		} else if (!strcasecmp(opt_string, "iv_large_sectors"))
 			set_bit(CRYPT_IV_LARGE_SECTORS, &cc->cipher_flags);
+		else if (!strcasecmp(opt_string, "allow_encrypt_override"))
+			set_bit(DM_CRYPT_ENCRYPT_OVERRIDE, &cc->flags);
 		else {
 			ti->error = "Invalid feature arguments";
 			return -EINVAL;
@@ -2770,12 +2773,15 @@ static int crypt_map(struct dm_target *ti, struct bio *bio)
 	struct crypt_config *cc = ti->private;
 
 	/*
-	 * If bio is REQ_PREFLUSH or REQ_OP_DISCARD, just bypass crypt queues.
+	 * If bio is REQ_PREFLUSH, REQ_NOENCRYPT, or REQ_OP_DISCARD,
+	 * just bypass crypt queues.
 	 * - for REQ_PREFLUSH device-mapper core ensures that no IO is in-flight
 	 * - for REQ_OP_DISCARD caller must use flush if IO ordering matters
 	 */
-	if (unlikely(bio->bi_opf & REQ_PREFLUSH ||
-	    bio_op(bio) == REQ_OP_DISCARD)) {
+	if (unlikely(bio->bi_opf & REQ_PREFLUSH) ||
+	    (unlikely(bio->bi_opf & REQ_NOENCRYPT) &&
+	     test_bit(DM_CRYPT_ENCRYPT_OVERRIDE, &cc->flags)) ||
+	    bio_op(bio) == REQ_OP_DISCARD) {
 		bio->bi_bdev = cc->dev->bdev;
 		if (bio_sectors(bio))
 			bio->bi_iter.bi_sector = cc->start +
@@ -2862,6 +2868,7 @@ static void crypt_status(struct dm_target *ti, status_type_t type,
 		num_feature_args += test_bit(DM_CRYPT_NO_OFFLOAD, &cc->flags);
 		num_feature_args += cc->sector_size != (1 << SECTOR_SHIFT);
 		num_feature_args += test_bit(CRYPT_IV_LARGE_SECTORS, &cc->cipher_flags);
+		num_feature_args += test_bit(DM_CRYPT_ENCRYPT_OVERRIDE, &cc->flags);
 		if (cc->on_disk_tag_size)
 			num_feature_args++;
 		if (num_feature_args) {
@@ -2878,6 +2885,8 @@ static void crypt_status(struct dm_target *ti, status_type_t type,
 				DMEMIT(" sector_size:%d", cc->sector_size);
 			if (test_bit(CRYPT_IV_LARGE_SECTORS, &cc->cipher_flags))
 				DMEMIT(" iv_large_sectors");
+			if (test_bit(DM_CRYPT_ENCRYPT_OVERRIDE, &cc->flags))
+				DMEMIT(" allow_encrypt_override");
 		}
 
 		break;
-- 
2.13.1.508.gb3defc5cc-goog
