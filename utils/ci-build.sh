#!/bin/bash -e

# fallback/default script
build_linux() {
	mkdir -p ${BUILD_DIR}/build
	cd ${BUILD_DIR}/build

	cmake .. \
	      -GNinja \
	      -DI18N=1 \
	      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
	cmake --build .
}

# default platform
PLATFORM=${PLATFORM:-linux}

# Compatibility with Travis-CI and GitLab-CI
if [ ! -z ${TRAVIS_BUILD_DIR} ]; then
	BUILD_DIR=${TRAVIS_BUILD_DIR}
elif [ ! -z ${CI_PROJECT_DIR} ]; then
	BUILD_DIR=${CI_PROJECT_DIR}
else
	BUILD_DIR="$(readlink -f $(dirname "$(readlink -f "${0}")")/../)"
fi

# parallel jobs
export CPUS_USED=2
if command -v nproc >/dev/null; then
	export CPUS_USED=$(nproc)
elif command -v sysctl >/dev/null; then
	export CPUS_USED=$(sysctl -n hw.logicalcpu)
fi

echo "*****************************************"
echo "Building Kaidan"
echo "^^^^^^^^^^^^^^^"
echo "PLATFORM=${PLATFORM}"
echo "BUILD_DIR=${BUILD_DIR}"
echo "CPUS_USED=${CPUS_USED}"
echo "*****************************************"
echo

# start build
if [[ ${PLATFORM} == "ubuntu-touch" ]]; then
	./utils/build-ubuntu-touch.sh
	mv bin/ubuntu-touch/*.click .
elif [[ ${PLATFORM} == "osx" ]]; then
	QT_MACOS=/usr/local/opt/qt ./utils/build-mac.sh
elif [[ ${PLATFORM} == "ios" ]]; then
	QT_IOS=/tmp/qt-ios ./utils/build-ios.sh
elif [[ ${PLATFORM} == "linux-appimage" ]]; then
	./utils/build-linux-appimage.sh
elif [[ ${PLATFORM} == "linux" ]]; then
	build_linux
else
	echo "Unknown platform!"
	exit 1
fi
