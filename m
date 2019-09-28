Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from sandeen.net ([63.231.237.45]:51264 "EHLO sandeen.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726673AbfI1ANp (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 27 Sep 2019 20:13:45 -0400
Subject: Re: [RFC PATCH 4/8] xfs_io/encrypt: extend 'get_encpolicy' to support
 v2 policies
References: <20190812175635.34186-1-ebiggers@kernel.org>
 <20190812175635.34186-5-ebiggers@kernel.org>
 <93a8536c-191d-340e-2d18-2ef87d0dcd5d@sandeen.net>
 <20190925232809.GC3163@gmail.com>
From: Eric Sandeen <sandeen@sandeen.net>
Message-ID: <6ef4798a-b506-c136-bdc8-93a12451ac60@sandeen.net>
Date: Fri, 27 Sep 2019 19:13:42 -0500
MIME-Version: 1.0
In-Reply-To: <20190925232809.GC3163@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-xfs@vger.kernel.org, fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 9/25/19 6:28 PM, Eric Biggers wrote:
> On Wed, Sep 25, 2019 at 12:23:25PM -0500, Eric Sandeen wrote:
>> On 8/12/19 12:56 PM, Eric Biggers wrote:
>>> From: Eric Biggers <ebiggers@google.com>
>>>
>>> get_encpolicy uses the FS_IOC_GET_ENCRYPTION_POLICY ioctl to retrieve
>>> the file's encryption policy, then displays it.  But that only works for
>>> v1 encryption policies.  A new ioctl, FS_IOC_GET_ENCRYPTION_POLICY_EX,
>>> has been introduced which is more flexible and can retrieve both v1 and
>>> v2 encryption policies.
>>
>> ...
>>
...

>>> +	fprintf(stderr,
>>> +		"%s: unexpected error checking for FS_IOC_GET_ENCRYPTION_POLICY_EX support: %s\n",
>>
>> Darrick also mentioned to me off-list that the io/encrypt.c code is chock full of
>> strings that really need to be _("translatable")
>>
> 
> Sure, I can do that, though is this really something that people want?  These
> commands are only intended for testing, and the xfsprogs translations don't seem
> actively maintained (only 1 language was updated in the last 10 years?).

True that there's not a ton of translation going on now, but it's easy enough
to toss in _("foo") and keep the possibility open, and be consistent.

So thanks  :)

-Eric
