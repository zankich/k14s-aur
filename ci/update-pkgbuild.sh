#!/bin/bash -exu

pacman -Sy --noconfirm git base-devel

useradd -m notroot

chown -R notroot k14s-aur-git/*

root_dir=$PWD

for tool in "kapp" "ytt" "vendir" "kbld"
do
  pushd "${root_dir}/${tool}-release"
    sha=($(sha256sum ${tool}-linux-amd64))
    version=$(cat version)

    if [[ "$(grep 'pkgver=' ${root_dir}/k14s-aur-git/${tool}-bin/PKGBUILD)" == "pkgver=${version}" ]]; then
      continue
    fi

    sed -i "s/pkgver=.*/pkgver=${version}/" "${root_dir}/k14s-aur-git/${tool}-bin/PKGBUILD"
    sed -i "s/pkgrel=.*/pkgrel=1/" "${root_dir}/k14s-aur-git/${tool}-bin/PKGBUILD"
    sed -i "s/sha256sums=.*/sha256sums=(\"${sha}\")/" "${root_dir}/k14s-aur-git/${tool}-bin/PKGBUILD"
  popd

  pushd "${root_dir}/k14s-aur-git/${tool}-bin"
    su -c "makepkg --printsrcinfo > .SRCINFO" -m "notroot"
  popd

  pushd "${root_dir}/k14s-aur-git/"
    status="$(git status --porcelain)"
    if [[ -n "$status" ]]; then
      git config user.name "ci bot"
      git config user.email "azankich+pezu3vxe66-bot@pivotal.io"

      git add "${tool}-bin/PKGBUILD" "${tool}-bin/.SRCINFO"
      git commit -m "ci: update ${tool} to ${version}"
    fi
  popd
done

shopt -s dotglob
cp -R "k14s-aur-git/." "updated-k14s-aur-git/"
