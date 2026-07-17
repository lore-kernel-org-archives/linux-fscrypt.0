Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0C6936A34F;
	Fri, 17 Jul 2026 04:46:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784263614; cv=none; b=qwIWxDc3mlvuxuwWXCVH/Z22i1NwlkhUlg+oaIPoBn/GXBm4dtTxL3yZe8GwhTJr91+SXYPwOHQQuLT+ud9cWsKDClTR5q9NNcT3flMP91cRsq3R1Bxj6HS1JfBcNGfBNppVZRmDJPnG96kk7f5Pb0Cj8PgIkhOY4Cj9d8ZuboE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784263614; c=relaxed/simple;
	bh=PIgaHjUp+4+NhaLVAiXu0ME04kXs4iVeQNf6WFzpJR4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OqpOkyH6xMe0BTecseSSRBwHmFSZfsPYe2FfZp00cX192ZZYM1IM6obqn3zJkS4yMDkzcBELTIHdmIcfFsz5lQq6+laYAiWNFKj6881seHFBoqu2rszdfkcEJ2suscarxxJRUg+aYmw36L1MxAbsbArPTz+OQlyYu2lhSuVV/2w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kBChQT36; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kBChQT36"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3E6E81F00A3E;
	Fri, 17 Jul 2026 04:46:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784263612;
	bh=agHA0qcVhF5iE5cIt2nGc6gofuhGuU2FFdwJ8yLpydg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=kBChQT36kDTyDFzwNkx03lKgNPpn57WXD8KZCwnDB6nSX+tLzk2yA4yZ9C27lyZWW
	 +E5JBynR+xp2bNhy8l74ORHXVKH6A27+F4Yh7E7OZsPZkh8Ti3dmLVbgt3SPx5+wqD
	 +rk5Eh96sSHT6J1aXBEHqg4TbCrZz3dml18trnltG+VGgboc5+ATGlJZMpm2VekIz5
	 /K6ElybAZhPwNwXeNoD7zxuGlREXKXkDVww3+ZFfDxGtxMs3kpFGKo1EeJLRN6gqK7
	 RZl8yWGpW0FpJD3y4J75escBuDqUvx8uTSqP6ytHOw/ovw7gUtnxHX7bR5z05JQ4Us
	 tUaOqyERZmAHA==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-hardening@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Randy Dunlap <rdunlap@infradead.org>,
	"Harry Yoo (Oracle)" <harry@kernel.org>,
	"Vlastimil Babka (SUSE)" <vbabka@kernel.org>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6.12 5/7] slab: recognize @GFP parameter as optional in kernel-doc
Date: Thu, 16 Jul 2026 21:43:01 -0700
Message-ID: <20260717044303.425265-6-ebiggers@kernel.org>
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

From: Randy Dunlap <rdunlap@infradead.org>

commit 7b5f5865fb11e60edd03c5e063e2d228b7062317 upstream.

Since the @GFP parameter in kmalloc_obj() etc. is now optional, change
the kernel-doc to indicate that it is optional. This avoids kernel-doc
warnings:

WARNING: include/linux/slab.h:1101 Excess function parameter 'GFP' description in 'kmalloc_obj'
WARNING: include/linux/slab.h:1113 Excess function parameter 'GFP' description in 'kmalloc_objs'
WARNING: include/linux/slab.h:1128 Excess function parameter 'GFP' description in 'kmalloc_flex'

Fixes: e19e1b480ac7 ("add default_gfp() helper macro and use it in the new *alloc_obj() helpers")
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Acked-by: Harry Yoo (Oracle) <harry@kernel.org>
Link: https://patch.msgid.link/20260617163125.2716279-1-rdunlap@infradead.org
Signed-off-by: Vlastimil Babka (SUSE) <vbabka@kernel.org>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 include/linux/slab.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 18a149e51346..773843a71960 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -924,7 +924,7 @@ static __always_inline __alloc_size(1) void *kmalloc_noprof(size_t size, gfp_t f
 /**
  * kmalloc_obj - Allocate a single instance of the given type
  * @VAR_OR_TYPE: Variable or type to allocate.
- * @GFP: GFP flags for the allocation.
+ * @...: optional GFP flags for the allocation (GFP_KERNEL when not specified).
  *
  * Returns: newly allocated pointer to a @VAR_OR_TYPE on success, or NULL
  * on failure.
@@ -936,7 +936,7 @@ static __always_inline __alloc_size(1) void *kmalloc_noprof(size_t size, gfp_t f
  * kmalloc_objs - Allocate an array of the given type
  * @VAR_OR_TYPE: Variable or type to allocate an array of.
  * @COUNT: How many elements in the array.
- * @GFP: GFP flags for the allocation.
+ * @...: optional GFP flags for the allocation (GFP_KERNEL when not specified).
  *
  * Returns: newly allocated pointer to array of @VAR_OR_TYPE on success,
  * or NULL on failure.
@@ -949,7 +949,7 @@ static __always_inline __alloc_size(1) void *kmalloc_noprof(size_t size, gfp_t f
  * @VAR_OR_TYPE: Variable or type to allocate (with its flex array).
  * @FAM: The name of the flexible array member of the structure.
  * @COUNT: How many flexible array member elements are desired.
- * @GFP: GFP flags for the allocation.
+ * @...: optional GFP flags for the allocation (GFP_KERNEL when not specified).
  *
  * Returns: newly allocated pointer to @VAR_OR_TYPE on success, NULL on
  * failure. If @FAM has been annotated with __counted_by(), the allocation
-- 
2.55.0

