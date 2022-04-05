Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19A2CC47081
	for <linux-fscrypt@archiver.kernel.org>; Wed,  6 Apr 2022 05:19:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1446917AbiDFFTb (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 6 Apr 2022 01:19:31 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36664 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1573573AbiDETWy (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Apr 2022 15:22:54 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4489347ACB;
        Tue,  5 Apr 2022 12:20:56 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id D6299617EE;
        Tue,  5 Apr 2022 19:20:55 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B7EBC385A3;
        Tue,  5 Apr 2022 19:20:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1649186455;
        bh=wuel0yRpvqoH42Shg0phMCGGxQASot3eqVV2HwOD7gc=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=VKJuTRiHJZSsnavBh4ApUesE7dAteXIDTW0TI5t1JbNUsVsjzWFNsDdsKvPP3855c
         M6i7YsE8mD9NgZCGl0hlLG8U6iqmjGturZFM09UvpopaTwhFFGH1I/lofFP2ZT9wPf
         6lp/9beYBIE4Cnn9PzAJM+wjpb9vyD92BuSyD6y9lsf9nWOJ3R83BJoFbbLaKnp9KL
         SeVlDrYh6+U1FnmXz0nvlBM7bCJyX8Y2fw2dVzQpJzVnpVC3X5PuUetkuxxUrMePhm
         cAcSlYaHNPqJ5TaulfkqLMyQUcCJbYUAnIPHjkur3pplzKxsySPTxKyGnB5ImO6R61
         XKkHmM/apDlug==
From:   Jeff Layton <jlayton@kernel.org>
To:     idryomov@gmail.com, xiubli@redhat.com
Cc:     ceph-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
        lhenriques@suse.de
Subject: [PATCH v13 25/59] ceph: set DCACHE_NOKEY_NAME in atomic open
Date:   Tue,  5 Apr 2022 15:19:56 -0400
Message-Id: <20220405192030.178326-26-jlayton@kernel.org>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220405192030.178326-1-jlayton@kernel.org>
References: <20220405192030.178326-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Atomic open can act as a lookup if handed a dentry that is negative on
the MDS. Ensure that we set DCACHE_NOKEY_NAME on the dentry in
atomic_open, if we don't have the key for the parent. Otherwise, we can
end up validating the dentry inappropriately if someone later adds a
key.

Reviewed-by: Xiubo Li <xiubli@redhat.com>
Reviewed-by: Luís Henriques <lhenriques@suse.de>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/ceph/file.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index dd183d12a3bd..dfc02caf4229 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -758,6 +758,13 @@ int ceph_atomic_open(struct inode *dir, struct dentry *dentry,
 	req->r_args.open.mask = cpu_to_le32(mask);
 	req->r_parent = dir;
 	ihold(dir);
+	if (IS_ENCRYPTED(dir)) {
+		if (!fscrypt_has_encryption_key(dir)) {
+			spin_lock(&dentry->d_lock);
+			dentry->d_flags |= DCACHE_NOKEY_NAME;
+			spin_unlock(&dentry->d_lock);
+		}
+	}
 
 	if (flags & O_CREAT) {
 		struct ceph_file_layout lo;
-- 
2.35.1

