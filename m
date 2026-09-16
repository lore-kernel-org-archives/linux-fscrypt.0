Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 26AF24A2E0F
	for <linux-fscrypt@vger.kernel.org>; Wed, 16 Sep 2026 09:21:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789550489; cv=none; b=cL4X+016TZhaSDJzdOfZ9Dw7LTT92doNTBjDEJetYdQiHsWwQw12fqWouHE4y+kg5bQqU8LUlafE9FSYWndAgSGsS1coA6W5PJ3Z6pW5JMGMQb79IQdf3QM5tT/NWGS2Um+01d7nouIKj2NrwYGjMfo4Ny6nap6sf5X4sEF7QG0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789550489; c=relaxed/simple;
	bh=kYbrojFvUZB3MY1/al9oOqd2OaVm7IXuCjTlrA2wWiQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ByODudKDAPjO2txff61PSLZhvz+H+GIDZ5gDnorWyLbBfY8Kie36SU8UeiR/OqoCGAEXUG2i10uk/CrzcBy8cqQli4p3J4Unp5KEWBcIGbeJyQkk05M+ceULpJjRTJRacOAqFD0Pjaq0rE/dilSrSfjM8o3YQqxEKsPGdY9tMk8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ewAdaSz4; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ewAdaSz4"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789550482;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=kH5FiRLDLSRuytv58SScZstNJyhhk8g/hOUPQB2O25A=;
	b=ewAdaSz4lAI2JtKT6BOPUXUskM9OFQil7l7P4cY9rgB8EmXe4/OpbnJ509wOiMZgI9OYNz
	SKc053dLj8kClcOZMSJti17BhpfnGALcX3Ni6ZGKB9T6NzUV/qrkmEaryuay/5RKVNXdmh
	oWcRpk3TqWJMMf8FZmWuu7bCtUcXwT8=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-375-rnmgoSj7NX2So_-B9_kMWA-1; Wed,
 16 Sep 2026 05:21:18 -0400
X-MC-Unique: rnmgoSj7NX2So_-B9_kMWA-1
X-Mimecast-MFC-AGG-ID: rnmgoSj7NX2So_-B9_kMWA_1789550477
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 51E521954B1E;
	Wed, 16 Sep 2026 09:21:17 +0000 (UTC)
Received: from ws (headnet03.pony-001.prod.iad2.dc.redhat.com [10.2.32.114])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id D21C81956052;
	Wed, 16 Sep 2026 09:21:15 +0000 (UTC)
Date: Wed, 16 Sep 2026 11:21:12 +0200
From: Karel Zak <kzak@redhat.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: util-linux@vger.kernel.org, Baoquan He <baoquan.he@linux.dev>, 
	linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH util-linux] swapon: document encryption support and
 limitations
Message-ID: <bxcsbo6pudezcwrrgbyrm6wslkiqhpk5namrbf6osu5nzuhkcb@aqftguervlyj>
References: <20260831175738.37770-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260831175738.37770-1-ebiggers@kernel.org>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

On Mon, Aug 31, 2026 at 10:57:38AM -0700, Eric Biggers wrote:
>  sys-utils/swapon.8.adoc | 6 ++++++
>  1 file changed, 6 insertions(+)

Applied. Thanks, and sorry for the delay.


-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com

