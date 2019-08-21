Return-Path: <SRS0=A8Az=WR=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: [PATCH 5/9] block: support diskcipher
Date: Wed, 21 Aug 2019 15:42:26 +0900
Message-ID: <004101d557eb$98b00060$ca100120$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190821064226epcas2p2835b8a9084988b79107e54abfc5e7dab@epcas2p2.samsung.com>
To: 'Jens Axboe' <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'  <tytso@mit.edu>,  'Chao Yu'  <chao@kernel.org>,  'Jaegeuk Kim' " <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>'Theodore Ts'o' <tytso@mit.edu>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.netlinux-samsung-soc, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This patch supports crypto information to be maintained via BIO
and passed to the storage driver.

To do this, 'bi_aux_private', 'REQ_CYPTE' and 'bi_dun' are added
to the block layer.

'bi_aux_private' is added for loading additional private information into
BIO.
'REQ_CRYPT' is added to distinguish that bi_aux_private is being used
for diskcipher.
F2FS among encryption users uses DUN(device unit number) as
the IV(initial vector) for cryptographic operations.
DUN is stored in 'bi_dun' of bi_iter as a specific value for each BIO.

Before attempting to merge the two BIOs, the operation is also added to
verify that the crypto information contained in two BIOs is consistent.

Cc: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Boojin Kim <boojin.kim@samsung.com>
---
 block/bio.c               |  1 +
 block/blk-merge.c         | 19 +++++++++++++++++--
 block/bounce.c            |  5 ++++-
 include/linux/bio.h       | 10 ++++++++++
 include/linux/blk_types.h |  4 ++++
 include/linux/bvec.h      |  3 +++
 6 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 5476965..c60eb8e 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -588,6 +588,7 @@ void __bio_clone_fast(struct bio *bio, struct bio
*bio_src)
 	bio->bi_write_hint = bio_src->bi_write_hint;
 	bio->bi_iter = bio_src->bi_iter;
 	bio->bi_io_vec = bio_src->bi_io_vec;
+	bio->bi_aux_private = bio_src->bi_aux_private;
 
 	bio_clone_blkg_association(bio, bio_src);
 	blkcg_bio_issue_init(bio);
diff --git a/block/blk-merge.c b/block/blk-merge.c
index 48e6725..d031257 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -7,6 +7,7 @@
 #include <linux/bio.h>
 #include <linux/blkdev.h>
 #include <linux/scatterlist.h>
+#include <crypto/diskcipher.h>
 
 #include <trace/events/block.h>
 
@@ -576,6 +577,8 @@ int ll_back_merge_fn(struct request *req, struct bio
*bio, unsigned int nr_segs)
 	if (blk_integrity_rq(req) &&
 	    integrity_req_gap_back_merge(req, bio))
 		return 0;
