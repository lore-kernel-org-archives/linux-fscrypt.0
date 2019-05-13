Return-Path: <SRS0=U3GG=TN=nod.at=richard@kernel.org>
Date: Mon, 13 May 2019 23:39:04 +0200 (CEST)
From: Richard Weinberger <richard@nod.at>
Message-ID: <1886500245.56511.1557783544203.JavaMail.zimbra@nod.at>
In-Reply-To: <20190513195652.GB142816@gmail.com>
References: <20190326075232.11717-1-s.hauer@pengutronix.de> <20190326075232.11717-2-s.hauer@pengutronix.de> <20190508031954.GA26575@sol.localdomain> <1170873772.48849.1557298158182.JavaMail.zimbra@nod.at> <20190513195652.GB142816@gmail.com>
Subject: Re: [PATCH 1/2] ubifs: Remove #ifdef around CONFIG_FS_ENCRYPTION
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Eric Biggers <ebiggers@kernel.org>
Cc: Sascha Hauer <s.hauer@pengutronix.de>, linux-mtd <linux-mtd@lists.infradead.org>, linux-fscrypt <linux-fscrypt@vger.kernel.org>, tytso <tytso@mit.edu>, kernel <kernel@pengutronix.de>
List-ID: <linux-fscrypt@vger.kernel.org>

----- Urspr=C3=BCngliche Mail -----
> This was merged to mainline and it's still broken.  This breaks UBIFS enc=
ryption
> entirely, BTW.  Do you not run xfstests before sending pull requests?

The simple answer is, not this time because my Laptops' filesystem broke
and I was kind of busy with recovery.
The issue is known, we have a patch and fixup will be sent to Linus
very soon. Nobody got hurt.

Thanks,
//richard
