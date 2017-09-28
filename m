Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 2/7] FS-Cache: fix dereference of NULL user_key_payload
Date: Thu, 28 Sep 2017 14:25:57 -0700
Message-Id: <20170928212602.41744-3-ebiggers3@gmail.com>
In-Reply-To: <20170928212602.41744-1-ebiggers3@gmail.com>
References: <20170928212602.41744-1-ebiggers3@gmail.com>
To: keyrings@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, Michael Halcrow <mhalcrow@google.com>, linux-cachefs@redhat.com, ecryptfs@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

When the file /proc/fs/fscache/objects (available with
CONFIG_FSCACHE_OBJECT_LIST=y) is opened, we request a user key with
description "fscache:objlist", then access its payload.  However, a
revoked key has a NULL payload, and we failed to check for this.
request_key() *does* skip revoked keys, but there is still a window
where the key can be revoked before we access its payload.

Fix it by checking for a NULL payload, treating it like a key which was
already revoked at the time it was requested.

Fixes: 4fbf4291aa15 ("FS-Cache: Allow the current state of all objects to be dumped")
Cc: <stable@vger.kernel.org>    [v2.6.32+]
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/fscache/object-list.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/fscache/object-list.c b/fs/fscache/object-list.c
index b5ab06fabc60..0438d4cd91ef 100644
--- a/fs/fscache/object-list.c
+++ b/fs/fscache/object-list.c
@@ -331,6 +331,13 @@ static void fscache_objlist_config(struct fscache_objlist_data *data)
 	rcu_read_lock();
 
 	confkey = user_key_payload_rcu(key);
+	if (!confkey) {
+		/* key was revoked */
+		rcu_read_unlock();
+		key_put(key);
+		goto no_config;
+	}
+
 	buf = confkey->data;
 
 	for (len = confkey->datalen - 1; len >= 0; len--) {
-- 
2.14.2.822.g60be5d43e6-goog
