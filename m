Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6620E34D90D;
	Fri, 17 Jul 2026 04:46:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784263613; cv=none; b=qLAlRi9okqIHALPNCnRcF2B/RO3eF58Pr/+cIhZDD+rIUEv2l+xStJr9SpHXYmN6xJZUsKzwFdj5XOPeEnjR/bzStE4PSGPMisDCO8PeL1F3KhBW6n2cTMkDFiuuI9OjHebLT97RcFlAvLlylBCGEOV+7krqYv6YLWkr+0/H8Uc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784263613; c=relaxed/simple;
	bh=GLhdkU8m47IprGSuIcwY3Tl1jAW+D8g0WIW1djqvZgs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ml6tmua2dQs/5S8vRAUD0PBcv4qT4QIYWrqAGtDsJzmcuHylDdJ1f5Xwo3bM0Id+goIdu4p/DIgtefKpfW/89gs5rRUM0XnZGTC5GUi2eo/fRtc/0ZgWbtFqpk6xRooyid3uZUu+NFO8CfSYnrfiorFFVg5gl/7+qTJzfvTC0gQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XKMypAsl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XKMypAsl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CD9CB1F00A3D;
	Fri, 17 Jul 2026 04:46:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784263612;
	bh=mGCNlnzFNUQxFaIeQbngU3BOCM42fvscJYZKV2r9/Is=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XKMypAslUyq2d+TsvRVFLLan4yH7/bgRXzBOkX27wLBIQvIBWsX+HHk/K+DLvcQ7l
	 J5zLS+5+AFIs/avRzJl/8vXgmwZlejnahPfbjjz3YX98nPh11fSW/dakpKXIk0qfKz
	 /RaEbik7Q5vQO/h5RV49AbYsdD5UKHqF7lXmsSMXBMeTgrkYBnjsbgPamifa1wE31b
	 XoA3Et6vyt6xFeA5VzOxPbv8Wj9mk+stW3dPZwIwblA42p8P+1GLHf8lXOMe4Wz8/g
	 NWmIjwRpwdlsIaARyW0p5tWHzC3t6p9sJjB4eb5t858zluYFNM6VLRwRrKpqdRJEgY
	 rYu7twQI+iUGQ==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-hardening@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ricardo Ribalda <ribalda@chromium.org>,
	Richard Fitzgerald <rf@opensource.cirrus.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6.12 4/7] default_gfp(): avoid using the "newfangled" __VA_OPT__ trick
Date: Thu, 16 Jul 2026 21:43:00 -0700
Message-ID: <20260717044303.425265-5-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260717044303.425265-1-ebiggers@kernel.org>
References: <20260717044303.425265-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Linus Torvalds <torvalds@linux-foundation.org>

commit 551d44200152cb26f75d2ef990aeb6185b7e37fd upstream.

The default_gfp() helper that I added is not wrong, but it turns out
that it causes unnecessary headaches for 'sparse' which doesn't support
the use of __VA_OPT__ (introduced in C++20 and C23, and supported by gcc
and clang for a long time).

We do already use __VA_OPT__ in some other cases in the kernel (drm/xe
and btrfs), but it has been fairly limited.  Now it triggers for pretty
much everything, and sparse ends up not working at all.

We can use the traditional gcc ',##__VA_ARGS__' syntax instead: it may
not be the "C standard" way and is slightly less natural in this
context, but it is the traditional model for this and avoids the sparse
problem.

Reported-and-tested-by: Ricardo Ribalda <ribalda@chromium.org>
Reported-and-tested-by: Richard Fitzgerald <rf@opensource.cirrus.com>
Reported-by: Ben Dooks <ben.dooks@codethink.co.uk>
Fixes: e19e1b480ac7 ("add default_gfp() helper macro and use it in the new *alloc_obj() helpers")
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 include/linux/gfp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index abe4282fbdb1..c7621a0714c1 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -13,8 +13,8 @@ struct vm_area_struct;
 struct mempolicy;
 
 /* Helper macro to avoid gfp flags if they are the default one */
-#define __default_gfp(a,...) a
-#define default_gfp(...) __default_gfp(__VA_ARGS__ __VA_OPT__(,) GFP_KERNEL)
+#define __default_gfp(a,b,...) b
+#define default_gfp(...) __default_gfp(,##__VA_ARGS__,GFP_KERNEL)
 
 /* Convert GFP flags to their corresponding migrate type */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
-- 
2.55.0

