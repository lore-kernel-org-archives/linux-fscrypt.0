Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC71FEB64D7
	for <linux-fscrypt@archiver.kernel.org>; Fri, 30 Jun 2023 06:49:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230013AbjF3GtE (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 30 Jun 2023 02:49:04 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39138 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231617AbjF3Gs5 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 30 Jun 2023 02:48:57 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F32862D70;
        Thu, 29 Jun 2023 23:48:56 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 74B18616D0;
        Fri, 30 Jun 2023 06:48:56 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A9821C433C0;
        Fri, 30 Jun 2023 06:48:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1688107735;
        bh=wVYGt7Gyhxaq7Gqm6ZIYNZewIWyooc0rhlyCKhUQPxg=;
        h=From:To:Cc:Subject:Date:From;
        b=NLOEJ47I7+Wa3NrhW5sIN8Iru/tPWkky05Fi3f3gXO3L+A5p1+2CQX7NCxI4UiCKm
         /uEF+UjbfWilcRPnPRF2dZdNvL7OcXaeuGeHKqFoMlkpqco8nhVynPfmuUHmDG3naR
         8IGeNMN+uaKpAEAzvWHxMkPph6MaODdikLF8HjJ7W0VmqlkwsFsvS2hEwRKfJnmegw
         AzpHLhjcCp+b4F0IVXXbadSTyW8BhbdComNnLRFxmsG7XGqINXlR8iUinyD2CfhgRR
         eUALPDLTOO3efkn05btT1xMafweDTDyM2vP5M4hN5ObYL2yKgUs/vI1dsGghO5AL7Q
         Voi3daw2qZuyQ==
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-crypto@vger.kernel.org, Dongsoo Lee <letrhee@nsr.re.kr>
Subject: [PATCH 0/2] fscrypt: update the encryption mode docs
Date:   Thu, 29 Jun 2023 23:48:09 -0700
Message-ID: <20230630064811.22569-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.41.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

This series improves the documentation for the encryption modes
supported by fscrypt.

Eric Biggers (2):
  fscrypt: improve the "Encryption modes and usage" section
  fscrypt: document the LEA support

 Documentation/filesystems/fscrypt.rst | 166 +++++++++++++++++++-------
 1 file changed, 121 insertions(+), 45 deletions(-)


base-commit: 82a2a51055895f419a3aaba15ffad419063191f0
-- 
2.41.0

