Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga06-in.huawei.com ([45.249.212.32]:33257 "EHLO huawei.com"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753911AbeDWDZg (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 22 Apr 2018 23:25:36 -0400
Subject: Re: [f2fs-dev] [PATCH v2 2/2] f2fs: refactor read path to allow
 multiple postprocessing steps
References: <20180418180948.152031-1-ebiggers@google.com>
 <20180418180948.152031-3-ebiggers@google.com>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <e317d735-22f7-60ec-ed5a-f78364705e2a@huawei.com>
Date: Mon, 23 Apr 2018 11:25:33 +0800
MIME-Version: 1.0
In-Reply-To: <20180418180948.152031-3-ebiggers@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Michael Halcrow <mhalcrow@google.com>, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 2018/4/19 2:09, Eric Biggers via Linux-f2fs-devel wrote:
> Currently f2fs's ->readpage() and ->readpages() assume that either the
> data undergoes no postprocessing, or decryption only.  But with
> fs-verity, there will be an additional authenticity verification step,
> and it may be needed either by itself, or combined with decryption.
> 
> To support this, store a 'struct bio_post_read_ctx' in ->bi_private
> which contains a work struct, a bitmask of postprocessing steps that are
> enabled, and an indicator of the current step.  The bio completion
> routine, if there was no I/O error, enqueues the first postprocessing
> step.  When that completes, it continues to the next step.  Pages that
> fail any postprocessing step have PageError set.  Once all steps have
> completed, pages without PageError set are set Uptodate, and all pages
> are unlocked.
> 
> Also replace f2fs_encrypted_file() with a new function
> f2fs_post_read_required() in places like direct I/O and garbage
> collection that really should be testing whether the file needs special
> I/O processing, not whether it is encrypted specifically.
> 
> This may also be useful for other future f2fs features such as
> compression.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>

Thanks,

