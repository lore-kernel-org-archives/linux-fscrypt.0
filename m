Return-Path: <dm-devel-bounces@redhat.com>
MIME-Version: 1.0
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
	<459f5760-3a1c-719d-2b44-824ba6283dd7@gmail.com>
	<CAKv+Gu9jk8KxWykTcKeh6k0HUb47wgx7iZYuwwN8AUyErFLXxA@mail.gmail.com>
	<075cddec-1603-4a23-17c4-c766b4bd9086@gmail.com>
	<6a45dfa5-e383-d8a3-ebf1-abdc43c95ebd@gmail.com>
	<CAKv+Gu-ZETNJh2VzUkpbQUmYv6Zqb7nVj91bxuxKoNAJwgON=w@mail.gmail.com>
	<b635b78d-cfe8-3fa4-d9b2-6cf4185dac71@gmail.com>
In-Reply-To: <b635b78d-cfe8-3fa4-d9b2-6cf4185dac71@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 21 Jun 2019 09:06:20 +0200
Message-ID: <CAKv+Gu-uRUFv1+yEqNdM1KpJSwic2oGF=CYPU6Sebf3eXwruMQ@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH v3 0/6] crypto: switch to crypto API for
	ESSIV generation
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

On Fri, 21 Jun 2019 at 09:01, Milan Broz <gmazyland@gmail.com> wrote:
>
> On 20/06/2019 15:52, Ard Biesheuvel wrote:
> >>>> Does this include configurations that combine authenc with essiv?
> >>>
> >>> Hm, seems that we are missing these in luks2-integrity-test. I'll add them there.
> >>>
> >>> I also used this older test
> >>> https://gitlab.com/omos/dm-crypt-test-scripts/blob/master/root/test_dmintegrity.sh
> >>>
> >>> (just aes-gcm-random need to be commented out, we never supported this format, it was
> >>> written for some devel version)
> >>>
> >>> But seems ESSIV is there tested only without AEAD composition...
> >>>
> >>> So yes, this AEAD part need more testing.
> >>
> >> And unfortunately it does not work - it returns EIO on sectors where it should not be data corruption.
> >>
> >> I added few lines with length-preserving mode with ESSIV + AEAD, please could you run luks2-integrity-test
> >> in cryptsetup upstream?
> >>
> >> This patch adds the tests:
> >> https://gitlab.com/cryptsetup/cryptsetup/commit/4c74ff5e5ae328cb61b44bf99f98d08ffee3366a
> >>
> >> It is ok on mainline kernel, fails with the patchset:
> >>
> >> # ./luks2-integrity-test
> >> [aes-cbc-essiv:sha256:hmac-sha256:128:512][FORMAT][ACTIVATE]sha256sum: /dev/mapper/dmi_test: Input/output error
> >> [FAIL]
> >>  Expecting ee501705a084cd0ab6f4a28014bcf62b8bfa3434de00b82743c50b3abf06232c got .
> >>
> >> FAILED backtrace:
> >> 77 ./luks2-integrity-test
> >> 112 intformat ./luks2-integrity-test
> >> 127 main ./luks2-integrity-test
> >>
> >
> > OK, I will investigate.
> >
> > I did my testing in a VM using a volume that was created using a
> > distro kernel, and mounted and used it using a kernel with these
> > changes applied.
> >
> > Likewise, if I take a working key.img and mode-test.img, i can mount
> > it and use it on the system running these patches.
> >
> > I noticed that this test uses algif_skcipher not algif_aead when it
> > formats the volume, and so I wonder if the way userland creates the
> > image is affected by this?
>
> Not sure if I understand the question, but I do not think userspace even touch data area here
> (except direct-io wiping after the format, but it does not read it back).
>
> It only encrypts keyslots - and here we cannot use AEAD (in fact it is already
> authenticated by a LUKS digest).
>
> So if the data area uses AEAD (or composition of length-preserving mode and
> some authentication tag like HMAC), we fallback to non-AEAD for keyslot encryption.
>
> In short, to test it, you need to activate device (that works ok with your patches)
> and *access* the data, testing LUKS format and just keyslot access will never use AEAD.
>
> So init the data by direct-io writes, and try to read them back (with dd).
>
> For testing data on dm-integrity (or dm-crypt with AEAD encryption stacked oved dm-integrity)
> I used small utility, maybe it could be useful https://github.com/mbroz/dm_int_tools
>

Thanks.

It appears that my code generates the wrong authentication tags on
encryption, but on decryption it works fine.
I'll keep digging ...

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
