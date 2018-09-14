Return-Path: <SRS0=0t/i=L4=verbum.org=walters@kernel.org>
Message-Id: <1536930930.1003187.1508104496.6465C44D@webmail.messagingengine.com>
From: Colin Walters <walters@verbum.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
In-Reply-To: <20180825044852.GB726@sol.localdomain>
Date: Fri, 14 Sep 2018 09:15:30 -0400
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-2-ebiggers@kernel.org>
 <1535132549.2855027.1485213752.129E3334@webmail.messagingengine.com>
 <20180825044852.GB726@sol.localdomain>
Subject: Re: [RFC PATCH 01/10] fs-verity: add setup code, UAPI, and Kconfig
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Aug 25, 2018, at 12:48 AM, Eric Biggers wrote:
>
> As Ted pointed out, only truncates are denied on fs-verity files, not other
> metadata changes like chmod().
> 
> Think of it this way: the purpose of fs-verity is *not* to make files immutable.
> It's to hash them.

Sorry for my unfamiliarity with Android internals but - in earlier discussion
I believe it was mentioned that APK (zip files?) that are being targeted here, right?

Now AIUI, Zip files have an internal header that contains e.g. the size and
indexes into the internal files.  So if someone added random data to the end
of a zip file, nothing is going to end up actually reading it.

However, there are file formats that use the size of the file reported by stat();
at least OSTree does this with serializing GVariant.  I'm sure there are others -
I'd imagine at least some things parsing ELF do this?
In such a case, we really want to deny appending to the file as well.

Unless there's some mechanism to deny applications reading not-verified
data?

And "hidden" data after fs-verity protected files would be a nice place
for persistent malware to hide.

Does anyone know of a use case for appending to a fs-verity file?

The slides here:
https://events.linuxfoundation.org/wp-content/uploads/2017/11/fs-verify_Mike-Halcrow_Eric-Biggers.pdf
even say "File becomes read-only!"

If not, then here's a strawman: Require that at FS_IOC_ENABLE_VERITY time
the file does not have any +w bits set (and I guess no ACLs that do so...
that may get ugly).  

I think that would make it easier to later factor out a "_CONTENTS_IMMUTABLE"
flag.
