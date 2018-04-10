Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from lilium.sigma-star.at ([109.75.188.150]:38608 "EHLO
        lilium.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752314AbeDJIS4 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 10 Apr 2018 04:18:56 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [RFC] UBIFS authentication
From: David Gstir <david@sigma-star.at>
In-Reply-To: <20180410070210.4chxbjlijoohpo5c@pengutronix.de>
Date: Tue, 10 Apr 2018 10:18:51 +0200
Content-Transfer-Encoding: 8BIT
Message-Id: <53E660CA-9F26-40C6-9C37-652F847BC737@sigma-star.at>
References: <E6D3BD02-AF3A-4B75-92FD-A8A07B4C9C51@sigma-star.at>
 <20180409095912.f7d35y7yjdnj2ffz@pengutronix.de>
 <9EEA8AD6-E46F-45B7-8A85-98E4CC82B1D3@sigma-star.at>
 <20180410070210.4chxbjlijoohpo5c@pengutronix.de>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, Richard Weinberger <richard@nod.at>, linux-kernel@vger.kernel.org, kernel@pengutronix.de
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Sascha,

> On 10.04.2018, at 09:02, Sascha Hauer <s.hauer@pengutronix.de> wrote:
> 
> On Mon, Apr 09, 2018 at 05:23:05PM +0200, David Gstir wrote:
>> Hi Sascha,
>> 
>>> On 09.04.2018, at 11:59, Sascha Hauer <s.hauer@pengutronix.de> wrote:
>>> 
>>> Hi David,
>>> 
>>> On Wed, Jan 17, 2018 at 04:19:14PM +0100, David Gstir wrote:
>>>> Hi everybody!
>>>> 
>>>> ### Index Authentication
>>>> 
>>>> Through UBIFS' concept of a wandering tree, it already takes care of only
>>>> updating and persisting changed parts from leaf node up to the root node
>>>> of the full B+ tree. This enables us to augment the index nodes of the tree
>>>> with a hash over each node's child nodes. As a result, the index basically also
>>>> a Merkle tree. Since the leaf nodes of the index contain the actual filesystem
>>>> data, the hashes of their parent index nodes thus cover all the file contents
>>>> and file metadata. When a file changes, the UBIFS index is updated accordingly
>>>> from the leaf nodes up to the root node including the master node. This process
>>>> can be hooked to recompute the hash only for each changed node at the same time.
>>>> Whenever a file is read, UBIFS can verify the hashes from each leaf node up to
>>>> the root node to ensure the node's integrity.
>>>> 
>>>> To ensure the authenticity of the whole index, the UBIFS master node stores a
>>>> keyed hash (HMAC) over its own contents (which includes the location of the root
>>>> node) and the root node of the index tree. As mentioned above, the master node
>>>> is always written to the flash whenever the index is persisted (ie. on index
>>>> commit).
>>>> 
>>>> Using this approach only UBIFS index nodes and the master node are changed to
>>>> include a hash. All other types of nodes will remain unchanged. This reduces
>>>> the storage overhead which is precious for users of UBIFS (ie. embedded
>>>> devices).
>>>> 
>>>> 
>>>>                                           HMAC Master Node
>>>>                                                |
>>>>                     ' ' ' ' ' ' ' ' ' ' ' ' ' '|' '
>>>>                     '     +---------------+    o  '
>>>>                     '     |  Master Node  |       '
>>>>                     '     +---------------+       '       Hash Index Node #1
>>>>                     '             |               '                |
>>>>      . . . . . . . .'. . . . . .  v . . . . . . . . . . . . . . . .|. . . . .
>>>>      .              '      +---------------+      '                o        .
>>>>      .              '      | Index Node #1 |      '                         .
>>>>      .              '      +---------------+      '                         .
>>>>      .              '        |    ...   |  (fanout: 8)                      .
>>>>      .              ' ' ' '  | ' ' ' '  | ' ' ' ' '                         .
>>>>      .               +-------+          +------+                            .
>>>>      .               |                         |                            .
>>>>      .     ' ' ' ' ' v ' ' ' ' '  ' ' ' ' ' '  v  ' ' ' ' ' ' ' ' ' ' '     .
>>>>      .     ' +---------------+ '  '     +---------------+             '     .
>>>>      .     ' | Index Node #2 | '  '     | Index Node #3 |             '     .
>>>>      .     ' +---------------+ '  '     +---------------+             '     .
>>>>      .     '   |   ...         '  '        |   ...   |                '     .
>>>>      . . . ' . v . . . . . . . '. ' . . .  v . . . . v . . . . . . . .' . . .
>>>>            ' +-----------+     '  '+----------+  +-----------+        '
>>>>            ' | Data Node |     '  '| INO Node |  | DENT Node |        '
>>>>            ' +-----------+     '  '+----------+  +-----------+        '
>>>>            '  o                '  '                                o  '
>>>>            ' '|' ' ' ' ' ' ' ' '  ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '|' '
>>>>               |                                                    |
>>>>         Hash Index Node #2                                Hash Index Node #3
>>> 
>>> When a hash covers an index node and also its children then of course
>>> this is really space efficient, but this also means that in order to
>>> read a node we always have to read all of its children. Also adding a
>>> new leaf node means rehashing all siblings. Is it really worth paying
>>> this price to save a few bytes for more hashes?
>>> I would rather suggest to add a hash per child to each index node.
>> 
>> What you propose is a simple tradeoff between the required on-flash storage
>> space and the amount of read operations needed to verify the index node integrity.
>> 
>> To get some numbers here: In case of SHA256 and a fanout of 8, we'd store an
>> additional 224 bytes per index node and safe 7 index node reads per tree level.
> 
> To get some more numbers I analyzed some typical rootfs here. It has:
> 
> 16137 data nodes with total size 41802586
> uncompressed data size:          62380950
> 2116 inode nodes with total size   347042
> 2115 dent nodes with total size    148790
> 2911 idx nodes with total size     547068
> Total number of branches: 23278
> 
> With a SHA256 per branch this would add another 744896 bytes or 1.7%
> overhead to the image (1.1% if using the uncompressed data size as base).

Yes, that matches my calculations. But IMHO these 1.7% matter and
we should not give them up that easily.



>> I hope it is clear that having a single hash does _not_ mean we have to read
>> the whole tree! :)
>> 
>> Considering that UBIFS is mostly used in embedded where storage space is rather
>> precious, we opted for storing a single hash. But sure, storing a hash per
>> branch/child  is a possibility and we have to discuss if that is acceptable
>> in most use cases.
>> 
>> As for adding new leaf nodes: If we add a leaf node, we'll always have to recompute
>> the hash of every index node on the path to the root node. Even with a hash per
>> branch/child. In case of TNC split/merge operations likely even more.
>> But I don't get why you think that would mean we have to recompute the hash
>> on all siblings of that nodes? Or do you simply mean that we have to re-read all
>> those siblings to compute the hash on the parent?
> 
> I mean that before we can use the "DENT Node" in the picture above we
> also have to verify the "INO Node". To get there, we also have to verify
> the unrelated "Index Node #2". so in reality we have to verify
> seven unrelated leaf nodes and another seven unrelated nodes per tree
> level before we can use a node. When changing nodes we have to make sure
> all the unrelated nodes stay in memory or we have to read them back from
> the device. Of course, some of the unrelated nodes will be used anyway
> in the next few moments, nevertheless I can imagine we pay a significant
> performance penalty for this.

Are you sure about that? The UBIFS TNC will first of all try to cache as
much as possible and I'd argue that most of the time the nodes required
for a hash will already be in memory. Even if we have to load the nodes
from memory, we could consider changing the cache semantics of the TNC
to optimize for that. Richard did some tests related to this at the UBI
level [1]. But that is something that we will have to evaluate once
we have a first PoC implementation of UBIFS authentication.

Anyways, I get what you mean and I agree that this is surely an optimization
worth pursuing! Also, note that the whole thing is rather a concept instead
of a detailed implementation guide, so there are bound to be things that
can be optimized. :)


> read/write throughput is another very precious resource on embedded
> systems ;)

Yep! :D

Thanks,
David

[1] http://lists.infradead.org/pipermail/linux-mtd/2016-July/068521.html

