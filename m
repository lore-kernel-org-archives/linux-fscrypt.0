Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E0EC937BE6C;
	Sat, 18 Jul 2026 21:49:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784411348; cv=none; b=QDgMO1w9u5aebBUrHl1ZFuOKziRdb4ArlQ7a60fpf6Ojew/F4BG0dNzXbNqj2LaXv2Pxfqk14up4KuucjgX+j0pOb1SM9B9axabfVVY4aTV3GxQw/1lkCPjOVEWP9PLoBdgfh0vocZA9accUCZtuwuTBhwoQojmXOA6tUcxgNSk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784411348; c=relaxed/simple;
	bh=GkRY/T4SLBivz/hw+IvKVPIUasDFWgb5WhasI3GbGGQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=urUla9XVscdzMiJTiOBKiFJ/mPFC5A9gvNvDTT7UqBmRrYW76N7sCns4eYc5XjfbcZHrT12uLx/c9clxT4vyCn7BdAEPEHUn+lX7/+ctNRTq/sMf1zD/B8yUxs9NdmEZZf6ZmciK3FTC1b2FeTim47GjmcEfflXpOnS4omw4484=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=W5Lkvhv8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="W5Lkvhv8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F2D6D1F00A3D;
	Sat, 18 Jul 2026 21:49:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784411346;
	bh=7tUng5UB5zoDVf4llbeDN6q8xct/811JqmccCtQmV/Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=W5Lkvhv8aQFtdZGWjUNgTCoILUgcG1j2EQfsokz9t02DPWinakrlBkvJoeFWO31TR
	 WG8h3XbFcvyDKF3YglZz4gH4af+Sf4Ax/I7dep/f8srOeoRwu8RhETVjLC7FHpjI+P
	 gRTpv4zpZpQFAaShH1yQKZ6fL+5+qKLy/zidfO/RaUrCFUHuPmYIOxLr+vhZMqrLFh
	 Ws4dmbJyti9lD8QGwXdwNkiTpnxuYhK6HVDBVDJVLYDp7vG06rvjWT5RfS09XT0nd+
	 eNxJbOHssU/fF0MaEoPfL8E6kpOFSmFcsvvGlEZVml64X1GkjF7jQ0mjGAFozKckQq
	 xmT6/NAfBQ2Kw==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-doc@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 4/6] fscrypt: Update docs for data path
Date: Sat, 18 Jul 2026 14:46:53 -0700
Message-ID: <20260718214655.63186-5-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260718214655.63186-1-ebiggers@kernel.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Update the "Data path changes" section to accurately document and
elaborate on the current implementation of file contents en/decryption.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 Documentation/filesystems/fscrypt.rst | 56 ++++++++++++++++++---------
 1 file changed, 37 insertions(+), 19 deletions(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 5f1b5b53aa16..ef0925f78fa1 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -1475,25 +1475,43 @@ keys`_ and `DIRECT_KEY policies`_.
 Data path changes
 -----------------
 
-When inline encryption is used, filesystems just need to associate
-encryption contexts with bios to specify how the block layer or the
-inline encryption hardware will encrypt/decrypt the file contents.
-
-When inline encryption isn't used, filesystems must encrypt/decrypt
-the file contents themselves, as described below:
-
-For the read path (->read_folio()) of regular files, filesystems can
-read the ciphertext into the page cache and decrypt it in-place.  The
-folio lock must be held until decryption has finished, to prevent the
-folio from becoming visible to userspace prematurely.
-
-For the write path (->writepages()) of regular files, filesystems
-cannot encrypt data in-place in the page cache, since the cached
-plaintext must be preserved.  Instead, filesystems must encrypt into a
-temporary buffer or "bounce page", then write out the temporary
-buffer.  Some filesystems, such as UBIFS, already use temporary
-buffers regardless of encryption.  Other filesystems, such as ext4 and
-F2FS, have to allocate bounce pages specially for encryption.
+The block-based filesystems that support fscrypt, such as ext4 and
+f2fs, use blk-crypto (:ref:`inline_encryption`) to implement file
+contents encryption and decryption.  With blk-crypto, the filesystem
+assigns an encryption context to each I/O request it issues to the
+contents of an encrypted file.  The encryption (for writes) or
+decryption (for reads) is handled by the block layer transparently to
+the filesystem, using either the CPU or inline encryption hardware.
+
+Non-block-based filesystems can't use blk-crypto, so they make the
+calls to the cryptographic algorithms at the filesystem layer instead.
+
+Regardless of the layer in which they occur (blk-crypto-fallback or the
+filesystem), for CPU-based encryption and decryption of file contents:
+
+- For reads, the ciphertext data is read from the storage backend
+  (block device, network, UBI device, etc.) into the destination
+  buffers, then decrypted in-place.  The destination buffers are
+  pagecache folios for buffered reads, or application-provided buffers
+  for direct reads.  In either case, the filesystem reports success
+  only after decryption has successfully completed.
+
+- For writes, the plaintext data is encrypted from the source buffers
+  (which cannot be modified) into bounce buffers.  Then, the
+  ciphertext in the bounce buffers is written to the storage backend.
+
+  The source buffers are usually pagecache folios for buffered writes,
+  or application-provided buffers for direct writes.  There are also
+  some cases (all files on UBIFS, and compressed files on f2fs) where
+  the filesystem already uses bounce buffers for writes for other
+  reasons; in these cases the source plaintext data is already in
+  bounce buffers.  UBIFS optimizes this case by encrypting the data
+  in-place in its existing bounce buffers.
+
+When inline encryption hardware is used instead of the CPU, reads from
+the storage backend logically return plaintext data, and writes accept
+plaintext data.  In that case the flow is simplified: there's no
+scheduling of decryption work, and no bounce buffers are used.
 
 Filename hashing and encoding
 -----------------------------
-- 
2.55.0

