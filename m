Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795105399;
	b=Za7/B8cByGcRfxRRWSIv1RDpQg9XzqnkMhe/er/5GA0rcCgVZuEfpYcOVUJodi7joqrg
	 goC0zaA6WDiKIYMbyiOE7/xRekzycRixlLzF93jPT1/c4TwMuWKAvBP/lq/8SRJRG/ieO
	 BVPDIMrNula7W4dP7saKjRKCJVY2dIL33wy6ukXH2rbPRvm7UXbYhzb0vUazKhYGZCWP2
	 ZT94nlGoTtzQNs6PVWOG2at4b4jvh/UaKoatlxsLIB0AWtocjDQZNTxA9Dy7SsIMwX6nI
	 6ZKgGHd3xsjQncLLNx2Xoknl0Q0krpQ9+mG4bDsF5C4CLdUCUfYTDUO4nUr12+zi9Pw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795105399;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Date:From:To:Cc:Subject:Message-ID:
	 Reply-To:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:User-Agent:X-Rspamd-Queue-Id:X-Spam-Level:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spamd-Result:X-Spam-Score;
	bh=pGj5HbpZMQVFnLgGwqwq1HzwBrkTidzvF9kv3fg0AJ0=;
	b=J/IRFq80h4C/PXXZUILL3+a3HtKbGV7vakydUTfzHncvvUF1kJJ/7KVblamVWOTy8HPy
	 5ZCoNswk2JErlV7LEHYLxK+1UI4AM9iVCfHF9YhCkzCxA3YGDAQIcV6MiQrROqlTq8K3P
	 P+vpJqeoYCQL7ruJdRZqQqk4ZeWyMPs975Y3gSK6QbJFikab5cW1p8mAmHqAd1gz0xdyN
	 PbVgZ8GgjYm+oprS4q985a4YAlcPIgdE9BtS2u/b1CuGhC9ER4QVza03DwKWCAGP6eAw8
	 eEvXpNt8GygAYbiqye3T4+FLIQr/yrsfDOFuEQo/kOPdD9KD99WALz4iER7ETpZMWTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zCpVIITa;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=szH07XgK;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zCpVIITa;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=szH07XgK;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3E7F606A32A;
	Thu, 19 Nov 2026 16:23:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E3E7F606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zCpVIITa;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=szH07XgK;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zCpVIITa;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=szH07XgK
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id B22501FCBC;
	Thu, 19 Nov 2026 16:23:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795105393;
	h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
	 cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=pGj5HbpZMQVFnLgGwqwq1HzwBrkTidzvF9kv3fg0AJ0=;
	b=zCpVIITadxuKe19ktUuwQ9hw/Q8Akrz6DPfqzWYgrQJqct6u8VTNIOKtJRlh+7j2gXO+X8
	mNnR0IXTzORpP+f/2ziqXQnkSQXJBgJyFHUcx1/r6jjdUtFAnSBaHNPsV+F1VuuVSPNTj9
	cMfgrR8jA2Aoxz75FD8GmqNRQBjg2MM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795105393;
	h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
	 cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=pGj5HbpZMQVFnLgGwqwq1HzwBrkTidzvF9kv3fg0AJ0=;
	b=szH07XgKW0Ri/DHD0v5Edd6rEwIXX2NQqJbC6pvY9oF3cAfD5W7Yz9KuOikhuLkXtSaD5Q
	JrATr+N9ej8YsbAg==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=zCpVIITa;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=szH07XgK
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795105393;
	h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
	 cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=pGj5HbpZMQVFnLgGwqwq1HzwBrkTidzvF9kv3fg0AJ0=;
	b=zCpVIITadxuKe19ktUuwQ9hw/Q8Akrz6DPfqzWYgrQJqct6u8VTNIOKtJRlh+7j2gXO+X8
	mNnR0IXTzORpP+f/2ziqXQnkSQXJBgJyFHUcx1/r6jjdUtFAnSBaHNPsV+F1VuuVSPNTj9
	cMfgrR8jA2Aoxz75FD8GmqNRQBjg2MM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795105393;
	h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
	 cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=pGj5HbpZMQVFnLgGwqwq1HzwBrkTidzvF9kv3fg0AJ0=;
	b=szH07XgKW0Ri/DHD0v5Edd6rEwIXX2NQqJbC6pvY9oF3cAfD5W7Yz9KuOikhuLkXtSaD5Q
	JrATr+N9ej8YsbAg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 794961342D;
	Thu, 19 Nov 2026 16:23:13 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id s+5wFHEi/2rIewAAD6G6ig
	(envelope-from <dsterba@suse.cz>); Thu, 19 Nov 2026 16:23:13 +0000
Date: Thu, 19 Nov 2026 17:23:12 +0100
From: David Sterba <dsterba@suse.cz>
To: Thorsten Blum <blum@kernel.org>
Cc: David Sterba <dsterba@suse.com>, Chris Mason <mason@kernel.org>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>,
	Richard Weinberger <richard@nod.at>,
	Zhihao Cheng <chengzhihao1@huawei.com>,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH 2/4] btrfs: Use FSTR() for the "default" name
Message-ID: <20261119162312.GA3245297@suse.cz>
Reply-To: dsterba@suse.cz
References: <20261118002845.574426-6-blum@kernel.org>
 <20261118002845.574426-8-blum@kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261118002845.574426-8-blum@kernel.org>
User-Agent: Mutt/1.5.23.1-rc1 (2014-03-12)
X-Rspamd-Queue-Id: B22501FCBC
X-Spam-Level: 
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spamd-Result: default: False [-13.21 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	HAS_REPLYTO(0.30)[dsterba@suse.cz];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	FROM_HAS_DN(0.00)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	ARC_NA(0.00)[];
	TO_DN_SOME(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCPT_COUNT_TWELVE(0.00)[14];
	MIME_TRACE(0.00)[0:+];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	REPLYTO_ADDR_EQ_FROM(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	MID_RHS_MATCH_FROM(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.cz:dkim,suse.cz:replyto]
X-Spam-Score: -13.21

On Wed, Nov 18, 2026 at 01:28:48AM +0100, Thorsten Blum wrote:
> Replace FSTR_INIT() with FSTR() and drop the hard-coded length argument.
> 
> Use FSTR() directly and remove the temporary name variables.
> 
> Signed-off-by: Thorsten Blum <blum@kernel.org>

Acked-by: David Sterba <dsterba@suse.com>
