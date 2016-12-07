#!/bin/bash

set -eux

apt-get -yq update
apt-get -yq install apt-transport-https
apt-get -yq install autoconf
apt-get -yq install bsdtar
apt-get -yq install build-essential
apt-get -yq install ca-certificates
apt-get -yq install curl
apt-get -yq install libboost-dev
apt-get -yq install libboost-iostreams-dev
apt-get -yq install libcurl4-openssl-dev
apt-get -yq install libexpat1-dev
apt-get -yq install libglib2.0-dev
apt-get -yq install libgnutls-dev
apt-get -yq install libgoogle-perftools-dev
apt-get -yq install libncurses5-dev
apt-get -yq install libpstreams-dev
apt-get -yq install libreadline6-dev
apt-get -yq install libssl-dev
apt-get -yq install nettle-dev
apt-get -yq install nfs-common
apt-get -yq install python-software-properties
apt-get -yq install s3cmd
apt-get -yq install software-properties-common
apt-get -yq install unzip
apt-get -yq install time
apt-get -yq install zlib1g-dev
apt-get -yq install libpam-tmpdir
apt-get -yq install libcairo2-dev

### security upgrades and cleanup
unattended-upgrades
apt -yq autoremove
apt-get clean
