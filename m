Date: Wed, 25 Sep 2019 16:28:09 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 4/8] xfs_io/encrypt: extend 'get_encpolicy' to
 support v2 policies
Message-ID: <20190925232809.GC3163@gmail.com>
References: <20190812175635.34186-1-ebiggers@kernel.org>
 <20190812175635.34186-5-ebiggers@kernel.org>
 <93a8536c-191d-340e-2d18-2ef87d0dcd5d@sandeen.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <93a8536c-191d-340e-2d18-2ef87d0dcd5d@sandeen.net>
To: Eric Sandeen <sandeen@sandeen.net>
Cc: linux-xfs@vger.kernel.org, fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Sep 25, 2019 at 12:23:25PM -0500, Eric Sandeen wrote:
> On 8/12/19 12:56 PM, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > get_encpolicy uses the FS_IOC_GET_ENCRYPTION_POLICY ioctl to retrieve
> > the file's encryption policy, then displays it.  But that only works for
> > v1 encryption policies.  A new ioctl, FS_IOC_GET_ENCRYPTION_POLICY_EX,
> > has been introduced which is more flexible and can retrieve both v1 and
> > v2 encryption policies.
> 
> ...
> 
> > +static void
> > +test_for_v2_policy_support(void)
> > +{
> > +	struct fscrypt_get_policy_ex_arg arg;
> > +
> > +	arg.policy_size = sizeof(arg.policy);
> > +
> > +	if (ioctl(file->fd, FS_IOC_GET_ENCRYPTION_POLICY_EX, &arg) == 0 ||
> > +	    errno == ENODATA /* file unencrypted */) {
> > +		printf("supported\n");
> > +		return;
> > +	}
> > +	if (errno == ENOTTY) {
> > +		printf("unsupported\n");
> > +		return;
> > +	}
> > +	fprintf(stderr,
> > +		"%s: unexpected error checking for FS_IOC_GET_ENCRYPTION_POLICY_EX support: %s\n",
> 
> Darrick also mentioned to me off-list that the io/encrypt.c code is chock full of
> strings that really need to be _("translatable")
> 

Sure, I can do that, though is this really something that people want?  These
commands are only intended for testing, and the xfsprogs translations don't seem
actively maintained (only 1 language was updated in the last 10 years?).

- Eric
