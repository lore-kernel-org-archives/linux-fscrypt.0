Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CD6D2EEE73;
	Fri, 17 Jul 2026 04:46:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784263612; cv=none; b=n0rY2mb1rK+3dLkaelw5LjQVe3BwHPXetzll/q4iMCPkvn9LRs77c0tmqR8sxITxgbXhV+SlvGa1EkZOIIX/6jeyZoU63jGmF7nQTAnqnpwmLtYBK9tfliCEk+xgRHcopyT6INNR3v3XZNsS0g84mTkLHMME2LttqewlCvytqwc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784263612; c=relaxed/simple;
	bh=LL9mxB2YokLqPzPhU7M3HSqO4I8f0exEUzsTZLmPTrA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ekeI3IJ0P4s6nswdsi5ZzghYxT7RnyaPZWES9vyyDTwgDoKNq5mqGOtp28J+Dq0rzVMCcgrgBhN2R4pP+k4iKI2Lbd7F6hi+N5Vjjl9yvCVg9jtIm1yHSr1IVdZQjlyyBiM09lC0+sVjtntwahk0rCiq97ySnPNjf3VAoEbtf4Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TUmdjypH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TUmdjypH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C1E691F00A3A;
	Fri, 17 Jul 2026 04:46:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784263611;
	bh=xatRQMV9MWwD2SSf3DV+2s0Vh+uk8WULL8ox0uG/owo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TUmdjypHTjKcSm89Eb6RXEF7U9UBXGIyGumRknvNqsB1VzN9BPrlZ0NrYWORhbVFO
	 pf2iFyx7ymtqL8li82nSH0tT38ovgHaeExHMyCk74NoargES6A7vwbLsBCO2g1Sfcv
	 e8rY74keiUMfULeJT+La13ano3SZBSbcnOOmaO710qkDr37Veo9TfN5oq1B3Tl+/Vw
	 Z1+nqbZAht017t3LMXKnlzT5BagNf9qIMiMIiMMtOCMuQ8RhA2c95Nc/VkZvcTnji9
	 bfXE3caF7Gb8JTV0LCKx4q29QITv+TLa0w05MkdooUzmDtX0h4+QIOpdBCn3eEZ4fN
	 c0nTmWvGLPlwA==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-hardening@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Kees Cook <kees@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6.12 1/7] slab: Introduce kmalloc_obj() and family
Date: Thu, 16 Jul 2026 21:42:57 -0700
Message-ID: <20260717044303.425265-2-ebiggers@kernel.org>
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

From: Kees Cook <kees@kernel.org>

commit 2932ba8d9c99875b98c951d9d3fd6d651d35df3a upstream.

Introduce type-aware kmalloc-family helpers to replace the common
idioms for single object and arrays of objects allocation:

	ptr = kmalloc(sizeof(*ptr), gfp);
	ptr = kmalloc(sizeof(struct some_obj_name), gfp);
	ptr = kzalloc(sizeof(*ptr), gfp);
	ptr = kmalloc_array(count, sizeof(*ptr), gfp);
	ptr = kcalloc(count, sizeof(*ptr), gfp);

These become, respectively:

	ptr = kmalloc_obj(*ptr, gfp);
	ptr = kmalloc_obj(*ptr, gfp);
	ptr = kzalloc_obj(*ptr, gfp);
	ptr = kmalloc_objs(*ptr, count, gfp);
	ptr = kzalloc_objs(*ptr, count, gfp);

Beyond the other benefits outlined below, the primary ergonomic benefit
is the elimination of needing "sizeof" nor the type name, and the
enforcement of assignment types (they do not return "void *", but rather
a pointer to the type of the first argument). The type name _can_ be
used, though, in the case where an assignment is indirect (e.g. via
"return"). This additionally allows[1] variables to be declared via
__auto_type:

	__auto_type ptr = kmalloc_obj(struct foo, gfp);

Internal introspection of the allocated type now becomes possible,
allowing for future alignment-aware choices to be made by the allocator
and future hardening work that can be type sensitive. For example,
adding __alignof(*ptr) as an argument to the internal allocators so that
appropriate/efficient alignment choices can be made, or being able to
correctly choose per-allocation offset randomization within a bucket
that does not break alignment requirements.

Link: https://lore.kernel.org/all/CAHk-=wiCOTW5UftUrAnvJkr6769D29tF7Of79gUjdQHS_TkF5A@mail.gmail.com/ [1]
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Link: https://patch.msgid.link/20251203233036.3212363-1-kees@kernel.org
Signed-off-by: Kees Cook <kees@kernel.org>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 Documentation/process/deprecated.rst | 24 ++++++++++++
 include/linux/slab.h                 | 58 ++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+)

diff --git a/Documentation/process/deprecated.rst b/Documentation/process/deprecated.rst
index 1f7f3e6c9cda..91c628fa2d59 100644
--- a/Documentation/process/deprecated.rst
+++ b/Documentation/process/deprecated.rst
@@ -372,3 +372,27 @@ The helper must be used::
 			DECLARE_FLEX_ARRAY(struct type2, two);
 		};
 	};
