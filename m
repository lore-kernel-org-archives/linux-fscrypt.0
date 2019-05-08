Return-Path: <sashal@kernel.org>
Date: Wed, 08 May 2019 15:56:03 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH V2] fscrypt: don't set policy for a dead directory
In-Reply-To: <1557307654-673-1-git-send-email-hongjiefang@asrmicro.com>
References: <1557307654-673-1-git-send-email-hongjiefang@asrmicro.com>
Message-Id: <20190508155604.1B59820989@mail.kernel.org>
To: Sasha Levin <sashal@kernel.org>, hongjiefang <hongjiefang@asrmicro.com>, tytso@mit.edu, jaegeuk@kernel.org, ebiggers@kernel.org
Cc: linux-fscrypt@vger.kernel.org, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 9bd8212f981e ext4 crypto: add encryption policy and password salt support.

The bot has tested the following trees: v5.0.13, v4.19.40, v4.14.116, v4.9.173, v4.4.179.

v5.0.13: Build OK!
v4.19.40: Build OK!
v4.14.116: Build OK!
v4.9.173: Failed to apply! Possible dependencies:
    Unable to calculate

v4.4.179: Failed to apply! Possible dependencies:
    002ced4be642 ("fscrypto: only allow setting encryption policy on directories")
    0b81d0779072 ("fs crypto: move per-file encryption from f2fs tree to fs/crypto")
    0cab80ee0c9e ("f2fs: fix to convert inline inode in ->setattr")
    0fac2d501b0d ("f2fs crypto: fix spelling typo in comment")
    0fd785eb931d ("f2fs: relocate is_merged_page")
    1dafa51d45c6 ("f2fs crypto: check for too-short encrypted file names")
    36b35a0dbe90 ("f2fs: support data flush in background")
    55d1cdb25a81 ("f2fs: relocate tracepoint of write_checkpoint")
    6b2553918d8b ("replace ->follow_link() with new method that could stay in RCU mode")
    6beceb5427aa ("f2fs: introduce time and interval facility")
    8dc0d6a11e7d ("f2fs: early check broken symlink length in the encrypted case")
    922ec355f863 ("f2fs crypto: avoid unneeded memory allocation when {en/de}crypting symlink")
    9e8925b67a80 ("locks: Allow disabling mandatory locking at compile time")
    a263669fa18f ("f2fs crypto: sync with ext4's fname padding")
    ae1086686487 ("f2fs crypto: handle unexpected lack of encryption keys")
    b9d777b85ff1 ("f2fs: check inline_data flag at converting time")
    ce855a3bd092 ("f2fs crypto: f2fs_page_crypto() doesn't need a encryption context")
    d0239e1bf520 ("f2fs: detect idle time depending on user behavior")
    d323d005ac4a ("f2fs: support file defragment")
    dffd0cfa06d4 ("fscrypt: use ENOTDIR when setting encryption policy on nondirectory")
    ed3360abbc04 ("f2fs crypto: make sure the encryption info is initialized on opendir(2)")


How should we proceed with this patch?

--
Thanks,
Sasha
