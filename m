Return-Path: <fstests-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v3 3/9] xfs_io/encrypt: generate encryption modes for 'help set_encpolicy'
Date: Fri, 27 Sep 2019 17:02:37 -0700
Message-Id: <20190928000243.77634-4-ebiggers@kernel.org>
In-Reply-To: <20190928000243.77634-1-ebiggers@kernel.org>
References: <20190928000243.77634-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: fstests-owner@vger.kernel.org
To: linux-xfs@vger.kernel.org
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Print all encryption modes that are defined in the code, rather than
hardcoding the modes in the help text.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 io/encrypt.c | 29 +++++++++++++++++++----------
 1 file changed, 19 insertions(+), 10 deletions(-)

diff --git a/io/encrypt.c b/io/encrypt.c
index 011a6410..7d3e3b73 100644
--- a/io/encrypt.c
+++ b/io/encrypt.c
@@ -136,12 +136,22 @@ struct fscrypt_get_key_status_arg {
 
 #endif /* !FS_IOC_GET_ENCRYPTION_POLICY_EX */
 
+static const struct {
+	__u8 mode;
+	const char *name;
+} available_modes[] = {
+	{FSCRYPT_MODE_AES_256_XTS, "AES-256-XTS"},
+	{FSCRYPT_MODE_AES_256_CTS, "AES-256-CTS"},
+};
+
 static cmdinfo_t get_encpolicy_cmd;
 static cmdinfo_t set_encpolicy_cmd;
 
 static void
 set_encpolicy_help(void)
 {
+	int i;
+
 	printf(_(
 "\n"
 " assign an encryption policy to the currently open file\n"
@@ -155,8 +165,15 @@ set_encpolicy_help(void)
 " -f FLAGS -- policy flags\n"
 " -v VERSION -- version of policy structure\n"
 "\n"
-" MODE can be numeric or one of the following predefined values:\n"
-"    AES-256-XTS, AES-256-CTS\n"
+" MODE can be numeric or one of the following predefined values:\n"));
+	printf("    ");
+	for (i = 0; i < ARRAY_SIZE(available_modes); i++) {
+		printf("%s", available_modes[i].name);
+		if (i != ARRAY_SIZE(available_modes) - 1)
+			printf(", ");
+	}
+	printf("\n");
+	printf(_(
 " FLAGS and VERSION must be numeric.\n"
 "\n"
 " Note that it's only possible to set an encryption policy on an empty\n"
@@ -164,14 +181,6 @@ set_encpolicy_help(void)
 "\n"));
 }
 
-static const struct {
-	__u8 mode;
-	const char *name;
-} available_modes[] = {
-	{FSCRYPT_MODE_AES_256_XTS, "AES-256-XTS"},
-	{FSCRYPT_MODE_AES_256_CTS, "AES-256-CTS"},
-};
-
 static bool
 parse_byte_value(const char *arg, __u8 *value_ret)
 {
-- 
2.23.0.444.g18eeb5a265-goog
