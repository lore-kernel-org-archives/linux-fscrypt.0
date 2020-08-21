Return-Path: <SRS0=i3fj=B7=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7292CC433E1
	for <linux-fscrypt@archiver.kernel.org>; Fri, 21 Aug 2020 18:29:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4B28F230FF
	for <linux-fscrypt@archiver.kernel.org>; Fri, 21 Aug 2020 18:29:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1598034557;
	bh=9/0cF3waO5SHLTvMbsBohWY6v0JOypTyA4ajf/JdgJg=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=OfEMgm/KaOGrgpNUcuffM2upTxqOB5YE75rXyBuDPQrG7Xz/vtkfO1Rx5FyUfi1Oz
	 5Wtg/4UH5xhH5IwSByIYbB4QWY67vKcYZOtLTNsnNEXcDnG0D6WYLJcod52gbyxun3
	 jr+PHpZFRh2O1oe3FjRi/XLU1d8OYTNyFja6jb/w=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726661AbgHUS2t (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 21 Aug 2020 14:28:49 -0400
Received: from mail.kernel.org ([198.145.29.99]:59388 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726664AbgHUS2W (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 21 Aug 2020 14:28:22 -0400
Received: from tleilax.com (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id DB0C623105;
        Fri, 21 Aug 2020 18:28:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1598034502;
        bh=9/0cF3waO5SHLTvMbsBohWY6v0JOypTyA4ajf/JdgJg=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=IjceX9vX0/fsLqLeelFXlLDVjFMCtoF9YEA9MA5rOJAx8I0y+duIsdsIo7TajcaQA
         wdd7J16wW0cdMpx9IY1dn0hkXFob7i7KGNxLpeu0Q+A4QlumvNzznoy6OvvD2BAJSe
         AZyXZaaRFyToCGYU3W0zyv3xt9AiA2S2QWso4fCI=
From:   Jeff Layton <jlayton@kernel.org>
To:     ceph-devel@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: [RFC PATCH 14/14] ceph: add fscrypt support to ceph_fill_trace
Date:   Fri, 21 Aug 2020 14:28:13 -0400
Message-Id: <20200821182813.52570-15-jlayton@kernel.org>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20200821182813.52570-1-jlayton@kernel.org>
References: <20200821182813.52570-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

When we get a dentry in a trace, decrypt the name so we can properly
instantiate the dentry.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/ceph/inode.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 007d01b7a2ba..945c25e7ed20 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -1273,6 +1273,7 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 		    !test_bit(CEPH_MDS_R_ABORTED, &req->r_req_flags)) {
 			struct qstr dname;
 			struct dentry *dn, *parent;
+			struct fscrypt_str oname = FSTR_INIT(NULL, 0);
 
 			BUG_ON(!rinfo->head->is_target);
 			BUG_ON(req->r_dentry);
@@ -1280,8 +1281,20 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 			parent = d_find_any_alias(dir);
 			BUG_ON(!parent);
 
-			dname.name = rinfo->dname;
-			dname.len = rinfo->dname_len;
+			err = ceph_fname_alloc_buffer(dir, &oname);
+			if (err < 0) {
+				dput(parent);
+				goto done;
+			}
+
+			err = ceph_fname_to_usr(dir, rinfo->dname, rinfo->dname_len, NULL, &oname);
+			if (err < 0) {
+				dput(parent);
+				ceph_fname_free_buffer(dir, &oname);
+				goto done;
+			}
+			dname.name = oname.name;
+			dname.len = oname.len;
 			dname.hash = full_name_hash(parent, dname.name, dname.len);
 			tvino.ino = le64_to_cpu(rinfo->targeti.in->ino);
 			tvino.snap = le64_to_cpu(rinfo->targeti.in->snapid);
@@ -1296,9 +1309,15 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 				     dname.len, dname.name, dn);
 				if (!dn) {
 					dput(parent);
+					ceph_fname_free_buffer(dir, &oname);
 					err = -ENOMEM;
 					goto done;
 				}
+				if (IS_ENCRYPTED(dir) && !fscrypt_has_encryption_key(dir)) {
+					spin_lock(&dn->d_lock);
+					dn->d_flags |= DCACHE_ENCRYPTED_NAME;
+					spin_unlock(&dn->d_lock);
+				}
 				err = 0;
 			} else if (d_really_is_positive(dn) &&
 				   (ceph_ino(d_inode(dn)) != tvino.ino ||
@@ -1310,6 +1329,7 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 				dput(dn);
 				goto retry_lookup;
 			}
+			ceph_fname_free_buffer(dir, &oname);
 
 			req->r_dentry = dn;
 			dput(parent);
-- 
2.26.2

