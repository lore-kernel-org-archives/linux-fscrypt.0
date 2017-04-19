Return-Path: <ebiggers3@gmail.com>
Date: Tue, 18 Apr 2017 21:01:38 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: use 32 bytes of encrypted filename
Message-ID: <20170419040138.GA563@zzz>
References: <20170418210642.6039-1-gwendal@chromium.org>
 <20170418230136.GA96152@gmail.com>
 <20170419001005.GA143911@gmail.com>
 <20170419014209.GB12215@jaegeuk.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419014209.GB12215@jaegeuk.local>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, ebiggers@google.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-mtd@lists.infradead.org, tytso@mit.edu, linux-ext4@vger.kernel.org, kinaba@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 18, 2017 at 06:42:09PM -0700, Jaegeuk Kim wrote:
> Hi Eric,
> 
> On 04/18, Eric Biggers wrote:
> > On Tue, Apr 18, 2017 at 04:01:36PM -0700, Eric Biggers wrote:
> > > 
> > > Strangely, f2fs and ubifs do not use the bytes from the filename at all when
> > > trying to find a specific directory entry in this case.  So this patch doesn't
> > > really affect them.  This seems unreliable; perhaps we should introduce a
> > > function like "fscrypt_name_matches()" which all the filesystems could call?
> > > Can any of the f2fs and ubifs developers explain why they don't look at any
> > > bytes from the filename?
> > > 
> 
> The fscrypt_setup_filename sets fname->hash in the bigname case, but doesn't
> give fname->disk_name. If it's not such the bigname case, we check its name
> since fname->hash is zero.
> 

Yes, that's what it does now.  The question is, in the "bigname" case why
doesn't f2fs check the 16 bytes of ciphertext in fname->crypto_buf too?  f2fs
doesn't even use 'minor_hash'; it can't possibly be the case that there are
never any collisions of a 32-bit hash in a directory, can it?

I actually tested it, and it definitely happens if you put a lot of files in an
encrypted directory on f2fs.  An example with 100000 files:

# seq -f "edir/abcdefghijklmnopqrstuvwxyz012345%.0f" 100000 | xargs touch
# find edir -type f | xargs stat -c %i | sort | uniq | wc -l
100000
# sync
# echo 3 > /proc/sys/vm/drop_caches
# keyctl new_session
# find edir -type f | xargs stat -c %i | sort | uniq | wc -l
99999

So when I tried accessing the encrypted directory without the key, two dentries
showed the same inode, due to a hash collision.

Actually, checking the last 16 bytes of ciphertext currently wouldn't even help
for those filenames since it's all the same, as they share a long common prefix:

# ls -1  edir | head -n 4
_++09VCAAAAgsQQf6Q5YgLgoO4f3PPSfb
_++1UWDAAAAgsQQf6Q5YgLgoO4f3PPSfb
_++2HAAAAAAgsQQf6Q5YgLgoO4f3PPSfb
_++4UxBAAAAgsQQf6Q5YgLgoO4f3PPSfb

But that's the bug, since the last two AES blocks are swapped when using
ciphertext stealing.  We should at least be using the second-to-last block in
which case we'd see:

# ls -1  edir | head -n 4
_++09VCAAAAw9VONwQEXOVv3RR,kOAKwB
_++1UWDAAAAAHDi7c3QZxbiltjOo1m0,F
_++2HAAAAAAAfd1Vx0oC31SmhzYpaYfwz
_++4UxBAAAAwZxcWjzORdAef50FB9sKY4

(In either case there are still a few A's at the beginning since f2fs doesn't
set 'minor_hash'.  That's okay, but only if collisions are ruled out by other
means.)

> > -		/* encrypted case */
> > -		de_name.name = d->filename[bit_pos];
> > -		de_name.len = le16_to_cpu(de->name_len);
> > -
> > -		/* show encrypted name */
> > -		if (fname->hash) {
> > -			if (de->hash_code == cpu_to_le32(fname->hash))
> > -				goto found;
> > -		} else if (de_name.len == name->len &&
> > -			de->hash_code == namehash &&
> > -			!memcmp(de_name.name, name->name, name->len))
> > +		if ((fname->hash == 0 ||
> > +		     fname->hash == le32_to_cpu(de->hash_code)) &&
> > +		    fscrypt_name_matches(fname, d->filename[bit_pos],
> > +					 le16_to_cpu(de->name_len)))
> 
> BTW, this slips checking namehash?
> 

Yes that's a mistake.  Actually it seems that 'namehash' is the same as
'fname->hash' when 'fname->hash' is nonzero, so the code should just be:

	if (de->hash_code == namehash &&
	    fscrypt_name_matches(fname, d->filename[bit_pos],
				 le16_to_cpu(de->name_len)))
		goto found;

- Eric
