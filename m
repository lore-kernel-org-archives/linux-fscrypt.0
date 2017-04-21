Return-Path: <jaegeuk@kernel.org>
Date: Fri, 21 Apr 2017 10:35:03 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: use 32 bytes of encrypted filename
Message-ID: <20170421173503.GA1228@jaegeuk.local>
References: <20170418210642.6039-1-gwendal@chromium.org>
 <20170418230136.GA96152@gmail.com>
 <20170419001005.GA143911@gmail.com>
 <20170419014209.GB12215@jaegeuk.local>
 <20170419040138.GA563@zzz>
 <20170419204448.GA1021@jaegeuk.local>
 <20170421074402.GA7459@zzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170421074402.GA7459@zzz>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, ebiggers@google.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-mtd@lists.infradead.org, tytso@mit.edu, linux-ext4@vger.kernel.org, kinaba@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On 04/21, Eric Biggers wrote:
> Hi Jaegeuk,
> 
> On Wed, Apr 19, 2017 at 01:44:48PM -0700, Jaegeuk Kim wrote:
> > 
> > Thank you for sharing more details. I could reproduce this issue and reach out
> > to what you mentioned. In order to resolve this, I wrote a patch for f2fs first
> > to act like ext4 for easy backports. Then, I expect a global fscrypt function
> > is easily able to clean them up.
> [...]
> > @@ -130,19 +130,29 @@ struct f2fs_dir_entry *find_target_dentry(struct fscrypt_name *fname,
> >  			continue;
> >  		}
> >  
> > -		/* encrypted case */
> > +		if (de->hash_code != namehash)
> > +			goto not_match;
> > +
> >  		de_name.name = d->filename[bit_pos];
> >  		de_name.len = le16_to_cpu(de->name_len);
> >  
> > -		/* show encrypted name */
> > -		if (fname->hash) {
> > -			if (de->hash_code == cpu_to_le32(fname->hash))
> > -				goto found;
> > -		} else if (de_name.len == name->len &&
> > -			de->hash_code == namehash &&
> > -			!memcmp(de_name.name, name->name, name->len))
> > +#ifdef CONFIG_F2FS_FS_ENCRYPTION
> > +		if (unlikely(!name->name)) {
> > +			if (fname->usr_fname->name[0] == '_') {
> > +				if (de_name.len >= 16 &&
> > +					!memcmp(de_name.name + de_name.len - 16,
> > +						fname->crypto_buf.name + 8, 16))
> > +					goto found;
> > +				goto not_match;
> > +			}
> > +			name->name = fname->crypto_buf.name;
> > +			name->len = fname->crypto_buf.len;
> > +		}
> > +#endif
> > +		if (de_name.len == name->len &&
> > +				!memcmp(de_name.name, name->name, name->len))
> >  			goto found;
> > -
> > +not_match:
> 
> I agree with this approach, but I don't think it's ever the case that
> fname->usr_fname->name[0] != '_'.  (Yes, ext4 checks it, but I think it's
> unneeded there too.)  And if it was, it doesn't make sense to modify the 'name'
> that is passed in.

Agreed, and actually I tried to sync ext4 as much as possible for further work
like 2.) and 3.) below. ;)

> In any case, I guess that unless there are other ideas we can do these patches:
> 
> 1.) f2fs patch to start checking the name, as above
> 2.) patch to start encoding last 32 bytes of the name (or second-to-last CTS
>     block, I haven't decided yet) rather than last 16 bytes, changing
>     fs/crypto/, fs/ext4/, and fs/f2fs/
> 3.) cleanup patches to introduce helper function and switch ext4 and f2fs to it

IMO, it'd better to do 3.) followed by 2.), since 2.) already needs to change
fs/crypto which does not give much backporting effort.

> (1) and (2) will be backported.
> 
> UBIFS can be changed to use the helper function later if needed.  It's not as
> important for it to be backported there since UBIFS does the "double hashing",
> and UBIFS encryption was just added in 4.10 anyway.
> 
> I can try to put together the full series when I have time.  It probably would
> make sense for it to go through the fscrypt tree, given the dependencies.

I found one issue in my patch and modified it in f2fs tree [1]. Given next merge
window probable starting next week, let me upstream this modified one first
through f2fs. Then, you can see it in 4.12-rc1 two weeks later, so fscrypt
patches can be easily integrated after then. If you have any concern, I'm also
okay to push this patch through fscrypt. Let me know.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs.git/commit/?h=dev-test&id=1585cfbbb269be6a112e0629a52123c0f9eaf4fa

Thanks,

> 
> Eric
