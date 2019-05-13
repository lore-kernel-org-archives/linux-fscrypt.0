Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Mon, 13 May 2019 12:12:05 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190513191204.GA142816@gmail.com>
References: <20190426204153.101861-1-ebiggers@kernel.org>
 <20190426204153.101861-5-ebiggers@kernel.org>
 <20190512122703.GJ15846@desktop>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190512122703.GJ15846@desktop>
Subject: Re: [f2fs-dev] [RFC PATCH 4/7] common/encrypt: add helper for
 ciphertext verification tests
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Eryu Guan <guaneryu@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, fstests@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eryu,

On Sun, May 12, 2019 at 08:27:03PM +0800, Eryu Guan wrote:
> > +# Retrieve the filename stored on-disk for the given file.
> > +# The name is printed to stdout in binary.
> > +_get_on_disk_filename()
> > +{
> > +	local device=$1
> > +	local inode=$2
> > +	local dir_inode=$3
> > +
> > +	case $FSTYP in
> > +	ext4)
> > +		# Extract the filename from the debugfs output line like:
> > +		#
> > +		#  131075  100644 (1)      0      0       0 22-Apr-2019 16:54 \xa2\x85\xb0z\x13\xe9\x09\x86R\xed\xdc\xce\xad\x14d\x19
> > +		#
> > +		$DEBUGFS_PROG $device -R "ls -l -r <$dir_inode>" \
> > +					2>>$seqres.full | perl -ne '
> > +			next if not /^\s*'$inode'\s+/;
> > +			s/.*?\d\d:\d\d //;
> > +			chomp;
> > +			s/\\x([[:xdigit:]]{2})/chr hex $1/eg;
> > +			print;'
> > +		;;
> > +	f2fs)
> > +		# Extract the filename from the dump.f2fs output line like:
> > +		#
> > +		#  i_name                        		[UpkzIPuts9by1oDmE+Ivfw]
> > +		#
> > +		# The name is base64-encoded, so we have to decode it here.
> > +		#
> > +		$DUMP_F2FS_PROG $device -i $inode | perl -ne '
> > +			next if not /^i_name\s+\[([A-Za-z0-9+,]+)\]/;
> > +			chomp $1;
> > +			my @chars = split //, $1;
> > +			my $ac = 0;
> > +			my $bits = 0;
> > +			my $table = join "", (A..Z, a..z, 0..9, "+", ",");
> > +			foreach (@chars) {
> > +				$ac += index($table, $_) << $bits;
> > +				$bits += 6;
> > +				if ($bits >= 8) {
> > +					print chr($ac & 0xff);
> > +					$ac >>= 8;
> > +					$bits -= 8;
> > +				}
> > +			}
> > +			if ($ac != 0) {
> > +				print STDERR "Invalid base64-encoded string!\n";
> > +			}'
> > +		;;
> > +	*)
> > +		_notrun "_get_on_disk_filename() isn't implemented on $FSTYP"
> 
> And looks like this function has nothing to do with fs encryption, move it to
> common/rc?

For ext4 that's true, but for f2fs the name is assumed to be base64-encoded,
which f2fs-tools only does for encrypted filenames.  I'll update the comment to
clarify that the function assumes the directory is encrypted.

> 
> > +		;;
> > +	esac
> > +}
> > +
> > +# Require support for _get_on_disk_filename()
> > +_require_get_on_disk_filename_support()
> > +{
> > +	echo "Checking for _get_on_disk_filename() support for $FSTYP" >> $seqres.full
> > +	case $FSTYP in
> > +	ext4)
> > +		# Verify that the "ls -l -r" debugfs command is supported and
> > +		# hex-encodes non-ASCII characters, rather than using an
> > +		# ambiguous escaping method.  This requires the e2fsprogs patch
> > +		# "debugfs: avoid ambiguity when printing filenames"
> > +		# (https://marc.info/?l=linux-ext4&m=155596495624232&w=2).
> > +		# TODO: once merged, list the minimum e2fsprogs version here.
> > +		_require_command "$DEBUGFS_PROG" debugfs
> > +		_scratch_mount
> > +		touch $SCRATCH_MNT/$'\xc1'
> > +		_scratch_unmount
> > +		if ! $DEBUGFS_PROG $SCRATCH_DEV -R "ls -l -r /" 2>&1 \
> > +			| tee -a $seqres.full | grep -E -q '\s+\\xc1\s*$'; then
> > +			_notrun "debugfs (e2fsprogs) is too old; doesn't support showing unambiguous on-disk filenames"
> > +		fi
> > +		;;
> > +	f2fs)
> > +		# Verify that dump.f2fs shows encrypted filenames in full.  This
> > +		# requires the patch "f2fs-tools: improve filename printing"
> > +		# (https://sourceforge.net/p/linux-f2fs/mailman/message/36648641/).
> > +		# TODO: once merged, list the minimum f2fs-tools version here.
> > +
> > +		_require_command "$DUMP_F2FS_PROG" dump.f2fs
> > +		_require_command "$KEYCTL_PROG" keyctl
> > +		_scratch_mount
> > +		_new_session_keyring
> > +
> > +		local keydesc=$(_generate_encryption_key)
> > +		local dir=$SCRATCH_MNT/test.${FUNCNAME[0]}
> > +		local file=$dir/$(perl -e 'print "A" x 255')
> > +		mkdir $dir
> > +		_set_encpolicy $dir $keydesc
> > +		touch $file
> > +		local inode=$(stat -c %i $file)
> > +
> > +		_scratch_unmount
> > +		$KEYCTL_PROG clear @s
> > +
> > +		# 255-character filename should result in 340 base64 characters.
> > +		if ! $DUMP_F2FS_PROG -i $inode $SCRATCH_DEV \
> > +			| grep -E -q '^i_name[[:space:]]+\[[A-Za-z0-9+,]{340}\]'; then
> > +			_notrun "dump.f2fs (f2fs-tools) is too old; doesn't support showing unambiguous on-disk filenames"
> > +		fi
> > +		;;
> > +	*)
> > +		_notrun "_get_on_disk_filename() isn't implemented on $FSTYP"
> > +		;;
> > +	esac
> > +}
> > +
> > +# Get the file's list of on-disk blocks as a comma-separated list of block
> > +# offsets from the start of the device.  "Blocks" are 512 bytes each here.
> > +_get_file_block_list()
> > +{
> > +	local file=$1
> > +
> > +	sync
> > +	$XFS_IO_PROG -c fiemap $file | perl -ne '
> > +		next if not /^\s*\d+: \[\d+\.\.\d+\]: (\d+)\.\.(\d+)/;
> > +		print $_ . "," foreach $1..$2;' | sed 's/,$//'
> > +}
> > +
> > +# Dump a block list that was previously saved by _get_file_block_list().
> > +_dump_file_blocks()
> > +{
> > +	local device=$1
> > +	local blocklist=$2
> > +	local block
> > +
> > +	for block in $(tr ',' ' ' <<< $blocklist); do
> > +		dd if=$device bs=512 count=1 skip=$block status=none
> > +	done
> > +}
> 
> Above two functions seem generic enough to be moved to common/rc

I feel that would be premature because common/rc is kind of bloated, and there's
a good chance these functions will only ever be used for encryption tests.
Normally, xfstests only test for user-visible behavior, so tests just 'cat' the
file contents, or 'ls' the filenames.  The encryption tests are somewhat special
in that they really care about what's *actually* stored on-disk.

So I think that common/encrypt is the most logical location for now.  But I
don't feel too strongly, and I can move it if you prefer.

Thanks for the review!

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
