Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72B2B2F12B3;
	Fri, 17 Jul 2026 04:46:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784263612; cv=none; b=YyFrq+Wr5H2k4BnJLtHyjzRNPRGhGHPf4T1tB7iojwFzZgoleT4fz1iGZBrXr+cRaR1Y2UIIRrZ+zk4sDYk4hEFVtOizw5Si1GdjvIfDMJvDZL70alVRPrrpQxrkA/zbkc+Mq1A1ZIC7FagqSG1LgDy8UKORz3rEAWvh8FPcQCM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784263612; c=relaxed/simple;
	bh=yIcHfM3xjQiQ61CxfZmKJHpZuG42hvfBCB5Y6uCfWq4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=T7GCGd+hRDL7e1EzeeKwe2flxLslFv0r/wHCdsmnZJvPKQugErvkVIxg6mDXhX+mL6KAc6NgG4qVeSeCY824JMKRBJMm52IzZ1RMD1dzeKY/l7WsUM24MsZhM0WIu1f8C9HdtS8cPra7U6pfjlEiuxR7oYWHtEv68W1CDd+kDtk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NMInv6v2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NMInv6v2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 258131F00A3F;
	Fri, 17 Jul 2026 04:46:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784263611;
	bh=fNeB/Y/cqOjzXec3adTFGQCU+s51eXxOcM2XPEZSHgQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NMInv6v2AGHF+xoWPgjhtTQ7MTgY9oRUlxZga8zhPVbF3qJvv4/WpFNJLv2ApZdvg
	 xaoqEiy3WtR5LnCfxvSTPONnGtY1U3U14lBR58qN2RbvAcOP87erg1bMzvR+2bY0h3
	 cwSNIsKuccrrQ4uxXt4/QM3GMq3qqxoUUlN8HNnis5AfhAfnSBvRDeBaiZw7knCxhp
	 0HukxtRUVQF/QVQ2batBXVVJ8W8D8DsbW1EHxDhJjUv6vs6w8NjAN92ZqRpU2Hx40k
	 2/F2m4hFPA8XY9m171bkBA+Ke2TfbAUEF9eBra0dKAruBfDgAjcIpvcsznq3pO94rY
	 MMKGel3mp8MFQ==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-hardening@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Kees Cook <kees@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6.12 2/7] slab: Introduce kmalloc_flex() and family
Date: Thu, 16 Jul 2026 21:42:58 -0700
Message-ID: <20260717044303.425265-3-ebiggers@kernel.org>
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

commit e4c8b46b924eb8de66c6f0accc9cdd0c2e8fa23b upstream.

As done for kmalloc_obj*(), introduce a type-aware allocator for flexible
arrays, which may also have "counted_by" annotations:

	ptr = kmalloc(struct_size(ptr, flex_member, count), gfp);

becomes:

	ptr = kmalloc_flex(*ptr, flex_member, count, gfp);

The internal use of __flex_counter() allows for automatically setting
the counter member of a struct's flexible array member when it has
been annotated with __counted_by(), avoiding any missed early size
initializations while __counted_by() annotations are added to the
kernel. Additionally, this also checks for "too large" allocations based
on the type size of the counter variable. For example:

	if (count > type_max(ptr->flex_counter))
		fail...;
	size = struct_size(ptr, flex_member, count);
	ptr = kmalloc(size, gfp);
	if (!ptr)
		fail...;
	ptr->flex_counter = count;

becomes (n.b. unchanged from earlier example):

	ptr = kmalloc_flex(*ptr, flex_member, count, gfp);
	if (!ptr)
		fail...;
	ptr->flex_counter = count;

Note that manual initialization of the flexible array counter is still
required (at some point) after allocation as not all compiler versions
support the __counted_by annotation yet. But doing it internally makes
sure they cannot be missed when __counted_by _is_ available, meaning
that the bounds checker will not trip due to the lack of "early enough"
initializations that used to work before enabling the stricter bounds
checking. For example:

	ptr = kmalloc_flex(*ptr, flex_member, count, gfp);
	fill(ptr->flex, count);
	ptr->flex_count = count;

This works correctly before adding a __counted_by annotation (since
nothing is checking ptr->flex accesses against ptr->flex_count). After
adding the annotation, the bounds sanitizer would trip during fill()
because ptr->flex_count wasn't set yet. But with kmalloc_flex() setting
ptr->flex_count internally at allocation time, the existing code works
without needing to move the ptr->flex_count assignment before the call
to fill(). (This has been a stumbling block for __counted_by adoption.)

Link: https://patch.msgid.link/20251203233036.3212363-4-kees@kernel.org
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Kees Cook <kees@kernel.org>
[Backport-notes: Removed the actual flex counter handling.  That's a new
 feature, which isn't necessary for just adding the new allocation APIs
 to get backports to apply cleanly.  Also, the allocation-time overflow
 check in the upstream commit was reverted upstream.]
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 Documentation/process/deprecated.rst |  7 +++++
 include/linux/slab.h                 | 42 ++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/Documentation/process/deprecated.rst b/Documentation/process/deprecated.rst
index 91c628fa2d59..fed56864d036 100644
--- a/Documentation/process/deprecated.rst
+++ b/Documentation/process/deprecated.rst
@@ -387,6 +387,7 @@ allocations. For example, these open coded assignments::
 	ptr = kzalloc(sizeof(*ptr), gfp);
 	ptr = kmalloc_array(count, sizeof(*ptr), gfp);
 	ptr = kcalloc(count, sizeof(*ptr), gfp);
