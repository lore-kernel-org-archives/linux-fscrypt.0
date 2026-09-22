Received: from mail-wr2-f12.google.com (mail-wr2-f12.google.com [74.125.225.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1165D53F694
	for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 14:05:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.225.76
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790085924; cv=pass; b=bYkMnveSSEVqrcAwI+PmM8x3JvZ9wHTRb56F7Q6Dgks4hHpkkZgqFhTdLe3DawRbaevZbcEu/S60yUGjlsfT0Uh1bZjAsMxhsH/OZ9+pLk/b3uIgC1+s3UEquoX0UwudkbFAvHwI3wwT61Sbuuz0WmK8Iax6WGjcUc+xJLV/rh0=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790085924; c=relaxed/simple;
	bh=u7bMS2QsTN3HhDT/yBr8GHkY+yLGOO8Zk8HLIkizkfo=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=RECJNHkXsc9rB9xFxYByQEeENPtZnblHJSjZyVbR3dIXblquMC7ZzF5VWa0rJ0tcumKbFADgEFM9O2F6zV5eIRFRetcg038LUtS6S4QTC9kZVmHo3M+TU0wdD+hX6qkMGR4Alu7EIeGET/KobK/IrWxYukQmRqoCdE3Vd8TysnM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=CfDyf+MT; arc=pass smtp.client-ip=74.125.225.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="CfDyf+MT"
Received: by mail-wr2-f12.google.com with SMTP id ffacd0b85a97d-4843c3ea1f6so1785794f8f.0
        for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 07:05:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790085920; cv=none;
        d=google.com; s=arc-20260327;
        b=Ob/g6h4KfiaSSADFtG11QeQaWKxTF5CpaXb9Ier4i/H1oI6/t2rKc8u3m6O7jkM9UB
         laGRQ6edGa9EE9Z9ouhy6sa7u+lfe1itDlk/oWohHAZ7xOIAjhrli/7PkY/m2METpBZu
         dqYLOxh6tNR2HAaBJK7WPAst0laHimVzjJ8xI5grmebZxahSOguBP9x++a59vPzHNUUd
         M3oE0/FBq1vavYRXjshf5JxRUTKEK/y+pqGETcw29I+pD40bbnfjk5yR/RMiaiahCNvf
         YmyCFN3xHlAgstOi3F7jWLJSuOZ5q9ZWa6OtHoYwA/4ymvwmAzR4o1hupMSKB0xxTXpG
         CEww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZrtHB84b364jzwBBOljWxOCtEOH9Ysc3gFWF5Y09jm0=;
        fh=RlGr2ELeJF322Wy9M1QwTOekI261TkEKB+ZzeBlST4o=;
        b=JDvZ22QNRnxAaU6yWy774ya9GPgSMX3BXKDy7zMY0HxJQvUzDV9gJ/xBEl0sezIV1t
         /18V8cFdQWdUzPYgIbWrmousyURNOd51Fy7B6ogm/z4WrycnZbXlCEgRn2NIsihha+hR
         82Q9vXHGpR/76xG9BLk3KFTF5swyn4cG0E3YXNcxuugbNq9dn4TCROS5mj41Y+JJ13Zn
         QyfzErv2IoK8rKHL+391gbQ9vZ7IkVo4z7xG5vQ8khNdt10rftCOba1W9h3tiOqaIqs7
         cS6ALcxQKrctJDiVtmHo4vtbgKGDi336itMyavfdR6DEWLAIkwjezOx31UJ6j/8whTSm
         dbMw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1790085920; x=1790690720; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ZrtHB84b364jzwBBOljWxOCtEOH9Ysc3gFWF5Y09jm0=;
        b=CfDyf+MTCmv4aQBDyPn7h30jqSH6DJE210hWBVMGI5KYGsuu6nm12ks/c/rQGNTZzX
         kCUmPPD3ORq91m53TVuAXAAz5qZYW3x4Rqm5SmcqNF+Hdh1iPI2yViMDvnexfNvp1qUh
         pc0lpnS8PgmhJ46tz3+1W1uTAIadlNXtWVGHo3oxIPh9k7pqvc3eCzCWEn2Jd+CfwXN3
         OTCAN+SbZIfKF7w9i7O0MzNf1esKMSGIkuo6BAUgVRJ6QuyK22oPXVLy/AmDvTGMqYYT
         DXlNLrt9SKPci73qbXwvEFrBBbbPoLOOQhtji6hz6sJ9iEAteQMUBhj7mUIDKsLWtmCw
         0h/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790085920; x=1790690720;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=ZrtHB84b364jzwBBOljWxOCtEOH9Ysc3gFWF5Y09jm0=;
        b=PsdBnUYpjZ+JSzOIitVY2XTlGc/B4pqaxbNZsXO9BjSxOgNUVO7X4Z/p8iMnkV60V3
         btncBqtesmEAx4XfasKQ//PaXqgrifBIt5FCFdcdTITDWNCpbMm5WpvOOz4RMmztVYHf
         N3LioU2eOty+5IGSTA0c/jREltO3DnJoL7v2nPasC81VfBO+UFkpXKyMcWN5yNnSMJGQ
         fNiG9I7nfXRS4QWCqC1iE6WjTg+w/ig0kMkI/a+JAdEy+VE/D6m4+BUThOm6CszJGcpB
         Pia9B4Sm7dvVB6xoWhs30moP2PMaDo4ebJYPY/KYGOzCwgDKMXKet+qYBkY3EXa0jkSz
         5Fbg==
X-Forwarded-Encrypted: i=1; AKwUvByaMaQ7+SgAm/eAnQcAe/XntMaIC83KWo4GB453w9VWpx2UwOFGiRcrADL7Ob5mZ102ADN6djRvYm0GIZ4q@vger.kernel.org
X-Gm-Message-State: AFuF++nxoWQmONhOL/tp8vGMhqlezRILMD6sHFfF1hJLJuYx9xy5Yc/H
	R4O/+601Dv9LBYQPUWvvQlVZHTYhBR8Pg1lyuiCa1V3wPoyvUGclQtSfGC8pu0PBQHheNyc2tgN
	STw8zgDEsyWC49hJmlIFmrQX46hr2o93p6DuuxdesMQ==
X-Gm-Gg: AYBFou3hepYbJxv3TeNTAn7tmgvgbqD3ryDGBZjFI8wzUJAMtVKjV+4PcycG/YvlCcH
	lhfL5CPKhJnunsc4YLAJuF3V+ERU0bwyDXVCbnmeMF27pLwHFtbY+y2D316bEtcyVnLKD2NF/Jh
	OUHyIN1mCGXglpZjE9eXTmTM1BCP3UuMM5gpWhs+zfu53t94LjRh3A3hH+KQH+0FSmjerQCNUO+
	owb8/ZjblbZqzgxYY5H68ZynDUt6FZOSEmBzh4qZEtG5WUwdQ+o6GmsRjnU5Z5hg4CIQvGHnHhE
	7clulBL30pu/4k93LtUuuKmjAv6B1OkEmm0P3NebmHCDsNF6uc8wXMtCJLeEcdmpAQ9rtVn3nw6
	tboHSxV1l112zNpLQvesuyRKDKSrdeozmIIo+YRhZ+6tb1Vnvbc1s
X-Received: by 2002:a05:6000:1884:b0:487:ee6:b76c with SMTP id
 ffacd0b85a97d-4871e386891mr20725607f8f.56.1790085920335; Tue, 22 Sep 2026
 07:05:20 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-12-neelx@suse.com>
 <20260602032534.GH2295@sol>
In-Reply-To: <20260602032534.GH2295@sol>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 22 Sep 2026 16:05:08 +0200
X-Gm-Features: AclHuK9buEKOllKFAYM2m_CAJ3xVlO7s0lRsVrq1N6uymn8JCD10DYisCBeAGOs
Message-ID: <CAPjX3FczT+7rBFbtu+t4FRg2_VCXO33BghmHAO4rD+mPA_5hDg@mail.gmail.com>
Subject: Re: [PATCH v7 11/43] btrfs: add inode encryption contexts
To: Eric Biggers <ebiggers@kernel.org>, Boris Burkov <boris@bur.io>, Chris Mason <mason@kernel.org>
Cc: Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Omar Sandoval <osandov@osandov.com>, Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 05:26, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:45AM +0200, Daniel Vacek wrote:
> > From: Omar Sandoval <osandov@osandov.com>
> >
> > fscrypt stores a context item with encrypted inodes that contains the
> > related encryption information.  fscrypt provides an arbitrary blob for
> > the filesystem to store, and it does not clearly fit into an existing
> > structure, so this goes in a new item type.
> >
> > Signed-off-by: Omar Sandoval <osandov@osandov.com>
> > Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > Signed-off-by: Daniel Vacek <neelx@suse.com>
> > ---
> >
> > v7 changes:
> >  * Fix a path leak as found by Chri's AI review.
> > v6 changes:
> >  * Shorten the inode context key macro name to BTRFS_FSCRYPT_INODE_CTX_KEY.
> > v5: https://lore.kernel.org/linux-btrfs/5a88efb484b0874a7430b83bc6e5f6b9aa5858d5.1706116485.git.josef@toxicpanda.com/
> > ---
> >  fs/btrfs/fscrypt.c              | 116 ++++++++++++++++++++++++++++++++
> >  fs/btrfs/fscrypt.h              |   2 +
> >  fs/btrfs/inode.c                |  19 ++++++
> >  fs/btrfs/ioctl.c                |   8 ++-
> >  include/uapi/linux/btrfs_tree.h |  10 +++
> >  5 files changed, 153 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/btrfs/fscrypt.c b/fs/btrfs/fscrypt.c
> > index 6cfba7d94e72..c503f817cbe7 100644
> > --- a/fs/btrfs/fscrypt.c
> > +++ b/fs/btrfs/fscrypt.c
> > @@ -1,10 +1,126 @@
> >  // SPDX-License-Identifier: GPL-2.0
> >
> > +#include <linux/iversion.h>
> >  #include "ctree.h"
> > +#include "accessors.h"
> >  #include "btrfs_inode.h"
> > +#include "disk-io.h"
> > +#include "fs.h"
> >  #include "fscrypt.h"
> > +#include "ioctl.h"
> > +#include "messages.h"
> > +#include "transaction.h"
> > +#include "xattr.h"
> > +
> > +static int btrfs_fscrypt_get_context(struct inode *inode, void *ctx, size_t len)
> > +{
> > +     struct btrfs_key key = {
> > +             .objectid = btrfs_ino(BTRFS_I(inode)),
> > +             .type = BTRFS_FSCRYPT_INODE_CTX_KEY,
> > +             .offset = 0,
> > +     };
> > +     struct btrfs_path *path;
> > +     struct extent_buffer *leaf;
> > +     unsigned long ptr;
> > +     int ret;
> > +
> > +
> > +     path = btrfs_alloc_path();
> > +     if (!path)
> > +             return -ENOMEM;
> > +
> > +     ret = btrfs_search_slot(NULL, BTRFS_I(inode)->root, &key, path, 0, 0);
> > +     if (ret) {
> > +             len = -ENOENT;
> > +             goto out;
> > +     }
> > +
> > +     leaf = path->nodes[0];
> > +     ptr = btrfs_item_ptr_offset(leaf, path->slots[0]);
> > +     /* fscrypt provides max context length, but it could be less */
> > +     len = min_t(size_t, len, btrfs_item_size(leaf, path->slots[0]));
> > +     read_extent_buffer(leaf, ctx, ptr, len);
> > +
> > +out:
> > +     btrfs_free_path(path);
> > +     return len;
> > +}
>
> This doesn't conform to the calling convention for
> fscrypt_operations::get_context, specifically in the cases where
> -ENODATA and -ERANGE are expected.
>
>         /*
>          * Get the fscrypt context of the given inode.
>          *
>          * @inode: the inode whose context to get
>          * @ctx: the buffer into which to get the context
>          * @len: length of the @ctx buffer in bytes
>          *
>          * Return: On success, returns the length of the context in bytes; this
>          *         may be less than @len.  On failure, returns -ENODATA if the
>          *         inode doesn't have a context, -ERANGE if the context is
>          *         longer than @len, or another -errno code.
>          */
>         int (*get_context)(struct inode *inode, void *ctx, size_t len);
>
> It also seems to be assuming that any error from btrfs_search_slot()
> means "not found", which isn't correct.
>
> The size_t variable called 'len' is also being used to store negative
> errno values, which is weird.

Those are valid points. I fixed the return codes and cleaned up the
function a bit.

> > +static int btrfs_fscrypt_set_context(struct inode *inode, const void *ctx,
> > +                                  size_t len, void *fs_data)
> > +{
> > +     struct btrfs_trans_handle *trans = fs_data;
> > +     struct btrfs_key key = {
> > +             .objectid = btrfs_ino(BTRFS_I(inode)),
> > +             .type = BTRFS_FSCRYPT_INODE_CTX_KEY,
> > +             .offset = 0,
> > +     };
> > +     struct btrfs_path *path = NULL;
> > +     struct extent_buffer *leaf;
> > +     unsigned long ptr;
> > +     int ret;
> > +
> > +     if (!trans)
> > +             trans = btrfs_start_transaction(BTRFS_I(inode)->root, 2);
> > +     if (IS_ERR(trans))
> > +             return PTR_ERR(trans);
> > +
> > +     path = btrfs_alloc_path();
> > +     if (!path) {
> > +             ret = -ENOMEM;
> > +             goto out_err;
> > +     }
> > +
> > +     ret = btrfs_search_slot(trans, BTRFS_I(inode)->root, &key, path, 0, 1);
> > +     if (ret < 0)
> > +             goto out_err;
> > +
> > +     if (ret > 0) {
> > +             btrfs_release_path(path);
> > +             ret = btrfs_insert_empty_item(trans, BTRFS_I(inode)->root, path, &key, len);
> > +             if (ret)
> > +                     goto out_err;
> > +     }
> > +
> > +     leaf = path->nodes[0];
> > +     ptr = btrfs_item_ptr_offset(leaf, path->slots[0]);
> > +
> > +     len = min_t(size_t, len, btrfs_item_size(leaf, path->slots[0]));
> > +     write_extent_buffer(leaf, ctx, ptr, len);
> > +     btrfs_mark_buffer_dirty(trans, leaf);
> > +     btrfs_release_path(path);
> > +
> > +     if (fs_data)
> > +             goto out_err;
> > +
> > +     BTRFS_I(inode)->flags |= BTRFS_INODE_ENCRYPT;
> > +     btrfs_sync_inode_flags_to_i_flags(BTRFS_I(inode));
> > +     inode_inc_iversion(inode);
> > +     inode_set_ctime_current(inode);
> > +     ret = btrfs_update_inode(trans, BTRFS_I(inode));
> > +     if (ret)
> > +             goto out_abort;
> > +     btrfs_free_path(path);
> > +     btrfs_end_transaction(trans);
> > +     return 0;
> > +out_abort:
> > +     btrfs_abort_transaction(trans, ret);
> > +out_err:
> > +     if (!fs_data)
> > +             btrfs_end_transaction(trans);
> > +     btrfs_free_path(path);
> > +     return ret;
> > +}
>
> The 'len = min_t(size_t, len, btrfs_item_size(leaf, path->slots[0]));'
> line seems scary, since it just truncates the data given.

Right. Actually let's refactor both functions and split the common part.

> > @@ -199,7 +203,7 @@ static int check_fsflags(unsigned int old_flags, unsigned int flags)
> >                     FS_NOATIME_FL | FS_NODUMP_FL | \
> >                     FS_SYNC_FL | FS_DIRSYNC_FL | \
> >                     FS_NOCOMP_FL | FS_COMPR_FL |
> > -                   FS_NOCOW_FL))
> > +                   FS_NOCOW_FL | FS_ENCRYPT_FL))
> >               return -EOPNOTSUPP;
>
> Do you know why FS_VERITY_FL isn't in this mask?

Not really. It seems that 41b37c51937e ("btrfs: initial fsverity
support") did not add this flag. I'm not sure if that is a mistake or
intentional. Maybe @Boris or @Chris would know?

--nX

> - Eric
