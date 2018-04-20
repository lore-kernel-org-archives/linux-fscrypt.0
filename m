Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pl0-f42.google.com ([209.85.160.42]:35093 "EHLO
        mail-pl0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751876AbeDTXbV (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 20 Apr 2018 19:31:21 -0400
Received: by mail-pl0-f42.google.com with SMTP id w21-v6so6030192plq.2
        for <linux-fscrypt@vger.kernel.org>; Fri, 20 Apr 2018 16:31:21 -0700 (PDT)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH] fscrypt: use unbound workqueue for decryption
Date: Fri, 20 Apr 2018 16:30:02 -0700
Message-Id: <20180420233002.134687-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Paul Crowley <paulcrowley@google.com>, Enric Balletbo i Serra <enric.balletbo@collabora.com>, Mikulas Patocka <mpatocka@redhat.com>, linux-kernel@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Improve fscrypt read performance by switching the decryption workqueue
from bound to unbound.  With the bound workqueue, when multiple bios
completed on the same CPU, they were decrypted on that same CPU.  But
with the unbound queue, they are now decrypted in parallel on any CPU.

Although fscrypt read performance can be tough to measure due to the
many sources of variation, this change is most beneficial when
decryption is slow, e.g. on CPUs without AES instructions.  For example,
I timed tarring up encrypted directories on f2fs.  On x86 with AES-NI
instructions disabled, the unbound workqueue improved performance by
about 25-35%, using 1 to NUM_CPUs jobs with 4 or 8 CPUs available.  But
with AES-NI enabled, performance was unchanged to within ~2%.

I also did the same test on a quad-core ARM CPU using xts-speck128-neon
encryption.  There performance was usually about 10% better with the
unbound workqueue, bringing it closer to the unencrypted speed.

The unbound workqueue may be worse in some cases due to worse locality,
but I think it's still the better default.  dm-crypt uses an unbound
workqueue by default too, so this change makes fscrypt match.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/crypto.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index ce654526c0fb..984e190f9b89 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -427,8 +427,17 @@ int fscrypt_initialize(unsigned int cop_flags)
  */
 static int __init fscrypt_init(void)
 {
+	/*
+	 * Use an unbound workqueue to allow bios to be decrypted in parallel
+	 * even when they happen to complete on the same CPU.  This sacrifices
+	 * locality, but it's worthwhile since decryption is CPU-intensive.
+	 *
+	 * Also use a high-priority workqueue to prioritize decryption work,
+	 * which blocks reads from completing, over regular application tasks.
+	 */
 	fscrypt_read_workqueue = alloc_workqueue("fscrypt_read_queue",
-							WQ_HIGHPRI, 0);
+						 WQ_UNBOUND | WQ_HIGHPRI,
+						 num_online_cpus());
 	if (!fscrypt_read_workqueue)
 		goto fail;
 
-- 
2.17.0.484.g0c8726318c-goog