+	if (blk_try_merge(req, bio) != ELEVATOR_BACK_MERGE)
+		return 0;
 	if (blk_rq_sectors(req) + bio_sectors(bio) >
 	    blk_rq_get_max_sectors(req, blk_rq_pos(req))) {
 		req_set_nomerge(req->q, req);
@@ -592,6 +595,8 @@ int ll_front_merge_fn(struct request *req, struct bio
*bio, unsigned int nr_segs
 	if (blk_integrity_rq(req) &&
 	    integrity_req_gap_front_merge(req, bio))
 		return 0;
+	if (blk_try_merge(req, bio) != ELEVATOR_FRONT_MERGE)
+		return 0;
 	if (blk_rq_sectors(req) + bio_sectors(bio) >
 	    blk_rq_get_max_sectors(req, bio->bi_iter.bi_sector)) {
 		req_set_nomerge(req->q, req);
@@ -738,6 +743,9 @@ static struct request *attempt_merge(struct
request_queue *q,
 	    !blk_write_same_mergeable(req->bio, next->bio))
 		return NULL;
 
+	if (!crypto_diskcipher_blk_mergeble(req->bio, next->bio))
+		return NULL;
+
 	/*
 	 * Don't allow merge of different write hints, or for a hint with
 	 * non-hint IO.
@@ -887,9 +895,16 @@ enum elv_merge blk_try_merge(struct request *rq, struct
bio *bio)
 {
 	if (blk_discard_mergable(rq))
 		return ELEVATOR_DISCARD_MERGE;
-	else if (blk_rq_pos(rq) + blk_rq_sectors(rq) ==
bio->bi_iter.bi_sector)
+	else if (blk_rq_pos(rq) + blk_rq_sectors(rq) ==
+					bio->bi_iter.bi_sector) {
+		if (!crypto_diskcipher_blk_mergeble(rq->bio, bio))
+			return ELEVATOR_NO_MERGE;
 		return ELEVATOR_BACK_MERGE;
-	else if (blk_rq_pos(rq) - bio_sectors(bio) ==
bio->bi_iter.bi_sector)
+	} else if (blk_rq_pos(rq) - bio_sectors(bio) ==
+					bio->bi_iter.bi_sector) {
+		if (!crypto_diskcipher_blk_mergeble(bio, rq->bio))
+			return ELEVATOR_NO_MERGE;
 		return ELEVATOR_FRONT_MERGE;
+	}
 	return ELEVATOR_NO_MERGE;
 }
diff --git a/block/bounce.c b/block/bounce.c
index f8ed677..720b065 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -252,7 +252,10 @@ static struct bio *bounce_clone_bio(struct bio
*bio_src, gfp_t gfp_mask,
 	bio->bi_write_hint	= bio_src->bi_write_hint;
 	bio->bi_iter.bi_sector	= bio_src->bi_iter.bi_sector;
 	bio->bi_iter.bi_size	= bio_src->bi_iter.bi_size;
-
+	bio->bi_aux_private = bio_src->bi_aux_private;
+#ifdef CONFIG_CRYPTO_DISKCIPHER
+	bio->bi_iter.bi_dun = bio_src->bi_iter.bi_dun;
+#endif
 	switch (bio_op(bio)) {
 	case REQ_OP_DISCARD:
 	case REQ_OP_SECURE_ERASE:
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 3cdb84c..351e65e 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -49,6 +49,12 @@
 #define bio_sectors(bio)	bvec_iter_sectors((bio)->bi_iter)
 #define bio_end_sector(bio)	bvec_iter_end_sector((bio)->bi_iter)
 
+#ifdef CONFIG_CRYPTO_DISKCIPHER
+#define bio_dun(bio)            ((bio)->bi_iter.bi_dun)
+#define bio_duns(bio)           (bio_sectors(bio) >> 3) /* 4KB unit */
+#define bio_end_dun(bio)        (bio_dun(bio) + bio_duns(bio))
+#endif
+
 /*
  * Return the data direction, READ or WRITE.
  */
@@ -143,6 +149,10 @@ static inline void bio_advance_iter(struct bio *bio,
struct bvec_iter *iter,
 {
 	iter->bi_sector += bytes >> 9;
 
+#ifdef CONFIG_CRYPTO_DISKCIPHER
+	if (iter->bi_dun)
+		iter->bi_dun += bytes >> 12;
+#endif
 	if (bio_no_advance_iter(bio))
 		iter->bi_size -= bytes;
 	else
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 75059c1..117119a 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -160,6 +160,8 @@ struct bio {
 	bio_end_io_t		*bi_end_io;
 
 	void			*bi_private;
+	void			*bi_aux_private;
+
 #ifdef CONFIG_BLK_CGROUP
 	/*
 	 * Represents the association of the css and request_queue for the
bio.
@@ -311,6 +313,7 @@ enum req_flag_bits {
 	__REQ_INTEGRITY,	/* I/O includes block integrity payload */
 	__REQ_FUA,		/* forced unit access */
 	__REQ_PREFLUSH,		/* request for cache flush */
+	__REQ_CRYPT,		/* request inline crypt */
 	__REQ_RAHEAD,		/* read ahead, can fail anytime */
 	__REQ_BACKGROUND,	/* background IO */
 	__REQ_NOWAIT,           /* Don't wait if request will block */
@@ -343,6 +346,7 @@ enum req_flag_bits {
 #define REQ_NOMERGE		(1ULL << __REQ_NOMERGE)
 #define REQ_IDLE		(1ULL << __REQ_IDLE)
 #define REQ_INTEGRITY		(1ULL << __REQ_INTEGRITY)
+#define REQ_CRYPT		(1ULL << __REQ_CRYPT)
 #define REQ_FUA			(1ULL << __REQ_FUA)
 #define REQ_PREFLUSH		(1ULL << __REQ_PREFLUSH)
 #define REQ_RAHEAD		(1ULL << __REQ_RAHEAD)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index a032f01..5f89641 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -30,6 +30,9 @@ struct bvec_iter {
 
 	unsigned int            bi_bvec_done;	/* number of bytes completed
in
 						   current bvec */
+#ifdef CONFIG_CRYPTO_DISKCIPHER
+	u64                     bi_dun;
+#endif
 };
 
 struct bvec_iter_all {
-- 
2.7.4
