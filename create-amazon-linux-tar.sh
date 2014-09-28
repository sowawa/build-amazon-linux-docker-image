#!/bin/bash

# Prepare yum install 
test -e /var/tmp/amazon-linux && rm -rf /var/tmp/amazon-linux
mkdir /var/tmp/amazon-linux

# Create my-yum.conf
rm -rf /etc/yum.repos.d/*.repo
cat <<_EOF_ > /tmp/my-yum.conf 2>&1

[amzn-main]
name=amzn-main-Base
mirrorlist=http://repo.ap-northeast-1.amazonaws.com/latest/main/mirror.list
mirror_expire=300
metadata_expire=300
priority=10
failovermethod=priority
fastestmirror_enabled=0
gpgcheck=0
# gpgcheck=1
# gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-ga
enabled=1
retries=5
timeout=10
report_instanceid=no

[amzn-updates]
name=amzn-updates-Base
mirrorlist=http://repo.ap-northeast-1.amazonaws.com/latest/updates/mirror.list
mirror_expire=300
metadata_expire=300
priority=10
failovermethod=priority
fastestmirror_enabled=0
gpgcheck=0
# gpgcheck=1
# gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-ga
enabled=1
retries=5
timeout=10
report_instanceid=no
_EOF_

# Install base packages and openssh
yum -c /tmp/my-yum.conf --installroot=/var/tmp/amazon-linux -y groupinstall "System Tools"
yum -c /tmp/my-yum.conf --installroot=/var/tmp/amazon-linux -y install openssh-server tar rootfiles sudo

# Create device files

# Prepare mk-dev.sh
cat << _EOF_ > /tmp/mk-dev.sh 2>&1
cd /var/tmp/amazon-linux/dev
mknod -m 666 null c 1 3
mknod -m 666 zero c 1 5
mknod -m 666 random c 1 8
mknod -m 666 urandom c 1 9
mkdir -m 755 pts
mkdir -m 1777 shm
mknod -m 666 tty c 5 0
mknod -m 666 tty0 c 4 0
mknod -m 666 tty1 c 4 1
mknod -m 666 tty2 c 4 2
mknod -m 666 tty3 c 4 3
mknod -m 666 tty4 c 4 4
mknod -m 600 console c 5 1
mknod -m 666 full c 1 7
mknod -m 600 initctl p
mknod -m 666 ptmx c 5 2
_EOF_

# Execute mk-dev.sh
bash /tmp/mk-dev.sh
rm /tmp/mk-dev.sh

cd /var/tmp/amazon-linux
tar -cf ../amazon-linux.tar .

echo 'Debug > build amazon-linux.tar'
