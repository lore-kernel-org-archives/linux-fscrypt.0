Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C32513033DE;
	Fri, 17 Jul 2026 04:46:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784263613; cv=none; b=vA4iOHZktTVQzjtKAiIwerzu70I14COVuUq7ta2YldUW7/FMwOwlEP7IbGf52NlmRbCeg5Cc2uqDw2fTQmNWc1i7QgbY9IFTSEMVVvTFtuKyGw2iN7j3d7x5CBuE2kyy61zdNTsOc0kxm/qnkBS2xSpLfgwmvlHRUyVLdN6lyoU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784263613; c=relaxed/simple;
	bh=JbD+pV0bxMio0bzJ2YrsvMqRt17grhfkpzgmVw/UZBw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jkw9kRv9K2I9VfNBCLcgmGwUKv8nFb49MHz5Yl1AHwOMNyBT7pQlLA0Ft0NM4o0Lxnn9Q0Xg9RnTckQ5ToRZCs3bewntDs0LJ+GrckGx7I6qv/d1OUp0I3ID9TbmpuDnqAjGbYpB/2ZwzfOC8EJ0gy/j+x1RyHIGmcDY9Ggy/jg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=g2piZX0y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="g2piZX0y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7D2721F00AC4;
	Fri, 17 Jul 2026 04:46:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784263611;
	bh=+3TkwhxL7AAa7pEOFpsU8nQCGpvkJ9pkYd16HJnht9c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=g2piZX0yOK353vDxyfIInRuHJ3H6BJCTgunq2s1U/m6g2P8gpYaiC3enJHfB82wg+
	 A7MJSduc7/P8QEsc1DY+WDY/YagXBJgWTKYYzEEmT4P203z59cAmnkf3iir2pXjz+C
	 BxCeRRZTArA381A6yJyIzW4UlbYa2H5+8cXfSDvE6qQMJv5EO163Qa2ZOiQPpwMN+e
	 XhVGq6+pD9zWTdWsrIBIG7vJEVkcTjV3j17jOZGAOp95NahCQvWz+o99Mfp77vJ1+a
	 7WHsOZgsX96ZI83XKLYz8jDtGrdJrPZQn1Yd6KMpBdSY7iGJzr7w2JDC4ubgIMGW2G
	 kI1oKql3cm4OQ==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-hardening@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6.12 3/7] add default_gfp() helper macro and use it in the new *alloc_obj() helpers
Date: Thu, 16 Jul 2026 21:42:59 -0700
Message-ID: <20260717044303.425265-4-ebiggers@kernel.org>
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

commit e19e1b480ac73c3e62ffebbca1174f0f511f43e7 upstream.

Most simple allocations use GFP_KERNEL, and with the new allocation
helpers being introduced, let's just take advantage of that to simplify
that default case.

It's a numbers game:

    git grep 'alloc_obj(' |
	sed 's/.*\(GFP_[_A-Z]*\).*/\1/' |
	sort | uniq -c | sort -n | tail

shows that about 90% of all those new allocator instances just use that
standard GFP_KERNEL.

Those helpers are already macros, and we can easily just make it be the
default case when the gfp argument is missing.

And yes, we could do that for all the legacy interfaces too, but let's
keep it to just the new ones at least for now, since those all got
converted recently anyway, so this is not any "extra" noise outside of
that limited conversion.

And, in fact, I want to do this before doing the -rc1 release, exactly
so that we don't get extra merge conflicts.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 include/linux/gfp.h  |  4 ++++
 include/linux/slab.h | 48 ++++++++++++++++++++++----------------------
 2 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index bc59016743fb..abe4282fbdb1 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -12,6 +12,10 @@
 struct vm_area_struct;
 struct mempolicy;
 
+/* Helper macro to avoid gfp flags if they are the default one */
+#define __default_gfp(a,...) a
+#define default_gfp(...) __default_gfp(__VA_ARGS__ __VA_OPT__(,) GFP_KERNEL)
+
 /* Convert GFP flags to their corresponding migrate type */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
 #define GFP_MOVABLE_SHIFT 3
