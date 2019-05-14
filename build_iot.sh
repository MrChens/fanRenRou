#!/bin/bash

#FIXME: the following var should move to a config file which like env.sh
CURRENT_DIR=`pwd`
PROJECT_DIR=${CURRENT_DIR}
BUILD_DIR=${PROJECT_DIR}/build
OUTPUT_DIR=${PROJECT_DIR}/output
OUTPUT_NAME_LIB="WSIotKit"

TEMP_STR="TEMP_STR"
CURRENT_ARCHITECTURE=`uname -m`
BUILD_MODE="Release"
LOG_MODE=${TEMP_STR}
INSTALL_PREFIX="."

function lowercase() {
    echo $1 | tr '[A-Z]' '[a-z]'
}

function generateXcode() {
	COUNT=$#
  echo "params count: ${COUNT}"

  PLATFORM=$1
  ARCHS=$2
  BUILD_TYPE=$3
  MAKE_LOG=$4
  echo "PLATFORM:${PLATFORM} ARCHS:${ARCHS} BUILD_TYPE=${BUILD_TYPE} MAKE_LOG=${MAKE_LOG}"

  XCODE_PROJ_DIR=./WSIotKit

  # OSX_SYSROOT="iphoneos"

  rm -rf ${XCODE_PROJ_DIR}
  mkdir -p ${XCODE_PROJ_DIR}
  pushd ${XCODE_PROJ_DIR}
  pwd
  cmake .. \
      -DPLATFORM=${PLATFORM} \
      -DCMAKE_OSX_SYSROOT=`lowercase ${OSX_SYSROOT}` \
      -DCMAKE_OSX_ARCHITECTURES="$(ARCHS)" \
      -G Xcode

  # xcodebuild -project WSIotKit.xcodeproj -scheme WSIotKit -sdk iphoneos12.1
  # xcodebuild -target WSIotKit -configuration Debug -showBuildSettings
  # /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS12.1.sdk
  # xcodebuild -target WSIotKit -configuration Debug SDKROOT=iphoneos
}

