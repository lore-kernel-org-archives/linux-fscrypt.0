Return-Path: <SRS0=XTu7=2B=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30A28C00454
	for <linux-fscrypt@archiver.kernel.org>; Wed, 11 Dec 2019 14:41:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 019122465C
	for <linux-fscrypt@archiver.kernel.org>; Wed, 11 Dec 2019 14:41:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=aol.com header.i=@aol.com header.b="fsjcTIV9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729946AbfLKOl0 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 11 Dec 2019 09:41:26 -0500
Received: from sonic316-54.consmr.mail.gq1.yahoo.com ([98.137.69.30]:46287
        "EHLO sonic316-54.consmr.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1730010AbfLKOlZ (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 11 Dec 2019 09:41:25 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=aol.com; s=a2048; t=1576075283; bh=8NXnEgzl9Hn8ih6NVxBSO6w7sunPtWemBcwEu/MIQmY=; h=Date:From:To:Cc:Subject:References:In-Reply-To:From:Subject; b=fsjcTIV9H5UBmlvgJKstt4aT/VgsSf7yCPzptrD0iuurqBijQPf9SpJnVFK30s2Ycx6WiiJ5vWb5xaNBaudYrK5FVORUy9y1N6Lq4pbRgfipFlGZLv6/tinLBRT9cWbuOkykanIr1jciUbo0mLN5d3UnwaJH6qCatvgK3tFU7AEnUxbBXXFBKdCLSGYVK6KAEJbeQPjSDOKv9Bb3ieEF/UcWl9axO8JI8thuE5nKudgH5053ddxAM2nDZvmSdNqK0B2hE24QgdCm8yASCFVItBXYHNvoPk8ssysD75q/fd6xZm10G0UVccXuCqvnk1TCLDHhSg3msuFeLNd5TBz2tw==
X-YMail-OSG: 7tLwCK8VM1kVE8ixC98XdwHbsJrsuowK0Ze0yHbgVvZa6ezhc58f6EXGiUYOjUo
 AvgARQgxWpqLV1OAf3D2fl_5DMhgK5Ev.ttEquU_oV7eCokz3DaqY_Qu0WCyuDhhoe.VlXjSIVbm
 5Y.5F2zhwxrWQo4nSq.f8HjwY_c7hRA_OOQ6ywzIT2B34zsJV6Ny9_d_KT_8ehqqkOkTnpdHxzeG
 GhGH8.QNcUaeNNP5J9yLC.nY1Ym1QvatVSdIhcqSA0cH7GLgnEFJ5I1lpKFoUlwJZxW5rpJxnOf0
 Upd9ZV1x5J4_Z7qOWQmE2QxMeQ3btI30By5jXTN61_bO5aQylvOx_Zs04VOX8Y89ZJ2It0hCO0S9
 n6iJlfoV7.owVYOlxTY1f69F9W91EVTG0r8jqAFjS7InWJzhffiRfuEjAoS5X1l2vVTXMY7gA3w.
 96SADI16lGU1I44jwY8D1XSZl6Jcy5i4gbpQg5kqhIoVfYVYo5pKgvfaLAE.kap5lEj.QvPy8buq
 YrN5hJzFd.IHzCnLMyldBirgqcHDFFgxut1v_Yub8z1eTN1U6jqqNOxSSSiqq2_3WD3.373SyRMA
 Wt5.ik0DP_r90uwwT5kxRyaJfDYRW1Oc8PDtrHWb61hTLUQHtd4RfNSJck9nIpiiMOJJJxSUTNOg
 GPoBIBZ1TlrZoLsYo.Ga_cuvHij58M9LD7yHcl48t_vfQUV6lHKXsjvlUJdl_WVsDDwJzSGILYPm
 sYxKRG4sJBSmxioh1u6VlKMRU4Qa5Y6nVx.9i51cjRtrDeD3a673qQVRb2i7OVtHbFgmsU84B_Vd
 7yqO3rtnmsGO45TPuMMTOrdQNBVQB.H62evznpNyGJgpr5btZicu4VYFtWFySdrSPrQ2sZmBFPPX
 txqmSEGEm8GyzRCsSMWyvset0sc50Kc3SOTFcsAwtlinDM55dJjAd3Sht3mAF49ttU27GypPpFUP
 6SzBMznAm6FS6EUxwy4PlXc1HPvF6HkXiffyCsthLUMy0WHG48OYxXeAgl2H1G.d5tqyYbwsNn7W
 FjS9MKf12dXY8FzTo32qAK_0Ng8M9GXVUdvsdb0I7pECxp5aCvEsVbt7FItG4HMBS8ztJPYZ54bE
 p2uwf.B1hmfnt87hZfIkVw3r4m8OXYszcbUqsHX3WhM.BrghCdqycqzRu8O8jJu2fsuSdFx_hWV6
 MMhCq72YiZxrk5xuN7XJeo.18JqmD0l66geIQWB38WxgtbOTN1xfgchBgzW.Bh_QC5Bqlgs.OBQr
 Ia_BVgCLitKrmkzLIiz9p4trv8BhmG2JQ7291iwAdXwRoFB5MgE4ohNYRsGpcSDDE8hgmWkQJqvB
 6_qUOovThV5EDGgwha5sBn8uY9VkIK.irycx0ed_u0gv7ilE_lZPAm9v8iexz5HMXgN4B3vwhHSW
 E
Received: from sonic.gate.mail.ne1.yahoo.com by sonic316.consmr.mail.gq1.yahoo.com with HTTP; Wed, 11 Dec 2019 14:41:23 +0000
Received: by smtp417.mail.gq1.yahoo.com (Oath Hermes SMTP Server) with ESMTPA ID 36f5534268c63ff9379ab7e119e12b1f;
          Wed, 11 Dec 2019 14:41:18 +0000 (UTC)
Date:   Wed, 11 Dec 2019 22:41:00 +0800
From:   Gao Xiang <hsiangkao@aol.com>
To:     Matthew Wilcox <willy@infradead.org>
Cc:     Gao Xiang <gaoxiang25@huawei.com>,
        Tiezhu Yang <yangtiezhu@loongson.cn>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Eric Biggers <ebiggers@kernel.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        linux-fsdevel@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-fscrypt@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-kernel@vger.kernel.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v5] fs: introduce is_dot_or_dotdot helper for cleanup
