Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794961780;
	b=AZ5K8ZE5iLymVjyzzMtHJOx8agyaevDah4jdMCw+E3HOQTPks4T8AeQTNLu3UCQPbPv5
	 YMNFieAR9V18MoQTAgiymZIBJJbEdImq+gMiTSEKkp/A9+4xhn4bF1Bg7laY7vTXfiYf1
	 Qwf1sIjnVeVXtkwlweplZ7onNKLJYnfpwg+TyPijmkzJuhua0C9O+FP338yjsYVLEG+4L
	 7L+VxmI0T+LTrtfU7wIFKbwSmbNzA+0bdcyIVh9vgyM/U0wrzSqKC8mQRW5dHf6O7+Xxg
	 Qkhh015YG3b80hl0vvz0xfrzMbGiCO9KgQ7whI52YU6Hebyg/ZWaby9Ltgc8rlQ3/ZA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794961780;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-Developer-Signature:
	 X-Developer-Key:Content-Transfer-Encoding;
	bh=77Zc1u0jfwO76KAyX4WCIbvGbPpwLYaW9Jlo2sPynfo=;
	b=KHC8QOTr/ZECkkvx1s99Csyh1INr+7uZZ5M1wkXPqGZARJanLe1xtDINXpqzATvwPdaU
	 8MWaEf3M5pjRGH6LuhNOtxXEgtsFnj2seC4piQiPQRma6w+QBEYfQTfutcUTnv5DU/F8B
	 qyvGKsZcHClQN13B4+hNfrb4sBoaY3SE05uLtYqCi+yxNrdaPagba6v/l9OutfyMt+ZnI
	 l5nj43U/kemOmZiinWva4PhDkrX3KhYrk933t9M8TjXWNyX5uUt4PnSk9h1iUzTuouKpB
	 0eESWge5zj72ohA0wW0kLwx/ooceaFay0zHWRWJEX44FfYxmhAiCyl3e2O1DEUGAd8g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DjUc1tFl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6F42606A32F;
	Wed, 18 Nov 2026 00:29:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DjUc1tFl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 022E21F000C5;
	Wed, 18 Nov 2026 00:29:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794961780;
	bh=77Zc1u0jfwO76KAyX4WCIbvGbPpwLYaW9Jlo2sPynfo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DjUc1tFlOzVBzrYcXaPjCSi6i0uyhGfvMjsCTw9wPfX9BGKuTOeFjr1b832Vu99cL
	 jp1BV4nyinAEqqimy7fZ3LpEC9U9HrsuiZl4zXdDGhZEjU0pGYEuMeRxZzztktpi6q
	 bX+6Q1ORLsoxks9UnBx0uFWziaMGC8KVjKvEh/3U//qqUxdJBQZhUmmRmluFUXOvHQ
	 HFn1FgAgCYF4mRr7ugb3wKX4DI05/Fz90qvN+m30J68S4EgLui8QMRKNDQUhwn6QZK
	 J6gm4FTPnDAc81JqjeSjs68y2lDw0blFNZmXCX3DGNY+89wnlJhoAjg4q0cpCqxpc2
	 YyLnYFIi6dOUQ==
From: Thorsten Blum <blum@kernel.org>
To: David Sterba <dsterba@suse.com>,
	Chris Mason <mason@kernel.org>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>,
	Richard Weinberger <richard@nod.at>,
	Zhihao Cheng <chengzhihao1@huawei.com>,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>
Cc: linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mtd@lists.infradead.org,
	linux-fscrypt@vger.kernel.org,
	Thorsten Blum <blum@kernel.org>
Subject: [PATCH 1/4] fscrypt: Add FSTR() helper macro
Date: Wed, 18 Nov 2026 01:28:47 +0100
Message-ID: <20261118002845.574426-7-blum@kernel.org>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <20261118002845.574426-6-blum@kernel.org>
References: <20261118002845.574426-6-blum@kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-Developer-Signature: v=1; a=openpgp-sha256; l=730; i=blum@kernel.org; h=from:subject; bh=9TS87tFQrJmJ2L6d5vREcb1e62JHLVxiiKSkN7PY/9U=; b=owGbwMvMwCUWt7pQ4caZUj3G02pJDFl/Ptq5/b51/ZGu2+FIucCFP+qZ/J50hR/m2B2qoMu2f p3ujtL9HaUsDGJcDLJiiiwPZv2Y4VtaU7nJJGInzBxWJpAhDFycAjARFRGG/4msy3fns51NOsx7 JpD/+k3J0ki2ju+qS+9b8detfVXCacXwV+7Ggvu/J2UIOnB823+jQsTzhqtj3f5yNef1Fs+E9l5 34gQA
X-Developer-Key: i=blum@kernel.org; a=openpgp; fpr=1D60735E8AEF3BE473B69D84733678FD8DFEEAD4
Content-Transfer-Encoding: 8bit

Similar to QSTR(), add FSTR() to initialize struct fscrypt_str from a
NUL-terminated string without specifying its length.

Signed-off-by: Thorsten Blum <blum@kernel.org>
---
 include/linux/fscrypt.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 28f2108e29f3..84d9147fda2f 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -50,6 +50,7 @@ struct fscrypt_name {
 };
 
 #define FSTR_INIT(n, l)		{ .name = n, .len = l }
+#define FSTR(n)			((struct fscrypt_str)FSTR_INIT(n, strlen(n)))
 #define FSTR_TO_QSTR(f)		QSTR_INIT((f)->name, (f)->len)
 #define fname_name(p)		((p)->disk_name.name)
 #define fname_len(p)		((p)->disk_name.len)
