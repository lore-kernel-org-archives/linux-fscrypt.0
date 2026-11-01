Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=148.163.135.74
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793564190;
	b=jf+ZIw735yWstT0+NzYORmKszHJ1XYhGyL05UalrKW83aGXWP0wmRGorhLdu42rRQ6cx
	 gX+sI6WrSABxFJf7PBv1sR1C4711t6yLEXqm5NmmkuPurn89uCLbhncaBOCWlde1nhz8f
	 TrqEym8qTiFNGuJW9i1LXr3z2Cad/GD4FHcRmLzXp0rMrsF/Df0mtIq2ZqEuWvElIpF+3
	 xDf0wqvNr/nk8/uuEfxcj5gGjGoPhQyePbqpl1Osp/61thuDcDiMetz8XVADMGn8wjFWf
	 knt/PA3xkVfv6IeToNp/XioIiDwktgLgA6VSSOtSBVmkD7anBTqa6/RLrHIEvRs/4Ag==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793564190;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:
	 DKIM-Signature:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:From:Date:
	 Subject:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Proofpoint-GUID:
	 X-Proofpoint-Spam-Info:X-Proofpoint-ORIG-GUID:
	 X-Proofpoint-Spam-Details-Enc:X-Authority-Analysis:
	 X-Proofpoint-Virus-Version:X-Proofpoint-Spam-Details;
	bh=BtqvH3vjepU6l8Kv/btHJpUB6/evyy2CtbBRVPfKP2g=;
	b=odAoKhTK6ZAOOSBtZpf6WtkK+wo1jRB8AkSuVknda2kHKnztqXyqxPWbuJJvIrVliTrR
	 zEnR8xizi/BJllOn1d6GTdZ/D/9w3hrbB4er27dZga2PHQMaHo+uUBt1rsggzJgwSpBsK
	 QxK9gVIppZl8W1/P1B4jHkX9WAgg3aUn/V2beh3Ma3m7Xfpd3fOQOYS6dbwpfHZDC8ZZM
	 tEUh9C1sILM72LLpIfByft8ihsSMFrzA/CB368vD9SVJ0kc0telr7OtvX5MuOecz2cQ5V
	 jxrMXvyNQ74NjlUgGGhIStvCqNx54x7ukOWNzl/biQqD9f3sWd3GrcI2d65oUpPVGBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=columbia.edu;
	spf=pass smtp.mailfrom=columbia.edu;
	dkim=pass header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=pps01 header.b="BOTP6sX/";
	dkim=pass header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=lionmail header.b=DKuIAHzK;
	arc=none smtp.remote-ip=148.163.135.74
Received: from mx0a-00364e01.pphosted.com (mx0a-00364e01.pphosted.com [148.163.135.74])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A37D606A327
	for <linux-fscrypt@vger.kernel.org>; Sun,  1 Nov 2026 20:16:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9A37D606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=columbia.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=columbia.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=pps01 header.b=BOTP6sX/;
	dkim=pass (2048-bit key, unprotected) header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=lionmail header.b=DKuIAHzK
Received: from pps.filterd (m0167068.ppops.net [127.0.0.1])
	by mx0a-00364e01.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6A1ESOAS3608610
	for <linux-fscrypt@vger.kernel.org>; Sun, 1 Nov 2026 15:16:29 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=columbia.edu; h=
	cc:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps01; bh=Btqv
	H3vjepU6l8Kv/btHJpUB6/evyy2CtbBRVPfKP2g=; b=BOTP6sX/PA1KGMzNmpuj
	GA2x+BC6ZMwFxS5xglAmXbYWr/bJlTE5WAVQjiVB25TU0ySljkagQW6hjtyb69TI
	A2jtVV9bHmm851HLuUlE7y6ABcJ8SjzbKPxws6UcqklSqdkRqqz+pkVNSiQqZlRf
	etPckgxXVKmGU0hL4GUZ2aejLMKe1A88R8kxAzoc1M/TZbmK1x3pZaZ3Ou5mHX9f
	rwbFLfvJHNaYAmaraiVkSQ0TmDoEosBTkG+1Sk5mADjAku9Up2Aq5uCrTrZyCIOW
	P0O8YMygDnV16oy6TqganDPB8NuiiRfLwdfMbmy+HhEC3BJKgGKufEzaaQrFQhWl
	RA==
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by mx0a-00364e01.pphosted.com (PPS) with ESMTPS id 4hp77fhm23-1
	(version=TLSv1.3 cipher=TLS_AES_128_GCM_SHA256 bits=128 verify=NOT)
	for <linux-fscrypt@vger.kernel.org>; Sun, 01 Nov 2026 15:16:28 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id 71dfb90a1353d-5eaad995a7eso570248e0c.3
        for <linux-fscrypt@vger.kernel.org>; Sun, 01 Nov 2026 12:16:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=columbia.edu; s=lionmail; t=1793564187; x=1794168987; darn=vger.kernel.org;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=BtqvH3vjepU6l8Kv/btHJpUB6/evyy2CtbBRVPfKP2g=;
        b=DKuIAHzKARzeprpqHeJ7BbvEloeJDiVMWpiA2qxqL0MlhLQnb+PX2qYMccKC8U0gSN
         RBJ2o/ysQu6l7IBFGQbUSSttxE+VJvqb2epClRSETJVc2jtMZst5OO2QbrubaRkdOFxM
         6Yzo5SgI/TqxkyjE/NakWTHP2uLk8GtoeUHpjQu1LqK7oFhL6NNBcGeMPQ0HnUkr4Rbn
         gsk73N7PLw2LIPHnT6Ha/HZcnTZPXgFBcE4I8F+o8AjOtD+8SJ/QCihB5buQpBgLNvXD
         zeQ/EJ2Bd9cSAJ+UaOlOpEU3GypslI1tlkCNWiXuqndhNfjo1AL4d3WjCspJ2qtiGV1+
         VDxg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793564187; x=1794168987;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=BtqvH3vjepU6l8Kv/btHJpUB6/evyy2CtbBRVPfKP2g=;
        b=aROuQ2yGkWs9ZymZYbmYVuAadlovsLrgUVaDL5pWQf2vriVPo8SSgu4L0Vf9h1U4JA
         E2cmFH6c+WJmQsehzj9D+L3Pz8UHVAv/wLZ86nVrOK+jXmUjOlxLRO4kT7Dhe2MEaVUu
         nstAktpVeGnsK05yNyvuRvNwXboKxN1q23JkpANpAycoGwBbIf+15BJc2IDeNZpORS3X
         b+AqoGJQnCJSX//2uec2x+PcRss9+wF8TjIutNgkU2i1hujemoZHdMyLn+Btmw/qBGhv
         NR4oCvSYntbQ3EHsMrz+RHNBjOuWMbdQDn5vfWUQMzH9F68v3R8f2r4A2ObVg98wNmjN
         1F7g==
