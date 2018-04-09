Return-Path: <linux-fsdevel-owner@vger.kernel.org>
Date: Mon, 9 Apr 2018 11:59:12 +0200
From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [RFC] UBIFS authentication
Message-ID: <20180409095912.f7d35y7yjdnj2ffz@pengutronix.de>
References: <E6D3BD02-AF3A-4B75-92FD-A8A07B4C9C51@sigma-star.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E6D3BD02-AF3A-4B75-92FD-A8A07B4C9C51@sigma-star.at>
Sender: linux-fsdevel-owner@vger.kernel.org
To: David Gstir <david@sigma-star.at>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, Richard Weinberger <richard@nod.at>, linux-kernel@vger.kernel.org, kernel@pengutronix.de
List-ID: <linux-fscrypt@vger.kernel.org>

Hi David,

On Wed, Jan 17, 2018 at 04:19:14PM +0100, David Gstir wrote:
> Hi everybody!
> 
> ### Index Authentication
> 
> Through UBIFS' concept of a wandering tree, it already takes care of only
> updating and persisting changed parts from leaf node up to the root node
> of the full B+ tree. This enables us to augment the index nodes of the tree
> with a hash over each node's child nodes. As a result, the index basically also
> a Merkle tree. Since the leaf nodes of the index contain the actual filesystem
> data, the hashes of their parent index nodes thus cover all the file contents
> and file metadata. When a file changes, the UBIFS index is updated accordingly
> from the leaf nodes up to the root node including the master node. This process
> can be hooked to recompute the hash only for each changed node at the same time.
> Whenever a file is read, UBIFS can verify the hashes from each leaf node up to
> the root node to ensure the node's integrity.
> 
> To ensure the authenticity of the whole index, the UBIFS master node stores a
> keyed hash (HMAC) over its own contents (which includes the location of the root
> node) and the root node of the index tree. As mentioned above, the master node
> is always written to the flash whenever the index is persisted (ie. on index
> commit).
> 
> Using this approach only UBIFS index nodes and the master node are changed to
> include a hash. All other types of nodes will remain unchanged. This reduces
> the storage overhead which is precious for users of UBIFS (ie. embedded
> devices).
> 
> 
>                                             HMAC Master Node
>                                                  |
>                       ' ' ' ' ' ' ' ' ' ' ' ' ' '|' '
>                       '     +---------------+    o  '
>                       '     |  Master Node  |       '
>                       '     +---------------+       '       Hash Index Node #1
>                       '             |               '                |
>        . . . . . . . .'. . . . . .  v . . . . . . . . . . . . . . . .|. . . . .
>        .              '      +---------------+      '                o        .
>        .              '      | Index Node #1 |      '                         .
>        .              '      +---------------+      '                         .
>        .              '        |    ...   |  (fanout: 8)                      .
>        .              ' ' ' '  | ' ' ' '  | ' ' ' ' '                         .
>        .               +-------+          +------+                            .
>        .               |                         |                            .
>        .     ' ' ' ' ' v ' ' ' ' '  ' ' ' ' ' '  v  ' ' ' ' ' ' ' ' ' ' '     .
>        .     ' +---------------+ '  '     +---------------+             '     .
>        .     ' | Index Node #2 | '  '     | Index Node #3 |             '     .
>        .     ' +---------------+ '  '     +---------------+             '     .
>        .     '   |   ...         '  '        |   ...   |                '     .
>        . . . ' . v . . . . . . . '. ' . . .  v . . . . v . . . . . . . .' . . .
>              ' +-----------+     '  '+----------+  +-----------+        '
>              ' | Data Node |     '  '| INO Node |  | DENT Node |        '
>              ' +-----------+     '  '+----------+  +-----------+        '
>              '  o                '  '                                o  '
>              ' '|' ' ' ' ' ' ' ' '  ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '|' '
>                 |                                                    |
>           Hash Index Node #2                                Hash Index Node #3

When a hash covers an index node and also its children then of course
this is really space efficient, but this also means that in order to
read a node we always have to read all of its children. Also adding a
new leaf node means rehashing all siblings. Is it really worth paying
this price to save a few bytes for more hashes?
I would rather suggest to add a hash per child to each index node.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
