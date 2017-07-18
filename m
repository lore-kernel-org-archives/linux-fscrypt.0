Return-Path: <ebiggers3@gmail.com>
Date: Tue, 18 Jul 2017 16:17:47 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: fscrypt request_module() deadlock
Message-ID: <20170718231747.GA51535@gmail.com>
References: <3450b67a-6766-d24e-5a84-18fff64d1b73@nod.at>
 <20170718061351.GD4764@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170718061351.GD4764@gondor.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Richard Weinberger <richard@nod.at>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, David Gstir <david@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jul 18, 2017 at 02:13:51PM +0800, Herbert Xu wrote:
> On Fri, Jun 30, 2017 at 05:27:34PM +0200, Richard Weinberger wrote:
> > Hi!
> > 
> > David and I faced a deadlock with switch_root when fscrypt was in use.
> > When /sbin/modprobe is encrypted using fscrypt and no other kernel component
> > requested an AES cipher before, first access to an encrypted file will trigger the
> > module_request() function, which will execute usermode helper /sbin/modprobe.
> > Is /sbin/modprobe also encrypted the kernel will deadlock because executing
> > it will again enter the module_request() path...
> > 
> > As workaround we currently do something like "ls /new_root > /dev/null" in our
> > initramfs to make request_module() happen before we change the root directory
> > to /new_root.
> > 
> > While this workaround is legit we think that this could be handled better.
> > Is there a way to request these ciphers before first usage? Herbert?
> > e.g. such that the filesystem can request them upon mount time.
> > 
> > Btw: This happens even when AES modules are builtins.
> 
> I think you're running into the problem because of templates, where
> the first instantiation will always be preceded by a request_module.
> 
> We should be able to fix this by doing two template probes instead
> of one.  So instead of the current order:
> 
> 1. Look up registered algorithms.
> 2. Request module.
> 3. Find templates (may request module).
> 
> We can do
> 
> 1. Look up registered algorithms.
> 2. Find templates without loading modules.
> 3. Request module.
> 4. Find templates (may request module).
> 

While that should solve the problem, isn't it possible to actually have a module
which supplies an algorithm like "xts(aes)"?  In that case it wouldn't be
desirable to instantiate the generic "xts" template.

Eric
