Return-Path: <linux-crypto-owner@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1708191605370.2380@file01.intranet.prod.int.rdu2.redhat.com>
References: <1502724094-23305-1-git-send-email-gilad@benyossef.com>
 <1502724094-23305-13-git-send-email-gilad@benyossef.com> <alpine.LRH.2.02.1708191605370.2380@file01.intranet.prod.int.rdu2.redhat.com>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Mon, 21 Aug 2017 15:48:05 +0300
Message-ID: <CAOtvUMdwH0u+1mOEJZxsgYCZ3mA-39_34bS+sCw8nMAX5bNXNQ@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH v5 12/19] dm: move dm-verity to generic async completion
Content-Type: text/plain; charset="UTF-8"
Sender: linux-crypto-owner@vger.kernel.org
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Aug 19, 2017 at 11:08 PM, Mikulas Patocka <mpatocka@redhat.com> wrote:
>
>
>
> On Mon, 14 Aug 2017, Gilad Ben-Yossef wrote:
>
> > dm-verity is starting async. crypto ops and waiting for them to complete.
> > Move it over to generic code doing the same.
> >
> > This also fixes a possible data coruption bug created by the
> > use of wait_for_completion_interruptible() without dealing
> > correctly with an interrupt aborting the wait prior to the
> > async op finishing.
>
> What is the exact problem there? The interruptible sleep is called from a
> workqueue and workqueues have all signals blocked. Are signals unblocked
> for some reason there?


I should have used "potential" rather then "possible". My bad.

My point was that the use of wait_for_completion_interruptible() is wrong
because we are not really ready to handle a signal *if* it arrives.

Yes, since we are being called from a workqueue this will not happen, but:

a. we (or rather I, since I wrote the offending code...) shouldn't call
*_interruptible() in a function that is executing with signals masked
unconditionally. It makes not sense.

b. someone might move the context this is executing in in the future, or make
some other change that will enable signals and create a very subtle bug.

>
>
> Should there be another patch for stable kernels that fixes the
> interruptible sleep?


No, for the reason you pointed yourself - signals are blocked here, so this
is a potential bug only but can't be triggered.

I already sent a patch set fixing similar places that had the
same issue and it went into stable - e.g.
https://patchwork.kernel.org/patch/9781693/

Thanks,
Gilad

