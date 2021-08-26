Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.7 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2255CC25AEE
	for <linux-fscrypt@archiver.kernel.org>; Thu, 26 Aug 2021 16:20:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 08986611C0
	for <linux-fscrypt@archiver.kernel.org>; Thu, 26 Aug 2021 16:20:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S243223AbhHZQVd (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 26 Aug 2021 12:21:33 -0400
Received: from mail.kernel.org ([198.145.29.99]:44862 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S243142AbhHZQVT (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 26 Aug 2021 12:21:19 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id BE60961159;
        Thu, 26 Aug 2021 16:20:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1629994832;
        bh=Zen3/R3gd0+91Qt1rm31/H+gDoiBd2S5RAAzCVMbBAQ=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=LhRJhUv8aY9ONWgodgNJ0AMmDs3K3ArGxHDl+vrJ7HFoWo3qqKDBlF9/qUlsBu2+Z
         K5NUgad5gO5mbYkufLzSW+kG5GuWRA1hwlWLZeX09ELKyZxl7kC/abD1sm5mnMAqDV
         Oq8OmMRoFg7fQrGJM9RQblrZkRTfDYq5777lLF3B7Z4eDhzhQ1ZGVBLEOl3lPF3m1h
         vqaleEvDztdhU52cHj7wasWNVwx9ujROLYEYKm4q0bu19pnn9gDZOOYVo7alehMfQg
         vpRbVqaIfN247O+oRnpiUp5sr5XeLiX6Fb659jKcNRS97qYXkITLhMUHLOa+h1G4b+
         3wlyUP9y3AJVA==
From:   Jeff Layton <jlayton@kernel.org>
To:     ceph-devel@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        dhowells@redhat.com, xiubli@redhat.com, lhenriques@suse.de,
        khiremat@redhat.com, ebiggers@kernel.org
Subject: [RFC PATCH v8 17/24] ceph: properly set DCACHE_NOKEY_NAME flag in lookup
Date:   Thu, 26 Aug 2021 12:20:07 -0400
Message-Id: <20210826162014.73464-18-jlayton@kernel.org>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <20210826162014.73464-1-jlayton@kernel.org>
References: <20210826162014.73464-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

This is required so that we know to invalidate these dentries when the
directory is unlocked.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/ceph/dir.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/ceph/dir.c b/fs/ceph/dir.c
index 288f6f0b4b74..4fa776d8fa53 100644
--- a/fs/ceph/dir.c
+++ b/fs/ceph/dir.c
@@ -751,6 +751,17 @@ static struct dentry *ceph_lookup(struct inode *dir, struct dentry *dentry,
 	if (dentry->d_name.len > NAME_MAX)
 		return ERR_PTR(-ENAMETOOLONG);
 
+	if (IS_ENCRYPTED(dir)) {
+		err = __fscrypt_prepare_readdir(dir);
+		if (err)
+			return ERR_PTR(err);
+		if (!fscrypt_has_encryption_key(dir)) {
+			spin_lock(&dentry->d_lock);
+			dentry->d_flags |= DCACHE_NOKEY_NAME;
+			spin_unlock(&dentry->d_lock);
+		}
+	}
+
 	/* can we conclude ENOENT locally? */
 	if (d_really_is_negative(dentry)) {
 		struct ceph_inode_info *ci = ceph_inode(dir);
-- 
2.31.1

