Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56378C49EAF
	for <linux-fscrypt@archiver.kernel.org>; Fri, 25 Jun 2021 13:59:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 43B4061458
	for <linux-fscrypt@archiver.kernel.org>; Fri, 25 Jun 2021 13:59:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232256AbhFYOBo (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 25 Jun 2021 10:01:44 -0400
Received: from mail.kernel.org ([198.145.29.99]:33754 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231985AbhFYOBP (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 25 Jun 2021 10:01:15 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 0BCDE61984;
        Fri, 25 Jun 2021 13:58:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1624629534;
        bh=db+LS7b/7zUKL9f/0cLTCPdRweBGyRCMYQHNKLZpAaI=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=nRXyCji2wjtsfhCOPtfA/HGpcCeeONVpFHeOC8JOpHCw9hI7FWDIgXt/6tDAEs48s
         nFkY+F2IeZp/9V1WYa8fRy8B1nodiTGIiFfEvciZCmXa5BpZibqs6hX4unvRQujkMt
         phSiDVG0CBRYPVUJ6HAq98qQyCKyXRrWmxxaiZuZl5Mvwe/h0xD0AyYVEGTNkzXaSc
         uiKvz3VOxheWPf2GF/ERHeCmyzrWthLYBripwIDKmNP+0GZgdVWJJvEfJzBFebdNqo
         0lbv4eZmfO6joc0oVzwNB/nRGjCXfUjcaz0GNl3ronQnwwxFC44AJZLn3XCQQ7w7nU
         7t6cSESA0ZQlA==
From:   Jeff Layton <jlayton@kernel.org>
To:     ceph-devel@vger.kernel.org
Cc:     lhenriques@suse.de, xiubli@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        dhowells@redhat.com
Subject: [RFC PATCH v7 24/24] ceph: add a new ceph.fscrypt.auth vxattr
Date:   Fri, 25 Jun 2021 09:58:34 -0400
Message-Id: <20210625135834.12934-25-jlayton@kernel.org>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <20210625135834.12934-1-jlayton@kernel.org>
References: <20210625135834.12934-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/ceph/xattr.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
index 16a62a2bd61e..b175b3029dc0 100644
--- a/fs/ceph/xattr.c
+++ b/fs/ceph/xattr.c
@@ -340,6 +340,16 @@ static ssize_t ceph_vxattrcb_caps(struct ceph_inode_info *ci, char *val,
 			      ceph_cap_string(issued), issued);
 }
 
+static ssize_t ceph_vxattrcb_fscrypt_auth(struct ceph_inode_info *ci, char *val, size_t size)
+{
+	if (size) {
+		if (size < ci->fscrypt_auth_len)
+			return -ERANGE;
+		memcpy(val, ci->fscrypt_auth, ci->fscrypt_auth_len);
+	}
+	return ci->fscrypt_auth_len;
+}
+
 #define CEPH_XATTR_NAME(_type, _name)	XATTR_CEPH_PREFIX #_type "." #_name
 #define CEPH_XATTR_NAME2(_type, _name, _name2)	\
 	XATTR_CEPH_PREFIX #_type "." #_name "." #_name2
@@ -473,6 +483,13 @@ static struct ceph_vxattr ceph_common_vxattrs[] = {
 		.exists_cb = NULL,
 		.flags = VXATTR_FLAG_READONLY,
 	},
+	{
+		.name = "ceph.fscrypt.auth",
+		.name_size = sizeof("ceph.fscrypt.auth"),
+		.getxattr_cb = ceph_vxattrcb_fscrypt_auth,
+		.exists_cb = NULL,
+		.flags = VXATTR_FLAG_READONLY,
+	},
 	{ .name = NULL, 0 }	/* Required table terminator */
 };
 
-- 
2.31.1

