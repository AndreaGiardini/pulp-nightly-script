#!/bin/bash

pushd ~

git clone https://github.com/pulp/pulp
pushd pulp
patch -p1 < ../api.patch
git add .
git commit -am "Apply patch"
#git checkout 2.5-dev
tito build --rpm --test
pushd agent
tito build --rpm --test
popd
popd

for r in pulp_puppet pulp_rpm pulp_ostree nectar pulp_openstack; do
    echo "checking out $r code"
    git clone https://github.com/pulp/$r
    echo "installing $r dev code"
    pushd $r
    #git checkout 2.5-dev
    tito build --rpm --test
    popd
done

rm -fr /var/www/html/*
cp -r /tmp/tito/* /var/www/html
createrepo /var/www/html
