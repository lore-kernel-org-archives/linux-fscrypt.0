Received: from mail-dy2-f15.google.com (mail-dy2-f15.google.com [74.125.229.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6F0C2D77F7
	for <linux-fscrypt@vger.kernel.org>; Fri, 25 Sep 2026 11:59:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.229.15
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790337564; cv=none; b=eO4purwsqiW4twfCRWIWUUX5O2ezn1ZUAjGUZRMEiYX8uuBkO24Qq4nzgWTF8lnvi29IhI6N2xoigBAbHjnZaPmjrw+m7YCBX4TPQWts+A0oeArlt5zTNkmhSJSjP8EXKbpFxvguMI1YqRui3o5nw/b2Nsj30btQ7vVbcty6fvA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790337564; c=relaxed/simple;
	bh=TU/NU4ilfrc8fq5DP7Oob88utYP0oOVtTdIAEzR+93g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ed1dNf6S3zYFLtFeaNIC8VaR2Xd76uGrf7w0+KPLRIJJUqBHonGAO0MzNTjSljGzdWmHVpD3b5QTBt+gvWlEHnD7xZ7zNxNZsKe93qzKkd9xCcSslEXB6a+tMGZJT1zsEKFiurOiIfBEtONZ3uranp/eUSrPYbMy82JsXnuXN/c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Y60Fx29O; arc=none smtp.client-ip=74.125.229.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y60Fx29O"
Received: by mail-dy2-f15.google.com with SMTP id 5a478bee46e88-32dec843c37so1112552eec.3
        for <linux-fscrypt@vger.kernel.org>; Fri, 25 Sep 2026 04:59:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790337559; x=1790942359; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=2kddma/7cZm+wbf7qqg6isnlL54B7YPTTBFAkT066ys=;
        b=Y60Fx29OIWzrBBzsvps4G1Q0D0zBxCR3ZpHQ8qezxZltfAH6Ammj9u2A1BFwtEhyko
         aqarF+vXTJGh6xehEPM7Tppd6923A+itcbT36vDf22qjGS7dqruD8uI8ErBcd9hYMpkr
         k1cxPWuqQvYsP1EwJwDuRWL2tIpG30z1PL6xiqZFoMMRsyhCS5MjEs9vwhBn1aktBS28
         /uZjq5jUMHfwpmPeIIVLzz5y1zuCsSQqM+2+fliHgSocCH/pD409+jHogwTTVD5wZ/wy
         weF2X8WWAqS8f/VXKsqI07kpDUQdRcAHYBmEZ6PQgdtbeODytUnBqEFu3BJMuRADOuKu
         +c8Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790337559; x=1790942359;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=2kddma/7cZm+wbf7qqg6isnlL54B7YPTTBFAkT066ys=;
        b=LA+bkMJwKlOzyDo38WayNTcZrFxuNQBhDRGi6BfyflN+g6Je0gMQo2Q3DflLeG/Ovr
         mPwKwuYvlPH+HDzfMhl4DqBrLit4ITnd8/PpcRwZ+N+q2DdYEa4kJ5dIbOpYBxjMbkOC
         8Pzlcm7mhSXaIEvaMF11K86w930inEV3yg/xymiut769jt/q+TZXJzyN9+0rm5mWTQht
         vS+6Ov+LAZZNNLnwNwCyUzD/uLBBsBZeMY1aw7LT0fL2UnMObsBmmn2OYzqaR1eWjsln
         0ln8N9B41e7XKStrud6oJCuxBd9ukpGPUJ6H/Th9LFO7rju3LcIRGfpMcRk+PfEEmUqW
         dd5g==
X-Gm-Message-State: AFuF++le/+fV3KiWoW3nSmkNGSuMHRK9KBBpc0oCMPbqiScBHRmua1F6
	8bU1CBBMbFiBIutb8yB8q/LhUmGlEpsz4tbC6tSiT+c6BO9PI33O6A0x
X-Gm-Gg: AYBFou1as4FiOd7rinN2rkRIOYrYGqUZVrycC4mvwhYLp2QRICb5s+9HJa8wCBooKev
	AbmQCkfAygnFlGCsYDOQTZxtZ5HqYkmzKgexkqfjQajYGX+/iHXbACB267+aypIXlnpMe08G5SI
	aaQb1ew2pzBQSI1hVqykFXjTJuk7tAXMlG1D9IrWtgFdQZauu+lO4/39EYwLpfDAs9ZMMSI7ChP
	uQuIk0YcbDGuBaWrigfz4jMudJPB/BJY3Ck8afeBIiGnveomXMTOlIvy0yHBOQKx+qXLPKgcAmx
	lT+BpEpDovWxlBj3h67aWSuT5k7WXWslsdBvo1KTxHvcSoS4+FiIr5c8avF0EQU5kU/reoCa2Kr
	2Qpz0/IMQTgbclHoSzrLg7MqOV0155lufoEx1H6E7lB+0jSqheLhscBTawUQNlk8tOvcMkwk1N6
	7IDEfbGWSiZawH9j0igL4WJpfBNaNjzIQ9FNjL8XXDnkFhXToo+DITrOCPnhgN0mSlgFcIBGB48
	Atp2JYZQufi+i1NNryKUr/xckjS/Zls+sSuNVFXknftnmaRUyyZWnHEBKKpZU78ag21dtMUSiul
	w1NvrG8ZBVPOqxtN3PlqYwVuBb71FbVWeeMJtpQOT+SPZrwngYi3iTly3j/VlYD7Rl5iXw==
X-Received: by 2002:a05:7301:1f15:b0:33b:bfb7:31cc with SMTP id 5a478bee46e88-342710ae1f0mr49098eec.16.1790337558827;
        Fri, 25 Sep 2026 04:59:18 -0700 (PDT)
Received: from spider.bream-herring.ts.net ([103.6.151.236])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-341447576b9sm7457878eec.15.2026.09.25.04.59.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 25 Sep 2026 04:59:18 -0700 (PDT)
From: Matthias Goergens <matthias.goergens@gmail.com>
To: ebiggers@kernel.org
Cc: linux-fscrypt@vger.kernel.org,
	tytso@mit.edu,
	jaegeuk@kernel.org
Subject: Re: [PATCH] MAINTAINERS: List the fscrypt branches
Date: Fri, 25 Sep 2026 19:59:15 +0800
Message-ID: <20260925115915.1074569-1-matthias.goergens@gmail.com>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260925041527.112609-1-ebiggers@kernel.org>
References: <20260925041527.112609-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Thu, Sep 24, 2026 at 09:15:27PM -0700, Eric Biggers wrote:
> The fscrypt entry in MAINTAINERS has a T: entry but it doesn't mention
> which branches are used.  Update it to have a T: entry for each branch.

Both branches exist and match what linux-next merges from this
repository (fscrypt and fscrypt-current in Next/Trees).

Reviewed-by: Matthias Goergens <matthias.goergens@gmail.com>
