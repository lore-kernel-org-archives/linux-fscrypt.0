Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=148.163.135.74
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793564187;
	b=MG4b9wjFurqENbb+fQ1VJd55tyueMzOntDRt4vSLnX2TubaJsrMih5IDYg1MexdYxvz9
	 +p9eva/wi0eEkNrGzKvu9ieZUMmqDnHj9R/oxXfpOEuVSjOvQJMHts5A5W+bvKyot0wT/
	 AoN3sgL/F4aQB91Ng4VX9C9oIeedV2JZH7OEjrHowjIlbJjavZZFNy2vRpuhArKRhhx70
	 vjtgiGvCHda96Cjj9GUvpP5DP9fNB9OjfXflUNyVlbLaZahudrKlHL8haseD29YNMQhd2
	 Ln27No5fgB+cidnsefvEhP98zmVgjSjCH0qO8eThbKg2GZFIQs/o3/CkXz983Cvr7/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793564187;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:
	 DKIM-Signature:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:From:
	 Subject:Date:Message-Id:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Proofpoint-ORIG-GUID:
	 X-Proofpoint-Spam-Info:X-Proofpoint-GUID:X-Authority-Analysis:
	 X-Proofpoint-Spam-Details-Enc:X-Proofpoint-Virus-Version:
	 X-Proofpoint-Spam-Details;
	bh=fnaImKbqLYBJXkiqJyPVd4xYWb1JTBRTzOceydKHDRA=;
	b=CrTgQl87d61Kgaq/5PH+VrV7k5nGoQNvHlV4MLNY4E9P4xENpZtmr/K4sFEmUg+RD2FK
	 q4JujI9BLcVv2pIeVJ8rwSFI7rGPXtwwf/BZax15YoFBddQ3egPkfiFqSP/UNUm1sgIHE
	 ueW1vg2X0QgoBpllBpf/gGI1ogsWNKqLHo1qfq7QaQd/sdKg3fZIjbTYSLtmp3kU1JMlq
	 Qg8p5QKtFcS7y1Km8pzHiZB9OGkhiMij2N00n7qQb3Dv5TwmnnT/xsrkZljCyuazQZv4/
	 LRGVSHFWz8zmRXvbBAFBF9IXuprQTmMtd6I+1j0yrH6aWJhPKSGyZc8gRCscNkVVX3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=columbia.edu;
	spf=pass smtp.mailfrom=columbia.edu;
	dkim=pass header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=pps01 header.b=GkqXNSzv;
	dkim=pass header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=lionmail header.b=MehO27oJ;
	arc=none smtp.remote-ip=148.163.135.74
Received: from mx0a-00364e01.pphosted.com (mx0a-00364e01.pphosted.com [148.163.135.74])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD038606A325
	for <linux-fscrypt@vger.kernel.org>; Sun,  1 Nov 2026 20:16:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BD038606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=columbia.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=columbia.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=pps01 header.b=GkqXNSzv;
	dkim=pass (2048-bit key, unprotected) header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=lionmail header.b=MehO27oJ
Received: from pps.filterd (m0167072.ppops.net [127.0.0.1])
	by mx0a-00364e01.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6A1GP0CX2276163
	for <linux-fscrypt@vger.kernel.org>; Sun, 1 Nov 2026 15:16:26 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=columbia.edu; h=
	cc:content-transfer-encoding:content-type:date:from:message-id
	:mime-version:subject:to; s=pps01; bh=fnaImKbqLYBJXkiqJyPVd4xYWb
	1JTBRTzOceydKHDRA=; b=GkqXNSzvcibFejxN1vpyEVcyXQnoG2isUtZLAI30wz
	1QDTXo02zK7Kpimay8r34ydldeU864kjqBvOZAz4iSG4x1REDnhkphyI18asI3E8
	ULSUlGqGhf+2m08obvF40x/pWwtLEkVsRHPI6y6kE3yx/ifyx2SprvBejozIA+Cr
	Lz5lVU8PvEU/dN3XShJhJ0/IKrDNFGiNh9G0q89GVfgid+bBYtmVVex5Wd88HLvP
	jbJqXQ3efJCLg7iaDyKBOcjcLUJPLBsyNuhPJPE0k3NGRQxK7Eoll3k1x/TMe4XO
	pryh3ZAAtvvIIR8uTW3BA4dGdJSF+WTQ2UrGNK5CBD6Q==
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by mx0a-00364e01.pphosted.com (PPS) with ESMTPS id 4hp8wxs178-1
	(version=TLSv1.3 cipher=TLS_AES_128_GCM_SHA256 bits=128 verify=NOT)
	for <linux-fscrypt@vger.kernel.org>; Sun, 01 Nov 2026 15:16:25 -0500 (EST)
