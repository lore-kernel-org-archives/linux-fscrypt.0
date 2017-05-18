Return-Path: <david@sigma-star.at>
From: David Gstir <david@sigma-star.at>
Message-Id: <6E436FB9-B223-4B78-8383-96A179801A35@sigma-star.at>
Content-Type: multipart/alternative;
 boundary="Apple-Mail=_371BEDCD-8DAE-4A54-AA24-E3C43B6A3BBB"
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v3] fscrypt: Add support for AES-128-CBC
Date: Thu, 18 May 2017 15:43:11 +0200
In-Reply-To: <20170517180850.GA91213@gmail.com>
References: <20170426215616.GA104929@gmail.com>
 <20170517112104.61106-1-david@sigma-star.at>
 <20170517180850.GA91213@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: tytso@mit.edu, jaegeuk@kernel.org, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Daniel Walter <dwalter@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_371BEDCD-8DAE-4A54-AA24-E3C43B6A3BBB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi Eric!

Thanks for the thorough review! :)

> On 17 May 2017, at 20:08, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> Hi David, thanks for the update!
>=20
> On Wed, May 17, 2017 at 01:21:04PM +0200, David Gstir wrote:
>> From: Daniel Walter <dwalter@sigma-star.at>
>>=20
>> fscrypt provides facilities to use different encryption algorithms =
which
>> are selectable by userspace when setting the encryption policy. =
Currently,
>> only AES-256-XTS for file contents and AES-256-CBC-CTS for file names =
are
>> implemented. This is a clear case of kernel offers the mechanism and
>> userspace selects a policy. Similar to what dm-crypt and ecryptfs =
have.
>>=20
>> This patch adds support for using AES-128-CBC for file contents and
>> AES-128-CBC-CTS for file name encryption. To mitigate watermarking
>> attacks, IVs are generated using the ESSIV algorithm. While AES-CBC =
is
>> actually slightly less secure than AES-XTS from a security point of =
view,
>> there is more widespread hardware support. Especially low-powered =
embedded
>> devices with crypto accelerators such as CAAM or CESA support only
>> AES-CBC-128 with an acceptable speed. Using AES-CBC gives us the =
acceptable
>> performance while still providing a moderate level of security for
>> persistent storage.
>=20
> You covered this briefly in an email, but can you include more detail =
in the
> commit message on the reasoning behind choosing AES-128 instead of =
AES-256?
> Note that this is independent of the decision of CBC vs. XTS.

Sure, I'll extend the commit message to include that.


