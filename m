Return-Path: <fstests-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v3 4/9] xfs_io/encrypt: add new encryption modes
Date: Fri, 27 Sep 2019 17:02:38 -0700
Message-Id: <20190928000243.77634-5-ebiggers@kernel.org>
In-Reply-To: <20190928000243.77634-1-ebiggers@kernel.org>
References: <20190928000243.77634-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: fstests-owner@vger.kernel.org
To: linux-xfs@vger.kernel.org
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add new encryption modes: AES-128-CBC and AES-128-CTS (supported since
Linux v4.11), and Adiantum (supported since Linux v5.0).

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 io/encrypt.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/io/encrypt.c b/io/encrypt.c
index 7d3e3b73..8a511379 100644
--- a/io/encrypt.c
+++ b/io/encrypt.c
@@ -142,6 +142,9 @@ static const struct {
 } available_modes[] = {
 	{FSCRYPT_MODE_AES_256_XTS, "AES-256-XTS"},
 	{FSCRYPT_MODE_AES_256_CTS, "AES-256-CTS"},
+	{FSCRYPT_MODE_AES_128_CBC, "AES-128-CBC"},
+	{FSCRYPT_MODE_AES_128_CTS, "AES-128-CTS"},
+	{FSCRYPT_MODE_ADIANTUM, "Adiantum"},
 };
 
 static cmdinfo_t get_encpolicy_cmd;
-- 
2.23.0.444.g18eeb5a265-goog