+
+Open-coded kmalloc assignments for struct objects
+-------------------------------------------------
+Performing open-coded kmalloc()-family allocation assignments prevents
+the kernel (and compiler) from being able to examine the type of the
+variable being assigned, which limits any related introspection that
+may help with alignment, wrap-around, or additional hardening. The
+kmalloc_obj()-family of macros provide this introspection, which can be
+used for the common code patterns for single, array, and flexible object
+allocations. For example, these open coded assignments::
+
+	ptr = kmalloc(sizeof(*ptr), gfp);
+	ptr = kzalloc(sizeof(*ptr), gfp);
+	ptr = kmalloc_array(count, sizeof(*ptr), gfp);
+	ptr = kcalloc(count, sizeof(*ptr), gfp);
+	ptr = kmalloc(sizeof(struct foo, gfp);
+
+become, respectively::
+
+	ptr = kmalloc_obj(*ptr, gfp);
+	ptr = kzalloc_obj(*ptr, gfp);
+	ptr = kmalloc_objs(*ptr, count, gfp);
+	ptr = kzalloc_objs(*ptr, count, gfp);
+	__auto_type ptr = kmalloc_obj(struct foo, gfp);
diff --git a/include/linux/slab.h b/include/linux/slab.h
index b35e2db7eb0e..718160551190 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -12,6 +12,7 @@
 #ifndef _LINUX_SLAB_H
 #define	_LINUX_SLAB_H
 
+#include <linux/bug.h>
 #include <linux/cache.h>
 #include <linux/gfp.h>
 #include <linux/overflow.h>
@@ -883,6 +884,63 @@ static __always_inline __alloc_size(1) void *kmalloc_noprof(size_t size, gfp_t f
 }
 #define kmalloc(...)				alloc_hooks(kmalloc_noprof(__VA_ARGS__))
 
+/**
+ * __alloc_objs - Allocate objects of a given type using
+ * @KMALLOC: which size-based kmalloc wrapper to allocate with.
+ * @GFP: GFP flags for the allocation.
+ * @TYPE: type to allocate space for.
+ * @COUNT: how many @TYPE objects to allocate.
+ *
+ * Returns: Newly allocated pointer to (first) @TYPE of @COUNT-many
+ * allocated @TYPE objects, or NULL on failure.
+ */
+#define __alloc_objs(KMALLOC, GFP, TYPE, COUNT)				\
+({									\
+	const size_t __obj_size = size_mul(sizeof(TYPE), COUNT);	\
+	(TYPE *)KMALLOC(__obj_size, GFP);				\
+})
+
+/**
+ * kmalloc_obj - Allocate a single instance of the given type
+ * @VAR_OR_TYPE: Variable or type to allocate.
+ * @GFP: GFP flags for the allocation.
+ *
+ * Returns: newly allocated pointer to a @VAR_OR_TYPE on success, or NULL
+ * on failure.
+ */
+#define kmalloc_obj(VAR_OR_TYPE, GFP)			\
+	__alloc_objs(kmalloc, GFP, typeof(VAR_OR_TYPE), 1)
+
+/**
+ * kmalloc_objs - Allocate an array of the given type
+ * @VAR_OR_TYPE: Variable or type to allocate an array of.
+ * @COUNT: How many elements in the array.
+ * @GFP: GFP flags for the allocation.
+ *
+ * Returns: newly allocated pointer to array of @VAR_OR_TYPE on success,
+ * or NULL on failure.
+ */
+#define kmalloc_objs(VAR_OR_TYPE, COUNT, GFP)		\
+	__alloc_objs(kmalloc, GFP, typeof(VAR_OR_TYPE), COUNT)
+
+/* All kzalloc aliases for kmalloc_(obj|objs|flex). */
+#define kzalloc_obj(P, GFP)				\
+	__alloc_objs(kzalloc, GFP, typeof(P), 1)
+#define kzalloc_objs(P, COUNT, GFP)			\
+	__alloc_objs(kzalloc, GFP, typeof(P), COUNT)
+
+/* All kvmalloc aliases for kmalloc_(obj|objs|flex). */
+#define kvmalloc_obj(P, GFP)				\
+	__alloc_objs(kvmalloc, GFP, typeof(P), 1)
+#define kvmalloc_objs(P, COUNT, GFP)			\
+	__alloc_objs(kvmalloc, GFP, typeof(P), COUNT)
+
+/* All kvzalloc aliases for kmalloc_(obj|objs|flex). */
+#define kvzalloc_obj(P, GFP)				\
+	__alloc_objs(kvzalloc, GFP, typeof(P), 1)
+#define kvzalloc_objs(P, COUNT, GFP)			\
+	__alloc_objs(kvzalloc, GFP, typeof(P), COUNT)
+
 #define kmem_buckets_alloc(_b, _size, _flags)	\
 	alloc_hooks(__kmalloc_node_noprof(PASS_BUCKET_PARAMS(_size, _b), _flags, NUMA_NO_NODE))
 
-- 
2.55.0

