Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from emh04.mail.saunalahti.fi ([62.142.5.110]:39898 "EHLO
        emh04.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725954AbeL3Qg1 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 30 Dec 2018 11:36:27 -0500
Date: Sun, 30 Dec 2018 18:29:06 +0200
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Bug report: unaligned access with ext4 encryption
Message-ID: <20181230162906.GI27785@darkstar.musicnaut.iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, David Howells <dhowells@redhat.com>
Cc: linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

When using ext4 encryption on SPARC, there's plenty of dmesg noise about
unaligned access:

[  167.269526] Kernel unaligned access at TPC[5497a0] find_and_lock_process_key+0x80/0x120
[  167.270152] Kernel unaligned access at TPC[5497a0] find_and_lock_process_key+0x80/0x120
[  181.087451] log_unaligned: 5 callbacks suppressed
[  181.087511] Kernel unaligned access at TPC[5497a0] find_and_lock_process_key+0x80/0x120
[  181.092435] Kernel unaligned access at TPC[5497a0] find_and_lock_process_key+0x80/0x120
[  181.095816] Kernel unaligned access at TPC[5497a0] find_and_lock_process_key+0x80/0x120

And also seen on an ARM machine:

$ cat /proc/cpu/alignment
User:           0
System:         1028193 (find_and_lock_process_key+0x84/0x10c)
Skipped:        0
Half:           0
Word:           1028193
DWord:          0
Multi:          0
User faults:    0 (ignored)

Looks like user_key_payload layout is not optimal when data address
is used for fscrypt_key... I tried the below change and got rid of the
messages. Not sure what the proper fix should be?

A.

diff --git a/include/keys/user-type.h b/include/keys/user-type.h
index e098cbe27db5..6495ffcfe510 100644
--- a/include/keys/user-type.h
+++ b/include/keys/user-type.h
@@ -31,7 +31,7 @@
 struct user_key_payload {
 	struct rcu_head	rcu;		/* RCU destructor */
 	unsigned short	datalen;	/* length of this data */
-	char		data[0];	/* actual data */
+	char data[0] __aligned(4);	/* actual data */
 };
 
 extern struct key_type key_type_user;
