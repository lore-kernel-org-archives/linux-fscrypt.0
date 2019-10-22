Return-Path: <SRS0=svGF=YP=sifive.com=paul.walmsley@kernel.org>
Date: Mon, 21 Oct 2019 18:23:11 -0700 (PDT)
From: Paul Walmsley <paul.walmsley@sifive.com>
Subject: Re: arch/riscv doesn't support xchg() on bool
In-Reply-To: <20191021204026.GE122863@gmail.com>
Message-ID: <alpine.DEB.2.21.9999.1910211744450.28831@viisi.sifive.com>
References: <20191021204026.GE122863@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On Mon, 21 Oct 2019, Eric Biggers wrote:

> The kbuild test robot reported a build error on RISC-V in this patch:
> 
> 	https://patchwork.kernel.org/patch/11182389/
> 
> ... because of the line:
> 
> 	if (!xchg(&mode->logged_impl_name, true)) {
> 
> where logged_impl_name is a 'bool'.  The problem is that unlike most (or 
> all?) other kernel architectures, arch/riscv/ doesn't support xchg() on 
> bytes.

When I looked at this in August, it looked like several Linux other 
architectures - SPARC, Microblaze, C-SKY, and Hexagon - also didn't 
support xchg() on anything other than 32-bit types:

https://lore.kernel.org/lkml/alpine.DEB.2.21.9999.1908161931110.32497@viisi.sifive.com/

Examples:

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/sparc/include/asm/cmpxchg_32.h#n18

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/sparc/include/asm/cmpxchg_32.h#n41

> Is there any chance this could be implemented, to avoid this
> architecture-specific quirk?

It is certainly possible.  I wonder whether it is wise.  Several of the 
other architectures implement a software workaround for this operation, 
and I guess you're advocating that we do the same.  We could copy one 
these implementations.  However, the workarounds balloon into quite a lot 
of code.  Here is an example from MIPS:

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/mips/kernel/cmpxchg.c#n10

I could be wrong, but I think this expansion would be pretty surprising 
for most users of xchg().  I suspect most xchg() users are looking for 
something performant, and would be better served by simply using a 
variable with a 32-bit type.

In the case of your patch, it appears that struct 
fscrypt_mode.logged_impl_name is only used in the patched function.  It 
looks like it could be promoted into a u32 without much difficulty.  
Would you be willing to consider that approach of solving the problem?  
Then the code would be able to take advantage of the fast hardware 
implementation that's available on many architectures (including RISC-V).

> Note, there's at least one other place in the kernel that also uses 
> xchg() on a bool.

Given the nasty compatibility code, I wonder if we'd be better served by 
removing most of this compatibility code across the kernel, and just 
requiring callers to use a 32-bit type?  For most callers that I've seen, 
this doesn't seem to be much of an issue; and it would avoid the nasty 
code involved in software emulations of xchg().


- Paul
