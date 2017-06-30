Return-Path: <linux-fsdevel-owner@vger.kernel.org>
From: Richard Weinberger <richard@nod.at>
Subject: fscrypt request_module() deadlock
Message-ID: <3450b67a-6766-d24e-5a84-18fff64d1b73@nod.at>
Date: Fri, 30 Jun 2017 17:27:34 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: linux-fsdevel-owner@vger.kernel.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, David Gstir <david@sigma-star.at>, herbert@gondor.apana.org.au
List-ID: <linux-fscrypt@vger.kernel.org>

Hi!

David and I faced a deadlock with switch_root when fscrypt was in use.
When /sbin/modprobe is encrypted using fscrypt and no other kernel component
requested an AES cipher before, first access to an encrypted file will trigger the
module_request() function, which will execute usermode helper /sbin/modprobe.
Is /sbin/modprobe also encrypted the kernel will deadlock because executing
it will again enter the module_request() path...

As workaround we currently do something like "ls /new_root > /dev/null" in our
initramfs to make request_module() happen before we change the root directory
to /new_root.

While this workaround is legit we think that this could be handled better.
Is there a way to request these ciphers before first usage? Herbert?
e.g. such that the filesystem can request them upon mount time.

Btw: This happens even when AES modules are builtins.

Thanks,
//richard
