Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82517C001B0
	for <linux-fscrypt@archiver.kernel.org>; Tue,  8 Aug 2023 23:45:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230038AbjHHXpN (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 8 Aug 2023 19:45:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42460 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229506AbjHHXpM (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 8 Aug 2023 19:45:12 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 43F301BF3
        for <linux-fscrypt@vger.kernel.org>; Tue,  8 Aug 2023 16:44:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1691538267;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=Uit/uI9wNXL5YCKyEI8jLmeigfyPLrbiOuFoHmEFQCw=;
        b=IqYME+S9VuL64uaYYKHAxZmvCG1vfU/01eXENbbyGIjlctRX49J0eQV4AXiUvsrwmVwxUM
        oZUA5H7hBlJ5YHGWjYnO9nWiZfOVt3vkChxLKAX9wG99amrW7IQ9Es7ghkvF8wKqsnmdW4
        oecuawhsfel5eh78adOvf1vs9jte4KI=
Received: from mimecast-mx02.redhat.com (66.187.233.73 [66.187.233.73]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-621-Miq98z2KM-2M0qdOh4MIgQ-1; Tue, 08 Aug 2023 19:44:24 -0400
X-MC-Unique: Miq98z2KM-2M0qdOh4MIgQ-1
Received: from smtp.corp.redhat.com (int-mx09.intmail.prod.int.rdu2.redhat.com [10.11.54.9])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 1DB263C14AA4;
        Tue,  8 Aug 2023 23:44:23 +0000 (UTC)
Received: from agk-cloud1.hosts.prod.upshift.rdu2.redhat.com (agk-cloud1.hosts.prod.upshift.rdu2.redhat.com [10.0.13.154])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A3551492C13;
        Tue,  8 Aug 2023 23:44:22 +0000 (UTC)
Received: by agk-cloud1.hosts.prod.upshift.rdu2.redhat.com (Postfix, from userid 3883)
        id 7C2AE403A55F; Wed,  9 Aug 2023 00:40:23 +0100 (BST)
Date:   Wed, 9 Aug 2023 00:40:23 +0100
From:   Alasdair G Kergon <agk@redhat.com>
To:     Fan Wu <wufan@linux.microsoft.com>
Cc:     Paul Moore <paul@paul-moore.com>,
        Mike Snitzer <snitzer@kernel.org>, corbet@lwn.net,
        zohar@linux.ibm.com, jmorris@namei.org, serge@hallyn.com,
        tytso@mit.edu, ebiggers@kernel.org, axboe@kernel.dk,
        agk@redhat.com, eparis@redhat.com, linux-doc@vger.kernel.org,
        linux-integrity@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-block@vger.kernel.org,
        dm-devel@redhat.com, audit@vger.kernel.org,
        roberto.sassu@huawei.com, linux-kernel@vger.kernel.org,
        Deven Bowers <deven.desai@linux.microsoft.com>
Subject: Re: [RFC PATCH v10 11/17] dm-verity: consume root hash digest and
 signature data via LSM hook
Message-ID: <20230808234023.GC120054@agk-cloud1.hosts.prod.upshift.rdu2.redhat.com>
Mail-Followup-To: Fan Wu <wufan@linux.microsoft.com>,
        Paul Moore <paul@paul-moore.com>, Mike Snitzer <snitzer@kernel.org>,
        corbet@lwn.net, zohar@linux.ibm.com, jmorris@namei.org,
        serge@hallyn.com, tytso@mit.edu, ebiggers@kernel.org,
        axboe@kernel.dk, agk@redhat.com, eparis@redhat.com,
        linux-doc@vger.kernel.org, linux-integrity@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-block@vger.kernel.org,
        dm-devel@redhat.com, audit@vger.kernel.org,
        roberto.sassu@huawei.com, linux-kernel@vger.kernel.org,
        Deven Bowers <deven.desai@linux.microsoft.com>
References: <1687986571-16823-1-git-send-email-wufan@linux.microsoft.com>
 <1687986571-16823-12-git-send-email-wufan@linux.microsoft.com>
 <ZKgm+ffQbdDTxrg9@redhat.com>
 <20230712034319.GA17642@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
 <CAHC9VhQFxqcfgR0acgdiXKP9LT1KLgGjZd-QHs6O1dEex31HEQ@mail.gmail.com>
 <20230808224503.GA20095@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230808224503.GA20095@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.9
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Aug 08, 2023 at 03:45:03PM -0700, Fan Wu wrote:
> On Tue, Jul 25, 2023 at 04:43:48PM -0400, Paul Moore wrote:
> > Where would the finalize() hook be called?
> 
> It is in the __bind function in drivers/md/dm.c, calling just before 
> rcu_assign_pointer(md->map, (void *)t) which activates the inactive table.
 
That would be after the existing commit point, meaning the table swap
cannot be cancelled there, so is the finalize() you are proposing void()
i.e. designed so it always succeeds?

Alasdair

