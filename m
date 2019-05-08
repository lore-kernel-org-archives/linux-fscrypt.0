Return-Path: <SRS0=Z5Os=TI=nod.at=richard@kernel.org>
Date: Wed, 8 May 2019 08:49:18 +0200 (CEST)
From: Richard Weinberger <richard@nod.at>
Message-ID: <1170873772.48849.1557298158182.JavaMail.zimbra@nod.at>
In-Reply-To: <20190508031954.GA26575@sol.localdomain>
References: <20190326075232.11717-1-s.hauer@pengutronix.de> <20190326075232.11717-2-s.hauer@pengutronix.de> <20190508031954.GA26575@sol.localdomain>
Subject: Re: [PATCH 1/2] ubifs: Remove #ifdef around CONFIG_FS_ENCRYPTION
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Eric Biggers <ebiggers@kernel.org>
Cc: Sascha Hauer <s.hauer@pengutronix.de>, linux-mtd <linux-mtd@lists.infradead.org>, linux-fscrypt@vger.kernel.org, tytso <tytso@mit.edu>, kernel <kernel@pengutronix.de>
List-ID: <linux-fscrypt@vger.kernel.org>

Eric,

----- Urspr=C3=BCngliche Mail -----
> Von: "Eric Biggers" <ebiggers@kernel.org>
> An: "Sascha Hauer" <s.hauer@pengutronix.de>, "richard" <richard@nod.at>
> CC: "linux-mtd" <linux-mtd@lists.infradead.org>, linux-fscrypt@vger.kerne=
l.org, "tytso" <tytso@mit.edu>, "kernel"
> <kernel@pengutronix.de>
> Gesendet: Mittwoch, 8. Mai 2019 05:19:55
> Betreff: Re: [PATCH 1/2] ubifs: Remove #ifdef around CONFIG_FS_ENCRYPTION

> On Tue, Mar 26, 2019 at 08:52:31AM +0100, Sascha Hauer wrote:
>> ifdefs reduce readablity and compile coverage. This removes the ifdefs
>> around CONFIG_FS_ENCRYPTION by using IS_ENABLED and relying on static
>> inline wrappers. A new static inline wrapper for setting sb->s_cop is
>> introduced to allow filesystems to unconditionally compile in their
>> s_cop operations.
>>=20
>> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
>> ---
>>  fs/ubifs/ioctl.c        | 11 +----------
>>  fs/ubifs/sb.c           |  7 ++++---
>>  fs/ubifs/super.c        |  4 +---
>>  include/linux/fscrypt.h | 11 +++++++++++
>>  4 files changed, 17 insertions(+), 16 deletions(-)
>>=20
>> diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
>> index 82e4e6a30b04..6b05b3ec500e 100644
>> --- a/fs/ubifs/ioctl.c
>> +++ b/fs/ubifs/ioctl.c
>> @@ -193,7 +193,6 @@ long ubifs_ioctl(struct file *file, unsigned int cmd=
,
>> unsigned long arg)
>>  =09=09return err;
>>  =09}
>>  =09case FS_IOC_SET_ENCRYPTION_POLICY: {
>> -#ifdef CONFIG_FS_ENCRYPTION
>>  =09=09struct ubifs_info *c =3D inode->i_sb->s_fs_info;
>> =20
>>  =09=09err =3D ubifs_enable_encryption(c);
>> @@ -201,17 +200,9 @@ long ubifs_ioctl(struct file *file, unsigned int cm=
d,
>> unsigned long arg)
>>  =09=09=09return err;
>> =20
>>  =09=09return fscrypt_ioctl_set_policy(file, (const void __user *)arg);
>> -#else
>> -=09=09return -EOPNOTSUPP;
>> -#endif
>>  =09}
>> -=09case FS_IOC_GET_ENCRYPTION_POLICY: {
>> -#ifdef CONFIG_FS_ENCRYPTION
>> +=09case FS_IOC_GET_ENCRYPTION_POLICY:
>>  =09=09return fscrypt_ioctl_get_policy(file, (void __user *)arg);
>> -#else
>> -=09=09return -EOPNOTSUPP;
>> -#endif
>> -=09}
>> =20
>>  =09default:
>>  =09=09return -ENOTTY;
>> diff --git a/fs/ubifs/sb.c b/fs/ubifs/sb.c
>> index 67fac1e8adfb..2afc8b1d4c3b 100644
>> --- a/fs/ubifs/sb.c
>> +++ b/fs/ubifs/sb.c
>> @@ -748,14 +748,12 @@ int ubifs_read_superblock(struct ubifs_info *c)
>>  =09=09goto out;
>>  =09}
>> =20
>> -#ifndef CONFIG_FS_ENCRYPTION
>> -=09if (c->encrypted) {
>> +=09if (!IS_ENABLED(CONFIG_UBIFS_FS_ENCRYPTION) && c->encrypted) {
>>  =09=09ubifs_err(c, "file system contains encrypted files but UBIFS"
>>  =09=09=09     " was built without crypto support.");
>>  =09=09err =3D -EINVAL;
>>  =09=09goto out;
>>  =09}
>=20
> A bit late, but I noticed this in ubifs/linux-next.  This needs to use
> CONFIG_FS_ENCRYPTION here, not CONFIG_UBIFS_FS_ENCRYPTION, as the latter =
no
> longer exists.

Thanks for spotting. I'll fit it myself in -next.

Thanks,
//richard