diff --git a/include/linux/slab.h b/include/linux/slab.h
index d54d44b053dd..18a149e51346 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -929,8 +929,8 @@ static __always_inline __alloc_size(1) void *kmalloc_noprof(size_t size, gfp_t f
  * Returns: newly allocated pointer to a @VAR_OR_TYPE on success, or NULL
  * on failure.
  */
-#define kmalloc_obj(VAR_OR_TYPE, GFP)			\
-	__alloc_objs(kmalloc, GFP, typeof(VAR_OR_TYPE), 1)
+#define kmalloc_obj(VAR_OR_TYPE, ...) \
+	__alloc_objs(kmalloc, default_gfp(__VA_ARGS__), typeof(VAR_OR_TYPE), 1)
 
 /**
  * kmalloc_objs - Allocate an array of the given type
@@ -941,8 +941,8 @@ static __always_inline __alloc_size(1) void *kmalloc_noprof(size_t size, gfp_t f
  * Returns: newly allocated pointer to array of @VAR_OR_TYPE on success,
  * or NULL on failure.
  */
-#define kmalloc_objs(VAR_OR_TYPE, COUNT, GFP)		\
-	__alloc_objs(kmalloc, GFP, typeof(VAR_OR_TYPE), COUNT)
+#define kmalloc_objs(VAR_OR_TYPE, COUNT, ...) \
+	__alloc_objs(kmalloc, default_gfp(__VA_ARGS__), typeof(VAR_OR_TYPE), COUNT)
 
 /**
  * kmalloc_flex - Allocate a single instance of the given flexible structure
@@ -956,32 +956,32 @@ static __always_inline __alloc_size(1) void *kmalloc_noprof(size_t size, gfp_t f
  * will immediately fail if @COUNT is larger than what the type of the
  * struct's counter variable can represent.
  */
-#define kmalloc_flex(VAR_OR_TYPE, FAM, COUNT, GFP)	\
-	__alloc_flex(kmalloc, GFP, typeof(VAR_OR_TYPE),	FAM, COUNT)
+#define kmalloc_flex(VAR_OR_TYPE, FAM, COUNT, ...) \
+	__alloc_flex(kmalloc, default_gfp(__VA_ARGS__), typeof(VAR_OR_TYPE), FAM, COUNT)
 
 /* All kzalloc aliases for kmalloc_(obj|objs|flex). */
-#define kzalloc_obj(P, GFP)				\
-	__alloc_objs(kzalloc, GFP, typeof(P), 1)
-#define kzalloc_objs(P, COUNT, GFP)			\
-	__alloc_objs(kzalloc, GFP, typeof(P), COUNT)
-#define kzalloc_flex(P, FAM, COUNT, GFP)		\
-	__alloc_flex(kzalloc, GFP, typeof(P), FAM, COUNT)
+#define kzalloc_obj(P, ...) \
+	__alloc_objs(kzalloc, default_gfp(__VA_ARGS__), typeof(P), 1)
+#define kzalloc_objs(P, COUNT, ...) \
+	__alloc_objs(kzalloc, default_gfp(__VA_ARGS__), typeof(P), COUNT)
+#define kzalloc_flex(P, FAM, COUNT, ...)		\
+	__alloc_flex(kzalloc, default_gfp(__VA_ARGS__), typeof(P), FAM, COUNT)
 
 /* All kvmalloc aliases for kmalloc_(obj|objs|flex). */
-#define kvmalloc_obj(P, GFP)				\
-	__alloc_objs(kvmalloc, GFP, typeof(P), 1)
-#define kvmalloc_objs(P, COUNT, GFP)			\
-	__alloc_objs(kvmalloc, GFP, typeof(P), COUNT)
-#define kvmalloc_flex(P, FAM, COUNT, GFP)		\
-	__alloc_flex(kvmalloc, GFP, typeof(P), FAM, COUNT)
+#define kvmalloc_obj(P, ...) \
+	__alloc_objs(kvmalloc, default_gfp(__VA_ARGS__), typeof(P), 1)
+#define kvmalloc_objs(P, COUNT, ...) \
+	__alloc_objs(kvmalloc, default_gfp(__VA_ARGS__), typeof(P), COUNT)
+#define kvmalloc_flex(P, FAM, COUNT, ...) \
+	__alloc_flex(kvmalloc, default_gfp(__VA_ARGS__), typeof(P), FAM, COUNT)
 
 /* All kvzalloc aliases for kmalloc_(obj|objs|flex). */
-#define kvzalloc_obj(P, GFP)				\
-	__alloc_objs(kvzalloc, GFP, typeof(P), 1)
-#define kvzalloc_objs(P, COUNT, GFP)			\
-	__alloc_objs(kvzalloc, GFP, typeof(P), COUNT)
-#define kvzalloc_flex(P, FAM, COUNT, GFP)		\
-	__alloc_flex(kvzalloc, GFP, typeof(P), FAM, COUNT)
+#define kvzalloc_obj(P, ...) \
+	__alloc_objs(kvzalloc, default_gfp(__VA_ARGS__), typeof(P), 1)
+#define kvzalloc_objs(P, COUNT, ...) \
+	__alloc_objs(kvzalloc, default_gfp(__VA_ARGS__), typeof(P), COUNT)
+#define kvzalloc_flex(P, FAM, COUNT, ...) \
+	__alloc_flex(kvzalloc, default_gfp(__VA_ARGS__), typeof(P), FAM, COUNT)
 
 #define kmem_buckets_alloc(_b, _size, _flags)	\
 	alloc_hooks(__kmalloc_node_noprof(PASS_BUCKET_PARAMS(_size, _b), _flags, NUMA_NO_NODE))
-- 
2.55.0

