Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=148.163.135.74
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793564191;
	b=M7ERrlTI3viVzsayVXwS9ocJYDKit4feLcZ4M1jwUag+/G7brBNlx796RNcDgJ9s6Vcx
	 GevskcDpt7VY3P3BbDytlhZTJ8wmGuIE40NrgwBXXr8xj9Cqxmg2RDejfq4ZSIZFi2Yzo
	 eXWgaUk3KDpZfAeiZZ9vIl9RcKfleaE0A4zsV5mgApjFpzZtIugSkEmVAqLJOZ54l8OUy
	 KlhELc4v6TiChxAOKmDnYqUbkuVkns2VOJ7M9tcvvh66CdtbBg8+yZvMpJS9usxPLAfhx
	 oqfOXys25BSyJtdiGYrSr0ruwiFneG8ylisel/O1WKQnGEbfOc1nnHV/dHkM9lew+bQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793564191;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:
	 DKIM-Signature:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:From:Date:
	 Subject:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Proofpoint-ORIG-GUID:
	 X-Proofpoint-Spam-Info:X-Proofpoint-GUID:X-Authority-Analysis:
	 X-Proofpoint-Spam-Details-Enc:X-Proofpoint-Virus-Version:
	 X-Proofpoint-Spam-Details;
	bh=BqTXqaIxt0sZIdIo6UKmgjkLMbcGDQb8Vj6tAnCQxek=;
	b=XWbzFax6RCqWbdW4f+qHM7GjcI3+6jIkRzE3yim4D9cb65HH50ub6YcfbyD+0ptOhmg+
	 9SftglDxoWshffEj491f723PMiXAkWu10i8TWVLZ4upi4lZXx6JoP82ue2WIAkrjxDoE3
	 qZ00GniuIS/03ZYgYIhEJB/0IP6WVEj7M5+bmiyBIiHjBumBAZ/yAj0jqhJM7UjphoOnY
	 myzO2pLVPP4+fdNEXAj00CGBrMnf92PYmtwJdqOsvYuLseQ2pMFnaTAMpWKuypC3A6lb4
	 qorXSj+y/by3hcBLYzFb4lbYPrCeOcSYuTUX7IlnMNvu8h+xqprK0ucxHinyl975u1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=columbia.edu;
	spf=pass smtp.mailfrom=columbia.edu;
	dkim=pass header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=pps01 header.b=TJG64jdv;
	dkim=pass header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=lionmail header.b=YpdMkAvW;
	arc=none smtp.remote-ip=148.163.135.74
Received: from mx0a-00364e01.pphosted.com (mx0a-00364e01.pphosted.com [148.163.135.74])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3BD5B606A32D
	for <linux-fscrypt@vger.kernel.org>; Sun,  1 Nov 2026 20:16:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3BD5B606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=columbia.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=columbia.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=pps01 header.b=TJG64jdv;
	dkim=pass (2048-bit key, unprotected) header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=lionmail header.b=YpdMkAvW
Received: from pps.filterd (m0167072.ppops.net [127.0.0.1])
	by mx0a-00364e01.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6A1GOUtw2275007
	for <linux-fscrypt@vger.kernel.org>; Sun, 1 Nov 2026 15:16:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=columbia.edu; h=
	cc:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps01; bh=BqTX
	qaIxt0sZIdIo6UKmgjkLMbcGDQb8Vj6tAnCQxek=; b=TJG64jdvVFfZcvxcctU+
	Eks2NAQ4Ak6/S12o0lVe0S6I8BOT8+fgifY4zlFiNb62u00yxwXiCetjKEcO2YLk
	UpkEXUyaS7nicbe/fvUUYzZz1ury4X2Lf6scvZJ/9wRzbX5IEX7czXTDzjaE7fzh
	ScmGjD71fxSRFDlYQUj+V6cvUaHwDpQ9gbD0G8+FqmLikYqHDEzMpT6LKzKO6nOq
	NL0Zk6yBNYIX/3DGrDO9+/d7VcEQZpRnsqnUPMUgmSGhoRZVP1cPbjCA9ip1EQR8
	zzVAocsbjHjSL7rRwvRd/8xR2bP6zQsTgY+krrMaGZ+Z3cGUzpFTx5uZrJVy7tlf
	aQ==
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by mx0a-00364e01.pphosted.com (PPS) with ESMTPS id 4hp8wxs17k-1
	(version=TLSv1.3 cipher=TLS_AES_128_GCM_SHA256 bits=128 verify=NOT)
	for <linux-fscrypt@vger.kernel.org>; Sun, 01 Nov 2026 15:16:30 -0500 (EST)
