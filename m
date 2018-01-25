Return-Path: <linux-fsdevel-owner@vger.kernel.org>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC] UBIFS authentication
From: David Gstir <david@sigma-star.at>
In-Reply-To: <E6D3BD02-AF3A-4B75-92FD-A8A07B4C9C51@sigma-star.at>
Date: Thu, 25 Jan 2018 09:49:32 +0100
Content-Transfer-Encoding: 8BIT
Message-Id: <AF303146-8E37-48B2-B9DF-8C3193138EFA@sigma-star.at>
References: <E6D3BD02-AF3A-4B75-92FD-A8A07B4C9C51@sigma-star.at>
Sender: linux-fsdevel-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org
Cc: Richard Weinberger <richard@nod.at>, linux-kernel@vger.kernel.org, kernel@pengutronix.de
List-ID: <linux-fscrypt@vger.kernel.org>

Hi!

> On 17.01.2018, at 16:19, David Gstir <david@sigma-star.at> wrote:
> 
> Hi everybody!
> 
> Richard and I have been working on extending UBIFS' security features and came
> up with the following concept to add full file contents and metadata authentication.
> 
> For block devices like eMMCs dm-crypt and dm-verity/dm-integrity can be used to
> get full data confidentiality and authenticity, but for raw flash or more
> specifically UBIFS, existing options are not ideal:
> 
> One option is to use eCryptfs with some out-of-tree patches that add AEAD cipher
> (AES-GCM) support, but does not look like there was much progress recently [1].
> 
> Another option is to use IMA/EVM as described by Marc Kleine-Budde in his
> ELCE 2016 talk [2], but this just protects the file payload and some attributes
> and not the full filesystem data structures.
> 
> A short overview of existing options is also given here [3].
> 
> Due to the design of UBIFS it is actually a bit easier than on other filesystems
> to authenticate its data structures and ensure consistency of on-flash data.
> 
> I've attached the whitepaper below and also published it here [4].
> 
> Comments are welcome. :)

*ping*

Did anybody get a chance to look at this yet, or is everybody still busy with Meltdown and Spectre? ;D

Thanks,
David
