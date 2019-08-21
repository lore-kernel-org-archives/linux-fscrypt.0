Return-Path: <SRS0=A8Az=WR=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: [PATCH 0/9] Flash Memory Protector Support
Date: Wed, 21 Aug 2019 15:42:06 +0900
Message-ID: <003c01d557eb$8ca76790$a5f636b0$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190821064206epcas2p1d1bcaae142416506bcedb3201d9a6658@epcas2p1.samsung.com>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>, "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'  <tytso@mit.edu>,  'Chao Yu'  <chao@kernel.org>,  'Jaegeuk Kim' " <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>'Theodore Ts'o' <tytso@mit.edu>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, "'Ulf Hansson'  <ulf.hansson@linaro.org>, <linux-crypto@vger.kernel.org>," <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.netlinux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Exynos has a H/W block called FMP (Flash Memory Protector) to protect data
stored on storage device.
FMP interworks with the storage controller to encrypt a data before writing
to the storage device and decrypt the data after reading from storage
device.
FMP is a kind of ICE (inline crypto engines), which is generally known
as being used for the above role.

To use FMP, the modification of various layers such as Fscrypt, ext4, f2fs,
DM-crypt, storage controller driver and block is required.
FMP solution introduces a new diskcipher similar to the existing skcipher
in crypo API in order to minimize the modification of these layers and
to improve the code readability.

This patchset includes the following for using FMP:
- Diskcipher and FMP are added to crypto API.
- The crypto users such as dm-crypt and fscrypt are modified to support
  diskcipher.
- The bio submitters such as f2fs, ext4, dm-crypt are modified to support
  diskcipher.
- Block layer is modified to pass diskcipher to storage controller driver.
- Storage controller driver is modified to support crypto operation.

Exynos FMP solution consists of Diskcipher and FMP driver.
Diskcipher is a symmetric key cipher of crypto API that supports inline
crypto engine like FMP.
FMP driver is a cipher algorithm running on diskcipher.
FMP driver registers 'cbc(aes)-disk' and 'xts(aes)-disk' algorithms to
crypto API.
FMP can be tested with various test vectors in testmgr of crypto API.

When encrypting using FMP, additional control is required to deliver and
manage encryption information between encryption users (fscrypt, DM-crypt)
and FMP drivers. Diskcipher provides this control.

The encryption using FMP is made up of 4 steps.
The first step is to assign a password and set a key.
Encryption users such as Fscrypt or DM-crypt assign diskcipher, and set key
to the diskcipher.
The second step is to deliver diskcipher that has crypto information to
storage drivers such as UFS and MMC. BIO is used to this delivery.
The BIO submitters, such as ext4, f2fs and DM-crypt, checks if there is
diskcipher in crypto configuration before issuing BIO. If there are
diskcipher, the submitter sets it to BIO.
In addition, the BIO submitter skips the task of encrypting data before BIO
and decrypting data after BIO is completed.
In the third step, the storage driver gets the diskcipher from the BIO and
requests the FMP to encrypt.
In the final step, the FMP extracts crypto information from the diskcipher
and writes it in the descriptor area allocated for FMP H/W.
The FMP H/W uses the descriptor of the storage controller to contain crypto
information. So the descriptor of storage controller should be expanded
for FMP.

Boojin Kim (9):
  crypt: Add diskcipher
  crypto: fmp: add Flash Memory Protector driver
  mmc: dw_mmc: support crypto operation
  mmc: dw_mmc-exynos: support FMP
  block: support diskcipher
  dm crypt: support diskcipher
  fscrypt: support diskcipher
  fs: ext4: support diskcipher
  fs: f2fs: support diskcipher

 block/bio.c                      |   1 +
 block/blk-merge.c                |  19 +-
 block/bounce.c                   |   5 +-
 crypto/Kconfig                   |   9 +
 crypto/Makefile                  |   1 +
 crypto/diskcipher.c              | 349 +++++++++++++++++++++++
 crypto/testmgr.c                 | 157 +++++++++++
 drivers/crypto/Kconfig           |   2 +
 drivers/crypto/Makefile          |   1 +
 drivers/crypto/fmp/Kconfig       |  13 +
 drivers/crypto/fmp/Makefile      |   1 +
 drivers/crypto/fmp/fmp.c         | 595
+++++++++++++++++++++++++++++++++++++++
 drivers/crypto/fmp/fmp_crypt.c   | 243 ++++++++++++++++
 drivers/crypto/fmp/fmp_test.c    | 310 ++++++++++++++++++++
 drivers/crypto/fmp/fmp_test.h    |  30 ++
 drivers/md/dm-crypt.c            | 112 +++++++-
 drivers/mmc/host/Kconfig         |   8 +
 drivers/mmc/host/dw_mmc-exynos.c |  62 ++++
 drivers/mmc/host/dw_mmc.c        |  48 +++-
 drivers/mmc/host/dw_mmc.h        |   6 +
 fs/buffer.c                      |   2 +
 fs/crypto/bio.c                  |  43 ++-
 fs/crypto/fscrypt_private.h      |  28 +-
 fs/crypto/keysetup.c             |  60 +++-
 fs/crypto/keysetup_v1.c          |   2 +-
 fs/ext4/inode.c                  |  39 ++-
 fs/ext4/page-io.c                |   8 +-
 fs/ext4/readpage.c               |   7 +
 fs/f2fs/data.c                   |  98 ++++++-
 fs/f2fs/f2fs.h                   |   2 +-
 include/crypto/diskcipher.h      | 245 ++++++++++++++++
 include/crypto/fmp.h             | 324 +++++++++++++++++++++
 include/linux/bio.h              |  10 +
 include/linux/blk_types.h        |   4 +
 include/linux/bvec.h             |   3 +
 include/linux/crypto.h           |   1 +
 include/linux/fscrypt.h          |  19 ++
 include/uapi/linux/fscrypt.h     |   2 +
 tools/include/uapi/linux/fs.h    |   1 +
 39 files changed, 2837 insertions(+), 33 deletions(-)
 create mode 100644 crypto/diskcipher.c
 create mode 100644 drivers/crypto/fmp/Kconfig
 create mode 100644 drivers/crypto/fmp/Makefile
 create mode 100644 drivers/crypto/fmp/fmp.c
 create mode 100644 drivers/crypto/fmp/fmp_crypt.c
 create mode 100644 drivers/crypto/fmp/fmp_test.c
 create mode 100644 drivers/crypto/fmp/fmp_test.h
 create mode 100644 include/crypto/diskcipher.h
 create mode 100644 include/crypto/fmp.h

-- 
2.7.4
