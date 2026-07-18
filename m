Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60A952931C6;
	Sat, 18 Jul 2026 21:25:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784409947; cv=none; b=SKqTRBueGGZ/B0UkQTooKxCgVPJPMSwVVPDtcsI52xCwbVzcin6gFBXaXxTWp+sFmt7C0Jd7ghODDhSTFS6ARI9hGrj3tsjaZrIhRE1sRc8JXiCBsVg7XvSsCtCqnnMMVpCDOgENHZe0XPy4FKpsnIt8etLc1pr3N8/8IftDE+Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784409947; c=relaxed/simple;
	bh=pimnO6eyEmlP64Jqk3zFWty5R76ZdI2J2tnt3GsxhSk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Cv5KFchk1MbcJ4jwzWLY3C/GXRU3nTQFCw/u4oqAgp/Z2qiXx8OdPraG+paLX1cmT7Xto3qDO7ybWF8NV6tX/KekQ9jmHzqZ9cQzRmMQu0G+YxFHPsUEYqokRMUttHZT1WGzus/EFjQnGhNoiAA6r8XgVrmvRNxY1mScaBp87a8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BVnURPf/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BVnURPf/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 840EC1F000E9;
	Sat, 18 Jul 2026 21:25:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784409946;
	bh=LJzNAboKjznTN5sSh9TD0SgE2gZ8VhtjaHd0JnerU30=;
	h=From:To:Cc:Subject:Date;
	b=BVnURPf/0Ws56XqbFRrjBkhoX+BQE1QUwtCshxrok6oBXNPcckg15cqcI28jq7LhD
	 f5gdX98HhWoTa3OVX3tIS7RwmgLFSVX951B7T2WX0OkPyrl4LTpn3uJyMZnaffKqTg
	 uwmVTbEQ8aDL6nmd4bKVvE04LdPzO5RtW+swyNvpVxOZ6dY9rPOddFzrsKDlP+hwK9
	 bFQg8E/oZi6mzrvpZTO5VT8rKFTo6JZqBO9uNKDeNNQZSZJwimdj+FCuDfhi8VmdBE
	 TvVn6N91VCzzAC8ZtDZS+Xj8A0m8ZJWAbsyNzPUUkqSZql325QrtdpZSc7t5EMV6Lx
	 h9BtoJ5/p/LVw==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: Update encryption policy version docs
Date: Sat, 18 Jul 2026 14:25:26 -0700
Message-ID: <20260718212526.53943-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Update the wording of the documentation to put v1 encryption policies a
bit more firmly in the past, explicitly calling them "deprecated" (which
is consistent with the warning message the kernel has printed ever since
v5.4).  Do the same for FS_IOC_GET_ENCRYPTION_POLICY which supports only
v1 policies, and remove the explicit recommendation to fall back to it.

Also clarify that reusing master keys across policies isn't the best
practice or normal usage, even though it's technically allowed for v2.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---

This patch is targeting the fscrypt tree

 Documentation/filesystems/fscrypt.rst | 40 ++++++++++++---------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 5f1b5b53aa16..d7b71c5ce286 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -188,8 +188,8 @@ attacks:
 - Non-root users cannot securely remove encryption keys.
 
 All the above problems are fixed with v2 encryption policies.  For
-this reason among others, it is recommended to use v2 encryption
-policies on all new encrypted directories.
+this reason among others, v1 encryption policies are deprecated.  Use
+v2 encryption policies on all new encrypted directories.
 
 Key hierarchy
 =============
@@ -305,7 +305,8 @@ included in the IV.  Moreover:
 
 - For v2 encryption policies, the encryption is done with a per-mode
   key derived using the KDF.  Users may use the same master key for
-  other v2 encryption policies.
+  other v2 encryption policies.  However, using a distinct master key
+  for each policy is still the best practice and normal usage.
 
 IV_INO_LBLK_64 policies
 -----------------------