Received: by mail-vs1-f69.google.com with SMTP id ada2fe7eead31-7c0bad5ec1cso605694137.1
        for <linux-fscrypt@vger.kernel.org>; Sun, 01 Nov 2026 12:16:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=columbia.edu; s=lionmail; t=1793564189; x=1794168989; darn=vger.kernel.org;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=BqTXqaIxt0sZIdIo6UKmgjkLMbcGDQb8Vj6tAnCQxek=;
        b=YpdMkAvWTJMPJ2txdznmb+h5yx9f22LGssPYaV8uOMkLkmV6aO5FAaLq1wG/sd7oCP
         x+DQHqEb8e6qfc6SKHIlj62ZbdmNpctUitUi/pJryu1+R6y/pwzDWbPiPIjkO32ruwri
         rFzFd3S1mRcs5D0R8V4par6Aam03bFNQZD21ILFWwZc1noSv0Yj3A4c8g50v0+TXfkER
         hr6QtQVHlooN5u2AN+OJXuK7Ss+/+rxhsX2JREBf/GwyDuTMSKJMlluw/uyW+rMYxOQR
         F9x4vJoebVXk+iLlMyO67BtnPDAlwnS3I/b8p7xbb/cICFcEeFzl/1cimeCxOejppa6H
         IcbQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793564189; x=1794168989;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=BqTXqaIxt0sZIdIo6UKmgjkLMbcGDQb8Vj6tAnCQxek=;
        b=NSlBkshK1h/NIitemawgoZeJWwP8yFCcncge2EAK70gPCRxS0SBUdtI4YhiykyLrLH
         BhTXJhBYk1amRjP8X1CXfXA63GlgcUFw/aeWsWqfsWK0yl2beRjJRPusGMbizOadcoss
         L8IGfFAHBGNKfTBYkUNPsNwgQZsht6b5wyxhe2Rrh/98uucFI0Nyh/Ng8R2lgMVgz2V1
         cSFOTi5FSgOLXFlkrfpPpHmJTK2A7xSy3lxScH5ALK6uu5TBwfenh0hMB4Iv2TnzC+s+
         //CbAHN8S/TydoL/AEVhP27HU8SFwU3CFIEnhJivz6Z4mZbr6t216zUtChzMz1xCw/gr
         yhpA==
X-Forwarded-Encrypted: i=1; AKwUvBzw3y3AuKGPlb8cnYu3cVix7ygz6vD+atA/Sf69az6UJxMog+11VZTVdSqy9JaZt38xAazXzIdl2HOPFKYV@vger.kernel.org
X-Gm-Message-State: APuU4Z9xTUj2wBIqFiM+bpLyODyVF/FzBVc6yWiceXDDde+QxqP6/Ceg
	ztl7cxCAVrU679yZdDzkDkyMoskNP4RInhmQZugSLmSjzcEPoC5B15FXSb2sUWVku9Rne41FbSV
	3evi0OTE4DL/1r/8ljGOEUE8jQgklmIxnmhCg7fbNCwIHFlYg714ieaAlyHMyK6g=
X-Gm-Gg: AYBFou3yOtsVhiVgGWNjAVxNUhvu6PhkKsWBrXYNxniBLEptEHk2DoWPvEvjp3NQJDq
	uqSRkujy0QEzoqdTHZQwmSqVmVtfz222uzh5EzVFeW8iW/F7qTwAZHKJlV86SkSOCR3fbSXD+aZ
	nt8zfMwQeigZL31YSw1kG8OX9+mZgMsLfo03FWAjSZfW6B3Fo2QRWzza4sBV24VJOx82S8/FrGn
	yXzqNZ1VyPppWE0AN9ySpaODzC839C6LIeGnX1/UPhKTtc1g+96wZAiHZEAOnTtfEyR/wSziY2q
	RP8ZXV66eaiJdOTjtwBiKFieH7d35Fxw1LJ08NmBUQHBieN8O9JvCCaMGz4mSPphvgvfKRaYyje
	Xfah4gAub3GLVDmSmdF2xihDtmdiC9Xojpw3uHOB96qUAIGY6r182RB85wJI=
X-Received: by 2002:a05:6102:3ec5:b0:7cc:2bb7:131d with SMTP id ada2fe7eead31-7d072baa484mr2927964137.9.1793564189539;
        Sun, 01 Nov 2026 12:16:29 -0800 (PST)
X-Received: by 2002:a05:6102:3ec5:b0:7cc:2bb7:131d with SMTP id ada2fe7eead31-7d072baa484mr2927962137.9.1793564189082;
        Sun, 01 Nov 2026 12:16:29 -0800 (PST)
Received: from [127.0.1.1] ([37.142.157.119])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e71b78a4csm15661423f8f.23.2026.11.01.12.16.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Nov 2026 12:16:28 -0800 (PST)
From: Tal Zussman <tz2294@columbia.edu>
Date: Sun, 01 Nov 2026 15:16:14 -0500
Subject: [PATCH 2/2] fscrypt: remove fscrypt_is_bounce_page()
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
Message-Id: <20261101-fscrypt-page-helpers-v1-2-bcfbfaf6a237@columbia.edu>
References: <20261101-fscrypt-page-helpers-v1-0-bcfbfaf6a237@columbia.edu>
In-Reply-To: <20261101-fscrypt-page-helpers-v1-0-bcfbfaf6a237@columbia.edu>
To: Eric Biggers <ebiggers@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tal Zussman <tz2294@columbia.edu>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793564181; l=1123;
 i=tz2294@columbia.edu; s=20250528; h=from:subject:message-id;
 bh=FuaDbBzgAylLyOkBuu6fOUJHcXnEh9zDTWNhiRskaFA=;
 b=2cJwYDDDrxsrDKPoMFODyRhRItzplz+Yx9oEv+a8snVPKzI6TGsnhK1uqKmGbTwaZaAyFWvNG
 fIH82I14oOhAlPB4WGMiCOPGIpva2qkQtCcvMk/ZCD4PfO/iwJv4xUi
