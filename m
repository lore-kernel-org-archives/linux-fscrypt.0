Return-Path: <SRS0=WgXM=ZY=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68C44C33CB9
	for <linux-fscrypt@archiver.kernel.org>; Mon,  2 Dec 2019 23:02:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3EB3620865
	for <linux-fscrypt@archiver.kernel.org>; Mon,  2 Dec 2019 23:02:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1575327754;
	bh=5TycULaQZpS/DKJs/QLw8slbVfis5ujHgJKQe/yYs0o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=NZiDp+3rJQNK5GgvyH8OJHMLtRN3i+/omzDfIWTnBxC1Y74ulhMHSUdEKmFr5/5Sv
	 VzT0hb3+QCJl8ht7jvjSHmoTqtgVJVFwA8v/Ik7P50TjIVLtcgI/xB+OZzaO6etaLp
	 aubdbY/BkQXSw27XRyxgb8xhXDMfRAziY1AqlLKk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726086AbfLBXCd (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 2 Dec 2019 18:02:33 -0500
Received: from mail.kernel.org ([198.145.29.99]:59508 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725939AbfLBXCd (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 2 Dec 2019 18:02:33 -0500
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 6B48C2071F;
        Mon,  2 Dec 2019 23:02:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1575327752;
        bh=5TycULaQZpS/DKJs/QLw8slbVfis5ujHgJKQe/yYs0o=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Anpcgyal8OxkbKcmQBByvwKnrFA5UqXyHlE7hQuIeZvXOk7ytJUeA9cT7kpa08UgY
         0FWoPop31+XxLGR/G35pQ0cZSTvruh1YLPJhYi8wN4EJG7NaX8/DcVAwvLfD2P4Stv
         XFJpTC9o0VTDU6adsY53TcSMWmRNIUgd3dR08Lm0=
From:   Eric Biggers <ebiggers@kernel.org>
To:     fstests@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>
Subject: [PATCH v2 3/5] common/encrypt: create named variables for UAPI constants
Date:   Mon,  2 Dec 2019 15:01:53 -0800
Message-Id: <20191202230155.99071-4-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.0.393.g34dc348eaf-goog
In-Reply-To: <20191202230155.99071-1-ebiggers@kernel.org>
References: <20191202230155.99071-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Use named variables rather than hard-coded numbers + comments.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 common/encrypt | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/common/encrypt b/common/encrypt
index 90f931fc..b967c65a 100644
--- a/common/encrypt
+++ b/common/encrypt
@@ -664,16 +664,26 @@ _do_verify_ciphertext_for_encryption_policy()
 	done
 }
 
+# fscrypt UAPI constants (see <linux/fscrypt.h>)
+
+FSCRYPT_MODE_AES_256_XTS=1
+FSCRYPT_MODE_AES_256_CTS=4
+FSCRYPT_MODE_AES_128_CBC=5
+FSCRYPT_MODE_AES_128_CTS=6
+FSCRYPT_MODE_ADIANTUM=9
+
+FSCRYPT_POLICY_FLAG_DIRECT_KEY=0x04
+
 _fscrypt_mode_name_to_num()
 {
 	local name=$1
 
 	case "$name" in
-	AES-256-XTS)		echo 1 ;; # FS_ENCRYPTION_MODE_AES_256_XTS
-	AES-256-CTS-CBC)	echo 4 ;; # FS_ENCRYPTION_MODE_AES_256_CTS
-	AES-128-CBC-ESSIV)	echo 5 ;; # FS_ENCRYPTION_MODE_AES_128_CBC
-	AES-128-CTS-CBC)	echo 6 ;; # FS_ENCRYPTION_MODE_AES_128_CTS
-	Adiantum)		echo 9 ;; # FS_ENCRYPTION_MODE_ADIANTUM
+	AES-256-XTS)		echo $FSCRYPT_MODE_AES_256_XTS ;;
+	AES-256-CTS-CBC)	echo $FSCRYPT_MODE_AES_256_CTS ;;
+	AES-128-CBC-ESSIV)	echo $FSCRYPT_MODE_AES_128_CBC ;;
+	AES-128-CTS-CBC)	echo $FSCRYPT_MODE_AES_128_CTS ;;
+	Adiantum)		echo $FSCRYPT_MODE_ADIANTUM ;;
 	*)			_fail "Unknown fscrypt mode: $name" ;;
 	esac
 }
@@ -705,7 +715,7 @@ _verify_ciphertext_for_encryption_policy()
 			     $filenames_encryption_mode ]; then
 				_fail "For direct key mode, contents and filenames modes must match"
 			fi
-			(( policy_flags |= 0x04 )) # FS_POLICY_FLAG_DIRECT_KEY
+			(( policy_flags |= FSCRYPT_POLICY_FLAG_DIRECT_KEY ))
 			;;
 		*)
 			_fail "Unknown option '$opt' passed to ${FUNCNAME[0]}"
@@ -721,11 +731,11 @@ _verify_ciphertext_for_encryption_policy()
 	if (( policy_version > 1 )); then
 		set_encpolicy_args+=" -v 2"
 		crypt_util_args+=" --kdf=HKDF-SHA512"
-		if (( policy_flags & 0x04 )); then
+		if (( policy_flags & FSCRYPT_POLICY_FLAG_DIRECT_KEY )); then
 			crypt_util_args+=" --mode-num=$contents_mode_num"
 		fi
 	else
-		if (( policy_flags & 0x04 )); then
+		if (( policy_flags & FSCRYPT_POLICY_FLAG_DIRECT_KEY )); then
 			crypt_util_args+=" --kdf=none"
 		else
 			crypt_util_args+=" --kdf=AES-128-ECB"
-- 
2.24.0.393.g34dc348eaf-goog

