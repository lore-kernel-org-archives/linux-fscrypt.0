Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEEE83BB10B;
	Fri, 26 Jun 2026 20:29:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782505793; cv=none; b=cyO6r4YBlFcKaEcV6EpDzu5mjtixnITXVdKXOgH1C0pNGQvyNs3QAuEU/kzvp7jtgaCDcMgoO9hkgf0up5zAdp2sjL50yHgIwueLGa/PvwwYxDQeHnIp6H3qF0lH83q6RunXWnz5XPwvghIZeqF7rOPNuKf/NqwjPgBubB19Qus=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782505793; c=relaxed/simple;
	bh=/hymBU9Tt2JbH1g4ywAkUCAHDuDsaRVBRCmYIBJfEMw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=adJIEttfQWOUkWTkwRVjOQ3rSgojsK58rlx/4w227AQZ1nfa+OvFWdNukrU+JpIGHacfygNuDIrjYgFc6o4AEgRpMPH/u/6/U64VEC5A2nfY2H+PCp0FGGiWMkk7O4cz6767cZsMzcSekmPUDr6x/7nnyO56+6oemMyh+Zp4HEw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dde0JfY9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dde0JfY9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E996D1F000E9;
	Fri, 26 Jun 2026 20:29:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782505792;
	bh=fmn3Xyqj2lzX64Sh5nR6byc0sMpEYjfG6FOf09H0vh0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=dde0JfY9Mxh//TAm69PplV82PfP4OW9pAr1X7zAsEdHnCJ2sQ2j3eeG/4DIdeyc+A
	 z84eZnZbFY1160QL7mdCUbxt/pW1nrAchvMHpEMwOEtayrkG1phOH9pCRgwpJLCf6S
	 1j3IYILFYoTfDzo5sEfdCmdVw4D4O1V43k4wUxkEbj0D//KAzh1ltmLrQx3pq7Mpia
	 IaQvER7yh7/MTnxiu7lnMokPqsBZ+cucaqrH2NpHzzLlN7hRMwesV6QTrrynPL84hu
	 E8+LP2+sY9gMbWvTty94Dm5i4WqhMlMDjoGyA1k7nl/yuqxn1afWhWv2n4t/hkjsmN
	 ZcMGifponSoTQ==
Date: Fri, 26 Jun 2026 20:29:49 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Luis Henriques <luis@igalia.com>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Jarkko Sakkinen <jarkko@kernel.org>, linux-fsdevel@vger.kernel.org,
	keyrings@vger.kernel.org, linux-kernel@vger.kernel.org,
	syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com,
	Mohammed EL Kadiri <med08elkadiri@gmail.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Replace mk_users keyring with simple list
Message-ID: <20260626202949.GA2368695@google.com>
References: <20260618221921.87896-1-ebiggers@kernel.org>
 <87tsqpd8d8.fsf@wotan.olymp>
 <20260626190232.GA1719948@google.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260626190232.GA1719948@google.com>

On Fri, Jun 26, 2026 at 07:02:32PM +0000, Eric Biggers wrote:
> On Fri, Jun 26, 2026 at 09:16:35AM +0100, Luis Henriques wrote:
> > Hi Eric!
> > 
> > On Thu, Jun 18 2026, Eric Biggers wrote:
> > 
> > > Change mk_users (the set of user claims to an fscrypt master key) from a
> > > 'struct key' keyring to a simple linked list.
> > >
> > > It's still a collection of 'struct key' for quota tracking.  It was
> > > originally thought to be natural that a collection of 'struct key'
> > > should be held in a 'struct key' keyring.  In reality, it's just been
> > > causing problems, similar to how using 'struct key' for the filesystem
> > > keyring caused problems and was removed in commit d7e7b9af104c
> > > ("fscrypt: stop using keyrings subsystem for fscrypt_master_key").
> > >
> > > Commit d3a7bd420076 ("fscrypt: clear keyring before calling key_put()")
> > > fixed mk_users cleanup to be synchronous.  But that apparently wasn't
> > > enough: the keyring subsystem's redundant locking is still generating
> > > lockdep false positives due to the interaction with filesystem reclaim.
> > >
> > > With the simple list, the redundant locking and lockdep issue goes away.
> > >
> > > Of course, searching a linked list is linear-time whereas the
> > > 'struct key' keyring used a fancy constant-time associative array.  But
> > > that's fine here, since in practice there's just one entry in the list.
> > > In fact the new code is much faster in practice, since it's much smaller
> > > and doesn't have to convert the kuid_t into a string to search for it.
> > >
> > > Reported-by: syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com
> > > Closes: https://syzkaller.appspot.com/bug?extid=f55b043dacf43776b50c
> > > Reported-by: Mohammed EL Kadiri <med08elkadiri@gmail.com>
> > > Closes: https://lore.kernel.org/keyrings/20260614150041.21172-1-med08elkadiri@gmail.com/
> > > Fixes: 23c688b54016 ("fscrypt: allow unprivileged users to add/remove keys for v2 policies")
> > > Cc: stable@vger.kernel.org
> > > Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> > > ---
> > >
> > > I'm planning to take this via the fscrypt tree for 7.2
> > 
> > I was hoping to have some more time to test this patch, but I don't think
> > that will happen any time soon.
> > 
> > I've done a review of the patch and couldn't find any obvious problem.
> > Though, again, a more in-depth review would require more time as it has
> > been a while since I took a look into this code.
> > 
> > I just wonder if this is really stable material.  It's a bit intrusive
> > (doesn't even apply cleanly in mainline), but above all it's fixing a
> > lockdep false positive.  Other than syzbot, has this been seen in the
> > wild?
> 
> Thanks!
> 
> It applies on top of
> "[PATCH] fscrypt: Fix key setup in edge case with multiple data unit sizes"
> (https://lore.kernel.org/linux-fscrypt/20260618180652.52742-1-ebiggers@kernel.org/).
> This time I tried just relying on the prerequisite-patch-id footer (as
> generated by 'git format-patch') to express the dependency.  But
> evidently that still doesn't work: for one, 'b4 am' just ignores it.
> 
> Since this patch has "Reported-by: syzbot" as well as "Fixes", the
> stable maintainers will apply it anyway.  If I actually wanted to stop
> that, I'd have to actively oppose the backport, likely multiple times
> indefinitely since people will continue to try to backport it.  And
> syzkaller would continue to get the lockdep warning on stable kernels.
> 
> So I'd rather just get it out the way and backport it the same time as
> "fscrypt: Fix key setup in edge case with multiple data unit sizes",
> which similarly tweaks some data structures in struct fscrypt_master_key
> and needs to be backported too.  "fscrypt: stop using keyrings subsystem
> for fscrypt_master_key" several years ago was backported too.

FWIW, I would also not be surprised if the old code would also fail
fuzzing in other ways, like keyctl() being used to directly manipulate
the keyrings from underneath what fs/crypto/ assumes.  I remember at
least considering that scenario when adding this code years ago, but I
think the reasoning was quite subtle and I may have missed something.

The 'struct key' keyrings just have a lot of obscure sharp corners.
Whereas simple lists, hash tables, etc. are much easier to evaluate.

- Eric
