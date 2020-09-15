Return-Path: <SRS0=1x/1=CZ=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A5FEC43461
	for <linux-fscrypt@archiver.kernel.org>; Wed, 16 Sep 2020 00:28:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DCEC420663
	for <linux-fscrypt@archiver.kernel.org>; Wed, 16 Sep 2020 00:28:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600216114;
	bh=WN/QqxErWebXTJi5I5vXL5r6WSAz9r37RH/cAQ3I5Wo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=UGPkUB4+l6enM0jMwcW9v8gH0fE95lcmotEum7XGChjfUCnZzgyWpJrgCGn2wn1VT
	 4XwwhGjqqjJnRxnbIj1ixxHN3s/x/8G19KHk43v48YPv7Xk2/kMh7vGpH4QUCGAUXf
	 Qtpf6erW4no/lqne7h1IIy17+q77VEsJQ2I4A9Y8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726769AbgIOOGq (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 15 Sep 2020 10:06:46 -0400
Received: from mail.kernel.org ([198.145.29.99]:56262 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726748AbgIOOFz (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 15 Sep 2020 10:05:55 -0400
Received: from tleilax.poochiereds.net (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 84076206A1;
        Tue, 15 Sep 2020 14:05:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600178755;
        bh=WN/QqxErWebXTJi5I5vXL5r6WSAz9r37RH/cAQ3I5Wo=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=h0tpSe8pJNaC0/c087YTJPu3ap6lZ8/1juxsuzlQ5B2A5CFrXj4IrYpmTRaht2Gsi
         Rlo7U+Udi/RFveE9rLdgEGcckKfwHPDryT/Am348XF8LB26bceRhhMOl8YMBwEbC+g
         lV/SYiB5sLfWufPbvOEGh5VjW//dUaHRijBRC8ww=
Message-ID: <5bdc7608df4ff480c07eb6a0e85514ebd986e5d9.camel@kernel.org>
Subject: Re: [RFC PATCH v3 16/16] ceph: create symlinks with encrypted and
 base64-encoded targets
From:   Jeff Layton <jlayton@kernel.org>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     ceph-devel@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date:   Tue, 15 Sep 2020 10:05:53 -0400
In-Reply-To: <20200915020725.GM899@sol.localdomain>
References: <20200914191707.380444-1-jlayton@kernel.org>
         <20200914191707.380444-17-jlayton@kernel.org>
         <20200915020725.GM899@sol.localdomain>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.36.5 (3.36.5-1.fc32) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, 2020-09-14 at 19:07 -0700, Eric Biggers wrote:
> On Mon, Sep 14, 2020 at 03:17:07PM -0400, Jeff Layton wrote:
> > +	if (IS_ENCRYPTED(req->r_new_inode)) {
> > +		int len = strlen(dest);
> > +
> > +		err = fscrypt_prepare_symlink(dir, dest, len, PATH_MAX, &osd_link);
> > +		if (err)
> > +			goto out_req;
> > +
> > +		err = fscrypt_encrypt_symlink(req->r_new_inode, dest, len, &osd_link);
> > +		if (err)
> > +			goto out_req;
> > +
> > +		req->r_path2 = kmalloc(FSCRYPT_BASE64_CHARS(osd_link.len) + 1, GFP_KERNEL);
> 
> osd_link.len includes a null terminator.  It seems that's not what's wanted
> here, and you should be subtracting 1 here.
> 
> (fscrypt_prepare_symlink() maybe should exclude the null terminator from the
> length instead.  But for the other filesystems it was easier to include it...)
> 

Got it. Fixed.

> > @@ -996,26 +995,39 @@ int ceph_fill_inode(struct inode *inode, struct page *locked_page,
> >  		inode->i_fop = &ceph_file_fops;
> >  		break;
> >  	case S_IFLNK:
> > -		inode->i_op = &ceph_symlink_iops;
> >  		if (!ci->i_symlink) {
> >  			u32 symlen = iinfo->symlink_len;
> >  			char *sym;
> >  
> >  			spin_unlock(&ci->i_ceph_lock);
> >  
> > -			if (symlen != i_size_read(inode)) {
> > -				pr_err("%s %llx.%llx BAD symlink "
> > -					"size %lld\n", __func__,
> > -					ceph_vinop(inode),
> > -					i_size_read(inode));
> > +			if (IS_ENCRYPTED(inode)) {
> > +				/* Do base64 decode so that we get the right size (maybe?) */
> > +				err = -ENOMEM;
> > +				sym = kmalloc(symlen + 1, GFP_NOFS);
> > +				if (!sym)
> > +					goto out;
> > +
> > +				symlen = fscrypt_base64_decode(iinfo->symlink, symlen, sym);
> > +				/*
> > +				 * i_size as reported by the MDS may be wrong, due to base64
> > +				 * inflation and padding. Fix it up here.
> > +				 */
> >  				i_size_write(inode, symlen);
> 
> Note that fscrypt_base64_decode() can fail (return -1) if the input is not valid
> base64.  That isn't being handled here.
> 

Thanks, fixed. It'll return -EIO in that case now.

> > +static const char *ceph_encrypted_get_link(struct dentry *dentry, struct inode *inode,
> > +					   struct delayed_call *done)
> > +{
> > +	struct ceph_inode_info *ci = ceph_inode(inode);
> > +
> > +	if (!dentry)
> > +		return ERR_PTR(-ECHILD);
> > +
> > +	return fscrypt_get_symlink(inode, ci->i_symlink, ksize(ci->i_symlink), done);
> 
> Using ksize() seems wrong here, since that would allow fscrypt_get_symlink() to
> read beyond the part of the buffer that is actually initialized.
> 

Is that actually a problem? I did have an earlier patch that carried
around the length, but it didn't seem to be necessary.

ISTM that that might end up decrypting more data than is actually
needed, but eventually there will be a NULL terminator in the data and
the rest would be ignored.

If it is a problem, then we should probably change the comment header
over fscrypt_get_symlink. It currently says:

   * @max_size: size of @caddr buffer

...which is another reason why I figured using ksize there was OK.

> > -static const struct inode_operations ceph_symlink_iops = {
> > +const struct inode_operations ceph_symlink_iops = {
> >  	.get_link = simple_get_link,
> >  	.setattr = ceph_setattr,
> >  	.getattr = ceph_getattr,
> >  	.listxattr = ceph_listxattr,
> >  };
> >  
> > +const struct inode_operations ceph_encrypted_symlink_iops = {
> > +	.get_link = ceph_encrypted_get_link,
> > +	.setattr = ceph_setattr,
> > +	.getattr = ceph_getattr,
> > +	.listxattr = ceph_listxattr,
> > +};
> 
> These don't need to be made global, as they're only used in fs/ceph/inode.c.
> 

Thanks, fixed.
-- 
Jeff Layton <jlayton@kernel.org>

