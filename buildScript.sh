#!/bin/bash

pushd ~

for r in pulp pulp_puppet pulp_rpm pulp_ostree nectar pulp_openstack; do
    echo "Cloning $r repo..."
    git clone https://github.com/pulp/$r
    echo "Creating packages..."
    pushd $r
    tito build --rpm --test
    popd
done

rm -fr /var/www/html/*
cp -r /tmp/tito/* /var/www/html
createrepo /var/www/html
