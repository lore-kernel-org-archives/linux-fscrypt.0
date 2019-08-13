Return-Path: <dm-devel-bounces@redhat.com>
MIME-Version: 1.0
References: <20190812145324.27090-1-ard.biesheuvel@linaro.org>
	<20190812145324.27090-3-ard.biesheuvel@linaro.org>
	<20190812194747.GB131059@gmail.com>
	<CAKv+Gu-9aHY0op6MEmN8PfQhNa0kv=xNYB6rqtaCoiUdH4OASA@mail.gmail.com>
	<20190813180020.GA233786@gmail.com>
In-Reply-To: <20190813180020.GA233786@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 13 Aug 2019 21:16:14 +0300
Message-ID: <CAKv+Gu8BFxyre0XDpE2To6yEvBP4E16abMZbR=r17TpQQko54Q@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH v10 2/7] fs: crypto: invoke crypto API for
 ESSIV handling
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
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, 13 Aug 2019 at 21:00, Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Tue, Aug 13, 2019 at 08:09:41AM +0300, Ard Biesheuvel wrote:
> > On Mon, 12 Aug 2019 at 22:47, Eric Biggers <ebiggers@kernel.org> wrote:
> > >
> > > On Mon, Aug 12, 2019 at 05:53:19PM +0300, Ard Biesheuvel wrote:
> > > > Instead of open coding the calculations for ESSIV handling, use a
> > > > ESSIV skcipher which does all of this under the hood.
> > > >
> > > > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > >
> > > This looks fine (except for one comment below), but this heavily conflicts with
> > > the fscrypt patches planned for v5.4.  So I suggest moving this to the end of
> > > the series and having Herbert take only 1-6, and I'll apply this one to the
> > > fscrypt tree later.
> > >
> >
> > I think the same applies to dm-crypt: at least patch #7 cannot be
> > applied until my eboiv patch is applied there as well, but [Milan
> > should confirm] I'd expect them to prefer taking those patches via the
> > dm tree anyway.
> >
> > Herbert, what would you prefer:
> > - taking a pull request from a [signed] tag based on v4.3-rc1 that
> > contains patches #1, #4, #5 and #6, allowing Eric and Milan/Mike to
> > merge it as well, and apply the respective fscrypt and dm-crypt
> > changes on top
> > - just take patches #1, #4, #5 and #6 as usual, and let the fscrypt
> > and dm-crypt changes be reposted to the respective lists during the
> > next cycle
> >
>
> FWIW I'd much prefer the second option, to minimize the number of special things
> that Linus will have to consider or deal with.  (There's also going to be a
> conflict between the fscrypt and keyrings trees.)  I'd be glad to take the
> fscrypt patch for 5.5, if the essiv template is added in 5.4.
>

Works for me. I'll respin with the dm-crypt and fscrypt patches
omitted (and the minor fixes you suggested applied).

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
