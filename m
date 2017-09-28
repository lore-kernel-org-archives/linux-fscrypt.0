Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 0/7] Fix dereferencing payload of revoked keys
Date: Thu, 28 Sep 2017 14:25:55 -0700
Message-Id: <20170928212602.41744-1-ebiggers3@gmail.com>
To: keyrings@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, Michael Halcrow <mhalcrow@google.com>, linux-cachefs@redhat.com, ecryptfs@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This series fixes the various users of the keyrings service that access
a "user" or "logon" key's payload without first checking whether the
payload pointer is NULL, or calling key_validate() while holding the key
semaphore.  Without one of these two checks, a NULL pointer dereference
will occur if the key has been revoked concurrently.  Usually this is
pretty easy to reproduce (in most of the cases even as an unprivileged
user), although it may be unlikely to happen by accident.

Patch 6 also fixes the lack of key length validation in ecryptfs.

These fixes probably will need to be split up between a few different
maintainers, but initially I'm sending the full series so that people
can see the full context of the fixes.

Eric Biggers (7):
  KEYS: encrypted: fix dereference of NULL user_key_payload
  FS-Cache: fix dereference of NULL user_key_payload
  lib/digsig: fix dereference of NULL user_key_payload
  fscrypt: fix dereference of NULL user_key_payload
  ecryptfs: fix dereference of NULL user_key_payload
  ecryptfs: fix out-of-bounds read of key payload
  ecryptfs: move key payload accessor functions into keystore.c

 fs/crypto/keyinfo.c                      |  5 +++
 fs/ecryptfs/ecryptfs_kernel.h            | 44 -------------------
 fs/ecryptfs/keystore.c                   | 73 +++++++++++++++++++++++++++++++-
 fs/fscache/object-list.c                 |  7 +++
 lib/digsig.c                             |  6 +++
 security/keys/encrypted-keys/encrypted.c |  7 +++
 6 files changed, 97 insertions(+), 45 deletions(-)

-- 
2.14.2.822.g60be5d43e6-goog