X-Forwarded-Encrypted: i=1; AKwUvBygsShX0zEJs2xp3W18jBSWaW4MoYYifSKujcQSx9PUco9zPlsDe3AtxYCUcw3FEOWWE/qDfCIy5IOxXtUZ@vger.kernel.org
X-Gm-Message-State: APuU4Z99qOZgBcj92WKDRlNmNDNPsHi5bxi+X/ekUNfI9rOKi762hJWW
	iEUCqBXuamPGTyvLEDsszf3Ii7DMP11zxxPyBxTXNSxt9qarX667t93fHJPulCGHfaS15owIDg4
	SzAxUdtSaBQrA29mMQpmPFIdJ8kMU6roRu5myH5NWTJwkKhBtdAaQy+S1UKRiVpw=
X-Gm-Gg: AYBFou0vvfG9LlcuuSp4gU+FtWBCYHvChu/eGX32bWlwiikoNdy/x7NzMosPVpiyQSt
	URX8dOK0FhNyRVxWL3NKRNq05TyH7ARHxI79R93E7JW41+IwxuRP3w6XHQYKBP9q03wcdfw+twf
	Wb3mwXWrShgzeHgR7GXLsRPo/7xTwRqE84pgw4AHaTZVElxw6MEsVEjEJFxAayf7rEqNszIoAq5
	k5hmd2e23zX+mfoTnKx8H5nXkq45c2UipHM81xp9IWRExYV62A6pSYAnSHUOZkqWVZFvGBOojU1
	6+YRku25srUDPRHIvidgyh03jd+X/f4MNIT+S95ghezTyQf074O4tMwEuhBBMM0/nFFrziGMNSM
	pLvNaq4JanxsYgOcpJuV+iDSBTwb+O1+x7CavembyTFZmpenHDFXtO2eOg5k=
X-Received: by 2002:a05:6102:549e:b0:7a7:196a:84ea with SMTP id ada2fe7eead31-7d072719b19mr3163947137.34.1793564187641;
        Sun, 01 Nov 2026 12:16:27 -0800 (PST)
X-Received: by 2002:a05:6102:549e:b0:7a7:196a:84ea with SMTP id ada2fe7eead31-7d072719b19mr3163939137.34.1793564187191;
        Sun, 01 Nov 2026 12:16:27 -0800 (PST)
Received: from [127.0.1.1] ([37.142.157.119])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e71b78a4csm15661423f8f.23.2026.11.01.12.16.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Nov 2026 12:16:26 -0800 (PST)
From: Tal Zussman <tz2294@columbia.edu>
Date: Sun, 01 Nov 2026 15:16:13 -0500
Subject: [PATCH 1/2] fscrypt: remove fscrypt_pagecache_page()
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261101-fscrypt-page-helpers-v1-1-bcfbfaf6a237@columbia.edu>
References: <20261101-fscrypt-page-helpers-v1-0-bcfbfaf6a237@columbia.edu>
In-Reply-To: <20261101-fscrypt-page-helpers-v1-0-bcfbfaf6a237@columbia.edu>
To: Eric Biggers <ebiggers@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tal Zussman <tz2294@columbia.edu>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793564181; l=1135;
 i=tz2294@columbia.edu; s=20250528; h=from:subject:message-id;
 bh=j0hglxfyXQKr4eI/+mHHcYxjY14CPbJUF3O9KwDO6K4=;
 b=c4dstX3JRXxdB6ucCvo+OW3XPyEFk8X21W409qAFvQSDcMAN2YAqAMtnHoOSQjwrnwNU0mR0Z
 n6Lq7+BaLbEChSq9oA6w8DgvOHtoEaAtWbYw2K89wsCYwQD4tGXIeLm
