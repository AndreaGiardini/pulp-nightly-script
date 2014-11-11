#!/bin/bash

#SETTINGS
projects='pulp pulp_puppet pulp_rpm pulp_ostree nectar pulp_openstack'
repoFolder='/var/www/html/pulp/'

pullReqs="$(curl --silent https://github.com/pulp/pulp/pulls | grep "^        #" | cut -c 10-)"

mkdir -p "$repoFolder"

pushd ~

for proj in $projects; do
    echo "Cloning $proj repo..."
    git clone https://github.com/pulp/$proj
    echo "Creating packages..."
    pushd $proj
    if [ $proj = "pulp" ]; then
        #If the project is pulp build a repo for each PR
        yum-builddep -y $(ls | grep .spec)
        for pr in $pullReqs; do
            git fetch origin pull/$pr/head:pr-$pr
            git checkout pr-$pr
            tito build --rpm --test
            mkdir -p "$repoFolder$pr"
            mv /tmp/tito/* "$repoFolder$pr"
        done
        git checkout master
        tito build --rpm --test
        mkdir -p "${repoFolder}master"
        mv /tmp/tito/* "${repoFolder}master"
    else
        yum-builddep -y $(ls | grep .spec)
        tito build --rpm --test
        #Copy results for each folder
        for pr in $pullReqs; do
            cp -r /tmp/tito/* "$repoFolder$pr"
        done
        cp -r /tmp/tito/* "${repoFolder}master"
        rm -fr /tmp/tito/*
    fi
    popd
done

for pr in $pullReqs; do
    createrepo "$repoFolder$pr"
done
createrepo "${repoFolder}master"
