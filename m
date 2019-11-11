Return-Path: <SRS0=IHSl=ZD=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70771C43331
	for <linux-fscrypt@archiver.kernel.org>; Mon, 11 Nov 2019 16:13:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44BF420856
	for <linux-fscrypt@archiver.kernel.org>; Mon, 11 Nov 2019 16:13:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="LPHfI77i"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726887AbfKKQNv (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 11 Nov 2019 11:13:51 -0500
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:43623 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726845AbfKKQNv (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 11 Nov 2019 11:13:51 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
        by mailout.nyi.internal (Postfix) with ESMTP id 7D24521A7B
        for <linux-fscrypt@vger.kernel.org>; Mon, 11 Nov 2019 11:13:50 -0500 (EST)
Received: from imap37 ([10.202.2.87])
  by compute3.internal (MEProxy); Mon, 11 Nov 2019 11:13:50 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=content-type:date:from:in-reply-to
        :message-id:mime-version:references:subject:to:x-me-proxy
        :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=pIGhfC
        TwADpXXJ1b70Rm+bVl4tKRfUyGg8vyfjI8Ffw=; b=LPHfI77i1eHpD+oPKkmLCR
        atP2Ln5EiftKq+EWXUNMzRr8gB972fjIomkjZB/hjECW8aJFn5+2RlVohomorTop
        6Lfed5braDIEFoSAI7i9ztDlnOhvXZFuTttrWBZygrBW7oGTK55K+QccFRC98pRt
        KXS5gWs44SAcFYj2ixL47KEGiqffeJOdUjD6otx6YKvA89v+A8OWw7CX1I4czgEz
        03glU37RfiRDaIRTGBNraIMgUJ5uw1QdMDvoP9DWd+JTmQjAIBZOBVszY6ycWaqU
        Zzr3JFo7h7GXvhhXt11KojJ2/z+NJiA/4/v34lMGYf2zAE9VbDfdYjeE7NbkzQ4A
        ==
X-ME-Sender: <xms:vYjJXT33JExTpa-6ERegBUp23O3eJSG7r4vP99KdssemlNI_D_lZRg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedufedruddvjedgkeekucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucenucfjughrpefofgggkfgjfhffhffvufgtsehttd
    ertderredtnecuhfhrohhmpedfveholhhinhcuhggrlhhtvghrshdfuceofigrlhhtvghr
    shesvhgvrhgsuhhmrdhorhhgqeenucfrrghrrghmpehmrghilhhfrhhomhepfigrlhhtvg
    hrshesvhgvrhgsuhhmrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:vojJXQWGhSm0llNUrNyvh0jrkjjgN8wqzp5fHWSxqwK6KsAg3oALrA>
    <xmx:vojJXeARy41XCVyfpHyEnqdrjudWVuPA2meR-9qnT67lwwRVzW4hpA>
    <xmx:vojJXVM36FuFAc_DEVjV6X-ak00Rb-NsJbJGW7SokpnKVE0_WGzL8A>
    <xmx:vojJXYHt4PzfF5EIhJSj8q20hW8XdzMFHUTX4vvLnfZuk2e30n7lTw>
Received: by mailuser.nyi.internal (Postfix, from userid 501)
        id CE531684005F; Mon, 11 Nov 2019 11:13:49 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
User-Agent: Cyrus-JMAP/3.1.7-509-ge3ec61c-fmstable-20191030v1
Mime-Version: 1.0
Message-Id: <c45a6392-e4ae-4a78-b90e-46036fad0683@www.fastmail.com>
In-Reply-To: <ec3d8041-e791-4016-943c-f1dade1be5eb@www.fastmail.com>
References: <696354c2-5d7a-4f37-93d2-9a58845ad22d@www.fastmail.com>
 <20191109034150.GC9739@sol.localdomain>
 <ec3d8041-e791-4016-943c-f1dade1be5eb@www.fastmail.com>
Date:   Mon, 11 Nov 2019 11:13:29 -0500
From:   "Colin Walters" <walters@verbum.org>
To:     linux-fscrypt@vger.kernel.org
Subject: Re: Some questions/thoughts on fs-verity
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Sat, Nov 9, 2019, at 1:46 PM, Colin Walters wrote:
>
> Or really a bottom line here is - I could imagine reworking our 
> userspace to do this FUSE mount of fs-verity tarball model, but if e.g. 
> the kernel filesystems aren't really feasably made safe against 
> malicious code, then...it may not be worth doing.

On thinking about this sub-thread more, if one is shipping an OS with a persistent storage volume (whether the same as the fs-verity'd OS or separate) that's mounted as a regular Linux filesystem, all the concerns about corrupted FS images apply, regardless of whether one is using dm-verity or fs-verity for the OS.

Although perhaps in theory in the dm-verity case, if the persistent volume is separate one could e.g. do some userspace sanity checking (fsck) of the persistent volume before mounting it, or e.g. apply OS updates before mounting it and reboot (to address the scenario where an older kernel has an arbitrary code execution flaw that's fixed in a new update).

Hmm.  Maybe it's just not feasible to avoid effectively verifying a full filesystem image for the early boot OS anytime soon (whether that's an initramfs image baked into a signed kernel or actually dm-verity).  But probably for us going down the path of including the OS update system in the initramfs, and signing initramfs images will make more sense than dm-verity.

Either way, this gets us to the point of "can apply security updates and/or inspect filesystems on disk before mounting them" executing signed/trusted code; but leaves open the rest of the discussion around applications (Linux containers, Android/flatpak style apps) etc. that doesn't scale to bake into the initramfs (or generate dm-verity partitions), and like Android is doing we want to support potentially privileged applications that are distinct from the OS.  And basically whether fs-verity can be extended to support regular filesystem trees for those.


