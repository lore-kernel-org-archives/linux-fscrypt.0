Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.216.41
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794672159;
	b=VWcvHyX6MG+bOva1Skrwlabj8fFkEqhH6w92AAdCfYBisjLJx3KHtDWDwAJuHlYW2DhJ
	 8gBKOj1QtgEVtrKcP6MfxQ9PXZOrs/dy+jGE+KtTVF8wkc0MtC3L+OPuBfMm8EdtnlpuN
	 izLDdC4YrSzg+FY/6bZ8g4CO1NLiQtqPAWHUr60mnd0cEHlaJr9/G2VRTlXRFdRZs6rsM
	 7q6nvAwEhxPSzC4Zqt+kh3oiUVg62FJr628G6elQrTu0Bl/bpLdhAM6TxWJ5HszrosSqa
	 enZ/gm3wXKYmGHwZlB6FNmjS4uXdpsZIsRCM1PmeaH4YZfJhn8y72wWjyJnyAqDQREQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794672159;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=MprJBhH8IjHCr2vOCfVSYowKiGsQhRGImfmMUR1eCcE=;
	b=2ychckgK9nApWDVxhKBRWFIsau5R9feIUAzzRZwzbwZWjhC7CxLdgO7OM63WBGUUCfBl
	 7OoqMdDpdp9+aRTjg966aUBQihinDRX/xCriZl8z4UzgS3dV5WGIYjlz5rxXEnw8f6FNs
	 +3u7mA23OIanATFjgcaEVUVfMZvI/ZIrmfNdLlzO6fZ3UJl+SWaZC2p0N525t5dnykY4P
	 FkqeDKLgufB1x197wvY1WPyTXTa4OUBUaF+aDcClbjJ+3CPxoujMot6SW0LjJ3mQ7RVYY
	 1yvr0VQ68Pf0mab9DSowDTNwnDzsLWG+KG5dJDSYULXE5n3ExvolEedQGzSErbggr/A==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=omnibond.com;
	spf=pass smtp.mailfrom=omnibond.com;
	dkim=pass header.d=omnibond.com header.i=@omnibond.com header.a=rsa-sha256 header.s=google header.b=jmQCeEaA;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.216.41