Message-ID: <20191211144055.GA6951@hsiangkao-HP-ZHAN-66-Pro-G1>
References: <1576030801-8609-1-git-send-email-yangtiezhu@loongson.cn>
 <20191211024858.GB732@sol.localdomain>
 <febbd7eb-5e53-6e7c-582d-5b224e441e37@loongson.cn>
 <20191211044723.GC4203@ZenIV.linux.org.uk>
 <4a90aaa9-18c8-f0a7-19e4-1c5bd5915a28@loongson.cn>
 <20191211071711.GA231266@architecture4>
 <20191211134014.GM32169@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191211134014.GM32169@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Mailer: WebService/1.1.14728 hermes Apache-HttpAsyncClient/4.1.4 (Java/1.8.0_181)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Hi Matthew,

On Wed, Dec 11, 2019 at 05:40:14AM -0800, Matthew Wilcox wrote:
> On Wed, Dec 11, 2019 at 03:17:11PM +0800, Gao Xiang wrote:
> > > static inline bool is_dot_or_dotdot(const unsigned char *name, size_t len)
> > > {
> > >         if (len >= 1 && unlikely(name[0] == '.')) {
> > 
> > 
> > And I suggest drop "unlikely" here since files start with prefix
> > '.' (plus specical ".", "..") are not as uncommon as you expected...
> 
> They absolutely are uncommon.  Even if you just consider
> /home/willy/kernel/linux/.git/config, only one of those six path elements
> starts with a '.'.

Okay, I think it depends on userdata and access patterns.
I admit I have no statistics on all those callers.

Just considering introducing an inline helper for cleanup, except for
lookup_one_len_common() (since it's on an error path), others were all
without unlikely() before.

Ignore my words if it seems unreasonable or unlikely() is an improvement
in this patch and sorry for annoying.

Thanks,
Gao Xiang

