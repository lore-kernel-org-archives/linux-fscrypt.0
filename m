Received: from mail-dy2-f12.google.com (mail-dy2-f12.google.com [74.125.229.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A92BC46D570
	for <linux-fscrypt@vger.kernel.org>; Fri, 25 Sep 2026 11:58:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.229.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790337522; cv=none; b=VXeNT2UxbRV41tBBxmRN3DVvrD8qGfLVJn14W5pVDHSv7V3lq7afBnrs6gHIbzRBUjUNUlysuZZhanAZm/8jExXtXVNbjwlJlhU1KoZOr16j6fQETIXWARJd7FDP8sR2tK0NwmPO19R0OX4ZQhZCK9UTbjXfaPkUtr5PacAXBuA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790337522; c=relaxed/simple;
	bh=FxKBpOBjA/JkIs/Fl2MnIY0gyzz7K9xSHeNXcVVjUAg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LjvMWQG4W05tpqvhxy+Ce/IOWwKrUmRnu/vB7NqECWN/bZttga+Td8eczMaXmWS0SBZSjVHX3WsDjZNNUeNpr4NU+1BU0jK71iATOi66nWYlnT51Hse5ewCSFbfGri6S8DCZp75BRAAwbrbmGctKoJp4iR0cRuKhY1vucC5SIRk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=GaPlG2Dk; arc=none smtp.client-ip=74.125.229.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GaPlG2Dk"
Received: by mail-dy2-f12.google.com with SMTP id 5a478bee46e88-328664dbe2dso383655eec.0
        for <linux-fscrypt@vger.kernel.org>; Fri, 25 Sep 2026 04:58:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790337518; x=1790942318; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lHC73SowwbefD+dnD0Tzun2jA32dwQM9QRKwhvKfql4=;
        b=GaPlG2DkO2mJgLcd/ks1YIFtbvuyfZW/Izqpg14xXg568EFClKdW7vz0DWyVVFVks9
         IT64UfuADAKycxs1y+RuO3rAnWkzkfOUUs/N5Mn3IETw2lBil+LSYDTFmX0dkDZLpCRS
         6YPw3VVX5jtJpFJG+1npus1NJkUujl+s6+IRVeKg4FnpMPoncbMQvetzK3jHWjzggVBN
         zYwwBfwlWOHe/NYqs2c90BnE9BsXbg1aDxg89UfejGjpGFQT8W81keKoT2ygtB/dMQ66
         cWkuWgV+EO4AUXybUiGH7nPNXmdqenFEmfwZOuDHnFYVOOElqfc1NxidPy8okYFPoGy/
         q9gQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790337518; x=1790942318;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=lHC73SowwbefD+dnD0Tzun2jA32dwQM9QRKwhvKfql4=;
        b=PYkFISpnHrQEI6WvXeAoFQAzK3pM8VL7orgnS3axgtcso/m35V7zug71DzgVOHYKe9
         iCG+ALEFKJaDsM1Hz6pJMvu40AYcP0aVfbZFsE+pCRrcnfyKZlW6NPmqOPIdM+wdPi9D
         isI7jtRANCvdbqkGI66H6yuhMovxI+AyYzTfgrZsIt1E9xXkLICqgbHvHj+KA0Vguz8j
         nLlKn9g9l+KyS8G00enVataEp+2Y6ydIUf3VuHn0P+3shW1vB1nIQYeHaJYbqZJMCgrg
         ADcbSr00xl7LU7vv72C8PBkh0czY4r3ZynZ02n512vsAz4NXwZTy8qqA11F6oy802v/0
         l+6g==
X-Gm-Message-State: AFuF++kh/HZINV2i8swZTZUKn5VfeEKtGmbpMQrO7leuI/evoBcPU3In
	9RqM8nWpYHYtco0JytMkf8JFw1M6TJs+iC4DDElc+ph2L/I3dBpj9YHw
X-Gm-Gg: AYBFou0yDEoVuQNotK2bAE+pUvKNJqkhj3ARuTGCsqW57uryP46PnuaPmHZEnEAHPEE
	X9zOjKMhUyaJAab8O6eBA78fDfZN87E+fLqj/S5UXI72NJDQU5jN4w5lCxmcqC+V41IGKRq6cLc
	UxVj0n7wRRWzl+ZYki5814SRUFKzJcScs1Lnfm+E5dByy+Aly04HKTPBNGgtQOCzh/hBhV5PqOh
	Uc/Get0iibgUUgf1XmbbDgJLNSkAD7+VzOElj4BuVHwTZ89NB6conICUcnoiyi91Y9Y2shYIchm
	h7joKdBP7KuttHaL7AnZCBU5bwq+38ZIO+fvkEoJU7p0ENFUE9xhvl1N171ifTAMj5JeNOOkDVF
	gn0lxU1h667aIuaXVuUWs3gdcdQu1v4L1Es2AGj5QMsTXKOyFVGOWjUkQrqx88GXylHVqxBbmCM
	llOEOKprzbRoP/eF74GoqpLQn4nTs5iocx7xFQmcBZ/jWoRm+8q8ix2cSLT64W2AEkfpA7SyGd3
	LVpyGNL9A+oPWsXbAujCiHUY+y1zKME30EBnOK7kEg+pItyXxlmyrFElQ2D6XXMsZNuFt5YWlCV
	n/oOzxS08eaPjRgn7eMpL7Xnz+ILA2QsN9RDNl7jYLckH9YBNQe6LUqZlGs=
X-Received: by 2002:a05:7301:1f15:b0:332:94e9:a732 with SMTP id 5a478bee46e88-34273b41bbemr4098eec.13.1790337518181;
        Fri, 25 Sep 2026 04:58:38 -0700 (PDT)
Received: from spider.bream-herring.ts.net ([103.6.151.236])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-34144757f31sm10299851eec.14.2026.09.25.04.58.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 25 Sep 2026 04:58:37 -0700 (PDT)
From: Matthias Goergens <matthias.goergens@gmail.com>
To: ebiggers@kernel.org
Cc: linux-fscrypt@vger.kernel.org,
	fsverity@lists.linux.dev,
	tytso@mit.edu,
	jaegeuk@kernel.org
Subject: Re: [PATCH] MAINTAINERS: List the fsverity branches
Date: Fri, 25 Sep 2026 19:58:34 +0800
Message-ID: <20260925115834.1067656-1-matthias.goergens@gmail.com>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260925042356.GA112369@sol>
References: <20260925041654.112935-1-ebiggers@kernel.org> <20260925042356.GA112369@sol>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Thu, Sep 24, 2026 at 09:16:54PM -0700, Eric Biggers wrote:
> The fsverity entry in MAINTAINERS has a T: entry but it doesn't mention
> which branches are used.  Update it to have a T: entry for each branch.

Both branches exist and match what linux-next merges from this
repository (fsverity and fsverity-current in Next/Trees).

Reviewed-by: Matthias Goergens <matthias.goergens@gmail.com>
