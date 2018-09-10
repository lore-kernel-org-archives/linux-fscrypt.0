Date: Mon, 10 Sep 2018 16:20:07 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v2 2/2] fscrypt: enable RCU-walk path for
 .d_revalidate
Message-ID: <20180910232007.GA19951@gmail.com>
References: <1536584468-15695-2-git-send-email-gaoxiang25@huawei.com>
 <1536584937-16960-1-git-send-email-gaoxiang25@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536584937-16960-1-git-send-email-gaoxiang25@huawei.com>
To: Gao Xiang <gaoxiang25@huawei.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Chao Yu <yuchao0@huawei.com>, Miao Xie <miaoxie@huawei.com>, weidu.du@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Gao,

On Mon, Sep 10, 2018 at 09:08:57PM +0800, Gao Xiang wrote:
> This patch attempts to enable RCU-walk for fscrypt.
> It looks harmless at glance and could have better
> performance than do ref-walk only.
> 
> Signed-off-by: Gao Xiang <gaoxiang25@huawei.com>
> ---
> change log v2:
> 	- READ_ONCE(dir->d_parent) -> READ_ONCE(dentry->d_parent)
> 
>  fs/crypto/crypto.c | 22 +++++++++++++---------
>  1 file changed, 13 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
> index b38c574..9bd21c0 100644
> --- a/fs/crypto/crypto.c
> +++ b/fs/crypto/crypto.c
> @@ -319,20 +319,24 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
>  {
>  	struct dentry *dir;
>  	int dir_has_key, cached_with_key;
> -
> -	if (flags & LOOKUP_RCU)
> -		return -ECHILD;
> -
> -	dir = dget_parent(dentry);
> -	if (!IS_ENCRYPTED(d_inode(dir))) {
> -		dput(dir);
> +	struct inode *dir_inode;
> +
> +	rcu_read_lock();
> +repeat:
> +	dir = READ_ONCE(dentry->d_parent);
> +	dir_inode = d_inode_rcu(dir);
> +	if (!IS_ENCRYPTED(dir_inode)) {
> +		rcu_read_unlock();
>  		return 0;
>  	}
> +	dir_has_key = (dir_inode->i_crypt_info != NULL);
> +	if (unlikely(READ_ONCE(dir->d_lockref.count) < 0 ||
> +		READ_ONCE(dentry->d_parent) != dir))
>
>
> +	rcu_read_unlock();
>  
>  	cached_with_key = READ_ONCE(dentry->d_flags) &
>  		DCACHE_ENCRYPTED_WITH_KEY;
> -	dir_has_key = (d_inode(dir)->i_crypt_info != NULL);
> -	dput(dir);
>  

I think you're right that we don't have to drop out of RCU mode here, but can
you please Cc linux-fsdevel so that people more knowledgeable about path lookup
can review this too?  This kind of stuff is very tricky.  Please resend both
patches.

Also please indent properly:

	if (unlikely(READ_ONCE(dir->d_lockref.count) < 0 ||
                     READ_ONCE(dentry->d_parent) != dir))
		goto repeat;

Why read d_lockref.count directly instead of using __lockref_is_dead()?

Also since there's no longer any reference to the parent dentry taken, how do
you know it's still positive (non-NULL d_inode), i.e. that the directory hasn't
been removed and turned into a negative dentry (NULL d_inode)?

I'm also wondering whether the retry loop is actually needed.  Can you explain
your thoughts more?  But if it is needed, in principle you'd actually need to
wait until after the loop before taking any action based on dir_inode, right?
That would mean the 'rcu_read_unlock(); return 0;' is in the wrong place.

Thanks,

- Eric