+	ptr = kmalloc(struct_size(ptr, flex_member, count), gfp);
 	ptr = kmalloc(sizeof(struct foo, gfp);
 
 become, respectively::
@@ -395,4 +396,10 @@ become, respectively::
 	ptr = kzalloc_obj(*ptr, gfp);
 	ptr = kmalloc_objs(*ptr, count, gfp);
 	ptr = kzalloc_objs(*ptr, count, gfp);
+	ptr = kmalloc_flex(*ptr, flex_member, count, gfp);
 	__auto_type ptr = kmalloc_obj(struct foo, gfp);
+
+If `ptr->flex_member` is annotated with __counted_by(), the allocation
+will automatically fail if `count` is larger than the maximum
+representable value that can be stored in the counter member associated
+with `flex_member`.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 718160551190..d54d44b053dd 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -900,6 +900,27 @@ static __always_inline __alloc_size(1) void *kmalloc_noprof(size_t size, gfp_t f
 	(TYPE *)KMALLOC(__obj_size, GFP);				\
 })
 
+/**
+ * __alloc_flex - Allocate an object that has a trailing flexible array
+ * @KMALLOC: kmalloc wrapper function to use for allocation.
+ * @GFP: GFP flags for the allocation.
+ * @TYPE: type of structure to allocate space for.
+ * @FAM: The name of the flexible array member of @TYPE structure.
+ * @COUNT: how many @FAM elements to allocate space for.
+ *
+ * Returns: Newly allocated pointer to @TYPE with @COUNT-many trailing
+ * @FAM elements, or NULL on failure or if @COUNT cannot be represented
+ * by the member of @TYPE that counts the @FAM elements (annotated via
+ * __counted_by()).
+ */
+#define __alloc_flex(KMALLOC, GFP, TYPE, FAM, COUNT)			\
+({									\
+	const size_t __count = (COUNT);					\
+	const size_t __obj_size = struct_size_t(TYPE, FAM, __count);	\
+	TYPE *__obj_ptr = KMALLOC(__obj_size, GFP);			\
+	__obj_ptr;							\
+})
+
 /**
  * kmalloc_obj - Allocate a single instance of the given type
  * @VAR_OR_TYPE: Variable or type to allocate.
@@ -923,23 +944,44 @@ static __always_inline __alloc_size(1) void *kmalloc_noprof(size_t size, gfp_t f
 #define kmalloc_objs(VAR_OR_TYPE, COUNT, GFP)		\
 	__alloc_objs(kmalloc, GFP, typeof(VAR_OR_TYPE), COUNT)
 
+/**
+ * kmalloc_flex - Allocate a single instance of the given flexible structure
+ * @VAR_OR_TYPE: Variable or type to allocate (with its flex array).
+ * @FAM: The name of the flexible array member of the structure.
+ * @COUNT: How many flexible array member elements are desired.
+ * @GFP: GFP flags for the allocation.
+ *
+ * Returns: newly allocated pointer to @VAR_OR_TYPE on success, NULL on
+ * failure. If @FAM has been annotated with __counted_by(), the allocation
+ * will immediately fail if @COUNT is larger than what the type of the
+ * struct's counter variable can represent.
+ */
+#define kmalloc_flex(VAR_OR_TYPE, FAM, COUNT, GFP)	\
+	__alloc_flex(kmalloc, GFP, typeof(VAR_OR_TYPE),	FAM, COUNT)
+
 /* All kzalloc aliases for kmalloc_(obj|objs|flex). */
 #define kzalloc_obj(P, GFP)				\
 	__alloc_objs(kzalloc, GFP, typeof(P), 1)
 #define kzalloc_objs(P, COUNT, GFP)			\
 	__alloc_objs(kzalloc, GFP, typeof(P), COUNT)
+#define kzalloc_flex(P, FAM, COUNT, GFP)		\
+	__alloc_flex(kzalloc, GFP, typeof(P), FAM, COUNT)
 
 /* All kvmalloc aliases for kmalloc_(obj|objs|flex). */
 #define kvmalloc_obj(P, GFP)				\
 	__alloc_objs(kvmalloc, GFP, typeof(P), 1)
 #define kvmalloc_objs(P, COUNT, GFP)			\
 	__alloc_objs(kvmalloc, GFP, typeof(P), COUNT)
+#define kvmalloc_flex(P, FAM, COUNT, GFP)		\
+	__alloc_flex(kvmalloc, GFP, typeof(P), FAM, COUNT)
 
 /* All kvzalloc aliases for kmalloc_(obj|objs|flex). */
 #define kvzalloc_obj(P, GFP)				\
 	__alloc_objs(kvzalloc, GFP, typeof(P), 1)
 #define kvzalloc_objs(P, COUNT, GFP)			\
 	__alloc_objs(kvzalloc, GFP, typeof(P), COUNT)
+#define kvzalloc_flex(P, FAM, COUNT, GFP)		\
+	__alloc_flex(kvzalloc, GFP, typeof(P), FAM, COUNT)
 
 #define kmem_buckets_alloc(_b, _size, _flags)	\
 	alloc_hooks(__kmalloc_node_noprof(PASS_BUCKET_PARAMS(_size, _b), _flags, NUMA_NO_NODE))
-- 
2.55.0

