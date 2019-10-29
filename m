Return-Path: <SRS0=+Ybm=YW=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67BC7CA9EC3
	for <linux-fscrypt@archiver.kernel.org>; Tue, 29 Oct 2019 20:43:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 30B8C208E3
	for <linux-fscrypt@archiver.kernel.org>; Tue, 29 Oct 2019 20:43:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1572381837;
	bh=6uKinpfPcLRaz3evDg6XWZp9GRM69VU/7RKl098ZYrc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=REZNEnPaJlj5RYlVhP3w9x2UzVESRfPLOSsHdi2eUH24yiDeJcjPCZI/YnnVM1Szo
	 k+B/vnAYHi6M42bQfQ7B3XVL3bKbEVB90B8JlfD+hJtuHk8k3yzm/6m8Rdt1y3PdLr
	 NnBjoCEVceoRqJuWfUCApEPa3Nt0teBE3Zdadods=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728118AbfJ2Un4 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 29 Oct 2019 16:43:56 -0400
Received: from mail.kernel.org ([198.145.29.99]:34752 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725840AbfJ2Un4 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 29 Oct 2019 16:43:56 -0400
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 928D521479;
        Tue, 29 Oct 2019 20:43:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1572381835;
        bh=6uKinpfPcLRaz3evDg6XWZp9GRM69VU/7RKl098ZYrc=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=F1vqZRv2eFon0GtBrubS3F8e3n4v3lX+Jc7jDQg+EZxKCGfEixUVBHBkysbExqltN
         roBhndZO2TwSgAGdgGQDvkeehTBKaAmzZ3De6S2jApC8pcFCkEdmVptT1PczW0qk0K
         jbi9gPsqlqJrizoOxtRc9vp5wHXzAHRlP9oxJ79A=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-api@vger.kernel.org,
        David Howells <dhowells@redhat.com>,
        Theodore Ts'o <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Victor Hsieh <victorhsieh@google.com>
Subject: [PATCH 2/4] ext4: support STATX_ATTR_VERITY
Date:   Tue, 29 Oct 2019 13:41:39 -0700
Message-Id: <20191029204141.145309-3-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.0.rc1.363.gb1bccd3e3d-goog
In-Reply-To: <20191029204141.145309-1-ebiggers@kernel.org>
References: <20191029204141.145309-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Set the STATX_ATTR_VERITY bit when the statx() system call is used on a
verity file on ext4.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/inode.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 516faa280ceda8..a7ca6517798008 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5717,12 +5717,15 @@ int ext4_getattr(const struct path *path, struct kstat *stat,
 		stat->attributes |= STATX_ATTR_IMMUTABLE;
 	if (flags & EXT4_NODUMP_FL)
 		stat->attributes |= STATX_ATTR_NODUMP;
+	if (flags & EXT4_VERITY_FL)
+		stat->attributes |= STATX_ATTR_VERITY;
 
 	stat->attributes_mask |= (STATX_ATTR_APPEND |
 				  STATX_ATTR_COMPRESSED |
 				  STATX_ATTR_ENCRYPTED |
 				  STATX_ATTR_IMMUTABLE |
-				  STATX_ATTR_NODUMP);
+				  STATX_ATTR_NODUMP |
+				  STATX_ATTR_VERITY);
 
 	generic_fillattr(inode, stat);
 	return 0;
-- 
2.24.0.rc1.363.gb1bccd3e3d-goog

