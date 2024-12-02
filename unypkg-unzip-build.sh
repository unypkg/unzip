#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1091,SC2154

set -vx

######################################################################################################################
### Setup Build System and GitHub

##apt install -y autopoint

wget -qO- uny.nu/pkg | bash -s buildsys

### Installing build dependencies
#unyp install python expat openssl

#pip3_bin=(/uny/pkg/python/*/bin/pip3)
#"${pip3_bin[0]}" install --upgrade pip
#"${pip3_bin[0]}" install docutils pygments

### Getting Variables from files
UNY_AUTO_PAT="$(cat UNY_AUTO_PAT)"
export UNY_AUTO_PAT
GH_TOKEN="$(cat GH_TOKEN)"
export GH_TOKEN

source /uny/git/unypkg/fn
uny_auto_github_conf

######################################################################################################################
### Timestamp & Download

uny_build_date

mkdir -pv /uny/sources
cd /uny/sources || exit

pkgname="unzip"
pkggit=""
gitdepth=""

### Get version info from git remote
# shellcheck disable=SC2086
latest_head="no-head"
latest_ver="6.0"
latest_commit_id="no-commit"

version_details

# Release package no matter what:
echo "newer" >release-"$pkgname"

wget https://sourceforge.net/projects/infozip/files/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz
tar xf unzip60.tar.gz
rm -f unzip60.tar.gz
mv zunzip60 unzip

cd "$pkg_git_repo_dir" || exit
wget https://www.linuxfromscratch.org/patches/blfs/12.2/unzip-6.0-consolidated_fixes-1.patch
wget https://www.linuxfromscratch.org/patches/blfs/12.2/unzip-6.0-gcc14-1.patch
patch -Np1 -i unzip-6.0-consolidated_fixes-1.patch
patch -Np1 -i unzip-6.0-gcc14-1.patch
cd /uny/sources || exit

archiving_source

######################################################################################################################
### Build

# unyc - run commands in uny's chroot environment
# shellcheck disable=SC2154
unyc <<"UNYEOF"
set -vx
source /uny/git/unypkg/fn

pkgname="unzip"

version_verbose_log_clean_unpack_cd
get_env_var_values
get_include_paths

####################################################
### Start of individual build script

unset LD_RUN_PATH

make -j"$(nproc)" -f unix/Makefile generic

make -j"$(nproc)" prefix=/uny/pkg/"$pkgname"/"$pkgver" -f unix/Makefile install

####################################################
### End of individual build script

add_to_paths_files
dependencies_file_and_unset_vars
cleanup_verbose_off_timing_end
UNYEOF

######################################################################################################################
### Packaging

package_unypkg
