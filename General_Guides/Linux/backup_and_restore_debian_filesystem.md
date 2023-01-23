Backup and Restore Debian Systems
=================================

## 1: Backing-up

"What should I use to backup my system then?" might you ask. Easy; the same thing you use to backup/compress everything else; TAR. Unlike Windows, Linux doesn't restrict root access to anything, so you can just throw every single file on a partition in a TAR file!

To do this, become root with

```bash
sudo su
```

and go to the root of your filesystem (we use this in our example, but you can go anywhere you want your backup to end up, including remote or removable drives.)

```bash
cd /
```

Now, below is the full command I would use to make a backup of my system:

```bash
tar cvpzf backup.tgz --exclude=/proc --exclude=/lost+found --exclude=/backup.tgz --exclude=/mnt --exclude=/sys /
```

Now, lets explain this a little bit.
The 'tar' part is, obviously, the program we're going to use.

'cvpfz' are the options we give to tar, like 'create archive' (obviously),
'preserve permissions'(to keep the same permissions on everything the same), and 'gzip' to keep the size down.

Next, the name the archive is going to get. backup.tgz in our example.

Next comes the root of the directory we want to backup. Since we want to backup everything; /

Now come the directories we want to exclude. We don't want to backup everything since some dirs aren't very useful to include. Also make sure you don't include the file itself, or else you'll get weird results.
You might also not want to include the /mnt folder if you have other partitions mounted there or you'll end up backing those up too. Also make sure you don't have anything mounted in /media (i.e. don't have any cd's or removable media mounted). Either that or exclude /media.

EDIT : kvidell suggests below we also exclude the /dev directory. I have other evidence that says it is very unwise to do so though.

Well, if the command agrees with you, hit enter (or return, whatever) and sit back&relax. This might take a while.

Afterwards you'll have a file called backup.tgz in the root of your filessytem, which is probably pretty large. Now you can burn it to DVD or move it to another machine, whatever you like!

EDIT2:
At the end of the process you might get a message along the lines of 'tar: Error exit delayed from previous errors' or something, but in most cases you can just ignore that.

Alternatively, you can use Bzip2 to compress your backup. This means higher compression but lower speed. If compression is important to you, just substitute
the 'z' in the command with 'j', and give the backup the right extension.

That would make the command look like this:

```bash
tar cvpjf backup.tar.bz2 --exclude=/proc --exclude=/lost+found --exclude=/backup.tar.bz2 --exclude=/mnt --exclude=/sys /
```

## 2: Restoring

Warning: Please, for goodness sake, be careful here. If you don't understand what you are doing here you might end up overwriting stuff that is important to you, so please take care!

Well, we'll just continue with our example from the previous chapter; the file backup.tgz in the root of the partition.

Once again, make sure you are root and that you and the backup file are in the root of the filesystem.

One of the beautiful things of Linux is that This'll work even on a running system; no need to screw around with boot-cd's or anything. Of course, if you've rendered your system unbootable you might have no choice but to use a live-cd, but the results are the same. You can even remove every single file of a Linux system while it is running with one command. I'm not giving you that command though!

Well, back on-topic.

This is the command that I would use:

```bash
tar xvpfz backup.tgz -C /
```

Or if you used bz2;

```bash
tar xvpfj backup.tar.bz2 -C /
```

WARNING: this will overwrite every single file on your partition with the one in the archive!

Just hit enter/return/your brother/whatever and watch the fireworks. Again, this might take a while. When it is done, you have a fully restored Ubuntu system! Just make sure that, before you do anything else, you re-create the directories you excluded:

```bash
mkdir proc
mkdir lost+found
mkdir mnt
mkdir sys
```

And when you reboot, everything should be the way it was when you made the backup!

## 2.1: GRUB restore

Now, if you want to move your system to a new harddisk or if you did something nasty to your GRUB (like, say, install Windows), You'll also need to reinstall GRUB.
There are several very good howto's on how to do that here on this forum, so i'm not going to reinvent the wheel. Instead, take a look here:

http://www.ubuntuforums.org/showthre...t=grub+restore

There are a couple of methods proposed. I personally recommend the second one, posted by remmelt, since that has always worked for me.

Well that's it! I hope it was helpful!

## References:
  - https://ubuntuforums.org/showthread.php?t=35087
