#!/bin/bash -exu

apt-get update && apt-get install -y git

root_dir=$PWD

for tool in "kapp" "ytt" "vendir" "kbld"
do
  pushd "${tool}-release"
    sha=($(sha256sum ${tool}-linux-amd64))
    version=$(cat version)
    sed -i "3s/.*/pkgver=${version}/" "${root_dir}/k14s-aur-git/${tool}-bin/PKGBUILD"
    sed -i "10s/.*/sha256sums=(\"${sha}\")/" "${root_dir}/k14s-aur-git/${tool}-bin/PKGBUILD"
  popd
done

pushd "k14s-aur-git/"
  status="$(git status --porcelain)"
  if [[ -n "$status" ]]; then
    git config user.name "ci bot"
    git config user.email "azankich+pezu3vxe66-bot@pivotal.io"

    git add --all .
    git commit -m "update tools"
  fi
popd

shopt -s dotglob
cp -R "k14s-aur-git/." "updated-k14s-aur-git/"