X-Developer-Key: i=tz2294@columbia.edu; a=ed25519;
 pk=BIj5KdACscEOyAC0oIkeZqLB3L94fzBnDccEooxeM5Y=
X-Proofpoint-ORIG-GUID: lmNv_uk1Jfb9SdrI4Qi62oQViZODGFvT
X-Proofpoint-Spam-Info: AW1haW4tMjYxMTAxMDA4MCBTYWx0ZWRfX/uqxZqOYmVNx
 B/p0GCcQmPuMiK7r9rfZT3DIs4tfTRoBlCM7QRnMKIkN9sKwSWqNMHaGN+8Qz3WSD9O+d0gMqHt
 mz6CnL7xtxrNt/d8IMj5PyP94uvk0Hj9xCjieVcSQNAGcnBqqYB4
X-Proofpoint-GUID: lmNv_uk1Jfb9SdrI4Qi62oQViZODGFvT
X-Authority-Analysis: v=2.4 cv=TpZzFzXh c=1 sm=1 tr=0 ts=6ae79e1e cx=c_pps
 a=5HAIKLe1ejAbszaTRHs9Ug==:117 a=Qz3frfIdACK70Hl/8c7MJg==:17
 a=IkcTkHD0fZMA:10 a=zJRp6_cAMcgA:10 a=x7bEGLp0ZPQA:10 a=A0y_DWxS2BwA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=Da8U98TiO7q1upZEImrf:22 a=SsB-OO3BMngHh3ZO9fOt:22
 a=slkTkWUpcQ_TrhisGP8A:9 a=QEXdDO2ut3YA:10 a=gYDTvv6II1OnSo0itH1n:22
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMTAxMDA4MCBTYWx0ZWRfX3lyH8DMXkYFZ
 n1P2UjCs0smSQPw0ysY9VVOCuU2x2htyqGdY/1Qv70N95+n/7aYhLuWDxZ8C7Ak4GntBt5YzBV+
 +wDhgxro2hNy5d4Ozif3oiCENYl84a8h28pOwfFuYdedPuvLMmuRkgU6TLCUNCRtnnBYCNwJEvD
 zxzB100MapH3GT84MwUUh4ldVe105FZ3ei40f9SXFZv9dLuyjc+o+aqbKYtzOWmjjYD3rO5Np+1
 px9i4GQNnNul2ILADMkKXHr7ZiaZbiyRN2mub7bo2lfbURdwmOWEf8p7cEJpKzzIvnv4ex2aLFP
 QsVSUqpNm4HUC4D4n/U1QOQmLaGraICvb55+1x8DAMy+huxatpnsviWJfCGpw7MS0E8cIv+KQVD
 p/OStnYjNUUu7PUePevPAauagivuFWkNPJzt4mBJAnaV+3vWZuztLP3eP3/Tl7gKlUszB/gTd8M
 ZiF1jUqDVoo2Ds854mQ==
X-Proofpoint-Virus-Version: vendor=nai engine=6900 definitions=11953
 signatures=596817
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 suspectscore=0 spamscore=0 phishscore=0 clxscore=1015 malwarescore=0
 priorityscore=1501 lowpriorityscore=10 impostorscore=10 bulkscore=10
 adultscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2610300000
 definitions=main-2611010080

fscrypt_is_bounce_page() no longer has any callers, so remove it. This
removes a use of page->mapping.

Signed-off-by: Tal Zussman <tz2294@columbia.edu>
---
 include/linux/fscrypt.h | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index e70f630fab0c..3a238bebbdf1 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -356,11 +356,6 @@ int fscrypt_decrypt_block_inplace(const struct inode *inode, struct page *page,
 				  unsigned int len, unsigned int offs,
 				  u64 lblk_num);
 
-static inline bool fscrypt_is_bounce_page(struct page *page)
-{
-	return page->mapping == NULL;
-}
-
 static inline bool fscrypt_is_bounce_folio(const struct folio *folio)
 {
 	return folio->mapping == NULL;
@@ -522,11 +517,6 @@ static inline int fscrypt_decrypt_block_inplace(const struct inode *inode,
 	return -EOPNOTSUPP;
 }
 
-static inline bool fscrypt_is_bounce_page(struct page *page)
-{
-	return false;
-}
-
 static inline bool fscrypt_is_bounce_folio(const struct folio *folio)
 {
 	return false;

-- 
2.39.5

