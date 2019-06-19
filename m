Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wm1-f65.google.com ([209.85.128.65]:36390 "EHLO
        mail-wm1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725980AbfFSG4i (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 19 Jun 2019 02:56:38 -0400
Subject: Re: [PATCH v2 0/4] crypto: switch to crypto API for ESSIV generation
References: <20190618212749.8995-1-ard.biesheuvel@linaro.org>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <099346ee-af6e-a560-079d-3fb68fb4eeba@gmail.com>
Date: Wed, 19 Jun 2019 08:56:33 +0200
MIME-Version: 1.0
In-Reply-To: <20190618212749.8995-1-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-crypto@vger.kernel.org
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 18/06/2019 23:27, Ard Biesheuvel wrote:
> This series creates an ESSIV template that produces a skcipher or AEAD
> transform based on a tuple of the form '<skcipher>,<cipher>,<shash>'
> (or '<aead>,<cipher>,<shash>' for the AEAD case). It exposes the
> encapsulated sync or async skcipher/aead by passing through all operations,
> while using the cipher/shash pair to transform the input IV into an ESSIV
> output IV.
> 
> This matches what both users of ESSIV in the kernel do, and so it is proposed
> as a replacement for those, in patches #2 and #4.
> 
> This code has been tested using the fscrypt test suggested by Eric
> (generic/549), as well as the mode-test script suggested by Milan for
> the dm-crypt case. I also tested the aead case in a virtual machine,
> but it definitely needs some wider testing from the dm-crypt experts.

Well, I just run "make check" on cyptsetup upstream (32bit VM, Linus' tree
with this patcheset applied), and get this on the first api test...

Just try
cryptsetup open --type plain -c aes-cbc-essiv:sha256 /dev/sdd test

kernel: alg: No test for essiv(cbc(aes),aes,sha256) (essiv(cbc-aes-aesni,aes-aesni,sha256-generic))
kernel: BUG: unable to handle page fault for address: 00c14578
kernel: #PF: supervisor read access in kernel mode
kernel: #PF: error_code(0x0000) - not-present page
kernel: *pde = 00000000 
kernel: Oops: 0000 [#1] PREEMPT SMP
kernel: CPU: 2 PID: 15611 Comm: kworker/u17:2 Not tainted 5.2.0-rc5+ #519
kernel: Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
kernel: Workqueue: kcryptd/253:2 kcryptd_crypt [dm_crypt]
kernel: EIP: essiv_skcipher_decrypt+0x3/0x20
kernel: Code: 5f 5d c3 90 90 90 90 55 8b 48 0c 89 e5 8d 41 10 ff 51 18 5d c3 66 90 55 8b 40 0c 89 e5 ff 50 08 5d c3 8d 74 26 00 90 8b 50 58 <f6> 02 01 75 10 55 83 c0 38 89 e5 ff 52 f0 5d c3 8d 74 26 00 90 b8
kernel: EAX: ee87fc08 EBX: ee87fd40 ECX: ee87fdc4 EDX: 00c14578
kernel: ESI: ee87fb78 EDI: f0a70800 EBP: ef7a9ed8 ESP: ef7a9e3c
kernel: DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010246
kernel: CR0: 80050033 CR2: 00c14578 CR3: 01b87000 CR4: 00140690
kernel: Call Trace:
kernel:  ? crypt_convert+0x864/0xe50 [dm_crypt]
kernel:  ? static_obj+0x32/0x50
kernel:  ? lockdep_init_map+0x34/0x1b0
kernel:  ? __init_waitqueue_head+0x29/0x40
kernel:  kcryptd_crypt+0xca/0x3b0 [dm_crypt]
kernel:  ? process_one_work+0x1a6/0x5a0
kernel:  process_one_work+0x214/0x5a0
kernel:  worker_thread+0x134/0x3e0
kernel:  ? process_one_work+0x5a0/0x5a0
kernel:  kthread+0xd4/0x100
kernel:  ? process_one_work+0x5a0/0x5a0
kernel:  ? kthread_park+0x90/0x90
kernel:  ret_from_fork+0x19/0x24
kernel: Modules linked in: dm_zero dm_integrity async_xor xor async_tx dm_verity reed_solomon dm_bufio dm_crypt loop dm_mod pktcdvd crc32_pclmul crc32c_intel aesni_intel aes_i586 crypto_simd cryptd ata_piix
kernel: CR2: 0000000000c14578
kernel: ---[ end trace 8a651b067b7b6a10 ]---
kernel: EIP: essiv_skcipher_decrypt+0x3/0x20
kernel: Code: 5f 5d c3 90 90 90 90 55 8b 48 0c 89 e5 8d 41 10 ff 51 18 5d c3 66 90 55 8b 40 0c 89 e5 ff 50 08 5d c3 8d 74 26 00 90 8b 50 58 <f6> 02 01 75 10 55 83 c0 38 89 e5 ff 52 f0 5d c3 8d 74 26 00 90 b8
kernel: EAX: ee87fc08 EBX: ee87fd40 ECX: ee87fdc4 EDX: 00c14578
kernel: ESI: ee87fb78 EDI: f0a70800 EBP: ef7a9ed8 ESP: c1b8b45c
kernel: DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010246
kernel: CR0: 80050033 CR2: 00c14578 CR3: 01b87000 CR4: 00140690

Milan
