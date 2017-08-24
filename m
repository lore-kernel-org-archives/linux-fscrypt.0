Return-Path: <linux-crypto-owner@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <201708242036.ODpqdw7q%fengguang.wu@intel.com>
References: <1503324309-13673-5-git-send-email-gilad@benyossef.com> <201708242036.ODpqdw7q%fengguang.wu@intel.com>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Thu, 24 Aug 2017 16:25:14 +0300
Message-ID: <CAOtvUMcJXyupc1N+wRRfJNWwS2P9V36J0_eYHLbdDtj4kWaYxw@mail.gmail.com>
Subject: Re: [PATCH v6 04/19] crypto: marvell/cesa: remove redundant backlog
 checks on EBUSY
Content-Type: text/plain; charset="UTF-8"
Sender: linux-crypto-owner@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Aug 24, 2017 at 4:01 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Gilad,
>
> [auto build test ERROR on cryptodev/master]
> [also build test ERROR on v4.13-rc6 next-20170823]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Gilad-Ben-Yossef/crypto-change-transient-busy-return-code-to-EAGAIN/20170824-180606
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/herbert/cryptodev-2.6.git master
> config: arm-allmodconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm
>
> All error/warnings (new ones prefixed by >>):
>
>    drivers/crypto/marvell/cesa.c: In function 'mv_cesa_queue_req':
>>> drivers/crypto/marvell/cesa.c:187:3: error: expected ')' before 'mv_cesa_tdma_chain'
>       mv_cesa_tdma_chain(engine, creq);
>       ^~~~~~~~~~~~~~~~~~
>>> drivers/crypto/marvell/cesa.c:196:1: error: expected expression before '}' token
>     }
>     ^
>>> drivers/crypto/marvell/cesa.c:196:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^

Oy! I thought I've added COMPILE_TEST to my local tree to build it. I didn't.

Fix underway.

Gilad

-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
