#!/bin/bash

test -e build.cpid && rm build.cpid

docker run -e `cat http_proxy.txt` \
  -v `pwd`/:/mnt \
  --cidfile=./build.cpid \
  sowawa/amazon-linux \
  /bin/bash /mnt/create-amazon-linux-tar.sh

CONTAINER_ID=`cat ./build.cpid`

test -e ./amazon-linux.tar && rm amazon-linux.tar
sudo docker cp $CONTAINER_ID:/var/tmp/amazon-linux.tar .

test -e ./system-release && rm system-release
sudo docker cp $CONTAINER_ID:/etc/system-release .
# VERSION=`cat system-release | grep -o -e 20[1-9][0-9]\.[0-9][0-9] | sed -e 's/\.//'`
VERSION=`cat system-release | grep -o -e 20[1-9][0-9]\.[0-9][0-9]`

cat amazon-linux.tar | docker import - sowawa/amazon-linux

test -e ./amazon-linux.tar && rm ./amazon-linux.tar
test -e ./build.cpid && rm ./build.cpid
test -e ./system-release && rm ./system-release

test -e ./Dockerfile && rm ./Dockerfile
cat << _EOF_ > Dockerfile 2>&1
From sowawa/amazon-linux
MAINTAINER sowawa <keisuke.sogawa@gmail.com>

RUN /bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-ga
RUN /bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-beta
CMD 'echo'
_EOF_

docker build -t sowawa/amazon-linux .
docker tag sowawa/amazon-linux:latest sowawa/amazon-linux:${VERSION}_`date +"%Y%m%d"`
test -e ./Dockerfile && rm ./Dockerfile