Received: by mail-ua1-f72.google.com with SMTP id a1e0cc1a2514c-98c6374b678so2375467241.3
        for <linux-fscrypt@vger.kernel.org>; Sun, 01 Nov 2026 12:16:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=columbia.edu; s=lionmail; t=1793564185; x=1794168985; darn=vger.kernel.org;
        h=cc:to:content-transfer-encoding:content-type:mime-version
         :message-id:date:subject:from:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=fnaImKbqLYBJXkiqJyPVd4xYWb1JTBRTzOceydKHDRA=;
        b=MehO27oJS12xjlwSjuSHO8Q7PUe7/O+AIfSXbhBTyQ1dXWQhLJCf7DBCqL1y/D2C8P
         bxn8pOUTSVO+Szwv0AnKLoKZe1mGDnVFg+uKwR4rVvdT7hQTDfbv0Rwl5W7bsEafZOUu
         QPOHsGCb4vpOJWyHc7I4NxSQdLvq1L7DmulFOQK8sgCv+xByagXpegFlQyW3YyupzLGv
         szCPn3QFpfJEyJlss6KTGPvZlLpqSSwVBRyprIwmn0fP3i38hGV5FC9ngRFFIcWpbFsf
         LTHQ9+nXaOVXpybi2gGXL5Ayq61g2aBtOxyAvT06B0VejJCM2ln9fs7I1m/WmTTjSygQ
         2stA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793564185; x=1794168985;
        h=cc:to:content-transfer-encoding:content-type:mime-version
         :message-id:date:subject:from:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=fnaImKbqLYBJXkiqJyPVd4xYWb1JTBRTzOceydKHDRA=;
        b=koB0enTHXbrolpdAd0RDfRYgGcYCZOasHnH+CVHB+2dmQciyNstAonJA2wr26s9ck3
         N2QadbffysyPcR6Y6V5rOaTcezPt6jwUeQkLuS4c46IXBG4oUY8tFMZ/dECzbdnHWSpL
         MkXTDKP6qEHuwolqPmAaS2/e133JI0ymX0FNHm4ytky6nGFz8kkLcDmMPfaNuWRwVayD
         GRGr+TyDAi+RFqmQfsmsm2T73929rqt37UtzHG3K92PZJKpxjUKAu1Rh4ke/82nFiqp2
         FdaG7gchcK5r1S0X/nR/lUHH66vXRhPxkbIzSLiyKaJB3w5hoaRFiRUuwHbAR935WPB5
         pkrw==
X-Forwarded-Encrypted: i=1; AKwUvBwWvSwHL5bIvRTpJ+GmSHjisRarvHGWInvdxhzMqRiJAYzsUKjOs0Mo5l6fT3Cp/YADNL0mbVOrglHVa+mh@vger.kernel.org
X-Gm-Message-State: APuU4Z+u2JqCeqp/Xbz3snTgezmNoIZvRqmYouLsghTdzD8+GhMLzBdN
	dVLeGVJbYOkU++DZY0CJ5rZhfJGUiK7hEfePFZnthkGmw5gBOwXaIC0nCnO47zpqFY9Em+torT0
	jiEorRvE/r4MDQcX9DdoYczb4RhqxSN91ikHQRmbeqMdV39xxhCZaOmEZeaLHLps=
X-Gm-Gg: AYBFou06mm/z3hFtcHZb4S0LMVe8OH3v5n0+v9l352KSEvhO7GxQU8ifQFU77XGkQXt
	cLq3GOuiiBLjPbpJVOek6ioF4WWZJhc1P85NyKYaLJL1IK4Gximr9U7nEO+PTBsnEDuWsqdKBbJ
	napcAOUiUdijSp6O5mxe9LWHDbBTgJepNiGmoW+GoN75hScS5RX7ybStftZQA2MV9UdLP0q1yo1
	tR+Ym3hkXuNCj9pQLwuMM9SuYL2pb3zedHVhCt6yzPwKIWzCG4V4C2RFOhW+ekOplonZ3TKEC9A
	mE8EqGCtUBz1TGbvcb0uWJNl95/wdSEf5VmecdJCSbj6v16MHX28D8rL+95UcwYVatdUfIQt042
	Od9qLs3JSsyy/qFFs9pYg3efE79gws08Mz3Jv0HvOXrenHptCuwoB8wuBsAE=
X-Received: by 2002:a05:6102:3706:b0:7bb:c382:2ff4 with SMTP id ada2fe7eead31-7d0726ca2femr3066696137.20.1793564184888;
        Sun, 01 Nov 2026 12:16:24 -0800 (PST)
X-Received: by 2002:a05:6102:3706:b0:7bb:c382:2ff4 with SMTP id ada2fe7eead31-7d0726ca2femr3066693137.20.1793564184373;
        Sun, 01 Nov 2026 12:16:24 -0800 (PST)
Received: from [127.0.1.1] ([37.142.157.119])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e71b78a4csm15661423f8f.23.2026.11.01.12.16.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Nov 2026 12:16:23 -0800 (PST)
From: Tal Zussman <tz2294@columbia.edu>
Subject: [PATCH 0/2] fscrypt: remove fscrypt_is_bounce_page() and
 fscrypt_pagecache_page()
