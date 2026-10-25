Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792953773;
	b=nb/5+s664+lj1CfzFYwG9GWOmi0BJ2o/XYFoAssviBs3C8PESt7Rfn56c7+jO90yKK+N
	 cYpnVyTyW6WMg3qtWJex2Cc9Z/xFo187XUGIqWP+0Tc10KSD82MBdD71DWvmdGGYui9ov
	 sLG6L7m5VtX62bEZLoLs1RnSY+Foq3yo4UP1HECuC/gtYRmRG5eH0ahGRQvC345Kj4wwR
	 erK/k+0fhrbYBxiq9EfYT44NUzqRs5C36hq5Iu0RNWINLiCCYTJ4S8/MSTE3MiNLAf22N
	 5AXKQoWC+xB/hQ76C4hhwi6zMw/oiYR+r0g5bbRk/4IOhOnT661o1FxMeMYpUniNuIQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792953773;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=MWImOuQ6ypazyDauHnpT+aNeaPFSVLwAEzW6QlQDKXg=;
	b=D0k/bD5JZlcCBd406+2/Zy8wP2fJvDPgU3bCCfxok9WusBpIKO3LGITO0xHC/tjg0awy
	 /fyn9s50p397rv8XU+rDwL25YgJeo5VberP8QAPZRJHsrZXM3slYM8BOtRmEZ5Rh3w7Kw
	 uq/k8cpYysPlyEs9KhxhVuy3j/2oropPw7FhmZCaLBXGnNKgmS1ltIG8tX3rQkXkk6wkV
	 cbl6nnqmJ5tOjNxv5ZOekjCiKnTMQcvItx0EZOwcvPwDcaEHSqr7PIT2BfoTVtQzPj3Ba
	 hs1UiAHWNICB+5O1M7Pp+Oq9u8uyw7noBBVnPv5kUoLTSca0E+i7qBtdUAmQcLI+EZA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=YnhCpwT5;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=UM9gNfOc;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54483606A324
	for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 18:42:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 54483606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=YnhCpwT5;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=UM9gNfOc
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792953772;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=MWImOuQ6ypazyDauHnpT+aNeaPFSVLwAEzW6QlQDKXg=;
	b=YnhCpwT5oQvz/xsrUA0NmjLzHab6GVhBdslYCvVwuNxMQiVjFWyHAAa7MZzA9rbsHGbJrs
	XF/ZiF3OT5B6xMZt+Gvat+tV5TS5jnaZ8FXoBApC3GYIW8tmKPWWGSgXJJtLxMpdQl5yTL
	2NlfnPpV/D7R7vAg/TCqQRF1aGmH29c=
