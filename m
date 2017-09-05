Return-Path: <keyrings-owner@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <CAFXBA=mqYxD3H_e38hEd2hVL4yvPXb_4DnfgGO5bf6YboTQVSg@mail.gmail.com>
References: <1503584350-7831-1-git-send-email-gilad@benyossef.com>
 <CAFXBA=n6W_n1P=NKHEUAgpaDDrdmh4QwB4aYma9xyio7UFP3Vw@mail.gmail.com>
 <CAOtvUMcjtEMj4eoCG_Rpp-8CmJP+Yu0dPDN3PyOTWjHapf_y1g@mail.gmail.com> <CAFXBA=mqYxD3H_e38hEd2hVL4yvPXb_4DnfgGO5bf6YboTQVSg@mail.gmail.com>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Tue, 5 Sep 2017 15:16:57 +0300
Message-ID: <CAOtvUMdrMEPjXqVk66EOM+2NYoU-Hze2+5Vx6HGuR4FDNxYzDQ@mail.gmail.com>
Subject: Re: [PATCH v7 00/19] simplify crypto wait for async op
Content-Type: text/plain; charset="UTF-8"
Sender: keyrings-owner@vger.kernel.org
To: Harsh Jain <harshjain.prof@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Arnaud Ebalard <arno@natisbad.org>, Matthias Brugger <matthias.bgg@gmail.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, device-mapper development <dm-devel@redhat.com>, Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-doc@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>, keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-ima-user@lists.sourceforge.net, linux-security-module@vger.kernel.org, Ofir Drang <ofir.drang@arm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Sep 5, 2017 at 2:23 PM, Harsh Jain <harshjain.prof@gmail.com> wrote:
> On Sun, Sep 3, 2017 at 11:47 AM, Gilad Ben-Yossef <gilad@benyossef.com> wrote:
>> On Thu, Aug 31, 2017 at 3:31 PM, Harsh Jain <harshjain.prof@gmail.com> wrote:
>>> HI Gilad,
>>>
>>> I think we need an update in ESP also. Now EBUSY return means driver
>>> has accepted, Packet should not be dropped in
>>>
>>> esp_output_tail() function.
>>
>> Good catch. You are right and the same holds true for ah_output() in ah4.c.
>>
>> But I do wonder, the code there now treats -EBUSY as a special case
>> and returns NET_XMIT_DROP
>> but if an AEAD or AHASH transformation return some other error, like
>> -ENOMEM or -EINVAL shouldn't
>> we return NET_XMIT_DROP in that case too?
> I think we should not,  XMIT_DROP implies drop current packet only,
> later on when device is recovered from busy state, Upper layer
> protocol(TCP) will re-transmit the packet. It helps in flow control.
>>

I see. Makes sense.

Thanks,
Gilad

-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
