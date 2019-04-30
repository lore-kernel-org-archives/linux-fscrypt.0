Return-Path: <SRS0=OaQ0=TA=infradead.org=willy@kernel.org>
Date: Mon, 29 Apr 2019 17:27:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH V2 00/13] Consolidate FS read I/O callbacks code
Message-ID: <20190430002751.GB13796@bombadil.infradead.org>
References: <20190428043121.30925-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190428043121.30925-1-chandan@linux.ibm.com>
To: Chandan Rajendra <chandan@linux.ibm.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Apr 28, 2019 at 10:01:08AM +0530, Chandan Rajendra wrote:
> With these changes in place, the patchset changes Ext4 to use
> mpage_readpage[s] instead of its own custom ext4_readpage[s]()
> functions. This is done to reduce duplicity of code across

FYI, "duplicity" means "lying".  You meant "duplication".
