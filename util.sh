# Detect host platform.
# Set PLATFORM environment variable to override default behavior.
# Supported platform types - 'linux', 'win', 'mac'
# 'msys' is the git bash shell, built using mingw-w64, running under Microsoft
# Windows.
function detect-platform() {
  # set PLATFORM to android on linux host to build android
  case "$OSTYPE" in
  darwin*)      PLATFORM=${PLATFORM:-mac} ;;
  linux*)       PLATFORM=${PLATFORM:-linux} ;;
  win32*|msys*) PLATFORM=${PLATFORM:-win} ;;
  *)            echo "Building on unsupported OS: $OSTYPE"; exit 1; ;;
  esac
}

# This prepares artifacts to be packaged.
# $1: The platform type.
# $2: The output directory.
# $3: The package filename.
# $4: The project's resource dirctory.
# $5: The build configurations.
# $6: : The revision number.
function package::prepare() {
  local platform="$1"
  local outdir="$2"
  local package_filename="$3"
  local resourcedir="$4"
  local configs="$5"

  if [ $platform = 'mac' ]; then
    CP='gcp'
  else
    CP='cp'
  fi
  pushd $outdir >/dev/null
  # create directory structure
  mkdir -p $package_filename/include $package_filename/lib
  for cfg in $configs; do
    mkdir -p $package_filename/lib/$cfg
  done

  # find and copy header files
  # copy all non third-party header files first then copy only the third-party
  # header files that are required such as abseil-cpp for optional.h

  pushd ${WEBRTC_ROOT}/src >/dev/null

  local headersSourceDir=.
  local headersDestDir=$outdir/$package_filename/include
  find $headersSourceDir -path './third_party*' -prune -o -name '*.h' -exec $CP --parents '{}' $headersDestDir ';'
  popd >/dev/null
  # find and copy libraries
  pushd src/out >/dev/null
  find . -maxdepth 3 \( -name '*.so' -o -name '*.dll' -o -name '*webrtc_full*' -o -name *.jar \) \
    -exec $CP --parents '{}' $outdir/$package_filename/lib ';'
  popd >/dev/null

  # for linux, add pkgconfig files
#  if [ $platform = 'linux' ]; then
#    for cfg in $configs; do
#      mkdir -p $package_filename/lib/$cfg/pkgconfig
#      CONFIG=$cfg envsubst '$CONFIG' < $resourcedir/pkgconfig/libwebrtc_full.pc.in > \
#        $package_filename/lib/$cfg/pkgconfig/libwebrtc_full.pc
#    done
#  fi
  popd >/dev/null
}

# This interprets a pattern and returns the interpreted one.
# $1: The pattern.
# $2: The output directory.
# $3: The platform type.
# $4: The target os for cross-compilation.
# $5: The target cpu for cross-compilation.
function interpret-pattern() {
  local pattern="$1"
  local platform="$2"
  local outdir="$3"
  local target_os="$4"
  local target_cpu="$5"

  pattern=${pattern//%p%/$platform}
  pattern=${pattern//%to%/$target_os}
  pattern=${pattern//%tc%/$target_cpu}

  echo "$pattern"
}
