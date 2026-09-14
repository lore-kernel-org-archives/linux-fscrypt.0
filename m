Received: from BYAPR05CU005.outbound.protection.outlook.com (mail-westusazon11010031.outbound.protection.outlook.com [52.101.85.31])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61DBB322B8F;
	Mon, 14 Sep 2026 02:24:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.85.31
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789352677; cv=fail; b=GEnbeIABO8ORaVttFx3iJwcr94BMCPHHLJlb6icDtoSbEnpcub4XKUa3mfWKbCLZXo5K2wLNa/jQe0GIdAZzeXZmc8ZHsdvu1EzGQsh7dmVfHarny5poZXW/Xg8vp/drfptOmq/6YaT2lkeFZUa+/AHLgjyPyapS9L2TOPIH3OA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789352677; c=relaxed/simple;
	bh=mlGhRQsDFVR+ZtrbFnxBErjRr3tinO9GhaaHYovRs8c=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=c56Qoy7SH/3ywtj5IN7CtyvH+QGCMv6W1zG4dIsUbijZCcYwl6oZd1ZLbWL7ZE9zwbBh90S+W9TEKeaEv+wIGO/fnDXv0Rlb+9z2FC6GQpxhSeKEubcazXmQaOyasX41CS4fpFCPHnU2BfK25N/x4uJfNyiD+syuCXO/DAQkyPo=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=kRqDGMZw; arc=fail smtp.client-ip=52.101.85.31
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="kRqDGMZw"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=rmMBfM41hCQl2XW3g7EIBop/EqGWur1brbRj1iJ53Ox9aPxwj4LrSic6MiMAHW95wuzbS9rNoctKtt67gvUnXaJhVJAtj5mpRna2uPCbwsnMGZpQgI26qiV67NPs4WkkP6Zn3lmUv0ph1a22dPCU/CGfVG8sb5ZY+/5dJoVjbLa1lh2fvFhpiPifotHd/S6tFVG0lEW8i0RnJrJndkZIfYtJwa3Nio9Y4iKfQdn8pThCwBhMRYJayuLBfcYx6NtcbOq+RGC186MHUeZxoVNFRD8xTfimwPFWiyF1o3A8N/TPK6RJQXNX4qE9IOqHibKgn+tP52JmQ+pYj56BL1DJYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=b96eSbyk6ByBEFjiSyHVjmOBfJffseci+FgonfWLP2s=;
 b=czmy0wvQVacafrIaJ/Iy3WrSCZ1cu5q64pjPuyK2XE/iwZilntHOSJhSX6wJm0ihw0kXgnCb8d2h62eY7V6yR5kMn2Ui6V6lBm5idz77ktEUdm34Ljejfm6yoJNEhxxvHWI0L9vhFHgwyfD8Q6CGom2/WJ9dTIIVXQ4fa2DF1oIbwIlMrbSDWAvxzuDNGJFue5Su7TTSh3lyb9StjjuDHFUfLURGjeuIxhbGktxcK6Ty9NkC/ebdzqGi4VXBTZ93BGPaP6tNgZxVA5v6NrFhM4V0BXU3LD61xLAfy0mxyOQxS0bBGUOkpDPSm5CrfGRp7eax+pD3EcniF1TbuUlbog==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=b96eSbyk6ByBEFjiSyHVjmOBfJffseci+FgonfWLP2s=;
 b=kRqDGMZwzfUXzsUUFMFhTWty4PlyGJFNKVjs7/JmmBcmoNl8Drv66GtEutIuDS45hLlc07wUQqqeETBtURA4j4gzJ1zaREZUbQHHjgHm0O/lprrP9o4gWqosIL14JugOiQsQ74/EDoebPzHU7++LJ1bIFLBJhr+Z9OWw3xzLAs+u2vSlMCXM8xuy4wcvrPlmRhTbHmmdltRI2sy+UGHMc/jyO71GPtdVV4z9PmIH9SuVj3p3ELlGkJ9q4eyfN9Fa06m6srxWlgEN9q7nRDrLtY4sggvzxz8kpPcJWmd5RlEI6/2otcy2TQyYIPkzgVYyXxLemkI/zXJlEav3dYKy2w==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by DS0PR12MB6486.namprd12.prod.outlook.com (2603:10b6:8:c5::21) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.406.12; Mon, 14 Sep
 2026 02:24:17 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0406.007; Mon, 14 Sep 2026
 02:24:17 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Sun, 13 Sep 2026 22:24:02 -0400
Subject: [PATCH v4 04/16] fscrypt: stop setting PG_private on bounce page
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260913-remove-pg_private-v4-4-848550f7574e@nvidia.com>
References: <20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com>
In-Reply-To: <20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com>
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
X-Mailer: b4 0.16.0
X-ClientProxiedBy: MN0PR03CA0011.namprd03.prod.outlook.com
 (2603:10b6:208:52f::13) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|DS0PR12MB6486:EE_
