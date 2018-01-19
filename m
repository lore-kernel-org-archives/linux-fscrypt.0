Return-Path: <akpm@linux-foundation.org>
Date: Fri, 19 Jan 2018 13:53:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fs/crypto/hooks.c: fix build with pre-4.6 gcc versions
Message-Id: <20180119135348.57f9efad999c62d93b95f9fa@linux-foundation.org>
In-Reply-To: <20180119214524.222850-1-ebiggers3@gmail.com>
References: <20180119214524.222850-1-ebiggers3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 19 Jan 2018 13:45:24 -0800 Eric Biggers <ebiggers3@gmail.com> wrote:

> From: Eric Biggers <ebiggers@google.com>
> 
> gcc versions prior to 4.6 require an extra level of braces when using a
> designated initializer for a member in an anonymous struct or union.
> This caused a compile error with the 'struct qstr' initialization in
> __fscrypt_encrypt_symlink().
> 
> Fix it by using QSTR_INIT().
> 
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Fixes: 76e81d6d5048 ("fscrypt: new helper functions for ->symlink()")
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Tested-by: Andrew Morton <akpm@linux-foundation.org>
