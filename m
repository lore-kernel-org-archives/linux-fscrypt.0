Return-Path: <SRS0=1x/1=CZ=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4B83C2BB84
	for <linux-fscrypt@archiver.kernel.org>; Wed, 16 Sep 2020 18:58:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5C4D920732
	for <linux-fscrypt@archiver.kernel.org>; Wed, 16 Sep 2020 18:58:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600282708;
	bh=n1onCclIHmwMoGh25tLRwWHw0UBcrbgKWpJjkHlSfpg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=ynNJELeIeaO/WSbb1c+o7yqtwgswl83HsgDj00iF3DCDAtiC4Ed/Z8rHO0N5dOhRM
	 lpKsqy1/QqiJiyainBkwlA6TFCGhey9d+ET0G1XJmAxXM3feLa2UWfOaX8P+9g2OYD
	 ThrL8nHNMSomj76lmu8BIm9zh94bSgqSEOPyfJyM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727915AbgIPS6Z (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 16 Sep 2020 14:58:25 -0400
Received: from mail.kernel.org ([198.145.29.99]:42052 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727556AbgIPRvY (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 16 Sep 2020 13:51:24 -0400
Received: from tleilax.poochiereds.net (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 75C2321D24;
        Wed, 16 Sep 2020 12:30:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600259402;
        bh=n1onCclIHmwMoGh25tLRwWHw0UBcrbgKWpJjkHlSfpg=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=cqY+Hr4E7moccOVxZBfqVvr5zwPPKPAICAHNhqHmOo10IQYl3SHm6IiXA2yZqjP26
         q5xO1xqN0NVZsHtwKaH5xUOkfzaegkB+4rLyL5tPgz8zsS8of/2XVpeS1ACvpc0Q+a
         zCjgavaXNHh5KzOwTr7YzJlxu6qS5dbw3i+tmfoU=
Message-ID: <bd9257732cfd98ee30ccc151125d21d6955d6f66.camel@kernel.org>
Subject: Re: [RFC PATCH v3 12/16] ceph: add encrypted fname handling to
 ceph_mdsc_build_path
From:   Jeff Layton <jlayton@kernel.org>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     ceph-devel@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Xiubo Li <xiubli@redhat.com>
Date:   Wed, 16 Sep 2020 08:30:01 -0400
In-Reply-To: <20200915014159.GK899@sol.localdomain>
References: <20200914191707.380444-1-jlayton@kernel.org>
         <20200914191707.380444-13-jlayton@kernel.org>
         <20200915014159.GK899@sol.localdomain>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.36.5 (3.36.5-1.fc32) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, 2020-09-14 at 18:41 -0700, Eric Biggers wrote:
> On Mon, Sep 14, 2020 at 03:17:03PM -0400, Jeff Layton wrote:
> > +		} else {
> > +			int err;
> > +			struct fscrypt_name fname = { };
> > +			int len;
> > +			char buf[FSCRYPT_BASE64_CHARS(NAME_MAX)];
> > +
> > +			dget(parent);
> > +			spin_unlock(&cur->d_lock);
> > +
> > +			err = fscrypt_setup_filename(d_inode(parent), &cur->d_name, 1, &fname);
> > +			if (err) {
> > +				dput(parent);
> > +				dput(cur);
> > +				return ERR_PTR(err);
> > +			}
> 
> It's still not clear how no-key names are handled here (or if they are even
> possible here).
> 

They're not really handled yet. We need support in the MDS for it, which
is being worked on by Xiubo (cc'ed):

    https://tracker.ceph.com/issues/47162

For now, working with names > ~149 characters can leave you with bad
dentries that the client may not be able to work with if you don't have
the key.

It sounds like we'll probably need to stabilize some version of the
nokey name so that we can allow the MDS to look them up. Would it be a
problem for us to use the current version of the nokey name format for
this, or would it be better to come up with some other distinct format
for this?

Using the current version of the nokey name is simple as we can just
pass it as-is to the MDS if someone is working in a directory w/o keys.

> > +
> > +			/* base64 encode the encrypted name */
> > +			len = fscrypt_base64_encode(fname.disk_name.name, fname.disk_name.len, buf);
> > +			pos -= len;
> > +			if (pos < 0) {
> > +				dput(parent);
> > +				fscrypt_free_filename(&fname);
> > +				break;
> > +			}
> > +			memcpy(path + pos, buf, len);
> > +			dout("non-ciphertext name = %.*s\n", len, buf);
> > +			fscrypt_free_filename(&fname);
> 
> This says "non-ciphertext name", which suggest that it's a plaintext name.  But
> actually it's a base64-encoded ciphertext name.
> 

Thanks. I fixed the comment.
-- 
Jeff Layton <jlayton@kernel.org>

