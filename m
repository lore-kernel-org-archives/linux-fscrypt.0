Return-Path: <anand.jain@oracle.com>
From: Anand Jain <anand.jain@oracle.com>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
References: <20170818194730.61575-1-ebiggers3@gmail.com>
Message-ID: <9dcef6c6-a758-ea57-0d51-55f33e365931@oracle.com>
Date: Mon, 21 Aug 2017 21:44:11 +0800
MIME-Version: 1.0
In-Reply-To: <20170818194730.61575-1-ebiggers3@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>



> +fscrypt is not guaranteed to protect confidentiality or authenticity
> +if an attacker is able to manipulate the filesystem offline prior to
> +an authorized user later accessing the filesystem.

  How does fscrypt / Android protect against Evil Maid attack. ?

Thanks, Anand