Date: Sun, 01 Nov 2026 15:16:12 -0500
Message-Id: <20261101-fscrypt-page-helpers-v1-0-bcfbfaf6a237@columbia.edu>
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
X-B4-Tracking: v=1; b=H4sIAAye52oC/yXMQQqDMBCF4avIrA04QS14leIiiWOdUmyYUWkJ3
 t2oy4/H+xMoCZNCVyQQ2lj5O2dgWUCY3Pwiw0M22Mq2iBWaUYP842Kiy9tEn0iiBr11Pnis2+Y
 B+RqFRv5d2Wd/W1f/prCcLdj3Azc6aLh4AAAA
X-Change-ID: 20261101-fscrypt-page-helpers-1b2abcb14657
To: Eric Biggers <ebiggers@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tal Zussman <tz2294@columbia.edu>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793564181; l=578;
 i=tz2294@columbia.edu; s=20250528; h=from:subject:message-id;
 bh=HFPShrW5JNev0UuC+9A6DubMHhA5PXNmLyvbbz/XIR0=;
 b=Aq6xafZVwUVCj89spVsNjSWOWhpxnQ//IKawZA/X2rTDku2fMNvP7tqTt3Ypq3td9pa8yl/n0
 FHYZd/VtnBIBqDyiSNVRJ7+LDZKr91yN24ofVLbPTzOyJ60Lez66+xJ
X-Developer-Key: i=tz2294@columbia.edu; a=ed25519;
 pk=BIj5KdACscEOyAC0oIkeZqLB3L94fzBnDccEooxeM5Y=
X-Proofpoint-ORIG-GUID: 5bSTQHZ9KaEa9luftqq1kZJt_kBL6W2J
X-Proofpoint-Spam-Info: AW1haW4tMjYxMTAxMDA4MCBTYWx0ZWRfX4uBBY/l91NB/
 v6IGN1M852yN1qYoVzjhC60VY7rrFT3pt8Q0nSH5yHBC3QCcH24yB1PxRXIjY4oqCXppYVKHkGc
 5Z4ZqJ7uYyHs6NEO7K9JFHVkRoGxS0MJ4q/+ulvtwmgJy7C+P9MP
X-Proofpoint-GUID: 5bSTQHZ9KaEa9luftqq1kZJt_kBL6W2J
X-Authority-Analysis: v=2.4 cv=TpZzFzXh c=1 sm=1 tr=0 ts=6ae79e19 cx=c_pps
 a=ULNsgckmlI/WJG3HAyAuOQ==:117 a=Qz3frfIdACK70Hl/8c7MJg==:17
 a=IkcTkHD0fZMA:10 a=zJRp6_cAMcgA:10 a=x7bEGLp0ZPQA:10 a=A0y_DWxS2BwA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=Da8U98TiO7q1upZEImrf:22 a=SsB-OO3BMngHh3ZO9fOt:22
 a=NbSN4xko3C3IRhU3f4kA:9 a=QEXdDO2ut3YA:10 a=1WsBpfsz9X-RYQiigVTh:22
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMTAxMDA4MCBTYWx0ZWRfX+wVOKjpKD6jE
 VAia2jArBof5GqvmLeh14CAu+7A4DvmZe5yX0M0X5I1bmP3ghUqdwLJgCZUHyrzBPJ0oUcPWdTi
 2iCzl6lUYyK9tkGv/4qI3cc60dkgb/Mn2sTXkuLgnkPoUzMog2pdmlwS0RMy2f9325qJbfWhK2G
 StDpTeQNaI26ezoWGyNRwPMXdPuENjYpSSxG4Mhe6oq3nUW7jjZgNiQi978mhe0B7VpvAXU3kNR
 WWSOeHFKhSaRsyX7bTGeH0RwhPg7SCd9S6+ebbIECfp2wofjzqEmW0XoJY1vY5ScHbTZ8/wWP7C
 uMs7gud3P2bd86Ru8nZOhofAwFXXKiXQRGgeeMIFN74lJoN5RSNTYy2hEuc7aMe/1ZMz4SKawTS
 wsekbneVLk1Gs2woiwUYBii4tc0E2kC1ay5PXf9bjpwZuKdubzF1cNyVuZR6z0nXYIW4G5vfpOn
 qE0jzvXJhbsa2ge0Hkg==
X-Proofpoint-Virus-Version: vendor=nai engine=6900 definitions=11953
 signatures=596817
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 suspectscore=0 spamscore=0 phishscore=0 clxscore=1011 malwarescore=0
 priorityscore=1501 lowpriorityscore=10 impostorscore=10 bulkscore=10
 adultscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2610300000
 definitions=main-2611010080

Commit ef9024b5fca2 ("ceph: remove ceph_fscrypt_pagecache_page() and
ceph_fscrypt_page_offset()") removed the last callers of these two
helpers as part of ceph folio conversions. Remove them.

---
Tal Zussman (2):
      fscrypt: remove fscrypt_pagecache_page()
      fscrypt: remove fscrypt_is_bounce_page()

 include/linux/fscrypt.h | 21 ---------------------
 1 file changed, 21 deletions(-)
---
base-commit: 46fec1c3029b552ec63b2d01af9d43a386f043ea
change-id: 20261101-fscrypt-page-helpers-1b2abcb14657

Best regards,
--  
Tal Zussman <tz2294@columbia.edu>

