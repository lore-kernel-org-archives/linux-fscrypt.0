Return-Path: <dm-devel-bounces@redhat.com>
MIME-Version: 1.0
References: <20190810094053.7423-1-ard.biesheuvel@linaro.org>
	<20190810094053.7423-4-ard.biesheuvel@linaro.org>
	<8679d2f5-b005-cd89-957e-d79440b78086@gmail.com>
	<CAKv+Gu-ZPPR5xQSR6T4o+8yJvsHY2a3xXZ5zsM_aGS3frVChgQ@mail.gmail.com>
	<82a87cae-8eb7-828c-35c3-fb39a9abe692@gmail.com>
In-Reply-To: <82a87cae-8eb7-828c-35c3-fb39a9abe692@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 12 Aug 2019 10:50:18 +0300
Message-ID: <CAKv+Gu_d+3NsTKFZbS+xeuxf5uCz=ENmPX-a=s-2kgLrW4d7cQ@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH v9 3/7] md: dm-crypt: switch to ESSIV crypto
	API template
List-Unsubscribe: <https://www.redhat.com/mailman/options/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
To: Milan Broz <gmazyland@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, device-mapper development <dm-devel@redhat.com>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, 12 Aug 2019 at 10:44, Milan Broz <gmazyland@gmail.com> wrote:
>
> On 12/08/2019 08:54, Ard Biesheuvel wrote:
> > On Mon, 12 Aug 2019 at 09:33, Milan Broz <gmazyland@gmail.com> wrote:
> >> Try for example
> >> # cryptsetup luksFormat /dev/sdc -c aes-cbc-essiv:sha256 --integrity hmac-sha256 -q -i1
> >>
> >> It should produce Crypto API string
> >>   authenc(hmac(sha256),essiv(cbc(aes),sha256))
> >> while it produces
> >>   essiv(authenc(hmac(sha256),cbc(aes)),sha256)
> >> (and fails).
> >>
> >
> > No. I don't know why it fails, but the latter is actually the correct
> > string. The essiv template is instantiated either as a skcipher or as
> > an aead, and it encapsulates the entire transformation. (This is
> > necessary considering that the IV is passed via the AAD and so the
> > ESSIV handling needs to touch that as well)
>
> Hm. Constructing these strings seems to be more confusing than dmcrypt mode combinations :-)
>
> But you are right, I actually tried the former string (authenc(hmac(sha256),essiv(cbc(aes),sha256)))
> and it worked, but I guess the authenticated IV (AAD) was actually the input to IV (plain sector number)
> not the output of ESSIV? Do I understand it correctly now?
>

Indeed. The former string instantiates the skcipher version of the
ESSIV template, and so the AAD handling is omitted, and we end up
using the plain IV in the authentication rather than the encrypted IV.

So when using the latter string, does it produce any error messages
when it fails?

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
