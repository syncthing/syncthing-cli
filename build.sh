#!/bin/bash
set -euo pipefail
set nullglob

echo Get dependencies
go get -d

rm -rf syncthing-cli-*-*

build() {
	export GOOS="$1"
	export GOARCH="$2"
	target="syncthing-cli-$GOOS-$GOARCH"
	go build -v
	mkdir "$target"
	if [ -f syncthing-cli ] ; then
		mv syncthing-cli "$target"
		tar zcvf "$target.tar.gz" "$target" 
	fi
	if [ -f syncthing-cli.exe ] ; then
	      	mv syncthing-cli.exe "$target"
		zip -r "$target.zip" "$target"
	fi
}

for goos in linux darwin windows solaris freebsd ; do
	build "$goos" amd64
done
for goos in linux windows freebsd ; do
	build "$goos" 386
done

# Hack used because we run as root under Docker
if [[ ${CHOWN_USER:-} != "" ]] ; then
	chown -R $CHOWN_USER .
fi
