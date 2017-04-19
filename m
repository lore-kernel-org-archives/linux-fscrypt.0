Return-Path: <gwendal@google.com>
MIME-Version: 1.0
Sender: gwendal@google.com
In-Reply-To: <20170419001005.GA143911@gmail.com>
References: <20170418210642.6039-1-gwendal@chromium.org> <20170418230136.GA96152@gmail.com>
 <20170419001005.GA143911@gmail.com>
From: Gwendal Grignou <gwendal@chromium.org>
Date: Wed, 19 Apr 2017 13:31:26 -0700
Message-ID: <CAMHSBOWm8+Mhi5+bjs+mcx2Pu70h2xw4+XgCPo-nxFT+7gdK9Q@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: use 32 bytes of encrypted filename
Content-Type: text/plain; charset=UTF-8
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Gwendal Grignou <gwendal@chromium.org>, Theodore Ts'o <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, Kazuhiro Inaba <kinaba@chromium.org>, Ryo Hashimoto <hashimoto@chromium.org>, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 18, 2017 at 5:10 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> On Tue, Apr 18, 2017 at 04:01:36PM -0700, Eric Biggers wrote:
>>
>> Strangely, f2fs and ubifs do not use the bytes from the filename at all when
>> trying to find a specific directory entry in this case.  So this patch doesn't
>> really affect them.  This seems unreliable; perhaps we should introduce a
>> function like "fscrypt_name_matches()" which all the filesystems could call?
>> Can any of the f2fs and ubifs developers explain why they don't look at any
>> bytes from the filename?
>>
>
> Just to give some ideas, here's an untested patch which does this and also
> updates F2FS to start checking the filename.  UBIFS seemed more difficult so I
> didn't touch it yet.
Verified your better patch - modified to work on 4.9 - is working with ext4,
More comment inline.
>
> Of course, this would need to be split into a few different patches if we
> actually wanted to go with it.
>
> ---
>
> diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
> index 37b49894c762..1fc19a265924 100644
> --- a/fs/crypto/fname.c
> +++ b/fs/crypto/fname.c
> @@ -160,12 +160,14 @@ static const char *lookup_table =
>         "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+,";
>
>  /**
> - * digest_encode() -
> + * base64_encode() -
I noticed there are another implementation of base64 in the kernel,
ceph_armor (although it uses the regular '/' instead of ',' for the
64th character).
Looking at RFC 3548 (https://tools.ietf.org/html/rfc3548#page-6) "Base
64 Encoding with URL and Filename Safe Alphabet", the 63th and 64th
character should be '-_' instead of '+,'.
Rename base64_filename_encode to be precise.

>   *
> - * Encodes the input digest using characters from the set [a-zA-Z0-9_+].
> - * The encoded string is roughly 4/3 times the size of the input string.
> + * Encode the input data using characters from the set [A-Za-z0-9+,].
> + *
> + * Return: the length of the encoded string.  This will be 4/3 times the size of
> + *        the input string, rounded up.
>   */
> -static int digest_encode(const char *src, int len, char *dst)
> +static int base64_encode(const char *src, int len, char *dst)
>  {
>         int i = 0, bits = 0, ac = 0;
>         char *cp = dst;
> @@ -185,7 +187,9 @@ static int digest_encode(const char *src, int len, char *dst)
>         return cp - dst;
>  }
>
> -static int digest_decode(const char *src, int len, char *dst)
> +#define BASE64_CHARS(nbytes)   DIV_ROUND_UP((nbytes) * 4, 3)
> +
> +static int base64_decode(const char *src, int len, char *dst)
>  {
>         int i = 0, bits = 0, ac = 0;
>         const char *p;
> @@ -274,7 +278,7 @@ int fscrypt_fname_disk_to_usr(struct inode *inode,
>                         struct fscrypt_str *oname)
>  {
>         const struct qstr qname = FSTR_TO_QSTR(iname);
> -       char buf[24];
> +       char buf[8 + FS_FNAME_CRYPTO_DIGEST_SIZE];
Given buf is now internal to fscrypto, we should define a structure:
struct fscrypto_bigname {
   u32 hash;
   u32 minor_hash;
   u8   digest[FS_FNAME_CRYPTO_DIGEST_SIZE];
}
>
>         if (fscrypt_is_dot_dotdot(&qname)) {
>                 oname->name[0] = '.';
> @@ -289,20 +293,35 @@ int fscrypt_fname_disk_to_usr(struct inode *inode,
>         if (inode->i_crypt_info)
>                 return fname_decrypt(inode, iname, oname);
>
> +       /* Key is unavailable.  Encode the name without decrypting it. */
> +
>         if (iname->len <= FS_FNAME_CRYPTO_DIGEST_SIZE) {
> -               oname->len = digest_encode(iname->name, iname->len,
> +               /* Short name: base64-encode the ciphertext directly */
> +               oname->len = base64_encode(iname->name, iname->len,
>                                            oname->name);
>                 return 0;
>         }
> +
> +       /*
> +        * Long name.  We can't simply base64-encode the full ciphertext, since
> +        * the resulting length may exceed NAME_MAX.  Instead, base64-encode a
> +        * filesystem-provided cookie ('hash' and 'minor_hash') followed by the
> +        * last two ciphertext blocks.  It's assumed this is sufficient to
> +        * identify the directory entry on ->lookup().  It's not actually
> +        * guaranteed, but with CBC or CBC-CTS mode encryption, it's good enough
> +        * since the unused blocks will affect the used ones.
> +        */
> +
>         if (hash) {
>                 memcpy(buf, &hash, 4);
>                 memcpy(buf + 4, &minor_hash, 4);
>         } else {
>                 memset(buf, 0, 8);
>         }
> -       memcpy(buf + 8, iname->name + iname->len - 16, 16);
> +       memcpy(buf + 8, iname->name + iname->len - FS_FNAME_CRYPTO_DIGEST_SIZE,
> +              FS_FNAME_CRYPTO_DIGEST_SIZE);
>         oname->name[0] = '_';
> -       oname->len = 1 + digest_encode(buf, 24, oname->name + 1);
> +       oname->len = 1 + base64_encode(buf, sizeof(buf), oname->name + 1);
>         return 0;
>  }
>  EXPORT_SYMBOL(fscrypt_fname_disk_to_usr);
> @@ -373,17 +392,21 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
>          * We don't have the key and we are doing a lookup; decode the
>          * user-supplied name
>          */
> -       if (iname->name[0] == '_')
> +       if (iname->name[0] == '_') {
>                 bigname = 1;
> -       if ((bigname && (iname->len != 33)) || (!bigname && (iname->len > 43)))
> +               if (iname->len !=
> +                   BASE64_CHARS(1 + 8 + FS_FNAME_CRYPTO_DIGEST_SIZE))
becomes 1 + sizeof(struct fscrypto_bigname)
> +                       return -ENOENT;
> +       } else if (iname->len > BASE64_CHARS(FS_FNAME_CRYPTO_DIGEST_SIZE))
>                 return -ENOENT;
>
> -       fname->crypto_buf.name = kmalloc(32, GFP_KERNEL);
> +       fname->crypto_buf.name = kmalloc(8 + FS_FNAME_CRYPTO_DIGEST_SIZE,
max(32, sizeof(struct fscrypto_bigname)) to be precise,
> +                                        GFP_KERNEL);
>         if (fname->crypto_buf.name == NULL)
>                 return -ENOMEM;
>
> -       ret = digest_decode(iname->name + bigname, iname->len - bigname,
> -                               fname->crypto_buf.name);
> +       ret = base64_decode(iname->name + bigname, iname->len - bigname,
> +                           fname->crypto_buf.name);
>         if (ret < 0) {
>                 ret = -ENOENT;
>                 goto errout;
> diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
> index e39696e64494..f1f15b84e02f 100644
> --- a/fs/crypto/fscrypt_private.h
> +++ b/fs/crypto/fscrypt_private.h
> @@ -13,8 +13,6 @@
>
>  #include <linux/fscrypt_supp.h>
>
> -#define FS_FNAME_CRYPTO_DIGEST_SIZE    32
> -
>  /* Encryption parameters */
>  #define FS_XTS_TWEAK_SIZE              16
>  #define FS_AES_128_ECB_KEY_SIZE                16
> diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
> index 07e5e1405771..d1618835de12 100644
> --- a/fs/ext4/namei.c
> +++ b/fs/ext4/namei.c
> @@ -1237,37 +1237,23 @@ static void dx_insert_block(struct dx_frame *frame, u32 hash, ext4_lblk_t block)
>  }
>
>  /*
> - * NOTE! unlike strncmp, ext4_match returns 1 for success, 0 for failure.
> + * Determine whether the filename being looked up matches the given dir_entry.
>   *
> - * `len <= EXT4_NAME_LEN' is guaranteed by caller.
> - * `de != NULL' is guaranteed by caller.
> + * Return: true if the entry matches, otherwise false.
>   */
> -static inline int ext4_match(struct ext4_filename *fname,
> -                            struct ext4_dir_entry_2 *de)
> +static inline bool ext4_match(const struct ext4_filename *fname,
> +                             const struct ext4_dir_entry_2 *de)
>  {
> -       const void *name = fname_name(fname);
> -       u32 len = fname_len(fname);
> +       const struct fscrypt_str *crypto_buf = NULL;
>
>         if (!de->inode)
>                 return 0;
>
>  #ifdef CONFIG_EXT4_FS_ENCRYPTION
> -       if (unlikely(!name)) {
> -               if (fname->usr_fname->name[0] == '_') {
> -                       int ret;
> -                       if (de->name_len < 16)
> -                               return 0;
> -                       ret = memcmp(de->name + de->name_len - 16,
> -                                    fname->crypto_buf.name + 8, 16);
> -                       return (ret == 0) ? 1 : 0;
> -               }
> -               name = fname->crypto_buf.name;
> -               len = fname->crypto_buf.len;
> -       }
> +       crypto_buf = &fname->crypto_buf;
>  #endif
> -       if (de->name_len != len)
> -               return 0;
> -       return (memcmp(de->name, name, len) == 0) ? 1 : 0;
> +       return fscrypt_match_dirent(fname->usr_fname, &fname->disk_name,
> +                                   crypto_buf, de->name, de->name_len);
>  }
>
>  /*
> @@ -1289,12 +1275,7 @@ int ext4_search_dir(struct buffer_head *bh, char *search_buf, int buf_size,
>                 /* this code is executed quadratically often */
>                 /* do minimal checking `by hand' */
>                 if ((char *) de + de->name_len <= dlimit) {
> -                       res = ext4_match(fname, de);
> -                       if (res < 0) {
> -                               res = -1;
> -                               goto return_result;
> -                       }
> -                       if (res > 0) {
> +                       if (ext4_match(fname, de)) {
>                                 /* found a match - just to be sure, do
>                                  * a full check */
>                                 if (ext4_check_dir_entry(dir, NULL, de, bh,
> @@ -1843,11 +1824,7 @@ int ext4_find_dest_de(struct inode *dir, struct inode *inode,
>                         res = -EFSCORRUPTED;
>                         goto return_result;
>                 }
> -               /* Provide crypto context and crypto buffer to ext4 match */
> -               res = ext4_match(fname, de);
> -               if (res < 0)
> -                       goto return_result;
> -               if (res > 0) {
> +               if (ext4_match(fname, de)) {
>                         res = -EEXIST;
>                         goto return_result;
>                 }
> diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
> index 8d5c62b07b28..07b80d78a9f6 100644
> --- a/fs/f2fs/dir.c
> +++ b/fs/f2fs/dir.c
> @@ -111,8 +111,6 @@ struct f2fs_dir_entry *find_target_dentry(struct fscrypt_name *fname,
>         struct f2fs_dir_entry *de;
>         unsigned long bit_pos = 0;
>         int max_len = 0;
> -       struct fscrypt_str de_name = FSTR_INIT(NULL, 0);
> -       struct fscrypt_str *name = &fname->disk_name;
>
>         if (max_slots)
>                 *max_slots = 0;
> @@ -130,17 +128,10 @@ struct f2fs_dir_entry *find_target_dentry(struct fscrypt_name *fname,
>                         continue;
>                 }
>
> -               /* encrypted case */
> -               de_name.name = d->filename[bit_pos];
> -               de_name.len = le16_to_cpu(de->name_len);
> -
> -               /* show encrypted name */
> -               if (fname->hash) {
> -                       if (de->hash_code == cpu_to_le32(fname->hash))
> -                               goto found;
> -               } else if (de_name.len == name->len &&
> -                       de->hash_code == namehash &&
> -                       !memcmp(de_name.name, name->name, name->len))
> +               if ((fname->hash == 0 ||
> +                    fname->hash == le32_to_cpu(de->hash_code)) &&
> +                   fscrypt_name_matches(fname, d->filename[bit_pos],
> +                                        le16_to_cpu(de->name_len)))
>                         goto found;
>
>                 if (max_slots && max_len > *max_slots)
> diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
> index 3511ca798804..4034976bea93 100644
> --- a/include/linux/fscrypt_notsupp.h
> +++ b/include/linux/fscrypt_notsupp.h
> @@ -147,6 +147,24 @@ static inline int fscrypt_fname_usr_to_disk(struct inode *inode,
>         return -EOPNOTSUPP;
>  }
>
> +static inline bool fscrypt_match_dirent(const struct qstr *usr_fname,
> +                                       const struct fscrypt_str *disk_name,
> +                                       const struct fscrypt_str *crypto_buf,
> +                                       const char *de_name, u32 de_name_len)
> +{
> +       /* Encryption support disabled; use standard comparison. */
> +       if (de_name_len != disk_name->len)
> +               return false;
> +       return !memcmp(de_name, disk_name->name, disk_name->len);
> +}
> +
> +static inline bool fscrypt_name_matches(const struct fscrypt_name *fname,
> +                                       const char *de_name, u32 de_name_len)
> +{
> +       return fscrypt_match_dirent(fname->usr_fname, &fname->disk_name,
> +                                   &fname->crypto_buf, de_name, de_name_len);
> +}
> +
>  /* bio.c */
>  static inline void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *ctx,
>                                              struct bio *bio)
> diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
> index a140f47e9b27..e3c9aa7209a1 100644
> --- a/include/linux/fscrypt_supp.h
> +++ b/include/linux/fscrypt_supp.h
> @@ -57,6 +57,63 @@ extern int fscrypt_fname_disk_to_usr(struct inode *, u32, u32,
>  extern int fscrypt_fname_usr_to_disk(struct inode *, const struct qstr *,
>                         struct fscrypt_str *);
>
> +/*
> + * Number of bytes of ciphertext from the end of the filename which the
> + * filesystem includes when encoding long encrypted filenames for presentation
> + * to userspace without the key.
> + */
> +#define FS_FNAME_CRYPTO_DIGEST_SIZE    (2 * FS_CRYPTO_BLOCK_SIZE)
> +
> +/**
> + * fscrypt_match_dirent() - does the directory entry match the name being looked up?
> + *
> + * This is like fscrypt_name_matches(), but for filesystems which don't use the
> + * fscrypt_name structure.  (We probably should make all filesystems do the same
> + * thing...)
> + */
> +static inline bool fscrypt_match_dirent(const struct qstr *usr_fname,
> +                                       const struct fscrypt_str *disk_name,
> +                                       const struct fscrypt_str *crypto_buf,
> +                                       const char *de_name, u32 de_name_len)
> +{
> +       if (unlikely(!disk_name->name)) {
> +               if (WARN_ON_ONCE(usr_fname->name[0] != '_'))
> +                       return false;
> +               if (de_name_len < FS_FNAME_CRYPTO_DIGEST_SIZE)
> +                       return false;
> +               return !memcmp(de_name + de_name_len - FS_FNAME_CRYPTO_DIGEST_SIZE,
> +                              crypto_buf->name + 8,/buf[
> +                              FS_FNAME_CRYPTO_DIGEST_SIZE);
> +       }
> +
> +       if (de_name_len != disk_name->len)
> +               return false;
> +       return !memcmp(de_name, disk_name->name, disk_name->len);
> +}
> +
> +/**
> + * fscrypt_name_matches() - does the directory entry match the name being looked up?
> + * @fname: the name being looked up
> + * @de_name: the name from the directory entry
> + * @de_name_len: the length of @de_name in bytes
> + *
> + * Normally @fname->disk_name will be set, and in that case we simply compare
> + * that to the directory entry.  The only exception is that if we don't have the
> + * key for an encrypted directory and a filename in it is very long, then the
> + * filename presented to userspace will only have the last
> + * FS_FNAME_CRYPTO_DIGEST_SIZE bytes of ciphertext encoded in it, so we can only
> + * compare that portion.  Note that despite this limit, due to the use of
> + * CBC-CTS encryption there should not be any collisions.
> + *
> + * Return: true if the name matches, otherwise false.
> + */
> +static inline bool fscrypt_name_matches(const struct fscrypt_name *fname,
> +                                       const char *de_name, u32 de_name_len)
> +{
> +       return fscrypt_match_dirent(fname->usr_fname, &fname->disk_name,
> +                                   &fname->crypto_buf, de_name, de_name_len);
> +}
> +
>  /* bio.c */
>  extern void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *, struct bio *);
>  extern void fscrypt_pullback_bio_page(struct page **, bool);
