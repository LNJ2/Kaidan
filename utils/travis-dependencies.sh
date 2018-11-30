#!/bin/bash -e

echo "*****************************************"
echo "Fetching dependencies"
echo "^^^^^^^^^^^^^^^^^^^^^"
echo "PLATFORM=${PLATFORM}"
echo "*****************************************"

install_ecm() {
	git clone https://anongit.kde.org/extra-cmake-modules.git
	cd extra-cmake-modules
	cmake . -GNinja
	ninja install
	cd ..
	rm -rf extra-cmake-modules
}

dependencies_osx() {
	brew install qt ninja ccache
	install_ecm
}

dependencies_ios() {
	brew install ninja ccache p7zip
	install_ecm
	pip3 install requests

	QT_VERSION=5.11.2
	wget https://git.kaidan.im/lnj/qli-installer/raw/master/qli-installer.py
	chmod +x qli-installer.py
	./qli-installer.py $QT_VERSION mac ios

	mv $QT_VERSION/ios /tmp/qt-ios
	rmdir $QT_VERSION
}

if [[ ${PLATFORM} == "osx" ]]; then
	dependencies_osx
elif [[ ${PLATFORM} == "ios" ]]; then
	dependencies_ios
fi
