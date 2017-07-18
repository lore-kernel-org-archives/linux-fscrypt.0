Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:50846 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbdGRGOU (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 18 Jul 2017 02:14:20 -0400
Date: Tue, 18 Jul 2017 14:13:51 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: fscrypt request_module() deadlock
Message-ID: <20170718061351.GD4764@gondor.apana.org.au>
References: <3450b67a-6766-d24e-5a84-18fff64d1b73@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3450b67a-6766-d24e-5a84-18fff64d1b73@nod.at>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, David Gstir <david@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jun 30, 2017 at 05:27:34PM +0200, Richard Weinberger wrote:
> Hi!
> 
> David and I faced a deadlock with switch_root when fscrypt was in use.
> When /sbin/modprobe is encrypted using fscrypt and no other kernel component
> requested an AES cipher before, first access to an encrypted file will trigger the
> module_request() function, which will execute usermode helper /sbin/modprobe.
> Is /sbin/modprobe also encrypted the kernel will deadlock because executing
> it will again enter the module_request() path...
> 
> As workaround we currently do something like "ls /new_root > /dev/null" in our
> initramfs to make request_module() happen before we change the root directory
> to /new_root.
> 
> While this workaround is legit we think that this could be handled better.
> Is there a way to request these ciphers before first usage? Herbert?
> e.g. such that the filesystem can request them upon mount time.
> 
> Btw: This happens even when AES modules are builtins.

I think you're running into the problem because of templates, where
the first instantiation will always be preceded by a request_module.

We should be able to fix this by doing two template probes instead
of one.  So instead of the current order:

1. Look up registered algorithms.
2. Request module.
3. Find templates (may request module).

We can do

1. Look up registered algorithms.
2. Find templates without loading modules.
3. Request module.
4. Find templates (may request module).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