X-MS-Office365-Filtering-Correlation-Id: 444d3686-e5c3-40c9-6d30-08df1207471d
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|7416014|366016|376014|1800799024|22082099003|18002099003|921020|10067099003|56012099006|11063799006;
X-Microsoft-Antispam-Message-Info:
	CFmEMJ710Akn5WIin2Pg03nulY4Iffx9/GRPq3ANf0oB2luRLZoR58kztgysvGx5xof8TJ55hKVQHi8CfLx4Cis5phLqrFkfsWkBj6NhvmSr9nAhkv0jwfgV6WpDgf7pGJy8r8QdYVTeNxJjLwFO7tiIalyIpRcXfufkMvI1IBwp0e7HrQgl9orm3Bd3gJOfi6b1btjLDbguZmVEhFhcivpe29+C1g/KMYXGiOZzi7m8teZBxJM5GHefGZcwfpeRv5QlmP46UAfFXy11etdS00vDErzHSX2FC6ub/tAHD/FHujULtT4toGEfjWiiBbrqFyxxpbFUj/c/XAfI/Yh9QiHyzYWeASZouYIXjU27p4lTUVenHLgbn3ehHrIrKSYt93Q/VGEXi8EvpucY591eI98dd8rrMqoVjBM1XPteGmGLdbTZ1TiBI7BJB9A9P+tCdnpjHNmPfa5WR/4kZ83HBslsf+4Hl3xY6/TWNnFDnvn2I3VwGsq0HlSgCYD0jEEO2T9LRFyK3CnkGRd2h2dQ09zpHRYj91HtfxpPsHGXpRmX/DkULUMPoYpZY/I/vD9SD6X/iy9mdCMakGzDw8p1MVG0qwQE4//ysAulKovi3/hC+1vAcSfUYnuW/xZHNgbwUQ3u4Q2fsZK64zHnZ5+9K8p6ZwH1S812eNmhWShJQU8qGoWgax2iO5ba4/o5Yf7/WUyjpPXSMoCGkx+lAZVlUQ==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(7416014)(366016)(376014)(1800799024)(22082099003)(18002099003)(921020)(10067099003)(56012099006)(11063799006);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?bklxQXZRWTZLdmoyTVljYjJ5VTZqZjNNVUNEWDQzS05nRE8zVmNDSFJpdFUx?=
 =?utf-8?B?U3YxOGExdGhrekJBOGZQYzhtTnV4YWVTNm9XRmxTdVhBSDJINi9IbVRuQTN1?=
 =?utf-8?B?QnR4c0pFb2txQ1NxUTFSR1ZyWjhaaHZqTWhreUZuSEh1djRQajFOTzY1V0ZP?=
 =?utf-8?B?cXo1ZVpBaHNyS3hlUkRhN1NYV2xzbjNtTmg4OUIyb1V3L0lOVkhuRUFOdUN0?=
 =?utf-8?B?VmFEUUVXd1U2L1ZCN0IvekNOL1hLVWxFWnhRWTRtQnJRUjMwTFlmTXkxQURm?=
 =?utf-8?B?QzNtU0REWXVaUEprZkJMYmpkbFN3a0dYMDVFeGJaT2hobFAyaG0zdnZ5ZDMv?=
 =?utf-8?B?b2FyKzUrWTcyZkQyaWpCcnhHOUlvSlltKzhvK01hYXNTZUczdjB0eVJTNXQr?=
 =?utf-8?B?dDVwY2NZQ1E4WmNmVzVRVXRrZjkwQXVyTlZLR24yTXNkcEtwNXg0ZlBDWWdx?=
 =?utf-8?B?aFltdko3b1p3NmxDcjB1aG5FWm9sRjRYeUsvQkI2NE1IK1ZxcU5zaGNpMGNL?=
 =?utf-8?B?b2taMTlKZktvQjlUb0pUaDJvS0JUTnZkS01UeGp0eEpPTnlKTHZvSDdPbHdw?=
 =?utf-8?B?MTVJTHhUNkpjV0dyOFZLOURhUDJnaUVMYU9HN3daOEl2NVlWUmEyc3ZiS2hD?=
 =?utf-8?B?Ri9PQzU0Zjhpb0dlQ3cyNCtYeENyY044ajlkK25hN0pZdkpqQ3BWU3FpOEJt?=
 =?utf-8?B?dGZMSmM0OWJ5QThjaGpVdklsVitYOUxzempUWXl5QzBqQmU5R1psL1R0Z2h4?=
 =?utf-8?B?UWtFT3dSK3d0MC9pQ3Y4N2IyYzBmSVVROXgxNE9CT0NFaDlBbUFMN2J2cERr?=
 =?utf-8?B?T0QvYzhQZEN0VFBWQW9yNG5hQUlDUjgyaGdxZUx3TWJ5VStoYVZleWdVWUxX?=
 =?utf-8?B?R21tUnhQR2Z1c0h5SkF0aGE0VCtoMlptVVhBcEF5TS9xL2hhUDlNNEo0MzNY?=
 =?utf-8?B?UDFodU9CNUU0ZEtBQ09pRG1vSGVIdm1McitDMnR6dTBqYThDUTBRa0pYeitv?=
 =?utf-8?B?dUZ5ZG9RU2lNQUdzeXlPYWVma0FIUlVxTmgvRGhFVDFIa2x3TnIrOHRQVDlh?=
 =?utf-8?B?a3lhdGRUM2c0SHl6dXpJbUdpdDJwTHFBc29JNVJEbXFuMytGd1AvRC9BWVlU?=
 =?utf-8?B?SDNiNlAxNHZuYkpNUzBjaEx2UnlSMjFRend0TWUwN1JJZGxmcjdmK0VKL1dr?=
 =?utf-8?B?elVheGNUaDJRalRRemJnY20xSUZGMnVXcHMxV3FZTys3ditla0UvQVQ3Rzkx?=
 =?utf-8?B?cEJmSDVRYXhqRWt3T0JFMENRR2g2VHA1aTIydVNHbGx5R245RzVXOEUzRGIw?=
 =?utf-8?B?YlVyUlNrOFVkY2JhNUJhZ01BaEZBS25wUDMzRkdSZjdmZUw0aHBGL0VPWVBi?=
 =?utf-8?B?aWNHbVJVRGFBakhvNCtjLzU4ZG5oN1M1bmI3WEFtK0cwM2cwZnR0L2pmNmMz?=
 =?utf-8?B?dlhOU3p6S09rY0ZGTjVOVUpNb2RUMndLeWRibnliQVRDSU9mK2Q3RW5Ya2JC?=
 =?utf-8?B?YU16a3dZL0NVL0QrQ3EvTm9McDlRb1g3bGhFTllueDhSRTB2YWh0WFBPUTFr?=
 =?utf-8?B?RXJmQWt3VU1uUFZYdm1lNm1MSGl2UGJYSDk5SDhUQjZaTkJKM2pHS2U4STFR?=
 =?utf-8?B?NnpjZFBXL1RLTWN0S0pHWU11ZVhWUVA1VDZnYkwvWDZkcEZrUENaY1dQTUk5?=
 =?utf-8?B?TFBYZmNLQVFOM1NMbnBOYkRIc1FleHFRWnZWTzhTR3FMZ2Y5KzIrOEN1UnlM?=
 =?utf-8?B?cjNVMHFFOUd5ZWFQVUlpNFJCbXg2NTdQNFlXb0N4OHVGS1oxSVhRNDUrUEx4?=
 =?utf-8?B?dCtUbi9RSlpxVThPTEdYRzVWaExxaUNPemtPQ0Q1U3ZPa2VwZzk3UjcvbGRU?=
 =?utf-8?B?US8wVG0ra2pBNCtRM1htTUlncmE2aUtNQWlDYldYUFpWMVBZRDdYUWlpd1ZQ?=
 =?utf-8?B?OC80c252MHpaNHpSTmptVkxKMTlPb2pOYzFjeHJaOW95dWlPYUlQVWowUGxh?=
 =?utf-8?B?VXFKMXNEaW16MXZrOE5pQVFPTHBubytEcm1nUnpyYlpQREU1SzI4T3RMMG14?=
 =?utf-8?B?TzEzem81MVlFaTNwWDRBeXBmMWRHQWVVSFBYVkNWcW9haG5hS3RJUEJ1RjBU?=
 =?utf-8?B?bjZycEU4M21zMXVOL1NyK0FTU2ZIU0puU0JxRy9OS3JrT1pwcTZwa0ZoUC9k?=
 =?utf-8?B?dUdvenY2MHZkWFBQVHRNc1lxL1QwMFcwR3Vibmx6M2pYOVl6ZVp4Mk9TUEhu?=
 =?utf-8?B?Z1hWNXNOYzQzelEySFZwOW1hS2RpckV2RzNhSVR6K1VTZFlSQTZiYVNaeXFx?=
 =?utf-8?Q?B86Yt89tNfBUp3adO3?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 444d3686-e5c3-40c9-6d30-08df1207471d
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 14 Sep 2026 02:24:17.7978
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: aJ3MVSfSSZCTSOGlh3f97ycp7Fcks0n7v7/nExCu6ws4fYnuf62uekayQ+XdgRaf
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS0PR12MB6486

The pointer to a plain text folio is stored in bound_page->private and
cannot be NULL until the bounce_page is freed, making PG_private redundant.

It prepares for a future commit that remove PG_private.

No functional change intended.

Assisted-by: LLM
To: Eric Biggers <ebiggers@kernel.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Acked-by: Eric Biggers <ebiggers@kernel.org>
Acked-by: Usama Arif <usama.arif@linux.dev>
Acked-by: David Hildenbrand (Arm) <david@kernel.org>
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

