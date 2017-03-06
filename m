Return-Path: <linux-ext4-owner@vger.kernel.org>
Date: Mon, 6 Mar 2017 00:58:27 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: New kvm-xfstests images uploaded
Message-ID: <20170306055827.omfoahfisn44l6bc@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-ext4-owner@vger.kernel.org
To: linux-fstests@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

I've uploaded a new kvm-xfstests image at:

https://www.kernel.org/pub/linux/kernel/people/tytso/kvm-xfstests

This has the latest xfstests, xfsprogs, and e2fsprogs update, as well
as changes to help debug problems in the journal_lazy patches:

e2fsprogs	v1.43.4-27-g686994eb (Fri, 3 Mar 2017 10:02:14 -0500)
fio		fio-2.17-1-g54441e7 (Wed, 18 Jan 2017 08:18:28 -0700)
quota		e0b6335 (Thu, 9 Feb 2017 11:55:45 +0100)
stress-ng	4ad62e1 (Mon, 27 Feb 2017 14:28:36 -0500)
xfsprogs	v4.10.0-rc1 (Wed, 15 Feb 2017 21:48:31 -0600)
xfstests-bld	032c8c3 (Fri, 3 Mar 2017 21:03:05 -0500)
xfstests	linux-v3.8-1414-g999e3f6 (Sun, 5 Mar 2017 19:11:35 -0500)

Also updated is the armhf_rootfs.tar.gz, and there is also a new
gce-xfstests test appliance image available as well.

Cheers,

					- Ted