>
>
> Mikulas
>
> > Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> > ---
> >  drivers/md/dm-verity-target.c | 81 +++++++++++--------------------------------
> >  drivers/md/dm-verity.h        |  5 ---
> >  2 files changed, 20 insertions(+), 66 deletions(-)
> >
> > diff --git a/drivers/md/dm-verity-target.c b/drivers/md/dm-verity-target.c
> > index 79f18d4..8df08a8 100644
> > --- a/drivers/md/dm-verity-target.c
> > +++ b/drivers/md/dm-verity-target.c
> > @@ -92,74 +92,33 @@ static sector_t verity_position_at_level(struct dm_verity *v, sector_t block,
> >       return block >> (level * v->hash_per_block_bits);
> >  }
> >
> > -/*
> > - * Callback function for asynchrnous crypto API completion notification
> > - */
> > -static void verity_op_done(struct crypto_async_request *base, int err)
> > -{
> > -     struct verity_result *res = (struct verity_result *)base->data;
> > -
> > -     if (err == -EINPROGRESS)
> > -             return;
> > -
> > -     res->err = err;
> > -     complete(&res->completion);
> > -}
> > -
> > -/*
> > - * Wait for async crypto API callback
> > - */
> > -static inline int verity_complete_op(struct verity_result *res, int ret)
> > -{
> > -     switch (ret) {
> > -     case 0:
> > -             break;
> > -
> > -     case -EINPROGRESS:
> > -     case -EBUSY:
> > -             ret = wait_for_completion_interruptible(&res->completion);
> > -             if (!ret)
> > -                     ret = res->err;
> > -             reinit_completion(&res->completion);
> > -             break;
> > -
> > -     default:
> > -             DMERR("verity_wait_hash: crypto op submission failed: %d", ret);
> > -     }
> > -
> > -     if (unlikely(ret < 0))
> > -             DMERR("verity_wait_hash: crypto op failed: %d", ret);
> > -
> > -     return ret;
> > -}
> > -
> >  static int verity_hash_update(struct dm_verity *v, struct ahash_request *req,
> >                               const u8 *data, size_t len,
> > -                             struct verity_result *res)
> > +                             struct crypto_wait *wait)
> >  {
> >       struct scatterlist sg;
> >
> >       sg_init_one(&sg, data, len);
> >       ahash_request_set_crypt(req, &sg, NULL, len);
> >
> > -     return verity_complete_op(res, crypto_ahash_update(req));
> > +     return crypto_wait_req(crypto_ahash_update(req), wait);
> >  }
> >
> >  /*
> >   * Wrapper for crypto_ahash_init, which handles verity salting.
> >   */
> >  static int verity_hash_init(struct dm_verity *v, struct ahash_request *req,
> > -                             struct verity_result *res)
> > +                             struct crypto_wait *wait)
> >  {
> >       int r;
> >
> >       ahash_request_set_tfm(req, v->tfm);
> >       ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP |
> >                                       CRYPTO_TFM_REQ_MAY_BACKLOG,
> > -                                     verity_op_done, (void *)res);
> > -     init_completion(&res->completion);
> > +                                     crypto_req_done, (void *)wait);
> > +     crypto_init_wait(wait);
> >
> > -     r = verity_complete_op(res, crypto_ahash_init(req));
> > +     r = crypto_wait_req(crypto_ahash_init(req), wait);
> >
> >       if (unlikely(r < 0)) {
> >               DMERR("crypto_ahash_init failed: %d", r);
> > @@ -167,18 +126,18 @@ static int verity_hash_init(struct dm_verity *v, struct ahash_request *req,
> >       }
> >
> >       if (likely(v->salt_size && (v->version >= 1)))
> > -             r = verity_hash_update(v, req, v->salt, v->salt_size, res);
> > +             r = verity_hash_update(v, req, v->salt, v->salt_size, wait);
> >
> >       return r;
> >  }
> >
> >  static int verity_hash_final(struct dm_verity *v, struct ahash_request *req,
> > -                          u8 *digest, struct verity_result *res)
> > +                          u8 *digest, struct crypto_wait *wait)
> >  {
> >       int r;
> >
> >       if (unlikely(v->salt_size && (!v->version))) {
> > -             r = verity_hash_update(v, req, v->salt, v->salt_size, res);
> > +             r = verity_hash_update(v, req, v->salt, v->salt_size, wait);
> >
> >               if (r < 0) {
> >                       DMERR("verity_hash_final failed updating salt: %d", r);
> > @@ -187,7 +146,7 @@ static int verity_hash_final(struct dm_verity *v, struct ahash_request *req,
> >       }
> >
> >       ahash_request_set_crypt(req, NULL, digest, 0);
> > -     r = verity_complete_op(res, crypto_ahash_final(req));
> > +     r = crypto_wait_req(crypto_ahash_final(req), wait);
> >  out:
> >       return r;
> >  }
> > @@ -196,17 +155,17 @@ int verity_hash(struct dm_verity *v, struct ahash_request *req,
> >               const u8 *data, size_t len, u8 *digest)
> >  {
> >       int r;
> > -     struct verity_result res;
> > +     struct crypto_wait wait;
> >
> > -     r = verity_hash_init(v, req, &res);
> > +     r = verity_hash_init(v, req, &wait);
> >       if (unlikely(r < 0))
> >               goto out;
> >
> > -     r = verity_hash_update(v, req, data, len, &res);
> > +     r = verity_hash_update(v, req, data, len, &wait);
> >       if (unlikely(r < 0))
> >               goto out;
> >
> > -     r = verity_hash_final(v, req, digest, &res);
> > +     r = verity_hash_final(v, req, digest, &wait);
> >
> >  out:
> >       return r;
> > @@ -389,7 +348,7 @@ int verity_hash_for_block(struct dm_verity *v, struct dm_verity_io *io,
> >   * Calculates the digest for the given bio
> >   */
> >  int verity_for_io_block(struct dm_verity *v, struct dm_verity_io *io,
> > -                     struct bvec_iter *iter, struct verity_result *res)
> > +                     struct bvec_iter *iter, struct crypto_wait *wait)
> >  {
> >       unsigned int todo = 1 << v->data_dev_block_bits;
> >       struct bio *bio = dm_bio_from_per_bio_data(io, v->ti->per_io_data_size);
> > @@ -414,7 +373,7 @@ int verity_for_io_block(struct dm_verity *v, struct dm_verity_io *io,
> >                */
> >               sg_set_page(&sg, bv.bv_page, len, bv.bv_offset);
> >               ahash_request_set_crypt(req, &sg, NULL, len);
> > -             r = verity_complete_op(res, crypto_ahash_update(req));
> > +             r = crypto_wait_req(crypto_ahash_update(req), wait);
> >
> >               if (unlikely(r < 0)) {
> >                       DMERR("verity_for_io_block crypto op failed: %d", r);
> > @@ -482,7 +441,7 @@ static int verity_verify_io(struct dm_verity_io *io)
> >       struct dm_verity *v = io->v;
> >       struct bvec_iter start;
> >       unsigned b;
> > -     struct verity_result res;
> > +     struct crypto_wait wait;
> >
> >       for (b = 0; b < io->n_blocks; b++) {
> >               int r;
> > @@ -507,17 +466,17 @@ static int verity_verify_io(struct dm_verity_io *io)
> >                       continue;
> >               }
> >
> > -             r = verity_hash_init(v, req, &res);
> > +             r = verity_hash_init(v, req, &wait);
> >               if (unlikely(r < 0))
> >                       return r;
> >
> >               start = io->iter;
> > -             r = verity_for_io_block(v, io, &io->iter, &res);
> > +             r = verity_for_io_block(v, io, &io->iter, &wait);
> >               if (unlikely(r < 0))
> >                       return r;
> >
> >               r = verity_hash_final(v, req, verity_io_real_digest(v, io),
> > -                                     &res);
> > +                                     &wait);
> >               if (unlikely(r < 0))
> >                       return r;
> >
> > diff --git a/drivers/md/dm-verity.h b/drivers/md/dm-verity.h
> > index a59e0ad..b675bc0 100644
> > --- a/drivers/md/dm-verity.h
> > +++ b/drivers/md/dm-verity.h
> > @@ -90,11 +90,6 @@ struct dm_verity_io {
> >        */
> >  };
> >
> > -struct verity_result {
> > -     struct completion completion;
> > -     int err;
> > -};
> > -
> >  static inline struct ahash_request *verity_io_hash_req(struct dm_verity *v,
> >                                                    struct dm_verity_io *io)
> >  {
> > --
> > 2.1.4
> >
> > --
> > dm-devel mailing list
> > dm-devel@redhat.com
> > https://www.redhat.com/mailman/listinfo/dm-devel
> >




-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
