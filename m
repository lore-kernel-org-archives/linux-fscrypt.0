Return-Path: <SRS0=1x/1=CZ=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA473C2BB84
	for <linux-fscrypt@archiver.kernel.org>; Wed, 16 Sep 2020 21:09:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6E6E6206DB
	for <linux-fscrypt@archiver.kernel.org>; Wed, 16 Sep 2020 21:09:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600290586;
	bh=6K24A2tdSZuNSj/rnsDK8OhQTP4O8YGiMgOthygKe5k=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=yjaJrLGFTngmtSBcivarTJB0u79Sw0y1/05h+FmisxKgj2DcypkrcPLTNwalYVm/7
	 5VPU5cUmEwgjAPsyaTWj+UFRbKlWDlRy89nDhfuiYfYLt8fCzZYqrOWMWGnBIPDyHJ
	 pvlPx5W3CuBCFvNrs6q+lyo9w9kSX2ZqGofMBNe4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726307AbgIPVJc (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 16 Sep 2020 17:09:32 -0400
Received: from mail.kernel.org ([198.145.29.99]:57158 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726189AbgIPPzc (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 16 Sep 2020 11:55:32 -0400
Received: from tleilax.poochiereds.net (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4DEEE206B5;
        Wed, 16 Sep 2020 12:15:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600258551;
        bh=6K24A2tdSZuNSj/rnsDK8OhQTP4O8YGiMgOthygKe5k=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=bshyljuNPlbZO+hrvL7YfovzHx+OTALy2MRNauBlgKvX7pAcwf2gt+D0lh87oxzUo
         r6LLVShXgqsjCz2Smt8nfmb3H/MrTwIa87cnNA2PM/AJNqJhkMFACg4CsVubsgzXtT
         3dSRP/kKEYdTVDCcXh6J9FawUAHmAoRZoK8PPL14=
Message-ID: <db27ff786e38effda896df738f58e1755a573a3a.camel@kernel.org>
Subject: Re: [RFC PATCH v3 16/16] ceph: create symlinks with encrypted and
 base64-encoded targets
From:   Jeff Layton <jlayton@kernel.org>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     ceph-devel@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date:   Wed, 16 Sep 2020 08:15:50 -0400
In-Reply-To: <20200915204953.GB3999121@gmail.com>
References: <20200914191707.380444-1-jlayton@kernel.org>
         <20200914191707.380444-17-jlayton@kernel.org>
         <20200915020725.GM899@sol.localdomain>
         <5bdc7608df4ff480c07eb6a0e85514ebd986e5d9.camel@kernel.org>
         <20200915204953.GB3999121@gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.36.5 (3.36.5-1.fc32) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, 2020-09-15 at 13:49 -0700, Eric Biggers wrote:
> On Tue, Sep 15, 2020 at 10:05:53AM -0400, Jeff Layton wrote:
> > > > +static const char *ceph_encrypted_get_link(struct dentry *dentry, struct inode *inode,
> > > > +					   struct delayed_call *done)
> > > > +{
> > > > +	struct ceph_inode_info *ci = ceph_inode(inode);
> > > > +
> > > > +	if (!dentry)
> > > > +		return ERR_PTR(-ECHILD);
> > > > +
> > > > +	return fscrypt_get_symlink(inode, ci->i_symlink, ksize(ci->i_symlink), done);
> > > 
> > > Using ksize() seems wrong here, since that would allow fscrypt_get_symlink() to
> > > read beyond the part of the buffer that is actually initialized.
> > > 
> > 
> > Is that actually a problem? I did have an earlier patch that carried
> > around the length, but it didn't seem to be necessary.
> > 
> > ISTM that that might end up decrypting more data than is actually
> > needed, but eventually there will be a NULL terminator in the data and
> > the rest would be ignored.
> > 
> 
> Yes it's a problem.  The code that decrypts the symlink adds the null terminator
> at the end.  So if the stated buffer size is wrong, then decrypted uninitialized
> memory can be included into the symlink target that userspace then sees.
> 
> > If it is a problem, then we should probably change the comment header
> > over fscrypt_get_symlink. It currently says:
> > 
> >    * @max_size: size of @caddr buffer
> > 
> > ...which is another reason why I figured using ksize there was OK.
> 
> ksize() is rarely used, as it should be.  (For one, it disables KASAN on the
> buffer...)  I think that when people see "buffer size" they almost always think
> the actual allocated size of the buffer, not ksize().  But we could change it to
> say "allocated size" if that would make it clearer...
> 

Ok, I'll rework it to carry around the length too. That should take care of the problem.

Thanks!
-- 
Jeff Layton <jlayton@kernel.org>

