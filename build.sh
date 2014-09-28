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

IMAGE_ID=`cat amazon-linux.tar | docker import - sowawa/amazon-linux`
docker tag $IMAGE_ID sowawa/amazon-linux:${VERSION}_`date +"%Y%m%d"`

test -e ./amazon-linux.tar && rm ./amazon-linux.tar
test -e ./build.cpid && rm ./build.cpid
test -e ./system-release && rm ./system-release