function build_mac() {
  COUNT=$#
  echo "params count: ${COUNT}"

  PLATFORM=$1
  ARCHS=$2
  BUILD_TYPE=$3
  MAKE_LOG=$4
  echo "PLATFORM:${PLATFORM} ARCHS:${ARCHS} BUILD_TYPE=${BUILD_TYPE} MAKE_LOG=${MAKE_LOG}"

  MAC_OUTPUT_DIR=${OUTPUT_DIR}/macos
  MAC_BUILD_DIR=${BUILD_DIR}/macos

  rm -rf ${MAC_OUTPUT_DIR}
  rm -rf ${MAC_BUILD_DIR}

  for ARCH in ${ARCHS}
    do
      echo "working with PLATFORM:${PLATFORM} arch: ${ARCH} "
      local TARGET_PATH_TMP=${MAC_OUTPUT_DIR}/${PLATFORM}.${ARCH}.target
      local BUILD_PATH_TMP=${MAC_BUILD_DIR}/${PLATFORM}.${ARCH}.build

      rm -rf ${BUILD_PATH_TMP}
      rm -rf ${TARGET_PATH_TMP}

      mkdir -p ${BUILD_PATH_TMP}
      mkdir -p ${TARGET_PATH_TMP}/lib/
      pushd ${BUILD_PATH_TMP}

      cmake ${PROJECT_DIR} \
          -DPLATFORM=${PLATFORM} \
          -DARCHITECTURE="${PLATFORM}.${ARCH}.target" \
          -DOUTPUT_NAME_LIB="${OUTPUT_NAME_LIB}" \
          -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DOUTPUT_DIR="${MAC_OUTPUT_DIR}"

      if [[ ${MAKE_LOG} == ${TEMP_STR} ]]; then
        make
      else
        make ${MAKE_LOG}
      fi

      make install
      IOTKIT_LIBS+="${TARGET_PATH_TMP}/lib/lib${OUTPUT_NAME_LIB}.a "
      IOTKIT_DYLIBS+="${TARGET_PATH_TMP}/lib/lib${OUTPUT_NAME_LIB}.dylib "
    done

    mkdir -p ${MAC_OUTPUT_DIR}/lib
    mkdir -p ${MAC_OUTPUT_DIR}/include

    lipo -create ${IOTKIT_LIBS} -output ${MAC_OUTPUT_DIR}/lib/lib${OUTPUT_NAME_LIB}.a
    lipo -create ${IOTKIT_DYLIBS} -output ${MAC_OUTPUT_DIR}/lib/lib${OUTPUT_NAME_LIB}.dylib

    cp -R ${MAC_BUILD_DIR}/macos.${ARCH}.build/include/* ${MAC_OUTPUT_DIR}/include/
}

function build_linux() {
  COUNT=$#
  echo "params count: ${COUNT}"

  PLATFORM=$1
  ARCHS=$2
  BUILD_TYPE=$3
  MAKE_LOG=$4
  echo "PLATFORM:${PLATFORM} ARCHS:${ARCHS} BUILD_TYPE=${BUILD_TYPE} MAKE_LOG=${MAKE_LOG}"

  LINUX_OUTPUT_DIR=${OUTPUT_DIR}/linux
  LINUX_BUILD_DIR=${BUILD_DIR}/linux

  rm -rf ${LINUX_OUTPUT_DIR}
  rm -rf ${LINUX_BUILD_DIR}

  for ARCH in ${ARCHS}
    do
      echo "working with PLATFORM:${PLATFORM} arch: ${ARCH} "
      local TARGET_PATH_TMP=${LINUX_OUTPUT_DIR}/${PLATFORM}.${ARCH}.target
      local BUILD_PATH_TMP=${LINUX_BUILD_DIR}/${PLATFORM}.${ARCH}.build

      rm -rf ${BUILD_PATH_TMP}
      rm -rf ${TARGET_PATH_TMP}

      mkdir -p ${BUILD_PATH_TMP}
      mkdir -p ${TARGET_PATH_TMP}/lib/
      pushd ${BUILD_PATH_TMP}

      cmake ${PROJECT_DIR} \
          -DPLATFORM=${PLATFORM} \
          -DARCHITECTURE="${PLATFORM}.${ARCH}.target" \
          -DOUTPUT_NAME_LIB="${OUTPUT_NAME_LIB}" \
          -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DOUTPUT_DIR="${LINUX_OUTPUT_DIR}"

      if [[ ${MAKE_LOG} == ${TEMP_STR} ]]; then
        make
      else
        make ${MAKE_LOG}
      fi

      make install

      IOTKIT_LIBS+="${TARGET_PATH_TMP}/lib/lib${OUTPUT_NAME_LIB}.a "
      IOTKIT_DYLIBS+="${TARGET_PATH_TMP}/lib/lib${OUTPUT_NAME_LIB}.dylib "
    done

    mkdir -p ${LINUX_OUTPUT_DIR}/lib
    mkdir -p ${LINUX_OUTPUT_DIR}/include

    lipo -create ${IOTKIT_LIBS} -output ${LINUX_OUTPUT_DIR}/lib/lib${OUTPUT_NAME_LIB}.a
    lipo -create ${IOTKIT_DYLIBS} -output ${LINUX_OUTPUT_DIR}/lib/lib${OUTPUT_NAME_LIB}.dylib

    cp -R ${LINUX_BUILD_DIR}/linux.${ARCH}.build/include/* ${LINUX_OUTPUT_DIR}/include/
}

function build_ios() {
  COUNT=$#
  echo "params count: ${COUNT}"

  PLATFORM=$1
  ARCHS=$2
  BUILD_TYPE=$3
  MAKE_LOG=$4

  echo "PLATFORM:${PLATFORM} ARCHS:${ARCHS} BUILD_TYPE=${BUILD_TYPE} MAKE_LOG=${MAKE_LOG}"

  IOS_OUTPUT_DIR=${OUTPUT_DIR}/iOS
  IOS_BUILD_DIR=${BUILD_DIR}/iOS

  rm -rf ${IOS_OUTPUT_DIR}
  rm -rf ${IOS_BUILD_DIR}

  for ARCH in ${ARCHS}
    do
      echo "working with arch: ${ARCH}"
      if [ ${ARCH} == "x86_64" ] || [ ${ARCH} == "i386" ]; then
        OSX_SYSROOT="iPhoneSimulator"
        EXTRA_CFLAGS=""
      else
        OSX_SYSROOT="iphoneos"
        EXTRA_CFLAGS="-fembed-bitcode"
      fi

      echo "working with OSX_SYSROOT: ${OSX_SYSROOT} arch: ${ARCH} "

      local TARGET_PATH_TMP=${IOS_OUTPUT_DIR}/${OSX_SYSROOT}.${ARCH}.target
      local BUILD_PATH_TMP=${IOS_BUILD_DIR}/${OSX_SYSROOT}.${ARCH}.build

      rm -rf ${BUILD_PATH_TMP}
      rm -rf ${TARGET_PATH_TMP}

      mkdir -p ${BUILD_PATH_TMP}
      mkdir -p ${TARGET_PATH_TMP}/lib/
      pushd ${BUILD_PATH_TMP}

      cmake ${PROJECT_DIR} \
          -DPLATFORM=${PLATFORM} \
          -DCMAKE_OSX_SYSROOT=`lowercase ${OSX_SYSROOT}` \
          -DCMAKE_OSX_ARCHITECTURES=${ARCH} \
          -DCMAKE_C_FLAGS=${EXTRA_CFLAGS} \
          -DARCHITECTURE="${OSX_SYSROOT}.${ARCH}.target" \
          -DOUTPUT_NAME_LIB="${OUTPUT_NAME_LIB}" \
          -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DOUTPUT_DIR="${IOS_OUTPUT_DIR}"

      if [[ ${MAKE_LOG} == ${TEMP_STR} ]]; then
        make
      else
        make ${MAKE_LOG}
      fi

      make install

      IOTKIT_LIBS+="${TARGET_PATH_TMP}/lib/lib${OUTPUT_NAME_LIB}.a "
      IOTKIT_DYLIBS+="${TARGET_PATH_TMP}/lib/lib${OUTPUT_NAME_LIB}.dylib "
    done

    mkdir -p ${IOS_OUTPUT_DIR}/lib
    mkdir -p ${IOS_OUTPUT_DIR}/include

    lipo -create ${IOTKIT_LIBS} -output ${IOS_OUTPUT_DIR}/lib/lib${OUTPUT_NAME_LIB}.a
    lipo -create ${IOTKIT_DYLIBS} -output ${IOS_OUTPUT_DIR}/lib/lib${OUTPUT_NAME_LIB}.dylib

    cp -R ${IOS_BUILD_DIR}/${OSX_SYSROOT}.${ARCH}.build/include/* ${IOS_OUTPUT_DIR}/include/
}

function usage() {
  echo ""
  echo "USEAGE:"
  echo -e " \t ./build_iot.sh [ios|mac|linux] [release|debug] [verbose]"
  echo ""
  echo "DESCRIPTION"
  echo -e " \t build_iot.sh is a shell that build iotKit with Multi-platform"
  echo ""
  echo "REQUIRED"
  echo -e " \t build_iot.sh should run with the following command line switchs:"
  echo -e "ios     \t build for iOS"
  echo -e "mac     \t build for macos"
  echo -e "linux   \t build for linux"
  echo -e "xcode     \t generate the Xcode project of libs for iOS"
  echo ""
  echo "OPTIONS"
  echo -e " \t build_iot.sh understands the following command line switches:"
  echo  ""
  echo -e "release \t Build iotKit with CFALGS=\"-O3 -DNDEBUG\", default is release"
  echo -e "debug   \t Build iotKit with CFALGS=\"-g -O0 -fsanitize=address -DDEBUG\""
  echo -e "verbose \t Build iotKit with \"make VERBOSE=1\" default is no verbose"
  echo ""
}

function configParams() {
  for var in $@; do
    if [[ ${var} == "release" ]]; then
      BUILD_MODE="Release"
    elif [[ ${var} == "debug" ]]; then
      BUILD_MODE="Debug"
    elif [[ ${var} == "verbose" ]]; then
      LOG_MODE="VERBOSE=1"
    fi
  done
}

function ios() {
  echo -e "build iotKit for iOS"
  configParams $@
  build_ios "ios" "arm64 armv7 x86_64 i386" ${BUILD_MODE} ${LOG_MODE}
    # build_ios "ios" "x86_64" ${BUILD_MODE} ${LOG_MODE}

}

function xcode() {
	echo -e "generate Xcode Project"
  configParams $@
	# generateXcode "ios" "arm64 armv7 x86_64 i386" ${BUILD_MODE} ${LOG_MODE}
    generateXcode "ios" "arm64" ${BUILD_MODE} ${LOG_MODE}

}

function linux() {
  echo -e "build iotKit for linux"
  configParams $@
  build_linux "linux" ${CURRENT_ARCHITECTURE} ${BUILD_MODE} ${LOG_MODE}
}

function macos() {
  echo -e "build iotKit for mac"
  configParams $@
  build_mac "macos" ${CURRENT_ARCHITECTURE} ${BUILD_MODE} ${LOG_MODE}
}

function main() {
  if [[ $# -lt 1 ]]; then
    usage
  else
    if [[ $1 == "ios" ]]; then
      ios $@
    elif [[ $1 == "mac" ]]; then
      macos $@
    elif [[ $1 == "linux" ]]; then
      linux $@
    elif [[ $1 == "xcode" ]]; then
    	xcode
    else
      usage
    fi
  fi
}

main $@
