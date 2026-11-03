Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.118
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793719928;
	b=KLH4BOfIDZ81puXxYHfhT8JDpLM+0q7D/Je5VV3jRqc27qXCLmGinHRRCPuNz1zxqKtd
	 PwumVtZv7LFJTRC12+ZDD5LhbWAmIGbr1LNw7JFa5XXp1egQElGgnE/MnB/8UkANBLjqX
	 FjasopkWrEY0ldjfTKOFjWKzJGgrTg+/5++ELzMYZHm5Ja7p+o+NJvq7Hk3l5F/lEVMs5
	 +kmyDd5Tn4ioCl+46N3n8LTVq9Bbx+Ng0FGQP/pYqcdt/rWKCBJKK3hv69SL/pP3H2i97
	 EH23wbdy6wA7syGWf7UlT5hNkTi9V1WMr9QMkTTKNhf7boOjbMXxmNW2N5675In6QHA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793719928;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=xpIMSn7l3l6OBOGSWWNUxE8zcd+CUJHKxWoXv5WS5/A=;
	b=i8OriswRkZaRJOwwcbU3TrgoiAPMyNiyz11bk8r8UPnx8FyHl8frDYHrSbe1QRNPsjYX
	 o8DAwDVbOtzY09UrenrbSCz0WTBFufIwzh7ZJXglX37Hq1QMc5BzmGinnOzJOsQ9TI4Rq
	 A0PTwMvDDxuvx7P7YW+W1tc/E8iXZO4v2mGqEPb+Ril7dZ87TBxtOAeE73senpna1qOgj
	 aMSeNJbygC6nO+31HYketu6FsaycydBD9MUKN55B5RqmrzZ4wKmF3rk0+2jGkEBrUcHy+
	 z7yP01VCJeXQRzRHVNbHVGVOUYILXx+ASEEUu/RXxnjqxeJqA2M8Jn6ylUJGHxYFSOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b="ftTU31X/";
	arc=none smtp.remote-ip=115.124.30.118
Received: from out30-118.freemail.mail.aliyun.com (out30-118.freemail.mail.aliyun.com [115.124.30.118])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D2BC606A324;
	Tue,  3 Nov 2026 15:32:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0D2BC606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=ftTU31X/
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793719924; h=From:To:Subject:Date:Message-ID:MIME-Version;
	bh=xpIMSn7l3l6OBOGSWWNUxE8zcd+CUJHKxWoXv5WS5/A=;
	b=ftTU31X/prydL2d4t0mIUY1fjEdBkNT9MDgCebre06FIq7TJraCa5XWKF+GiutGLulcJ80uUPsajT/DDPnOqSY2zVZTDpx1ryC2wji7FaekQ26ZO9RRSg6IGHRk5f1q6jcnLvkVIaSNqQRN+K1CrMsbQ7CTCO5FoDpLjxulNngg=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R311e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045098064;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0XE3LUTu_1793719923;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XE3LUTu_1793719923 cluster:ay36)
          by smtp.aliyun-inc.com;
          Tue, 03 Nov 2026 23:32:03 +0800
From: Baokun Li <libaokun@linux.alibaba.com>
To: linux-fscrypt@vger.kernel.org
Cc: ebiggers@kernel.org,
	jaegeuk@kernel.org,
	tytso@mit.edu,
	linux-ext4@vger.kernel.org,
	adilger.kernel@dilger.ca,
	jack@suse.cz,
	yi.zhang@huawei.com,
	ojaswin@linux.ibm.com,
	ritesh.list@gmail.com,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/4] fscrypt: Validate the test_dummy_encryption policy for new inodes
Date: Tue,  3 Nov 2026 23:31:30 +0800
Message-ID: <20261103153132.4154855-3-libaokun@linux.alibaba.com>
X-Mailer: git-send-email 2.43.7
In-Reply-To: <20261103153132.4154855-1-libaokun@linux.alibaba.com>
References: <20261103153132.4154855-1-libaokun@linux.alibaba.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Policies set through FS_IOC_SET_ENCRYPTION_POLICY or inherited from
an encrypted directory are validated, but the test_dummy_encryption
policy is not.

fscrypt_prepare_new_inode() applies it directly to the new inode.
As a result, a v1 dummy policy on a filesystem whose block size
exceeds the page size is used unchecked, and data written under
it is lost at writeback.

Fix this by validating dummy policy in fscrypt_prepare_new_inode()
before applying it. Inodes in an encrypted directory inherit an
already validated policy, so the check only concerns the unencrypted
case where the dummy policy is used.

Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
---
 fs/crypto/keysetup.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index a77b889d7578..497ba67ec6fe 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -763,6 +763,14 @@ int fscrypt_prepare_new_inode(struct inode *dir, struct inode *inode,
 	    !S_ISLNK(inode->i_mode))
 		return 0;
 
+	/*
+	 * A policy inherited from an encrypted directory was validated
+	 * when the directory's key was set up.  The test dummy policy was
+	 * not, so check it here.
+	 */
+	if (!IS_ENCRYPTED(dir) && !fscrypt_supported_policy(policy, inode))
+		return -EINVAL;
+
 	*encrypt_ret = true;
 
 	get_random_bytes(nonce, FSCRYPT_FILE_NONCE_SIZE);
-- 
2.43.7

