Return-Path: <SRS0=ZpEn=CQ=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C19FC433E2
	for <linux-fscrypt@archiver.kernel.org>; Mon,  7 Sep 2020 23:01:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1B600215A4
	for <linux-fscrypt@archiver.kernel.org>; Mon,  7 Sep 2020 23:01:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727944AbgIGXBB (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 7 Sep 2020 19:01:01 -0400
Received: from smtprelay0192.hostedemail.com ([216.40.44.192]:32790 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726929AbgIGXBA (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 7 Sep 2020 19:01:00 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay05.hostedemail.com (Postfix) with ESMTP id 2A26E18029121;
        Mon,  7 Sep 2020 23:00:56 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: sky91_0512991270cf
X-Filterd-Recvd-Size: 4449
Received: from XPS-9350 (cpe-72-134-242-36.natsow.res.rr.com [72.134.242.36])
        (Authenticated sender: joe@perches.com)
        by omf19.hostedemail.com (Postfix) with ESMTPA;
        Mon,  7 Sep 2020 23:00:55 +0000 (UTC)
Message-ID: <a661d908cd6e2b0396c75c2eb52b95f33e92cd5e.camel@perches.com>
Subject: Re: [PATCH] fscrypt: Reduce object size of logging messages
From:   Joe Perches <joe@perches.com>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        linux-fscrypt@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Date:   Mon, 07 Sep 2020 16:00:52 -0700
In-Reply-To: <20200907222338.GA68127@sol.localdomain>
References: <d9e2693cc157bbc09df92a91a9ecad8dcc8438ce.camel@perches.com>
         <20200904230341.GA6172@sol.localdomain>
         <ec1347522c95c89425b3189b071b35f9d912e3e0.camel@perches.com>
         <20200907222338.GA68127@sol.localdomain>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.36.4-0ubuntu1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Hi again.

On Mon, 2020-09-07 at 15:23 -0700, Eric Biggers wrote:
> On Fri, Sep 04, 2020 at 09:38:23PM -0700, Joe Perches wrote:
> > > > diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
> > > > index 9212325763b0..c82cc3907e43 100644
> > > > --- a/fs/crypto/crypto.c
> > > > +++ b/fs/crypto/crypto.c
> > > > @@ -329,25 +329,27 @@ int fscrypt_initialize(unsigned int cop_flags)
> > > >  	return err;
> > > >  }
> > > >  
> > > > -void fscrypt_msg(const struct inode *inode, const char *level,
> > > > -		 const char *fmt, ...)
> > > > +void fscrypt_printk(const struct inode *inode, const char *fmt, ...)
> > > >  {
> > > >  	static DEFINE_RATELIMIT_STATE(rs, DEFAULT_RATELIMIT_INTERVAL,
> > > >  				      DEFAULT_RATELIMIT_BURST);
> > > >  	struct va_format vaf;
> > > >  	va_list args;
> > > > +	int level;
> > > >  
> > > >  	if (!__ratelimit(&rs))
> > > >  		return;
> > > >  
> > > >  	va_start(args, fmt);
> > > > -	vaf.fmt = fmt;
> > > > +	level = printk_get_level(fmt);
> > > > +	vaf.fmt = printk_skip_level(fmt);
> > > >  	vaf.va = &args;
> > > >  	if (inode)
> > > > -		printk("%sfscrypt (%s, inode %lu): %pV\n",
> > > > -		       level, inode->i_sb->s_id, inode->i_ino, &vaf);
> > > > +		printk("%c%cfscrypt (%s, inode %lu): %pV\n",
> > > > +		       KERN_SOH_ASCII, level, inode->i_sb->s_id, inode->i_ino,
> > > > +		       &vaf);
> > > >  	else
> > > > -		printk("%sfscrypt: %pV\n", level, &vaf);
> > > > +		printk("%c%cfscrypt: %pV\n", KERN_SOH_ASCII, level, &vaf);
> > > >  	va_end(args);
> > > 
> > > The problem with this approach is that if fscrypt_printk() is called without
> > > providing a log level in the format string (which one would assume would work,
> > > since printk() allows it), then the real format string will be truncated to just
> > > KERN_SOH because 'level' will be 0.
> > > Can you find a way to avoid that?
> > 
> > While I don't think this is a problem in that all the fscrypt_<level>
> > calls will always prefix a KERN_<LEVEL>,
> 
> It's still a pitfall that people could run into later.  It would be better to
> make fscrypt_printk() work in the expected way.
> 
> > what btrfs uses:
> > 
> > 	char lvl[PRINTK_MAX_SINGLE_HEADER_LEN + 1] = "\0";
> > ...
> > 	while ((kern_level = printk_get_level(fmt)) != 0) {
> > 		size_t size = printk_skip_level(fmt) - fmt;
> > 
> > 		if (kern_level >= '0' && kern_level <= '7') {
> > 			memcpy(lvl, fmt,  size);
> > 			lvl[size] = '\0';
> > 		}
> > 		fmt += size;
> > 	}
> > 
> > and use "%s...", lvl, ...
> 
> Is the loop really needed?

It prevents defects (that btrfs had) where
btrfs_<level> used formats with KERN_<LEVEL>.

> > > > +#define fscrypt_warn(inode, fmt, ...)					\
> > > > +	fscrypt_printk(inode, KERN_WARNING fmt, ##__VA_ARGS__)
> > > 
> > > It's probably best to keep the parentheses around 'inode'.
> > 
> > Not really as it's an independent argument that can't
> > effectively have any other purpose but to be an argument
> > to the fsrypt_printk function.
> 
> True, but since forgetting to include parentheses around macro arguments is such
> a common mistake, IMO they should just always be included so that people don't
> have to think about whether the omission is correct or not.

We think differently.
Unnecessary parentheses are unnecessary and there
isn't a possiblity adding them here can be useful.