@@ -604,7 +605,9 @@ This structure must be initialized as follows:
   struct fscrypt_policy_v1 is used or FSCRYPT_POLICY_V2 (2) if
   struct fscrypt_policy_v2 is used. (Note: we refer to the original
   policy version as "v1", though its version code is really 0.)
-  For new encrypted directories, use v2 policies.
+  For new encrypted directories, use v2 policies, which are supported
+  since Linux v5.4.  v1 policies are deprecated and have several
+  usability and security problems.
 
 - ``contents_encryption_mode`` and ``filenames_encryption_mode`` must
   be set to constants from ``<linux/fscrypt.h>`` which identify the
@@ -739,17 +742,6 @@ FS_IOC_SET_ENCRYPTION_POLICY can fail with the following errors:
 Getting an encryption policy
 ----------------------------
 
-Two ioctls are available to get a file's encryption policy:
-
-- `FS_IOC_GET_ENCRYPTION_POLICY_EX`_
-- `FS_IOC_GET_ENCRYPTION_POLICY`_
-
-The extended (_EX) version of the ioctl is more general and is
-recommended to use when possible.  However, on older kernels only the
-original ioctl is available.  Applications should try the extended
-version, and if it fails with ENOTTY fall back to the original
-version.
-
 FS_IOC_GET_ENCRYPTION_POLICY_EX
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
@@ -783,7 +775,6 @@ FS_IOC_GET_ENCRYPTION_POLICY_EX can fail with the following errors:
 - ``ENODATA``: the file is not encrypted
 - ``ENOTTY``: this type of filesystem does not implement encryption,
   or this kernel is too old to support FS_IOC_GET_ENCRYPTION_POLICY_EX
-  (try FS_IOC_GET_ENCRYPTION_POLICY instead)
 - ``EOPNOTSUPP``: the kernel was not configured with encryption
   support for this filesystem, or the filesystem superblock has not
   had encryption enabled on it
@@ -799,12 +790,13 @@ check for STATX_ATTR_ENCRYPTED in stx_attributes.
 FS_IOC_GET_ENCRYPTION_POLICY
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
-The FS_IOC_GET_ENCRYPTION_POLICY ioctl can also retrieve the
-encryption policy, if any, for a directory or regular file.  However,
-unlike `FS_IOC_GET_ENCRYPTION_POLICY_EX`_,
-FS_IOC_GET_ENCRYPTION_POLICY only supports the original policy
-version.  It takes in a pointer directly to struct fscrypt_policy_v1
-rather than struct fscrypt_get_policy_ex_arg.
+The FS_IOC_GET_ENCRYPTION_POLICY ioctl is deprecated.  It supports
+only v1 encryption policies, which themselves are deprecated.  Use
+`FS_IOC_GET_ENCRYPTION_POLICY_EX`_ instead.
+
+FS_IOC_GET_ENCRYPTION_POLICY retrieves the encryption policy for a
+directory or regular file, but only if it uses a v1 policy.  It takes
+in a pointer directly to struct fscrypt_policy_v1.
 
 The error codes for FS_IOC_GET_ENCRYPTION_POLICY are the same as those
 for FS_IOC_GET_ENCRYPTION_POLICY_EX, except that
@@ -887,6 +879,10 @@ as follows:
   To add this type of key, the calling process must have the
   CAP_SYS_ADMIN capability in the initial user namespace.
 
+  (Note that v1 encryption policies are deprecated.  The ability to
+  add a key for v1 encryption policies remains only for compatibility
+  with existing encrypted directories.)
+
   Alternatively, if the key is being added for use by v2 encryption
   policies, then ``key_spec.type`` must contain
   FSCRYPT_KEY_SPEC_TYPE_IDENTIFIER, and ``key_spec.u.identifier`` is

base-commit: 49a8501f1194e8e6a14c58628cbae678f3594a41
-- 
2.55.0

