Received: from BN8PR05CU002.outbound.protection.outlook.com (mail-eastus2azon11011056.outbound.protection.outlook.com [52.101.57.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 721522FA0C6;
	Tue,  8 Sep 2026 02:56:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.57.56
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788836207; cv=fail; b=A7KtaeLeoHVw0XGN73CLkyanacZ8fC/+qQCUADFpNEz2lDfhCcX50RtG3y9eZQ6ZMO9wcMRx3vLVRsteeqY0pnXaijWYzEWd650QnJzlBJKGD7DBNdW8JWKB2K3pxCKxon3NhSg0Fezqt8R2quqWRRQyRir/jqtSXva4TY5mW2A=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788836207; c=relaxed/simple;
	bh=Ty8ogNj7wZxdWLgSnH0+9SZJOU9go05juWfxSGyaZuo=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=GpXNFUe4xLuNBIr760+e2lkTp8sfcYw4+qLvXMw2lSCUGfA5IlVZ5NrkpSoy5xRM0Xm4AZ20v/XLSqI7YlCpNwW+DkFg3sn5rTbp1wfUByuWZ8NNC/ZrrNp3p7FTsCqDHFh9kWyP7ARkgZRST2gJ7D7TG6ZdC919Tc6TIeaOiik=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=mMyNXtX1; arc=fail smtp.client-ip=52.101.57.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="mMyNXtX1"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=FVamF+vknjboiIu4xnKCF084W5+FT9kSpDVQtQzwNId0DZUrCqJdsWMJZCf16JM/eivC/a0DgZNbSXU0xLvCJRwSDYPkmD1Srt1OW7tkQIU+ApCzpVfMJh/rtQayrBffP1autmIIngLEkufmUarGnzR8mpxHKkC+KEOqOrHStDJY7SsuiBSy60IEfRIU9hn79RtDfxDkIWVwPbfujH3ddGgV0WMpW9J0Dx+6ovH832EUnsWAG5LXT9s4jqoUeK5ymP3Tzhro5S+gpqPEn6NWXqfx4ORLeaEOL+sJeYjCCaxaQHlnhZzpvQgVdVd4Tz7ibxA+XnXBYb/WK/MqmQkW3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=y2oTi3b+3hCoNxGuOUkwhWgvncgMihYm5DrEEikckAM=;
 b=ZSEif/QkKaKVtpJJx+qBbVHMFaIEw6hSJg78cX6A/p8saO8pGqQIMBbLc9eMWvXSFHRxoGLu5PWLuBj0BYVDDRm5ZGzsnhejLac36pdBdLYv2aPuoJYHbHGqZMDuglvCk7TxxOOYTvYcsJDSU7GeNxaPEuY5qnr3kOnCl+YEWmdYue2ztfGo39+vf1WCNz8OjcH8o+YGFseyOheu64tcgdqPDdCsAu54uGaTY2EfmeMYjbMDd9ohTw9DIRrq9IPH5uBLOsVG9uUSKdPt8Jxo2gTGjdc33o1PWF5u1cK68WBN98uDkn4u40Qk4jcopfnGTkvgxVLQCgvI/XQ0PakraA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=y2oTi3b+3hCoNxGuOUkwhWgvncgMihYm5DrEEikckAM=;
 b=mMyNXtX1RnIw1ta0aaDOi4SxokGe32Qp4FLY18Tn5yRtu7ZekwFKoP2FFhRwRz1Ib7wjuQuNsNemdv1ECgjcxcWzGr6yfKIzJ6HDDFO10/LBlUrmcmAPyFx0EHxyWsfkUzkc5rxDUDafgXO3n+99+IleCW371do5onz3PsIO9XHqs63sU2mwfmJvaLsJNh2qqEIU8BB/aRVCbzyqA/WM0CLiDlL+XLeaIH6QXFZR7y7sTW6zUA3plOv2aW2OgHoJtI5Szmmkw2CDVZT/FMiqE5ULjXafREOn1S2l6EZhAmhwkP+VHjPiV22kr6awXm4Zh7gQNMaVV4NmIQv7pGiItQ==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by DM6PR12MB4435.namprd12.prod.outlook.com (2603:10b6:5:2a6::23) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.382.15; Tue, 8 Sep
 2026 02:56:31 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0382.014; Tue, 8 Sep 2026
 02:56:31 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Mon, 07 Sep 2026 22:56:11 -0400
Subject: [PATCH v3 04/14] fscrypt: stop setting PG_private on bounce page
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260907-remove-pg_private-v3-4-6ae22f9d9272@nvidia.com>
References: <20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com>
In-Reply-To: <20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com>
To: David Hildenbrand <david@kernel.org>, 
 "Matthew Wilcox (Oracle)" <willy@infradead.org>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 Muchun Song <muchun.song@linux.dev>, Lorenzo Stoakes <ljs@kernel.org>, 
 "Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
 Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
 Michal Hocko <mhocko@suse.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, 
 Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>, 
 Dev Jain <dev.jain@arm.com>, Barry Song <baohua@kernel.org>, 
 Lance Yang <lance.yang@linux.dev>, Usama Arif <usama.arif@linux.dev>, 
 Gregory Price <gourry@gourry.net>, 
 Ying Huang <ying.huang@linux.alibaba.com>, 
 Alistair Popple <apopple@nvidia.com>, Johannes Weiner <hannes@cmpxchg.org>, 
 Qi Zheng <qi.zheng@linux.dev>, Shakeel Butt <shakeel.butt@linux.dev>, 
 Kairui Song <kasong@tencent.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
 Zi Yan <ziy@nvidia.com>, Eric Biggers <ebiggers@kernel.org>, 
 "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, 
 linux-fscrypt@vger.kernel.org
X-Mailer: b4 0.15.2
X-ClientProxiedBy: DS1P221CA0005.NAMP221.PROD.OUTLOOK.COM (2603:10b6:8:451::9)
 To IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|DM6PR12MB4435:EE_
X-MS-Office365-Filtering-Correlation-Id: 88d1de28-9cc3-4d5b-1f3b-08df0d54c925
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|7416014|366016|23010399003|1800799024|921020|10067099003|56012099006|11063799006|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	YOYD8QjNOmgaavs5owygNd+yFGQiz3h7QvocmuUT89ZfHMmeWSB96qKSVlq1XMFiZ/2StAHZskhusLiw3f79CycTSp2YECqlGtyd46sOTXqZzsM81FN+JLzOjygfPSiMBA4AxOiu1ioAriEgB0XN+nY/JHEPhbira3Ze/jjyeW7rcuTkD/VLTwxsRtBXA4io/19RXHdP4atFoHevwlGU8TQFfBmPltNBCvryFQbcjaJ3HpOwpeIpnN4jTv27gLrWYnc13Em5EhcIDWvna9yB+WKFXjCOdCMgV/ZecayPINhRKvWlcbB1iTL3Byy0OWLRcLAdZPWEaSjZ/KaevQ6VrlTrgUMr2tH6eYoJc9r7/2YbdNStApLf6zrgETixLbP6KHTxEMIhgq+AkbibLzBFKMB2ouvFy/XchsloEJ49QbQtUUT2DGWC+XfN2E8wwuT0rJunpjlVZId5IBt1KjTpdPbQW1IWHRumFBrWhAROHyt4zDjgb7B65i/GiAWlJ9fVMt68EeO18usr+UvVLgx+7SIeEUl/2aJ/YgEt4ozNhchzoaTqgFBrZPp77UFaEu1mXfLrY0Cv/vWy04rXrU1O9HL/ck3zaNVnK0q2w3VPfh6Dy+g0a7+ajZzemSOKkcHrnaj3nfRGgywbm0ZsASwx44CHBYfbAaK+beSmSbQVmk1hbxSUSnrak28SChLxeUMC5pdYHHallsGzN6H+nWQxBQ==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(7416014)(366016)(23010399003)(1800799024)(921020)(10067099003)(56012099006)(11063799006)(22082099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?WGtLL2tzdEUrY3FMZVdSMWN5ci8vU1pJTFQydnZBZEg2NmtQNG45MUFwODdx?=
 =?utf-8?B?ZkF1WHpyR3I2L2RFQndIK0FWclBvZTZTMytqSElXYkRIZnp0cHFlejV6YnhC?=
 =?utf-8?B?WXloRjFLaUdmZWZKcUhsc2ZpK09IMWNpcDhHclZzbHp3c3pMdVdlYWpLZ2px?=
 =?utf-8?B?MGJlZW5EazJ4c25pTnJIMWNlSHNleFlOc3A1bklBRzY5OG5scmpTWjZENXIz?=
 =?utf-8?B?NWx0cnoydTJrUHU0ajM0czhUTW9GOFFzUnlibStoakFZbDVGVzYvaVRuY2h4?=
 =?utf-8?B?ckJ1TktNUWZlRFNXTVoxT2pMWTNrV3czWFlVdFRwdnVrbmV4c3NKSmdySWda?=
 =?utf-8?B?YkpsMmp5MHl0R0tzblk4Yk40UFhneVNsN3ZiR2xmdzg3ZVROSDFoTEpsV1dX?=
 =?utf-8?B?azd1WVJuMFovYXVSSzRpS0ltM2JmdXY5ZTB4N2Q2WDFIdEowdWRYaGtqMzla?=
 =?utf-8?B?SkRyNGtMQUI2SEdJWEhJM2RVcVV6Z1JnejB4RjhwT2M3RjZnNUJrQW1kS3FN?=
 =?utf-8?B?Y1hWY3NjRUsvN2U4NGtNRUFhRGVteHo0NW1DclhGZlFsSmFvSExQTnhYR1Rr?=
 =?utf-8?B?T0J0Y1VsZFl1bmVuTEs1TVVhVnpOeThmYUMrUkVoSlZGYWM4RHN0MkRZdzdV?=
 =?utf-8?B?eWRTM0JydUtCQWJubi9RRUdSWnRhazJUNTNOMGMwckpITFhLNFIrZlVlTzU0?=
 =?utf-8?B?ZFYvbno2OG1icm83UEJZeUtFMlRCZHdiYjZQYjM2RzJLbmMrSFQ1MzVOZitz?=
 =?utf-8?B?Q2RuUmJyRXFDR0lISDcrNm9Zb2xTcC9tMUYrczlQSnlZUTBKbnpKTkFiTDAw?=
 =?utf-8?B?NTlyVEx1QVNEeEpJQi95UGU5dGFTZkx5UlhhVzQrcCt2aWVjQWF0WkdmaEJj?=
 =?utf-8?B?dlNZN1dtM1lUbWpYcCtiU0E2SmV6Ky9RakFGbWo4UmRHSzkwVzVhL1kwMmhh?=
 =?utf-8?B?R01TQTIzZ1Z1TThRNzBTdjEyMXZwYnBCNnkzSnB6anNnWVRRd3FyNDJ0T3BT?=
 =?utf-8?B?Rlc1ZkhURDQ2cFRETStvUFI3QTZtMEFsV2QrUnVSVUlxN1BMN2pXSkNmN0Jw?=
 =?utf-8?B?RmQwWjdwTHBwckcwVTN6d0hISms3STQzdU1DRWU3YndYM2h5dXZvVGt2K0xj?=
 =?utf-8?B?VXM5Y29BdkpvemFTMlM0Z2Fock96V1RDTlpTcUFFZEh6eEdOazBQMUJOa3l2?=
 =?utf-8?B?OElmeDdqZ1J5Zlh0c21ZdzNuS3hwcjYrV1ZpU3duN1dJUUFtdkN5RDZGSElH?=
 =?utf-8?B?UkdYUU5iTk0wL0l2Ris2MXJ1QVlweWMvUm1mUVUvSkRYcS9ubEF2ekN0VjJ6?=
 =?utf-8?B?bHdXSXBmUlM2ek9OS0VqcWZlWno3SE11aWJCRm55YW5rMXhNN2tNRE0rejUz?=
 =?utf-8?B?bStIc0wrTmMvZUV1aUxyVjJsdTZBayt3bE9QTndZWm0vNVNMTEhEN0JrUUY4?=
 =?utf-8?B?L2YxTE1rL29YTytKeWp5OTJqc3VGajJjTGZ6NExkek1GSkRYSXFMSFJDL0x2?=
 =?utf-8?B?SFV4RDlCcXhLalp6L0xoOUR3UlhhZGtHd2FEcHdlQ0VDb3FHRFB0YkNhS3FX?=
 =?utf-8?B?VVM3R0w1UnhlOXhGcDF3Qm8wajEzMFc5WDRsTWNUOWh6OFBvYlhyK21CNmVj?=
 =?utf-8?B?V3p2Zml6bnNVSy9XSmxRQVgzYk5FZnFFMlg2a0lZZ1d2OGd6ZkozZVR5QmJS?=
 =?utf-8?B?eHMyMjZ1bldILzVPRjJmMVQxa2o5QnRMYVZYUXdPOTREenU5dVgyNGVzN2NF?=
 =?utf-8?B?SlZjbVIzT0VMVlRtMWd2aEJNN05UWFNjSkpaZkdydGFKbHpWeElEbXVUMHlj?=
 =?utf-8?B?QzhLSnQ4eUVvUjBRQWtFYmFmSHovaWdBZDdvMTE2aTJrN1ZjOTlOemE0aHdi?=
 =?utf-8?B?TlBhVnZPZThzQjVMK09STWVYY1RTZ3cvWE12RjNvZ3pwTmFua1RFaXhnSGNP?=
 =?utf-8?B?elpPdjE1Yy9zNTBIMm5LQWl6UUpaRmhQQWhNaUgralk2SDhnY2tVS2V3OU1P?=
 =?utf-8?B?cXBCMVh6YXlTWWFNalJyd1k0SGpnNFRQRGljUTBoNm83RjJza21UUnVNVEhD?=
 =?utf-8?B?RVpzYTc1alJKK0FPaEpFOXJGK25teHNlL0NLT1RyVUtOSFducEIyaXIxdFNl?=
 =?utf-8?B?dmVLVmtzUS9aQW5ydnFvOUVZbVdCZmJLZmR1SGJ2ZmpOSWJXTld4eGJ2RldY?=
 =?utf-8?B?djB5V1UySTBrcmJSOE1XUThWZHNyOENiQVJpYXlHOE93REl5ZUVHeUtINE5Q?=
 =?utf-8?B?MHQyZ0tJZlo0SHpwWWpMMjZEdXNuKzd3aGg3WHFGSUxMM0xndVBHRUtWYnlL?=
 =?utf-8?Q?u3ZPWAjckKBw2tRAKm?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 88d1de28-9cc3-4d5b-1f3b-08df0d54c925
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 Sep 2026 02:56:31.4073
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 4Gksj8d/2nDz0YgDlbM4c5+jN0uDWD3G+mRMLBVw3S+mzertBN5WjRflnF4pd0wt
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB4435

The pointer to a plain text folio is stored in bound_page->private and
cannot be NULL until the bounce_page is freed, making PG_private redundant.

It prepares for a future commit that remove PG_private.

No functional change intended.

Assisted-by: Claude:claude-opus-4-8
Assisted-by: Codex:gpt-5
To: Eric Biggers <ebiggers@kernel.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Acked-by: Eric Biggers <ebiggers@kernel.org>
Acked-by: Usama Arif <usama.arif@linux.dev>
Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 fs/crypto/crypto.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 5286a124b0d98..aced5c50a4601 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -65,7 +65,6 @@ void fscrypt_free_bounce_page(struct page *bounce_page)
 	if (!bounce_page)
 		return;
 	set_page_private(bounce_page, (unsigned long)NULL);
-	ClearPagePrivate(bounce_page);
 	mempool_free(bounce_page, fscrypt_bounce_page_pool);
 }
 EXPORT_SYMBOL(fscrypt_free_bounce_page);
@@ -210,7 +209,6 @@ struct page *fscrypt_encrypt_pagecache_blocks(struct folio *folio,
 			return ERR_PTR(err);
 		}
 	}
-	SetPagePrivate(ciphertext_page);
 	set_page_private(ciphertext_page, (unsigned long)folio);
 	return ciphertext_page;
 }

-- 
2.53.0

