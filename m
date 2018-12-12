Return-Path: <SRS0=xCEI=OV=thunk.org=tytso@kernel.org>
Date: Tue, 11 Dec 2018 21:55:25 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [BUG BISECT next] Files cannot be opened after "fsverity: Move
 verity status check to fsverity_file_open"
Message-ID: <20181212025525.GF4464@thunk.org>
References: <CAJKOXPdNS+Qs6t1GwrgYhWT5EbtORJwYMzSrDPf8oAxv7ndNBg@mail.gmail.com>
 <20181211222721.GC4464@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211222721.GC4464@thunk.org>
To: Krzysztof Kozlowski <krzk@kernel.org>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, Eric Biggers <ebiggers@kernel.org>, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The fscrypt.git tree has been updated with for the problem.  Apologies
for not testing the !CONFIG_FS_VERITY case.

							- Ted
