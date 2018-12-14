#!/bin/bash

#  Automatic build script for mbedtls
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Felix Schulze on 08.04.11.
#  Copyright 2010 Felix Schulze. All rights reserved.
#  modify this script by mingtingjian on 2015_08_06
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#  Change values here
#
VERSION="2.14.0"
SDKVERSION=`xcrun -sdk iphoneos --show-sdk-version`
#
###########################################################################
#
# Don't change anything here
CURRENTPATH=`pwd`
ARCHS="x86_64 armv7 armv7s arm64"
DEVELOPER=`xcode-select -print-path`

##########
mkdir -p mbedTLS
cd mbedTLS

set -e
if [ ! -e mbedtls-${VERSION}-gpl.tgz ]; then
    echo "Downloading mbedtls-${VERSION}-gpl.tgz"
    curl -O https://tls.mbed.org/download/mbedtls-${VERSION}-gpl.tgz
else
    echo "Using mbedtls-${VERSION}-gpl.tgz"
fi

if [ ! -e lib/libmbedtls.a ]; then
    rm -rf bin
    rm -rf lib

    mkdir -p bin
    mkdir -p lib
    mkdir -p src

    for ARCH in ${ARCHS}
    do
        if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
            PLATFORM="iPhoneSimulator"
        else
            PLATFORM="iPhoneOS"
        fi

        tar zxvf mbedtls-${VERSION}-gpl.tgz -C src
    	cp src/mbedtls-${VERSION}/configs/config-suite-b.h src/mbedtls-${VERSION}/include/config.h
        cd src/mbedtls-${VERSION}/library


        echo "Building mbedtls for ${PLATFORM} ${SDKVERSION} ${ARCH}"

        echo "Patching Makefile..."
        sed -i.bak '4d' ${CURRENTPATH}/mbedTLS/src/mbedtls-${VERSION}/library/Makefile

        echo "Please stand by..."

        export DEVROOT="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
        export SDKROOT="${DEVROOT}/SDKs/${PLATFORM}${SDKVERSION}.sdk"
        export BUILD_TOOLS="${DEVELOPER}"
        export CC="${BUILD_TOOLS}/usr/bin/gcc -fembed-bitcode -arch ${ARCH}"
        #export CC=${BUILD_TOOLS}/usr/bin/gcc
        #export LD=${BUILD_TOOLS}/usr/bin/ld
        #export CPP=${BUILD_TOOLS}/usr/bin/cpp
        #export CXX=${BUILD_TOOLS}/usr/bin/g++
        #export AR=${DEVROOT}/usr/bin/ar
        #export AS=${DEVROOT}/usr/bin/as
        #export NM=${DEVROOT}/usr/bin/nm
        #export CXXCPP=${BUILD_TOOLS}/usr/bin/cpp
        #export RANLIB=${BUILD_TOOLS}/usr/bin/ranlib
        export LDFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT}"
        export CFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${CURRENTPATH}/mbedTLS/src/mbedtls-${VERSION}/include -DMBEDTLS_CONFIG_FILE='<config.h>'"

        make

        cp libmbedtls.a ${CURRENTPATH}/mbedTLS/bin/libmbedtls-${ARCH}.a
        cp libmbedx509.a ${CURRENTPATH}/mbedTLS/bin/libmbedx509-${ARCH}.a
        cp libmbedcrypto.a ${CURRENTPATH}/mbedTLS/bin/libmbedcrypto-${ARCH}.a
        cp -R ${CURRENTPATH}/mbedTLS/src/mbedtls-${VERSION}/include ${CURRENTPATH}/mbedTLS
        cp ${CURRENTPATH}/mbedTLS/src/mbedtls-${VERSION}/LICENSE ${CURRENTPATH}/mbedTLS/include/mbedtls/LICENSE
        cd ${CURRENTPATH}/mbedTLS
        rm -rf src/mbedtls-${VERSION}

    done

    lipo -create ${CURRENTPATH}"/mbedTLS/bin/libmbedtls-x86_64.a" ${CURRENTPATH}"/mbedTLS/bin/libmbedtls-armv7.a" ${CURRENTPATH}"/mbedTLS/bin/libmbedtls-armv7s.a" ${CURRENTPATH}"/mbedTLS/bin/libmbedtls-arm64.a" -output ${CURRENTPATH}"/mbedTLS/lib/libmbedtls.a"
    lipo -create ${CURRENTPATH}"/mbedTLS/bin/libmbedx509-x86_64.a" ${CURRENTPATH}"/mbedTLS/bin/libmbedx509-armv7.a" ${CURRENTPATH}"/mbedTLS/bin/libmbedx509-armv7s.a" ${CURRENTPATH}"/mbedTLS/bin/libmbedx509-arm64.a" -output ${CURRENTPATH}"/mbedTLS/lib/libmbedx509.a"
    lipo -create ${CURRENTPATH}"/mbedTLS/bin/libmbedcrypto-x86_64.a" ${CURRENTPATH}"/mbedTLS/bin/libmbedcrypto-armv7.a" ${CURRENTPATH}"/mbedTLS/bin/libmbedcrypto-armv7s.a" ${CURRENTPATH}"/mbedTLS/bin/libmbedcrypto-arm64.a" -output ${CURRENTPATH}"/mbedTLS/lib/libmbedcrypto.a"

    echo "Build library..."
else
    echo "Using existing libs"
fi

echo "Building done."
