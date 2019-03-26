Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([85.220.165.71]:54737 "EHLO
        metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730422AbfCZHww (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 26 Mar 2019 03:52:52 -0400
From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 0/2] ubifs: Get rid of some ifdefs
Date: Tue, 26 Mar 2019 08:52:30 +0100
Message-Id: <20190326075232.11717-1-s.hauer@pengutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org
Cc: Richard Weinberger <richard@nod.at>, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, kernel@pengutronix.de, Sascha Hauer <s.hauer@pengutronix.de>
List-ID: <linux-fscrypt@vger.kernel.org>

This series gets rid of some ifdefs in the UBFIS code. fscrypt folks are
on Cc because I introduce a static inline wrapper for setting the
super_block.s_cop ops so that filesystems do not have to add a
#ifdef CONFIG_FS_ENCRYPTION around setting the ops. I can do this as an
extra patch if that's desired.

Sascha

Sascha Hauer (2):
  ubifs: Remove #ifdef around CONFIG_FS_ENCRYPTION
  ubifs: Remove ifdefs around CONFIG_UBIFS_ATIME_SUPPORT

 fs/ubifs/dir.c          |  2 --
 fs/ubifs/file.c         | 16 +++++++---------
 fs/ubifs/ioctl.c        | 11 +----------
 fs/ubifs/sb.c           |  7 ++++---
 fs/ubifs/super.c        | 20 +++++++++-----------
 fs/ubifs/ubifs.h        |  2 --
 include/linux/fscrypt.h | 11 +++++++++++
 7 files changed, 32 insertions(+), 37 deletions(-)

-- 
2.20.1