X-Developer-Key: i=tz2294@columbia.edu; a=ed25519;
 pk=BIj5KdACscEOyAC0oIkeZqLB3L94fzBnDccEooxeM5Y=
X-Proofpoint-GUID: ORCyEESzapzne5nkJMbvfPxOJDO2QYKZ
X-Proofpoint-Spam-Info: AW1haW4tMjYxMTAxMDA4MCBTYWx0ZWRfX9UNMHBrQUoii
 Du6Ru+EtuOrTlCYGjfOGgHbBqgD69caXzzlYLZGWRpZLZ1ACxHDBB8X2dvQyj4uoIPO+IsX7Mab
 KaM1tcB6bWUnUGM+6UxyW7TSKAWapGgPoaQv3kccZXLzz82cNlMS
X-Proofpoint-ORIG-GUID: ORCyEESzapzne5nkJMbvfPxOJDO2QYKZ
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMTAxMDA4MCBTYWx0ZWRfX4gjkZWwCIabi
 rWpNhUzavPkuVHrERLuf4T+B7z8wENxukoEvYFrUV5Yd8J3cZrxyW9A2b5WLh39+u4t20snzA1y
 xvVZn7+/zit0KQ3YfjRwCmxuzWjulTg+i/O3VT1n3G7z/TPabAMDOwWERNTh604dNirQdRXzvfo
 zdRmkR7yW0bqCQHm+vD7fVCtPWAW92sGl8j/oqwilAhqOZ7b1qX0wvmMbrJWi7uy6Dns0Q2X+xz
 FqtfoXmEI/lh3J/e+QKiGrJXcQZBrMNE44IyKROT0uGl997ChxTACGjj45kNfIKLWFQUeNNHyJT
 p1dswlSCw7XThxWTOVAmzG31T9IVWi8cq+8JFNeDY18ta7VYZuDXS0tIV/Gjt0wChfLvH31jhZB
 rgHYxCf4+p7INrkBnvUusf49yIQiC7cYZKdi/SN+0iZYi5ZFrR82WrcZaXYE0DFvIlmauvNA/7R
 295zc3jyPlN95DZ3gTw==
X-Authority-Analysis: v=2.4 cv=OLOyTiaB c=1 sm=1 tr=0 ts=6ae79e1c cx=c_pps
 a=JIY1xp/sjQ9K5JH4t62bdg==:117 a=Qz3frfIdACK70Hl/8c7MJg==:17
 a=IkcTkHD0fZMA:10 a=zJRp6_cAMcgA:10 a=x7bEGLp0ZPQA:10 a=A0y_DWxS2BwA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=Da8U98TiO7q1upZEImrf:22 a=usPcmh10W0ubT8QP8_c3:22
 a=JcHXAtbk2vn7OX0MrtcA:9 a=QEXdDO2ut3YA:10 a=tNoRWFLymzeba-QzToBc:22
X-Proofpoint-Virus-Version: vendor=nai engine=6900 definitions=11953
 signatures=596817
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 priorityscore=1501 phishscore=0 malwarescore=0 lowpriorityscore=10
 adultscore=0 clxscore=1011 bulkscore=10 impostorscore=10 spamscore=0
 suspectscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2610300000
 definitions=main-2611010080

fscrypt_pagecache_page() no longer has any callers, so remove it. This
removes a use of page_private().

Signed-off-by: Tal Zussman <tz2294@columbia.edu>
---
 include/linux/fscrypt.h | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 28f2108e29f3..e70f630fab0c 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -361,11 +361,6 @@ static inline bool fscrypt_is_bounce_page(struct page *page)
 	return page->mapping == NULL;
 }
 
-static inline struct page *fscrypt_pagecache_page(struct page *bounce_page)
-{
-	return (struct page *)page_private(bounce_page);
-}
-
 static inline bool fscrypt_is_bounce_folio(const struct folio *folio)
 {
 	return folio->mapping == NULL;
@@ -532,12 +527,6 @@ static inline bool fscrypt_is_bounce_page(struct page *page)
 	return false;
 }
 
-static inline struct page *fscrypt_pagecache_page(struct page *bounce_page)
-{
-	WARN_ON_ONCE(1);
-	return ERR_PTR(-EINVAL);
-}
-
 static inline bool fscrypt_is_bounce_folio(const struct folio *folio)
 {
 	return false;

-- 
2.39.5

