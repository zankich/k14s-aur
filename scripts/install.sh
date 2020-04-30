#!/bin/bash -exu

for tool in "kapp-bin"  "kbld-bin"  "vendir-bin"  "ytt-bin"
do
	pushd ${tool}
		makepkg -sicC
	popd
done
