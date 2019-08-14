Date: Wed, 14 Aug 2019 15:30:11 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fscrypt: clean up base64 encoding/decoding
Message-ID: <20190814223011.GC101319@gmail.com>
References: <20190724194606.40483-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724194606.40483-1-ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jul 24, 2019 at 12:46:06PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Some minor cleanups for the code that base64 encodes and decodes
> encrypted filenames and long name digests:
> 
> - Rename "digest_{encode,decode}()" => "base64_{encode,decode}()" since
>   they are used for filenames too, not just for long name digests.
> - Replace 'while' loops with more conventional 'for' loops.
> - Use 'u8' for binary data.  Keep 'char' for string data.
> - Fully constify the lookup table (pointer was not const).
> - Improve comment.
> 
> No actual change in behavior.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied to fscrypt tree for 5.4.

- Eric