Received: from mail-ej1-f72.google.com (mail-ej1-f72.google.com
 [209.85.218.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-692-KPCu9zkPNMObsb7GWQ_0qA-1; Sun, 25 Oct 2026 14:42:51 -0400
X-MC-Unique: KPCu9zkPNMObsb7GWQ_0qA-1
X-Mimecast-MFC-AGG-ID: KPCu9zkPNMObsb7GWQ_0qA_1792953770
Received: by mail-ej1-f72.google.com with SMTP id a640c23a62f3a-c3613c35145so256373966b.3
        for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 11:42:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792953770; x=1793558570; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=MWImOuQ6ypazyDauHnpT+aNeaPFSVLwAEzW6QlQDKXg=;
        b=UM9gNfOcWXQfA6+mcNx2oOQLAI7uqUEEJFZll8z+z1ftL3/5ziQNEzQZ2OVoqKwM/Y
         SNSw00ojeXr7N5jtYuSeSmSMQgS9ml/ddfALqfu8o6Fl0t9twnlZBDuUOhPEg3IdskWh
         5TG0xGt5EXyDYYVjdcoduwqJEf1arIEMiBaS4EUdyhJm3bFZu9j3kccBjnwUuIaB4I73
         /W8AF1sw/drE6ylMDrWiNEaoHXUVzKHZhOBPHAVE8oFN3orLP9zqagTldlOmG9tmSFnQ
         ZjXQBNGhXrMnPUsHVVNuIF2Sia8pCLtK4Bbq9jNdDQuCpP4YAH9uHRF/GqeNBJkvB6sE
         dvng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792953770; x=1793558570;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=MWImOuQ6ypazyDauHnpT+aNeaPFSVLwAEzW6QlQDKXg=;
        b=uelQs4LQA2mgrcfg1gDGQe358jnEd1uSTgWXugTrErDZslFPBqhntFY1RXZQ1ZvXx0
         4Fcg1xD+lGVJVvRfjglxRKOHVutW72lso3kxb5Vn5XNEa9t/ob25VthAwVpjRhbnuiy3
         KDanQNBwOs+MGf130ynuW9NjEre51z6yCoekFnYurwiqmTG12j1qSR3dJnjh74xj4YeH
         WXS49KWGb9E492YNKbpjiVd/WgILafm6t2P71bhGQo4W2/j45NhQDbETvkB9cpm4vBuw
         sC0MrkGQmTLBs4J/iL6pvhNWwqZ96q3QXZM4ykxSDDRYi7HEq392q32oBMzLHSppsqTt
         8RhA==
X-Forwarded-Encrypted: i=1; AKwUvBxfMe9P11aPoe3Is5EXRwTf4inyz7xP/ov/yR32ftZ8cKZ55WiLkhk9stiMhAw8BdPsLvc9HA0iBOtyZ8I2@vger.kernel.org
X-Gm-Message-State: AFq9FYJNN6XoF2ix8D8s5oOjERXJEO1oNSqaSWmgBivBaUmtLB71DXrG
	rcLn4ZjVWrRW++pajsQ9ywLfOoER6YaD4O+pYs3h4e+Kfeyf6ZudsUKI1Zco5dEVC/iT6NCQk/K
	PwphiVuPDp97rMqzDR6r2cuDsrJkO7eLZNwu4IbJKcfH00gz/7q7p7YRCTGHXKrFdJBc=
X-Gm-Gg: AYBFou1YtpI5su212fpv8YZjyvkLiKR+bZIK0JjORi3mRv1yaIOqyyRq4iXyFSqrdDh
	hWoQCGh/Cw9wOekAJ/AOdwMRroEXXKL03Ocb5NfdjVnqvyKSS79GzFd9zWUY/ceLOzhv46DXQX7
	A4ZObdKZsnPJU3gm38v6ZOE6eBuvnnv7UNN9i2E/B0PSw6h3w47niia0upNu4FqBI1Rfv0BRe+g
	IqKMkwUkdxfZwigPWC3qY1kAilhohn4+rfe8d0ZPI3fUY6gF0xy5yehhDcU+sHWRJAnTPIuJrI/
	IKQu2dx3/KpEbtFAlrieecMCh+akyTLBFvy+W25XY7MsWi7ky+y5MiW0cLZsMyI/SeKvrgO8hLV
	huVu3lg5CuBt8PKz8KymSB/I8tiSsJpB8uKtD668KDR55YGSs4by2Z2nZhfKF51XyRLsyvbOi5z
	dddf+X9zbhZPoHuzUR4/P8cURe/htWPMO+6auikN/7OiVmPmbQoYrGpcXvYjMgh4zL88++EuUN2
	FM=
X-Received: by 2002:a17:907:a095:b0:c42:24ea:3227 with SMTP id a640c23a62f3a-c46bde93411mr663664366b.31.1792953769862;
        Sun, 25 Oct 2026 11:42:49 -0700 (PDT)
X-Received: by 2002:a17:907:a095:b0:c42:24ea:3227 with SMTP id a640c23a62f3a-c46bde93411mr663659466b.31.1792953769487;
        Sun, 25 Oct 2026 11:42:49 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c46bd66e51fsm230750866b.64.2026.10.25.11.42.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Oct 2026 11:42:49 -0700 (PDT)
From: Alex Markuze <amarkuze@redhat.com>
To: ceph-devel@vger.kernel.org
Cc: idryomov@gmail.com,
	xiubo.li@clyso.com,
	slava@dubeyko.com,
	viro@zeniv.linux.org.uk,
	brauner@kernel.org,
	jack@suse.cz,
	linux-fsdevel@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	ebiggers@kernel.org,
	tytso@mit.edu,
	jaegeuk@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v6 1/5] dcache: export d_find_alias_rcu() for modular filesystems
Date: Sun, 25 Oct 2026 18:42:41 +0000
Message-Id: <99467b57d12e5b671246aa5e216ddce3a7dc3923.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
References: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

CephFS subvolume quarantine needs a dentry alias for its RCU ancestry
walk without acquiring a dentry reference. d_find_alias_rcu() provides
that lookup, but is unavailable to a modular Ceph client.

Export d_find_alias_rcu() to GPL modules. The Ceph quarantine state
handling patch uses the export with the helper's RCU lifetime rules.

Signed-off-by: Alex Markuze <amarkuze@redhat.com>
---
 fs/dcache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 1b1a81f10da67c608704383086c3facb64ee3b3b..13ba553081b33a54fd8d1cac5cbc55d0149e4ad7 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1248,6 +1248,7 @@ struct dentry *d_find_alias_rcu(struct inode *inode)
 	spin_unlock(&inode->i_lock);
 	return de;
 }
+EXPORT_SYMBOL_GPL(d_find_alias_rcu);
 
 /*
  *	Try to kill dentries associated with this inode.