>=20
>> @@ -129,27 +136,37 @@ static int determine_cipher_type(struct =
fscrypt_info *ci, struct inode *inode,
>> 				 const char **cipher_str_ret, int =
*keysize_ret)
>> {
>> 	if (S_ISREG(inode->i_mode)) {
>> -		if (ci->ci_data_mode =3D=3D =
FS_ENCRYPTION_MODE_AES_256_XTS) {
>> +		switch (ci->ci_data_mode) {
>> +		case FS_ENCRYPTION_MODE_AES_256_XTS:
>> 			*cipher_str_ret =3D "xts(aes)";
>> 			*keysize_ret =3D FS_AES_256_XTS_KEY_SIZE;
>> 			return 0;
>> +		case FS_ENCRYPTION_MODE_AES_128_CBC:
>> +			*cipher_str_ret =3D "cbc(aes)";
>> +			*keysize_ret =3D FS_AES_128_CBC_KEY_SIZE;
>> +			return 0;
>> +		default:
>> +			pr_warn_once("fscrypto: unsupported contents =
encryption mode %d for inode %lu\n",
>> +				     ci->ci_data_mode, inode->i_ino);
>> +			return -ENOKEY;
>> 		}
>> -		pr_warn_once("fscrypto: unsupported contents encryption =
mode "
>> -			     "%d for inode %lu\n",
>> -			     ci->ci_data_mode, inode->i_ino);
>> -		return -ENOKEY;
>> 	}
>>=20
>> 	if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) {
>> -		if (ci->ci_filename_mode =3D=3D =
FS_ENCRYPTION_MODE_AES_256_CTS) {
>> +		switch (ci->ci_filename_mode) {
>> +		case FS_ENCRYPTION_MODE_AES_256_CTS:
>> 			*cipher_str_ret =3D "cts(cbc(aes))";
>> 			*keysize_ret =3D FS_AES_256_CTS_KEY_SIZE;
>> 			return 0;
>> +		case FS_ENCRYPTION_MODE_AES_128_CTS:
>> +			*cipher_str_ret =3D "cts(cbc(aes))";
>> +			*keysize_ret =3D FS_AES_128_CTS_KEY_SIZE;
>> +			return 0;
>> +		default:
>> +			pr_warn_once("fscrypto: unsupported filenames =
encryption mode %d for inode %lu\n",
>> +				     ci->ci_filename_mode, =
inode->i_ino);
>> +			return -ENOKEY;
>> 		}
>> -		pr_warn_once("fscrypto: unsupported filenames encryption =
mode "
>> -			     "%d for inode %lu\n",
>> -			     ci->ci_filename_mode, inode->i_ino);
>> -		return -ENOKEY;
>> 	}
>=20
> With the added call to fscrypt_valid_enc_modes() earlier, the warnings =
about
> unsupported encryption modes are no longer reachable.  IMO, the
> fscrypt_valid_enc_modes() check should be moved into this function, a =
proper
> warning message added for it, and the redundant warnings removed.  =
Also now that
> there will be more modes I think it would be appropriate to put the =
algorithm
> names and key sizes in a table, to avoid the ugly switch statements. =20=


I agree. I'll clean this up.



>> +	int err;
>> +
>> +	/* init hash transform on demand */
>> +	if (unlikely(essiv_hash_tfm =3D=3D NULL)) {
>> +		mutex_lock(&essiv_hash_lock);
>> +		if (essiv_hash_tfm =3D=3D NULL) {
>> +			essiv_hash_tfm =3D crypto_alloc_shash("sha256", =
0, 0);
>> +			if (IS_ERR(essiv_hash_tfm)) {
>> +				pr_warn_ratelimited("fscrypt: error =
allocating SHA-256 transform: %ld\n",
>> +						    =
PTR_ERR(essiv_hash_tfm));
>> +				err =3D PTR_ERR(essiv_hash_tfm);
>> +				essiv_hash_tfm =3D NULL;
>> +				mutex_unlock(&essiv_hash_lock);
>> +				return err;
>> +			}
>> +		}
>> +		mutex_unlock(&essiv_hash_lock);
>> +	}
>=20
> There is a bug here: a thread can set essiv_hash_tfm to an ERR_PTR(), =
and
> another thread can use it before it's set back to NULL. =20

Sorry, I missed that... :-(



>> +	err =3D crypto_cipher_setkey(essiv_tfm, salt, =
SHA256_DIGEST_SIZE);
>> +	if (err)
>> +		goto out;
>=20
> sizeof(salt) instead of hardcoding SHA256_DIGEST_SIZE.
>=20
> I think there should also be a brief comment explaining that the ESSIV =
cipher
> uses AES-256 so that its key size matches the size of the hash, even =
though the
> "real" encryption may use AES-128.

Good point!


>=20
>> +void fscrypt_essiv_cleanup(void)
>> +{
>> +	crypto_free_shash(essiv_hash_tfm);
>> +	essiv_hash_tfm =3D NULL;
>> +}
>=20
> This is called from fscrypt_destroy(), which is a little weird because
> fscrypt_destroy() is meant to clean up only from =
"fscrypt_initialize()", which
> only allocates certain things.  I think it should be called from
> "fscrypt_exit()" instead.  Then you could also add the __exit =
annotation, and
> remove setting essiv_hash_tfm to NULL which would clearly be =
unnecessary.

fscrypt_destroy() is actually also called from fscrypt_exit(). Thats why =
I chose it,
but changing this fscrypt_exit() seems the cleaner approach. :)

Thanks,
David

--
sigma star gmbh | Eduard-Bodem-Gasse 6, 6020 Innsbruck, Austria
UID/VAT Nr: ATU 66964118 | FN: 374287y


--Apple-Mail=_371BEDCD-8DAE-4A54-AA24-E3C43B6A3BBB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dus-ascii"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><div dir=3D"auto" style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><div dir=3D"auto" style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;">Hi =
Eric!<div class=3D""><br class=3D""></div><div class=3D"">Thanks for the =
thorough review! :)</div><div class=3D""><br class=3D""><blockquote =
type=3D"cite" class=3D"">On 17 May 2017, at 20:08, Eric Biggers &lt;<a =
href=3D"mailto:ebiggers3@gmail.com" class=3D"">ebiggers3@gmail.com</a>&gt;=
 wrote:<br class=3D""><br class=3D"">Hi David, thanks for the update!<br =
class=3D""><br class=3D"">On Wed, May 17, 2017 at 01:21:04PM +0200, =
David Gstir wrote:<br class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Menlo-Regular; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;" =
class=3D"">From: Daniel Walter &lt;<a =
href=3D"mailto:dwalter@sigma-star.at" =
class=3D"">dwalter@sigma-star.at</a>&gt;<br class=3D""><br =
class=3D"">fscrypt provides facilities to use different encryption =
algorithms which<br class=3D"">are selectable by userspace when setting =
the encryption policy. Currently,<br class=3D"">only AES-256-XTS for =
file contents and AES-256-CBC-CTS for file names are<br =
class=3D"">implemented. This is a clear case of kernel offers the =
mechanism and<br class=3D"">userspace selects a policy. Similar to what =
dm-crypt and ecryptfs have.<br class=3D""><br class=3D"">This patch adds =
support for using AES-128-CBC for file contents and<br =
class=3D"">AES-128-CBC-CTS for file name encryption. To mitigate =
watermarking<br class=3D"">attacks, IVs are generated using the ESSIV =
algorithm. While AES-CBC is<br class=3D"">actually slightly less secure =
than AES-XTS from a security point of view,<br class=3D"">there is more =
widespread hardware support. Especially low-powered embedded<br =
class=3D"">devices with crypto accelerators such as CAAM or CESA support =
only<br class=3D"">AES-CBC-128 with an acceptable speed. Using AES-CBC =
gives us the acceptable<br class=3D"">performance while still providing =
a moderate level of security for<br class=3D"">persistent storage.<br =
class=3D""></blockquote><br class=3D"">You covered this briefly in an =
email, but can you include more detail in the<br class=3D"">commit =
message on the reasoning behind choosing AES-128 instead of AES-256?<br =
class=3D"">Note that this is independent of the decision of CBC vs. =
XTS.<br class=3D""></blockquote><div class=3D""><br class=3D""></div><div =
class=3D"">Sure, I'll extend the commit message to include =
that.</div><div class=3D""><br class=3D""></div><br class=3D""><blockquote=
 type=3D"cite" class=3D""><br class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Menlo-Regular; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;" =
class=3D"">@@ -129,27 +136,37 @@ static int determine_cipher_type(struct =
fscrypt_info *ci, struct inode *inode,<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>&nbsp;const char **cipher_str_ret, int *keysize_ret)<br =
class=3D"">{<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>if (S_ISREG(inode-&gt;i_mode)) =
{<br class=3D"">-<span class=3D"Apple-tab-span" style=3D"white-space:pre">=
	</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>if (ci-&gt;ci_data_mode =3D=3D FS_ENCRYPTION_MODE_AES_256_XTS) =
{<br class=3D"">+<span class=3D"Apple-tab-span" style=3D"white-space:pre">=
	</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>switch (ci-&gt;ci_data_mode) {<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>case =
FS_ENCRYPTION_MODE_AES_256_XTS:<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*cipher_str_ret =3D "xts(aes)";<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*keysize_ret =3D FS_AES_256_XTS_KEY_SIZE;<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>return =
0;<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>case =
FS_ENCRYPTION_MODE_AES_128_CBC:<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*cipher_str_ret =3D "cbc(aes)";<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*keysize_ret =3D FS_AES_128_CBC_KEY_SIZE;<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>return =
0;<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>default:<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>pr_warn_once("fscrypto: unsupported contents encryption mode %d =
for inode %lu\n",<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>&nbsp;&nbsp; &nbsp; =
ci-&gt;ci_data_mode, inode-&gt;i_ino);<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>return =
-ENOKEY;<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>}<br class=3D"">-<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>pr_warn_once("fscrypto: unsupported contents encryption mode "<br =
class=3D"">-<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>&nbsp;&nbsp; &nbsp; "%d for inode %lu\n",<br class=3D"">-<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>&nbsp;&nbsp; &nbsp; ci-&gt;ci_data_mode, inode-&gt;i_ino);<br =
class=3D"">-<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>return -ENOKEY;<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>}<br class=3D""><br =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>if (S_ISDIR(inode-&gt;i_mode) || S_ISLNK(inode-&gt;i_mode)) {<br =
class=3D"">-<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>if (ci-&gt;ci_filename_mode =3D=3D =
FS_ENCRYPTION_MODE_AES_256_CTS) {<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>switch =
(ci-&gt;ci_filename_mode) {<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>case =
FS_ENCRYPTION_MODE_AES_256_CTS:<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*cipher_str_ret =3D "cts(cbc(aes))";<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*keysize_ret =3D FS_AES_256_CTS_KEY_SIZE;<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>return =
0;<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>case =
FS_ENCRYPTION_MODE_AES_128_CTS:<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*cipher_str_ret =3D "cts(cbc(aes))";<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*keysize_ret =3D FS_AES_128_CTS_KEY_SIZE;<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>return =
0;<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>default:<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>pr_warn_once("fscrypto: unsupported filenames encryption mode %d =
for inode %lu\n",<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>&nbsp;&nbsp; &nbsp; =
ci-&gt;ci_filename_mode, inode-&gt;i_ino);<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>return =
-ENOKEY;<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>}<br class=3D"">-<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>pr_warn_once("fscrypto: unsupported filenames encryption mode =
"<br class=3D"">-<span class=3D"Apple-tab-span" style=3D"white-space:pre">=
	</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>&nbsp;&nbsp; &nbsp; "%d for inode %lu\n",<br class=3D"">-<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>&nbsp;&nbsp; &nbsp; ci-&gt;ci_filename_mode, inode-&gt;i_ino);<br =
class=3D"">-<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>return -ENOKEY;<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>}<br class=3D""></blockquote><br =
class=3D"">With the added call to fscrypt_valid_enc_modes() earlier, the =
warnings about<br class=3D"">unsupported encryption modes are no longer =
reachable. &nbsp;IMO, the<br class=3D"">fscrypt_valid_enc_modes() check =
should be moved into this function, a proper<br class=3D"">warning =
message added for it, and the redundant warnings removed. &nbsp;Also now =
that<br class=3D"">there will be more modes I think it would be =
appropriate to put the algorithm<br class=3D"">names and key sizes in a =
table, to avoid the ugly switch statements. &nbsp;</blockquote><div =
class=3D""><br class=3D""></div><div class=3D"">I agree. I'll clean this =
up.</div><div class=3D""><br class=3D""></div><div class=3D""><br =
class=3D""></div><div class=3D""><br class=3D""></div><blockquote =
type=3D"cite" class=3D""><blockquote type=3D"cite" style=3D"font-family: =
Menlo-Regular; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px;" class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>int =
err;<br class=3D"">+<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>/* init hash transform on demand =
*/<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>if (unlikely(essiv_hash_tfm =3D=3D =
NULL)) {<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>mutex_lock(&amp;essiv_hash_lock);<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if =
(essiv_hash_tfm =3D=3D NULL) {<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>essiv_hash_tfm =3D crypto_alloc_shash("sha256", 0, 0);<br =
class=3D"">+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>if (IS_ERR(essiv_hash_tfm)) {<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>pr_warn_ratelimited("fscrypt: error allocating SHA-256 transform: =
%ld\n",<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>&nbsp;&nbsp; =
&nbsp;PTR_ERR(essiv_hash_tfm));<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>err =3D =
PTR_ERR(essiv_hash_tfm);<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>essiv_hash_tfm =3D NULL;<br =
class=3D"">+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>mutex_unlock(&amp;essiv_hash_lock);<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>return =
err;<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>}<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>}<br =
class=3D"">+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>mutex_unlock(&amp;essiv_hash_lock);<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>}<br =
class=3D""></blockquote><br class=3D"">There is a bug here: a thread can =
set essiv_hash_tfm to an ERR_PTR(), and<br class=3D"">another thread can =
use it before it's set back to NULL. &nbsp;</blockquote><div =
class=3D""><br class=3D""></div><div class=3D"">Sorry, I missed that... =
:-(</div><div class=3D""><br class=3D""></div><div class=3D""><br =
class=3D""></div><br class=3D""><blockquote type=3D"cite" =
class=3D""><blockquote type=3D"cite" style=3D"font-family: =
Menlo-Regular; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px;" class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>err =3D =
crypto_cipher_setkey(essiv_tfm, salt, SHA256_DIGEST_SIZE);<br =
class=3D"">+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>if (err)<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>goto out;<br =
class=3D""></blockquote><br class=3D"">sizeof(salt) instead of =
hardcoding SHA256_DIGEST_SIZE.<br class=3D""><br class=3D"">I think =
there should also be a brief comment explaining that the ESSIV cipher<br =
class=3D"">uses AES-256 so that its key size matches the size of the =
hash, even though the<br class=3D"">"real" encryption may use =
AES-128.<br class=3D""></blockquote><div class=3D""><br =
class=3D""></div><div class=3D"">Good point!</div><div class=3D""><br =
class=3D""></div><br class=3D""><blockquote type=3D"cite" class=3D""><br =
class=3D""><blockquote type=3D"cite" style=3D"font-family: =
Menlo-Regular; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px;" class=3D"">+void =
fscrypt_essiv_cleanup(void)<br class=3D"">+{<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>crypto_free_shash(essiv_hash_tfm);<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>essiv_hash_tfm =3D NULL;<br class=3D"">+}<br =
class=3D""></blockquote><br class=3D"">This is called from =
fscrypt_destroy(), which is a little weird because<br =
class=3D"">fscrypt_destroy() is meant to clean up only from =
"fscrypt_initialize()", which<br class=3D"">only allocates certain =
things. &nbsp;I think it should be called from<br =
class=3D"">"fscrypt_exit()" instead. &nbsp;Then you could also add the =
__exit annotation, and<br class=3D"">remove setting essiv_hash_tfm to =
NULL which would clearly be unnecessary.<br class=3D""></blockquote><div =
class=3D""><br class=3D""></div><div class=3D"">fscrypt_destroy() is =
actually also called from fscrypt_exit(). Thats why I chose =
it,</div><div class=3D"">but changing this fscrypt_exit() seems the =
cleaner approach. :)</div><div class=3D""><br class=3D""></div><div =
class=3D"">Thanks,</div><div class=3D"">David</div><br class=3D""><div =
class=3D"">--<br class=3D"">sigma star gmbh | Eduard-Bodem-Gasse 6, 6020 =
Innsbruck, Austria<br class=3D"">UID/VAT Nr: ATU 66964118 | FN: =
374287y<br class=3D""></div><br =
class=3D""></div></div></div></body></html>=

--Apple-Mail=_371BEDCD-8DAE-4A54-AA24-E3C43B6A3BBB--
