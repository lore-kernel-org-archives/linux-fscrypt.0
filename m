Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-ed1-f54.google.com ([209.85.208.54]:42895 "EHLO
        mail-ed1-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726878AbfA0TpE (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 27 Jan 2019 14:45:04 -0500
Received: by mail-ed1-f54.google.com with SMTP id y20so11316139edw.9
        for <linux-fscrypt@vger.kernel.org>; Sun, 27 Jan 2019 11:45:03 -0800 (PST)
MIME-Version: 1.0
From: Thibaud Ecarot <thibaud.ecarot@gmail.com>
Date: Sun, 27 Jan 2019 14:44:51 -0500
Message-ID: <CA+XEK3=xSuRZJpfPmt0dLn6R-SWyA4h5tY1hEW33zSJLYN758w@mail.gmail.com>
Subject: Transparent encryption mechanism
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hello,

I am currently working on a transparent encryption mechanism that I
can use as a Linux kernel module. I will detail below my goal and how
I imagined a solution to meet my needs.

I wanted to contact you today to have your opinion on my solution and
to have some ways to follow on the function of the Linux kernel to
hooked. I am open to any suggestions.

Objective : Transparent encryption mechanism should be able to encrypt
and decrypt a file on the fly based on ACLs that have been defined by
a particular user (not necessarily root). The aim is to dispel the
attack vector by a root. The root account is usually intended for
administrators who may not have the credentials to see the contents of
a particular file. To achieve this goal, an authorized user should be
able to see the contents of a file. For unauthorized users, the file
will display the encrypted content.

My proposal : To achieve this, I think to write a Linux kernel module
that will create a hook on the call function which opens a file (I do
not know the name of this function, may be vfs_open). The hook will be
implemented with ftrace. My idea is to check ACLs before opening a
file and if there are particular ACLs for that file, I display an
encrypted file or the decrypted content of the file if the user has
rights on that file.

What do you think about this idea ? I know there are "Linux agents"
that do this work without being a Linux kernel module but I do not
know how they work because it does not have to be executed in the
userspace for security reasons. I am interested to know if you have
other ideas. Finally, I would like to find a document on the kernel
functions associated with the interface virtual file system because I
do not know the function to hooked.

Thanks in advance.
Thibaud.
