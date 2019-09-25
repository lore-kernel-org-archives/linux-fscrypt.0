Return-Path: <SRS0=sy75=XU=sandeen.net=sandeen@kernel.org>
Subject: Re: [RFC PATCH 4/8] xfs_io/encrypt: extend 'get_encpolicy' to support
 v2 policies
References: <20190812175635.34186-1-ebiggers@kernel.org>
 <20190812175635.34186-5-ebiggers@kernel.org>
From: Eric Sandeen <sandeen@sandeen.net>
Message-ID: <93a8536c-191d-340e-2d18-2ef87d0dcd5d@sandeen.net>
Date: Wed, 25 Sep 2019 12:23:25 -0500
MIME-Version: 1.0
In-Reply-To: <20190812175635.34186-5-ebiggers@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>, linux-xfs@vger.kernel.org
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 8/12/19 12:56 PM, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> get_encpolicy uses the FS_IOC_GET_ENCRYPTION_POLICY ioctl to retrieve
> the file's encryption policy, then displays it.  But that only works for
> v1 encryption policies.  A new ioctl, FS_IOC_GET_ENCRYPTION_POLICY_EX,
> has been introduced which is more flexible and can retrieve both v1 and
> v2 encryption policies.

...

> +static void
> +test_for_v2_policy_support(void)
> +{
> +	struct fscrypt_get_policy_ex_arg arg;
> +
> +	arg.policy_size = sizeof(arg.policy);
> +
> +	if (ioctl(file->fd, FS_IOC_GET_ENCRYPTION_POLICY_EX, &arg) == 0 ||
> +	    errno == ENODATA /* file unencrypted */) {
> +		printf("supported\n");
> +		return;
> +	}
> +	if (errno == ENOTTY) {
> +		printf("unsupported\n");
> +		return;
> +	}
> +	fprintf(stderr,
> +		"%s: unexpected error checking for FS_IOC_GET_ENCRYPTION_POLICY_EX support: %s\n",

Darrick also mentioned to me off-list that the io/encrypt.c code is chock full of
strings that really need to be _("translatable")

-Eric

> +		file->name, strerror(errno));
> +	exitcode = 1;
> +}
> +
> +static void
> +show_v1_encryption_policy(const struct fscrypt_policy_v1 *policy)
> +{
> +	printf("Encryption policy for %s:\n", file->name);
> +	printf("\tPolicy version: %u\n", policy->version);
> +	printf("\tMaster key descriptor: %s\n",
> +	       keydesc2str(policy->master_key_descriptor));
> +	printf("\tContents encryption mode: %u (%s)\n",
> +	       policy->contents_encryption_mode,
> +	       mode2str(policy->contents_encryption_mode));
> +	printf("\tFilenames encryption mode: %u (%s)\n",
> +	       policy->filenames_encryption_mode,
> +	       mode2str(policy->filenames_encryption_mode));
> +	printf("\tFlags: 0x%02x\n", policy->flags);
> +}
> +
> +static void
> +show_v2_encryption_policy(const struct fscrypt_policy_v2 *policy)
> +{
> +	printf("Encryption policy for %s:\n", file->name);
> +	printf("\tPolicy version: %u\n", policy->version);
> +	printf("\tMaster key identifier: %s\n",
> +	       keyid2str(policy->master_key_identifier));
> +	printf("\tContents encryption mode: %u (%s)\n",
> +	       policy->contents_encryption_mode,
> +	       mode2str(policy->contents_encryption_mode));
> +	printf("\tFilenames encryption mode: %u (%s)\n",
> +	       policy->filenames_encryption_mode,
> +	       mode2str(policy->filenames_encryption_mode));
> +	printf("\tFlags: 0x%02x\n", policy->flags);
> +}
> +
>  static int
>  get_encpolicy_f(int argc, char **argv)
>  {
> -	struct fscrypt_policy policy;
> +	int c;
> +	struct fscrypt_get_policy_ex_arg arg;
> +	bool only_use_v1_ioctl = false;
> +	int res;
>  
> -	if (ioctl(file->fd, FS_IOC_GET_ENCRYPTION_POLICY, &policy) < 0) {
> +	while ((c = getopt(argc, argv, "1t")) != EOF) {
> +		switch (c) {
> +		case '1':
> +			only_use_v1_ioctl = true;
> +			break;
> +		case 't':
> +			test_for_v2_policy_support();
> +			return 0;
> +		default:
> +			return command_usage(&get_encpolicy_cmd);
> +		}
> +	}
> +	argc -= optind;
> +	argv += optind;
> +
> +	if (argc != 0)
> +		return command_usage(&get_encpolicy_cmd);
> +
> +	/* first try the new ioctl */
> +	if (only_use_v1_ioctl) {
> +		res = -1;
> +		errno = ENOTTY;
> +	} else {
> +		arg.policy_size = sizeof(arg.policy);
> +		res = ioctl(file->fd, FS_IOC_GET_ENCRYPTION_POLICY_EX, &arg);
> +	}
> +
> +	/* fall back to the old ioctl */
> +	if (res != 0 && errno == ENOTTY)
> +		res = ioctl(file->fd, FS_IOC_GET_ENCRYPTION_POLICY,
> +			    &arg.policy.v1);
> +
> +	if (res != 0) {
>  		fprintf(stderr, "%s: failed to get encryption policy: %s\n",
>  			file->name, strerror(errno));
>  		exitcode = 1;
>  		return 0;
>  	}
>  
> -	printf("Encryption policy for %s:\n", file->name);
> -	printf("\tPolicy version: %u\n", policy.version);
> -	printf("\tMaster key descriptor: %s\n",
> -	       keydesc2str(policy.master_key_descriptor));
> -	printf("\tContents encryption mode: %u (%s)\n",
> -	       policy.contents_encryption_mode,
> -	       mode2str(policy.contents_encryption_mode));
> -	printf("\tFilenames encryption mode: %u (%s)\n",
> -	       policy.filenames_encryption_mode,
> -	       mode2str(policy.filenames_encryption_mode));
> -	printf("\tFlags: 0x%02x\n", policy.flags);
> +	switch (arg.policy.version) {
> +	case FSCRYPT_POLICY_V1:
> +		show_v1_encryption_policy(&arg.policy.v1);
> +		break;
> +	case FSCRYPT_POLICY_V2:
> +		show_v2_encryption_policy(&arg.policy.v2);
> +		break;
> +	default:
> +		printf("Encryption policy for %s:\n", file->name);
> +		printf("\tPolicy version: %u (unknown)\n", arg.policy.version);
> +		break;
> +	}
>  	return 0;
>  }
>  
> @@ -351,11 +467,13 @@ encrypt_init(void)
>  {
>  	get_encpolicy_cmd.name = "get_encpolicy";
>  	get_encpolicy_cmd.cfunc = get_encpolicy_f;
> +	get_encpolicy_cmd.args = _("[-1] [-t]");
>  	get_encpolicy_cmd.argmin = 0;
> -	get_encpolicy_cmd.argmax = 0;
> +	get_encpolicy_cmd.argmax = -1;
>  	get_encpolicy_cmd.flags = CMD_NOMAP_OK | CMD_FOREIGN_OK;
>  	get_encpolicy_cmd.oneline =
>  		_("display the encryption policy of the current file");
> +	get_encpolicy_cmd.help = get_encpolicy_help;
>  
>  	set_encpolicy_cmd.name = "set_encpolicy";
>  	set_encpolicy_cmd.cfunc = set_encpolicy_f;
> diff --git a/man/man8/xfs_io.8 b/man/man8/xfs_io.8
> index 6e064bdd..3dd34a0c 100644
> --- a/man/man8/xfs_io.8
> +++ b/man/man8/xfs_io.8
> @@ -724,10 +724,21 @@ version of policy structure (numeric)
>  .RE
>  .PD
>  .TP
> -.BR get_encpolicy
> +.BI "get_encpolicy [ \-1 ] [ \-t ]"
>  On filesystems that support encryption, display the encryption policy of the
>  current file.
> -
> +.RS 1.0i
> +.PD 0
> +.TP 0.4i
> +.BI \-1
> +Use only the old ioctl to get the encryption policy.  This only works if the
> +file has a v1 encryption policy.
> +.TP
> +.BI \-t
> +Test whether v2 encryption policies are supported.  Prints "supported",
> +"unsupported", or an error message.
> +.RE
> +.PD
>  .TP
>  .BR lsattr " [ " \-R " | " \-D " | " \-a " | " \-v " ]"
>  List extended inode flags on the currently open file. If the
> 
