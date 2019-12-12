#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/util.sh

WEBRTC_ROOT=${WEBRTC_ROOT:-"/home/jiben/Documents/rtc/webrtc-checkout"}
DEBUG=${DEBUG:-0}

OUTDIR=${OUTDIR:-out}
CONFIGS=${CONFIGS:-Debug Release}
PACKAGE_FILENAME_PATTERN=${PACKAGE_FILENAME_PATTERN:-"webrtcbuilds-%to%-%tc%"}
PACKAGE_NAME_PATTERN=${PACKAGE_NAME_PATTERN:-"webrtcbuilds"}

[ "$DEBUG" = 1 ] && set -x

mkdir -p $OUTDIR
OUTDIR=$(cd $OUTDIR && pwd -P)

detect-platform
TARGET_OS=${TARGET_OS:-$PLATFORM}
TARGET_CPU=${TARGET_CPU:-x64}
echo "Host OS: $PLATFORM"
echo "Target OS: $TARGET_OS"
echo "Target CPU: $TARGET_CPU"

echo Packaging WebRTC
PACKAGE_FILENAME=$(interpret-pattern "$PACKAGE_FILENAME_PATTERN" "$PLATFORM" "$OUTDIR" "$TARGET_OS" "$TARGET_CPU" )

package::prepare $PLATFORM $OUTDIR $PACKAGE_FILENAME $DIR/resource "$CONFIGS" 

echo Packaging Done
