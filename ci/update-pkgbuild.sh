#!/bin/bash -exu

pacman -Sy --noconfirm git

useradd -m notroot
su notroot

root_dir=$PWD

for tool in "kapp" "ytt" "vendir" "kbld"
do
  pushd "${root_dir}/${tool}-release"
    sha=($(sha256sum ${tool}-linux-amd64))
    version=$(cat version)
    sed -i "s/pkgver=.*/pkgver=${version}/" "${root_dir}/k14s-aur-git/${tool}-bin/PKGBUILD"
    sed -i "s/sha256sums=.*/sha256sums=(\"${sha}\")/" "${root_dir}/k14s-aur-git/${tool}-bin/PKGBUILD"
  popd

  pushd "${root_dir}/k14s-aur-git/${tool}-bin"
    makepkg --printsrcinfo > .SRCINFO
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
