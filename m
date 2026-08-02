Received: from SA9PR02CU001.outbound.protection.outlook.com (mail-southcentralusazon11013010.outbound.protection.outlook.com [40.93.196.10])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0183A175A66;
	Sun,  2 Aug 2026 01:29:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.196.10
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785634176; cv=fail; b=ivqsiREU4f7/GwKvvPl7InmcccP5hMCrSBrJ99bT+ze6y9O8T44sA2Gl9GbzPuin9FEUsZG8q/nq0Ex9yIVErFzikO35cXgVV/vbQ94CvYsr4QCSrHAvYYYIq9h1cVh0W/Mwgls1iCoGH1vz6Do+iSCqkOBPY32RhK57AzuG5dE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785634176; c=relaxed/simple;
	bh=jPI44+3TmYYVX0fX8TYPDM28lkFdF34gpvKpLh5bi1c=;
	h=Content-Type:Date:Message-Id:Subject:Cc:To:From:References:
	 In-Reply-To:MIME-Version; b=cTm+HJYJI1PHOczWSXN+G6uIwjWhahJsyz7Zi/IlfBgG6oj019eMEkPTrJmPTtn6Rvpl+sIy4KryDHeFKYIs21qClhF9RUoMYHueLTqoh8wwdM7eOX5mD0Ky9WJCrvjAucS/3Z15pzo1fPsEfuCFlIhEQcU8+8BFmX6Hi1Pr8Ik=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=Mr1+qEf6; arc=fail smtp.client-ip=40.93.196.10
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="Mr1+qEf6"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=k/AMGK/qp+OdbTolIUe67WDqptCfxLXczTuKywQoSkj3mcLxQQ6wUPNhPtN4iVcfUJgg0KzJ13dlWaHzj7H/5K0gp7TUnIWUlUb4ujkonIq98MTgdPFRMpncaQRl2bvO+Lan+HhkUHVd5ftyFslrtiWJsv0gmEGZ8JzStoZmEmZ5+B+mGZwaWEaTwxCOMGFSBr2LgTPfqKCE+sq7I00gc2GdePEB38wM3BMow0z6REX0MupAXnpvb2jYxKf9aafX9m7+9ybuBo/au8GuoQmHb7WOsrODtGbGh5DlRpMPBY0LErCyQNRtRNZcnUwoCWoQEjQFnMP7wEpC3goNbs/RBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=nSYU0S22JcaHUbGHLDHL7SsTMm+QWf+qruFrPCccA9k=;
 b=Q6ygIzkII2CMee7jKfcAnLw4MGwjU25n1G6IadU6orcGYEkg/K5ISXmvQtLloeo5xvdTR7fX58xxsXyvrL3ajdo2zKd+80R7l7Sb/3L8tUd0GnQMN3u8Fg/nMx1uqQSbUU41GBGVH2j/vx9ruQoopPiRZNciKhWwSI04MbtYvcHmojstZkGASg+3Xy7GJ63+Gg8g8Tr36Nwry5lhHIghMFFAFdG4a46JZXM3HC+3HKRWg3qGf3TA3MfVdsdsZo0TuTShx/+v5wcIFf086/Sivo4IeSqpqqzP81KUD60DSx4BUEVa2Lc9GoW6v+jeO0vBU49tSexFjzfvvD4eoFMkkA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nSYU0S22JcaHUbGHLDHL7SsTMm+QWf+qruFrPCccA9k=;
 b=Mr1+qEf6CnVacDagzyGzCAe+G38eKQCmSyeEU0POZssjXksJS5M5K7LcJde9f8MXDgL5PKJUNNdlE774JiNN1gUxrIlhmjd3PRBWdGZ4ztL7F105SzTmlW7FWYMViaUBitOtRn98bHt4LnTgJqN/7HZ7wq89RTNYvIuxc5X19mZJqdeqGdAk6M0YLTrXRpm39iD/GUxZBaO7gIO4GAv9/6xOL3Gu3SX3d9XsyI1VxpQEjrWdZtJpCSMAoFNFgS2j3y6MuzYNKXrLPLMK5NUP35pEGfRueXpdhn64Ah8eaCc8vmBiSEdCm22Et5IX4TD2RWiRJ9VsDny5QlI4YbrhSw==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by CH3PR12MB7497.namprd12.prod.outlook.com (2603:10b6:610:153::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.270.17; Sun, 2 Aug
 2026 01:29:28 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0270.016; Sun, 2 Aug 2026
 01:29:27 +0000
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8
Date: Sat, 01 Aug 2026 21:29:23 -0400
Message-Id: <DKE2HE1W6S5T.3CBF1B0M1GKOL@nvidia.com>
Subject: Re: [PATCH RFC 04/14] fs/crypto: stop setting PG_private on bounce
 page
Cc: "David Hildenbrand" <david@kernel.org>, "Matthew Wilcox (Oracle)"
 <willy@infradead.org>, "Andrew Morton" <akpm@linux-foundation.org>, "Muchun
 Song" <muchun.song@linux.dev>, "Lorenzo Stoakes" <ljs@kernel.org>, "Liam R.
 Howlett" <liam@infradead.org>, "Vlastimil Babka" <vbabka@kernel.org>, "Mike
 Rapoport" <rppt@kernel.org>, "Suren Baghdasaryan" <surenb@google.com>,
 "Michal Hocko" <mhocko@suse.com>, "Baolin Wang"
 <baolin.wang@linux.alibaba.com>, "Nico Pache" <nico.pache@linux.dev>, "Ryan
 Roberts" <ryan.roberts@arm.com>, "Dev Jain" <dev.jain@arm.com>, "Barry
 Song" <baohua@kernel.org>, "Lance Yang" <lance.yang@linux.dev>, "Gregory
 Price" <gourry@gourry.net>, "Ying Huang" <ying.huang@linux.alibaba.com>,
 "Alistair Popple" <apopple@nvidia.com>, "Johannes Weiner"
 <hannes@cmpxchg.org>, "Qi Zheng" <qi.zheng@linux.dev>, "Shakeel Butt"
 <shakeel.butt@linux.dev>, "Kairui Song" <kasong@tencent.com>,
 <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, "Eric Biggers"
 <ebiggers@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, "Jaegeuk Kim"
 <jaegeuk@kernel.org>, <linux-fscrypt@vger.kernel.org>
To: "Usama Arif" <usama.arif@linux.dev>
From: "Zi Yan" <ziy@nvidia.com>
X-Mailer: aerc 0.21.0
References: <20260731-remove-pg_private-v1-4-142c97ba3562@nvidia.com>
 <20260801145208.1930586-1-usama.arif@linux.dev>
In-Reply-To: <20260801145208.1930586-1-usama.arif@linux.dev>
X-ClientProxiedBy: CY5PR15CA0159.namprd15.prod.outlook.com
 (2603:10b6:930:67::27) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|CH3PR12MB7497:EE_
X-MS-Office365-Filtering-Correlation-Id: a34cc103-9422-4506-a12d-08def0357e66
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|7416014|376014|1800799024|23010399003|366016|11063799006|4143699003|5023799004|56012099006|10067099003|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	P9DoHMC1x87cTSV898q2TtiFRWoHPQNtcz43/LIwti48CotKLPGkaZXVYi8RyC+Hsbbo0g98Wjer82foFU6wRKEbQRIsQRKq3PCv8Tc4FapnZnNoaMpof2TM//HsCZJFDxEZ2Vz4GDOvf1ezwaWudkMc/ptUaZaXaREF/UhaoOe7x/jXUcgeUaF3wZH6tQEB4BUtK6HU5KYsE1EOb8T09MmcsSPMlG1St8LGJ4epBhTjxWPcP2RDOz+YeZn9980x7hCdNM7DcmlE8OyHXUYt87E+coaSi97olFrmcU1uVXUh2QzmdV3PeIK37A5DeKf608I4U9lQrf35UT/cWb2bDUbj6cADiO0A4+hkPgXpRIiv8aY0F8orf7FbZ3z7rT1kVEjUFu+j/7GzrNhm8NPbKHj2AsiIuWi1JUK4FhHxysgAp8pDgtBhHvPzqf9vO8orAS9XDXohXd+S0a0i7WwgX0KeSe9EPU4XnLg63ITYuz1d9HFLxKIZ4S+Fht7JcXaTQMlhThZM+FM2WH5yoYqjwIOXbd4EMyXnx8+T5tZWPuIRieNPVo0sWLEwmkYJOapKPv6ahkd7PYIcq1w3CsBthwasaov+pZe7/Otk89hlB9HDeBIM2sF8SzVCKyexlukFeSz7U83GlIn29kbTdE8f6cvkTZKQ8HtwH+ldOVDDNlA=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(7416014)(376014)(1800799024)(23010399003)(366016)(11063799006)(4143699003)(5023799004)(56012099006)(10067099003)(22082099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?bDJlOG1vOHQ1eVhyR2trL3kwTlEzVTJ4end3bkJRUE1TNU83Z1laUUYxVGdK?=
 =?utf-8?B?eUxha3FYVllSTjdCZHhJTFV0d292c0Q1V3ArdHMzRmNzL1pHaUlXOVNaRFhX?=
 =?utf-8?B?TjBTNG5QTC9TdjNXTGdnVTB5dXZvY29aZk9JdUxQOTFXajAyWkt3VWYxZC9q?=
 =?utf-8?B?aFRCd3IrMjBHek1kejdJQ3dpK3B2L3ZOSkU4ekRBNW1LbldUSGJoZml4SjVN?=
 =?utf-8?B?ZjFmVWtSbXRISHVFektKc1pkYUV1bXZQQlJOWXIrQ1NBcWF6a3NtVWJyeTh6?=
 =?utf-8?B?WHlYc3pWNllGSEV4WEozbXZ3ZU0zUTJPTElBVG52MjBwRVJxbUlsam5HNytE?=
 =?utf-8?B?VDdOYTJVcGlpaGs3bFFhTXp6VzdxZWhEUTZoWEk0WnVvZ1NlSm91T3JZTDQ1?=
 =?utf-8?B?aUhreXhkUTNETVNZb2ZDck1kSk5Jc0ZNZ2ord3VaZWE3cVlPWWgybSs5QlQw?=
 =?utf-8?B?NDFDbmhURHNjU0dCNjB3Vk1pZUlmUkVRZlJqY3JrcEQ5eWprNXV3a2N5SzR1?=
 =?utf-8?B?dFVia1pIS3dDc2ZJOWF3N0JlVDcyV3ZVWExYeXRUajFDQnpGVFFLRDI1Rmg1?=
 =?utf-8?B?ZnRnTU5SbVJabzd1TlluN0JBVGtXS3oxUWQwOUFVOXRPZnFYRVkrYXdiczFX?=
 =?utf-8?B?VURvNjFBVE40R2dhZkszSllES0NSTkZDWk5lcmVGSWR1NTlFa25LZk0ydzJR?=
 =?utf-8?B?OFpqUnppN3dpaTVJWENJOVVGVWZ2R1Y0YXZ0amlOVFFTa1VPSEplZEtmMlVR?=
 =?utf-8?B?cHlkWGhJYzkrMlN3TTd1NHEyZFc5T3Y0UDVFUEVQMnkyTUE2Y0l6djY0TE1v?=
 =?utf-8?B?N0RFTC9sdWp3TFhWRE5tdDdmdlJsZ0pEU3FtSmNCMHFqTXNob0NJZkM4bUVo?=
 =?utf-8?B?eGl3S1QrNTRzc1RJU0tRcWtXdmRyMDVGS2ZNQVdibnMwZDRzNXViYXRKOFNW?=
 =?utf-8?B?SnMxREhIbVpyQ1p6cXZOTi8rWi9NMHhmNHFkUkhlRXd0OEVJaFM0ckoxcnJL?=
 =?utf-8?B?dnZZVDlhcEpWL3cwd0hkTFAvblhpUnFIYmFXajZLZHpVcWJsYmU2Wno0NVd3?=
 =?utf-8?B?a0c1K3VJdDdiNGJPTkpKbnZYL3RxUitwWERpZmtDUEZNV1dVa3NZZ3ZLa0lr?=
 =?utf-8?B?djBubDM2QmNUdmx0ZDF6czNLRCsrczlvRzRKcWNZWjNLTEFoUWRIeFNOV0Fx?=
 =?utf-8?B?UnFsQnZ1QlpTOTNvaUZ1Q3p6ZjRTaGRFS2c4ZTZkeitlWFBPYk03ZE15ZjlV?=
 =?utf-8?B?QnVlZ0lyU0Uvb1NWdFVGSGowdXRQb28wSjVML1Bra0NLVy9UR0UvVmMrVUFO?=
 =?utf-8?B?SGc5UjhLQkFacTkrcWV5aTNrU1BVb2NxczdIRUpGUk9qTGlyTXF0ZDJMWjAv?=
 =?utf-8?B?NDNIZEpUSGE3TGswRXhwNThGUTlMQXNYZ2duWEtzR2NaQi9heXVpRlRlN0ZJ?=
 =?utf-8?B?azJ4RWdIc3Q1Z2M0L3h1U0tQdHJmWUpycWkwK21PN1pLV2VPSFRKdHNzN2s0?=
 =?utf-8?B?cXJLSUpMZm1ueGZ6YXAxc2xPUUgxc2RiNXFqR0VHeTNYelBqd1dXaE1LUGhV?=
 =?utf-8?B?amRFeVlCN1AzMkl4UnFlL3ZSOHlKL0lEWEwzUkRFNXFHNnZ2ai9sKzBhc1dS?=
 =?utf-8?B?NW9ySEtXN3JsYkFCdTZqNTNOUVJXQWdzbHJVUjNYVUNuNm40RDRTQzBoS09V?=
 =?utf-8?B?aHgwWm9nRTZmdjdnNGNPVmNta2IrVUhyZy9EOUxJY1kwNVY3bWNQbUhuS3pk?=
 =?utf-8?B?RGVVSExOQjdyempmNTMwYkp1RFlUOXI1Rkh0RkFES3RVYUdCcnFXZXVwTkRO?=
 =?utf-8?B?cjAvd3B2SGpLbE5kb1k4cFp0TTVyNVNaRzJYZ09RbFRPSXRBOGdvcklFdDNs?=
 =?utf-8?B?MXkwM05zQTdmTUJrWUgzOWVnQUUvVkY4QmFVOWV6WUJsY2hobmlmNUlBNVM2?=
 =?utf-8?B?cHVxNy9LdmZGY2FVQ0FFMnB6UG5zZzczbW5vb0o4WWh6bktidDVkQlRyVDUw?=
 =?utf-8?B?Ti90cjg2eGNRVU02dUVIZkJXMUZVS3B2VFBpVmhOcENJWGVKR2p0ZmV0Nk1N?=
 =?utf-8?B?YUl2c1JuRnV6cWFTSTIzZEd0S3VRQU14SnZJemtEL24xcmkzd05JZGJxR0wz?=
 =?utf-8?B?TVFINm5hNGJ2VzJsd3ExS21vZkNwL2hNenZhV0pKN1RUR0ZPL3lJckhVMjlC?=
 =?utf-8?B?VE4veVNmdXBCQVRQUFR3QnF0d0NBTmRtbnZZOS9acHB0YzRTbTlqRnc5T1c1?=
 =?utf-8?B?UjRtWFZEbHBrVFRFcURDd1QvVkNMenZGd2krVXBFMmZYbytuNzZLVzhOK0Uy?=
 =?utf-8?Q?2J38MAzOdEloGH7YYY?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a34cc103-9422-4506-a12d-08def0357e66
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Aug 2026 01:29:27.9034
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: tzovTb73ShqvryfAtktubFqIjH0j4GfVmoR7WRNhwD9WWkLP+sLikDqw2Vc8xTfb
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH3PR12MB7497

On Sat Aug 1, 2026 at 10:52 AM EDT, Usama Arif wrote:
> On Fri, 31 Jul 2026 22:13:27 -0400 Zi Yan <ziy@nvidia.com> wrote:
>
>> The point to a plaintext folio is stored in page->private and cannot be
>> NULL, making PG_private redundant.
>
> s/point to/pointer to/
>
>
> And fscrypt_free_bounce_page() NULLs it, so that needs to be corrected.

Will change it to:

The pointer to a plaintext folio is stored in bounce_page->private and
cannot be NULL until the bounce_page is freed, making PG_private
redundant.

>
> =20
>> It prepares for a future commit that remove PG_private.
>>=20
>> No funtional change intended.
>>=20
>> Assisted-by: Claude:claude-opus-4-8
>> Assisted-by: Codex:gpt-5
>> Signed-off-by: Zi Yan <ziy@nvidia.com>
>> To: Eric Biggers <ebiggers@kernel.org>
>> To: "Theodore Y. Ts'o" <tytso@mit.edu>
>> To: Jaegeuk Kim <jaegeuk@kernel.org>
>> Cc: linux-fscrypt@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>  fs/crypto/crypto.c | 2 --
>>  1 file changed, 2 deletions(-)
>
> Nothing in fscrypt or its users tests PG_private on a bounce page, so
> this looks right to me. The commit message needs to be corrected but code
> looks correct.
>
> Feel free to add:
>
> Acked-by: Usama Arif <usama.arif@linux.dev>

Thanks.

>
>
>>=20
>> diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
>> index 570a2231c945a..c8a98dd94650f 100644
>> --- a/fs/crypto/crypto.c
>> +++ b/fs/crypto/crypto.c
>> @@ -73,7 +73,6 @@ void fscrypt_free_bounce_page(struct page *bounce_page=
)
>>  	if (!bounce_page)
>>  		return;
>>  	set_page_private(bounce_page, (unsigned long)NULL);
>> -	ClearPagePrivate(bounce_page);
>>  	mempool_free(bounce_page, fscrypt_bounce_page_pool);
>>  }
>>  EXPORT_SYMBOL(fscrypt_free_bounce_page);
>> @@ -202,7 +201,6 @@ struct page *fscrypt_encrypt_pagecache_blocks(struct=
 folio *folio,
>>  			return ERR_PTR(err);
>>  		}
>>  	}
>> -	SetPagePrivate(ciphertext_page);
>>  	set_page_private(ciphertext_page, (unsigned long)folio);
>>  	return ciphertext_page;
>>  }
>>=20
>> --=20
>> 2.53.0
>>=20
>>=20




--=20
Best Regards,
Yan, Zi

