#!/bin/bash -e

git submodule update --init --remote --checkout

clickable clean build click-build review

if [ ! -z $OPENSTORE_API_KEY ]; then
	echo "Publishing click pacakge in OpenStore"
	clickable publish
fi