Received: from mail-pj1-f41.google.com (mail-pj1-f41.google.com [209.85.216.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17516606A327
	for <linux-fscrypt@vger.kernel.org>; Sat, 14 Nov 2026 16:02:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 17516606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=omnibond.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=omnibond.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=omnibond.com header.i=@omnibond.com header.a=rsa-sha256 header.s=google header.b=jmQCeEaA
Received: by mail-pj1-f41.google.com with SMTP id 98e67ed59e1d1-3b0b3438540so1902016a91.0
        for <linux-fscrypt@vger.kernel.org>; Sat, 14 Nov 2026 08:02:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794672158; cv=none;
        d=google.com; s=arc-20260327;
        b=fl7ejuvKRzrOv5Ig3PA9DXrue1rJPdUAmqkwgbfB6zpesyDFeUQ3EjaHKsGDrwJ2zp
         W4/k3ZPM8kz58h3WGT5RLoOuHGaWR+VVJaLoel0lNLYjb32oPA3H1nBKq9B/LjuQQR7f
         KHNSGx5hP6nfRIhHfYFPSL7lZopTx5+p/EXYZ0SDLOieVnMQdCpsQKFQZd8f3QteqqRH
         An9sVETnxB6VWuaMfap96ixKiKqzGpwt2giRg4nJlgCdKyEFc/Vbma69YMo/2m7aFALa
         ONXaaxtM+/1pSi9+wuzmtedhV+gcWmjINDkNechzIRzSnn7kph7gXAto33G0ryk6w7bq
         RoEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=MprJBhH8IjHCr2vOCfVSYowKiGsQhRGImfmMUR1eCcE=;
        fh=ynwIY6vRxuPgz3631RVEB5Nw5I0lK92GZwbFOPbllNQ=;
        b=hRwa5931vg9XNfjrMgIwrQ3zvCIhfG3TJ161HLcjiOX3betu9fZuThpGi7mnGhI2Sq
         ZMlq1tT+5xYlGM0nnqLa+6uNPFH/8by/tilRwkKcRrP3gbMmnfE141FSDUWf0/muWGhx
         FLuAHVrwvR6EGJ1t9uuLP9vWmaWQdqVZxZ+DoTxQEGg7Uhba4o9VHglZ2oQoC+yAhHXB
         rNinfATiZPDSvJf1zqXSSFCG6CjgfZqHG1LR1X11dhosgazJyza6Y68jSuSCUSz0bPyV
         SsM0cnZpVBCpVaiy3s538AainVD6dqwy+LXhm2F4SZia1zqe3jr66OuzC8KLoznVm3NR
         vp8Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=omnibond.com; s=google; t=1794672158; x=1795276958; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=MprJBhH8IjHCr2vOCfVSYowKiGsQhRGImfmMUR1eCcE=;
        b=jmQCeEaAIpi2/LlQ6WpVkHTsDUMuOU1b9cr9bnxzCbW5hqioAPOHFeBru+5yifMOXb
         e9DgLoTFFjN361i2nuUlYWekTjeuJ9VpULyMJcIRU1TCUIijFY0Do0+C0VdOXORDic6g
         1PXBmdcwIAU0qw0IGfNRTBt1nNG8Ld1nIaSOs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794672158; x=1795276958;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=MprJBhH8IjHCr2vOCfVSYowKiGsQhRGImfmMUR1eCcE=;
        b=Jaa0hZJkhf7koEpbLFaF57oore8YGenToZ0FnUqvrbah2m4OL3RR5od9AmbdozBgAO
         Ykb58aPQ29jlAwdncWQiRC6N4K1rxhjQEIrfAo6EdThyaLR9F8GYXurwVHPR/PToUBzU
         AwSCa0W1oTxqbnQnB65JMp9mTR2fgfDHq8rU3fZo8xzzNqFfuM3reW3FP1NYH/2x+2y8
         NmUPIKIKuFSmevNrBAWBx/8iXi/OXLRVHJ8T0ZvbyDhe/lEEAm31suzP/tR8VzYA8iu5
         frau7JthSVBCQSOtXe8npIQaf2/j+00zUBDUM8CzvwiZJHfDzp0/QBLppa5AffYtRQud
         +pfg==
X-Forwarded-Encrypted: i=1; AL+hErEC5A2p6mkLaWhzUUXkqbJvTlu3EeXGOLCoaZMdOTOgC+QVV7L7eOV1GNIM5AW0F4jqxoxuz+iRNelt2cNW@vger.kernel.org
X-Gm-Message-State: APuU4Z9WJrZQegfEMGn7GfRL4AGuwtb8m1kd2OEGS0hllx/EFHlU1mZC
	bYAj8oEaLTwqcMaStSV3xtZL7DsFV/xJ0W7T8itN18LJWz8ojPCMoWuuxtQ5yFOIXj43VBZLykh
	81af38nXOhPrwBK8yiQDiP99IqcS0JSxbRDAoxyVh
X-Gm-Gg: AYBFou0GKkSTU9QvzSPTSfzhwZczqg6EUZCQ0bLAVAX1pgNKTj1lkhsvtQ1ZnkUKrVd
	TQEBwBefTIw8BhemX8obyCZsE6Rtp0BZb4u0MsNiXHv0GaRuaYJ22f0xo8cDDnq6cbAykYYB1zL
	pW09JSjVBVlP9gIXs09DMtB43fiBBpLyulaEHiY58aWOMre0YiWyCOSdZLuqvRjkzLaszujirgw
	JglHwx6uzImXfJPaByb4W2cl0KL3coP/jlTd1UZXyQHr/4KzdMYRgJYAdArdNFlDyFPPUhNuYHl
	mkn5elNVsxM7JRozr5WwqYIFIDtGrkIeenxM6p/aMFedU2Ql2FE8OCFNJu4GIHLWuX+gB0k+WHW
	MBxAkpPLhAGFyq8FeNNf29PlYtXwILEcbew6C+4SdO2xM4S9W
X-Received: by 2002:a17:90a:c2c8:b0:3ac:a11a:7c8d with SMTP id
 98e67ed59e1d1-3b1b0b5e4e3mr5529866a91.59.1794672158207; Sat, 14 Nov 2026
 08:02:38 -0800 (PST)
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261113083336.15152-1-jack@suse.cz> <20261113084700.739002-16-jack@suse.cz>
 <sashiko-outbox-212490@kernel.org> <6vifbr2gkvxhq2rer5agf6jwy3lrsjqpkxcrfdnypjqqjao4uw@j2al5rnaailb>
In-Reply-To: <6vifbr2gkvxhq2rer5agf6jwy3lrsjqpkxcrfdnypjqqjao4uw@j2al5rnaailb>
From: Mike Marshall <hubcap@omnibond.com>
Date: Sat, 14 Nov 2026 11:02:27 -0500
X-Gm-Features: AclHuK8w0nFYPcNdJvOGfFrUolQ8uILgHyz1m2idTjqCICOoU3cjJ06FvFk0mYY
Message-ID: <CAOg9mSQYDoH0ASc_HCgR=oZrGa1r=wy5OuS9qwX5arjd0bKP1w@mail.gmail.com>
Subject: Re: [PATCH 03/13] orangefs: Check PAGECACHE_TAG_DIRTY instead of
 I_DIRTY_PAGES inode state
To: Jan Kara <jack@suse.cz>
Cc: sashiko-reviews@lists.linux.dev, Christian Brauner <brauner@kernel.org>, 
	Andreas Gruenbacher <agruenba@redhat.com>, Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, 
	Dave Kleikamp <shaggy@kernel.org>, Carlos Maiolino <cem@kernel.org>, David Howells <dhowells@redhat.com>, 
	Marc Dionne <marc.dionne@auristor.com>, Miklos Szeredi <miklos@szeredi.hu>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Eric Biggers <ebiggers@kernel.org>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, 
	Anna Schumaker <anna@kernel.org>, Mike Marshall <hubcap@omnibond.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I worked through Jan's patch and sashiko-bot's review
with grok build, and came up with this... If what I've
got here passes muster, I'm thinking Jan should still
be marked as Author: and Signed-off-by:  it is his patch
with a little change, but I wouldn't want to attribute
anything to him that he doesn't want attributed, so
let me know... My version probably won't feed through
"git am" since I'm using gmail. I'm not sure how to add
a message to a thread with "git send-email", even
when I add in the message-id...


PAGECACHE_TAG_DIRTY is the authoritative source of dirty folios.
I_DIRTY_PAGES can stay set after filemap_fdatawrite(), which is how
orangefs_flush() and orangefs_fsync() write the mapping, so a getattr
keeps serving the cached inode after the folios are clean.

The dirty tag alone is not enough. folio_start_writeback() clears it
and sets PAGECACHE_TAG_WRITEBACK before wait_for_direct_io() sends the
write. OrangeFS writepages does not return until that call finishes, so
I_DIRTY_PAGES still covers the round trip today. A getattr that looks
only at the dirty tag stores the server's old size while the write is
in flight. orangefs_writepage_locked() then reads that size and shortens
the write.

Hold the cached attributes while either tag is set.


---
 fs/orangefs/orangefs-utils.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/orangefs/orangefs-utils.c b/fs/orangefs/orangefs-utils.c
index 9ab1119ebd28..72fa9865bb86 100644
--- a/fs/orangefs/orangefs-utils.c
+++ b/fs/orangefs/orangefs-utils.c
@@ -233,6 +233,20 @@ static int orangefs_inode_is_stale(struct inode *inode=
,
  return 0;
 }

+/*
+ * Dirty and writeback tags, not I_DIRTY_PAGES. filemap_fdatawrite()
+ * leaves that flag set after the folios are clean. folio_start_writeback(=
)
+ * clears the dirty tag before wait_for_direct_io() returns, so the
+ * writeback tag is what covers the server write.
+ */
+static bool orangefs_writeback_pending(struct inode *inode)
+{
+ struct address_space *mapping =3D inode->i_mapping;
+
+ return mapping_tagged(mapping, PAGECACHE_TAG_DIRTY) ||
+       mapping_tagged(mapping, PAGECACHE_TAG_WRITEBACK);
+}
+
 int orangefs_inode_getattr(struct inode *inode, int flags)
 {
  struct orangefs_inode_s *orangefs_inode =3D ORANGEFS_I(inode);
@@ -247,7 +261,8 @@ again:
  spin_lock(&inode->i_lock);
  /* Must have all the attributes in the mask and be within cache time. */
  if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
-    orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAGES)=
 {
+    orangefs_inode->attr_valid ||
+    orangefs_writeback_pending(inode)) {
  if (orangefs_inode->attr_valid) {
  spin_unlock(&inode->i_lock);
  write_inode_now(inode, 1);
@@ -281,13 +296,14 @@ again2:
  spin_lock(&inode->i_lock);
  /* Must have all the attributes in the mask and be within cache time. */
  if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
-    orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAGES)=
 {
+    orangefs_inode->attr_valid ||
+    orangefs_writeback_pending(inode)) {
  if (orangefs_inode->attr_valid) {
  spin_unlock(&inode->i_lock);
  write_inode_now(inode, 1);
  goto again2;
  }
- if (inode_state_read(inode) & I_DIRTY_PAGES) {
+ if (orangefs_writeback_pending(inode)) {
  ret =3D 0;
  goto out_unlock;
  }

On Fri, Nov 13, 2026 at 5:34=E2=80=AFAM Jan Kara <jack@suse.cz> wrote:
>
> On Fri 13-11-26 09:00:01, sashiko-bot@kernel.org wrote:
> > Thank you for your contribution! Sashiko AI review found 1 potential
> > issue to consider:
> > - [High] orangefs: stale i_size overwrite during writeback in
> >   orangefs_inode_getattr()
>
> ...
>
> > > diff --git a/fs/orangefs/orangefs-utils.c b/fs/orangefs/orangefs-util=
s.c
> > > index 9ab1119ebd28a..4c4036f470cdd 100644
> > > --- a/fs/orangefs/orangefs-utils.c
> > > +++ b/fs/orangefs/orangefs-utils.c
> > > @@ -247,7 +247,8 @@ int orangefs_inode_getattr(struct inode *inode, i=
nt flags)
> > >     spin_lock(&inode->i_lock);
> > >     /* Must have all the attributes in the mask and be within cache t=
ime. */
> > >     if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)=
) ||
> > > -       orangefs_inode->attr_valid || inode_state_read(inode) & I_DIR=
TY_PAGES) {
> > > +       orangefs_inode->attr_valid ||
> > > +       mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
> > >             if (orangefs_inode->attr_valid) {
> > >                     spin_unlock(&inode->i_lock);
> > >                     write_inode_now(inode, 1);
> > > @@ -281,13 +282,14 @@ int orangefs_inode_getattr(struct inode *inode,=
 int flags)
> > >     spin_lock(&inode->i_lock);
> > >     /* Must have all the attributes in the mask and be within cache t=
ime. */
> > >     if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)=
) ||
> > > -       orangefs_inode->attr_valid || inode_state_read(inode) & I_DIR=
TY_PAGES) {
> > > +       orangefs_inode->attr_valid ||
> > > +       mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
> > >             if (orangefs_inode->attr_valid) {
> > >                     spin_unlock(&inode->i_lock);
> > >                     write_inode_now(inode, 1);
> > >                     goto again2;
> > >             }
> > > -           if (inode_state_read(inode) & I_DIRTY_PAGES) {
> > > +           if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)=
) {
> > >                     ret =3D 0;
> > >                     goto out_unlock;
> > >             }
> >
> > [Severity: High]
> > Can orangefs_inode_getattr() overwrite inode->i_size with a stale size =
from
> > the server while pagecache writeback is in flight?
> >
> > When a buffered write extends a file in orangefs_write_end(), inode->i_=
size
> > is updated in memory and the folio is marked dirty, while the server on=
ly
> > learns the new size once the writeback RPC in wait_for_direct_io()
> > completes.  Previously, I_DIRTY_PAGES stayed set in
> > __writeback_single_inode() across the entire do_writepages() call.
> > However, folio_start_writeback() clears PAGECACHE_TAG_DIRTY and sets
> > PAGECACHE_TAG_WRITEBACK before wait_for_direct_io() sends the write to =
the
> > server:
> >
> > CPU0                                  CPU1
> > orangefs_writepage_locked()
> >   folio_start_writeback(folio)
> >     /* clears PAGECACHE_TAG_DIRTY,
> >        sets PAGECACHE_TAG_WRITEBACK */
> >                                       orangefs_getattr()
> >                                         orangefs_inode_getattr(...,
> >                                             ORANGEFS_GETATTR_SIZE)
> >                                           /* PAGECACHE_TAG_DIRTY is fal=
se */
> >                                           service_operation(GETATTR)
> >                                           inode->i_size =3D ...; <-- st=
ale size
> >   len =3D i_size_read(inode);
> >   wait_for_direct_io(ORANGEFS_IO_WRITE, ...)
>
> Yeah, that's a good catch but I think that this is pre-existing issue. Wh=
en
> we don't wait for writeback to complete in __writeback_single_inode()
> (which happens for sync(2) or for WB_SYNC_NONE writeback), we can clear
> I_DIRTY_PAGES before writeback completes as well. So this patch just make=
s
> the race window larger.
>
> But I agree with adding a check for PAGECACHE_TAG_WRITEBACK into the
> conditions as well to close the race window altogether. Another option
> would be to sample i_size before calling folio_start_writeback() but I fi=
nd
> that too subtle, it would require some barriers etc., so I won't do that
> unless orangefs guys insist.
>
>                                                                 Honza
>
> >
> > As a result, any concurrent getattr with non-zero flags (such as
> > orangefs_getattr() or orangefs_file_llseek()) fetches the pre-write siz=
e
> > from the server and clobbers inode->i_size, which also causes
> > orangefs_writepage_locked() (or a subsequent batch in
> > orangefs_writepages_work()) to clamp the write length to the stale size=
 and
> > truncate the buffered write.
> >
> > Should these checks also test mapping_tagged(inode->i_mapping,
> > PAGECACHE_TAG_WRITEBACK) (or mapping_writably_mapped() / a helper cover=
ing
> > both PAGECACHE_TAG_DIRTY and PAGECACHE_TAG_WRITEBACK)?
> >
> > --
> > Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261113083336.=
15152-1-jack@suse.cz?part=3D3
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
