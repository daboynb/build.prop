##!/system/bin/sh
#
# To be run with the /system/build.prop (build.prop) and
# /vendor/build.prop (vendor-build.prop) from the stock
# ROM of a device you want to spoof values from

# system build.prop to custom.pif.json/.prop creator \
#        by osm0sis @ xda-developers"

item() { echo "\n- $@"; }
die() { echo "\n\n! $@"; exit 1; }
file_getprop() { grep "^$2=" "$1" 2>/dev/null | tail -n1 | cut -d= -f2-; }

case $0 in
  *.sh) shdir="$0";;
     *) shdir="$(lsof -p $$ 2>/dev/null | grep -o '/.*gen_custom_pif.sh$')";;
esac;
shdir=$(dirname "$(readlink -f "$shdir")");

cd $shdir;

case $1 in
  json|prop) FORMAT=$1;;
  "") FORMAT=json;;
esac;
item "Using format: $FORMAT";

[ ! -f build.prop ] \
   && die "No build.prop files found in script directory";

item "Parsing build.prop(s) ...";

PRODUCT=$(file_getprop build.prop ro.product.name);
DEVICE=$(file_getprop build.prop ro.product.device);
MANUFACTURER=$(file_getprop build.prop ro.product.manufacturer);
BRAND=$(file_getprop build.prop ro.product.brand);
MODEL=$(file_getprop build.prop ro.product.model);
FINGERPRINT=$(file_getprop build.prop ro.build.fingerprint);
BUILD_ID=$(file_getprop build.prop ro.product.build.id);
VNDK_VERSION=$(file_getprop build.prop ro.product.vndk.version);

[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop build.prop ro.product.system.name);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop build.prop ro.product.system.device);
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop build.prop ro.product.system_ext.manufacturer);
[ -z "$BRAND" ] && BRAND=$(file_getprop build.prop ro.product.system.brand);
[ -z "$MODEL" ] && MODEL=$(file_getprop build.prop ro.product.system.model);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop build.prop ro.system.build.fingerprint);
[ -z "$BUILD_ID" ] && BUILD_ID=$(file_getprop build.prop ro.product.build.id);
[ -z "$VNDK_VERSION" ] && VNDK_VERSION=$(file_getprop build.prop ro.product.vndk.version);

case $DEVICE in
  generic) die "Generic /system/build.prop values found, rename to system-build.prop and add product-build.prop";;
esac;

[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop build.prop ro.product.product.name);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop build.prop ro.product.product.device);
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop product-build.prop ro.product.product.manufacturer);
[ -z "$BRAND" ] && BRAND=$(file_getprop build.prop ro.product.product.brand);
[ -z "$MODEL" ] && MODEL=$(file_getprop build.prop ro.product.product.model);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop build.prop ro.product.build.fingerprint);
[ -z "$BUILD_ID" ] && BUILD_ID=$(file_getprop build.prop ro.product.build.id);
[ -z "$VNDK_VERSION" ] && VNDK_VERSION=$(file_getprop build.prop ro.product.vndk.version);

if [ -z "$FINGERPRINT" ]; then
  if [ -f build.prop ]; then
    die "No fingerprint found, use a /system/build.prop to start";
  else
    die "No fingerprint found, unable to continue";
  fi;
fi;
echo "$FINGERPRINT";

LIST="PRODUCT DEVICE MANUFACTURER BRAND MODEL FINGERPRINT";

item "Parsing build UTC date ...";
UTC=$(file_getprop build.prop ro.build.date.utc);
[ -z "$UTC" ] && UTC=$(file_getprop build.prop ro.build.date.utc);
date -u -d @$UTC;

if [ "$UTC" -gt 1521158400 ]; then
  item "Build date newer than March 2018, adding SECURITY_PATCH ...";
  SECURITY_PATCH=$(file_getprop build.prop ro.build.version.security_patch);
  [ -z "$SECURITY_PATCH" ] && SECURITY_PATCH=$(file_getprop build.prop ro.build.version.security_patch);
  LIST="$LIST SECURITY_PATCH";
  echo "$SECURITY_PATCH";
fi;

item "Parsing build first API level ...";
FIRST_API_LEVEL=$(file_getprop build.prop ro.product.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop build.prop ro.board.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop build.prop ro.board.api_level);

if [ -z "$FIRST_API_LEVEL" ]; then
  [ ! -f build.prop ] && die "No first API level found, add vendor-build.prop";
  item "No first API level found, falling back to build SDK version ...";
  [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop build.prop ro.build.version.sdk);
  [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop build.prop ro.system.build.version.sdk);
  [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop build.prop ro.build.version.sdk);
  [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop build.prop ro.system.build.version.sdk);
  [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop build.prop ro.vendor.build.version.sdk);
  [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop build.prop ro.product.build.version.sdk);
fi;
echo "$FIRST_API_LEVEL";

if [ "$FIRST_API_LEVEL" -gt 32 ]; then
  item "First API level 33 or higher, resetting to 32 ...";
  FIRST_API_LEVEL=32;
fi;
LIST="$LIST FIRST_API_LEVEL";

if [ -f pif.$FORMAT ]; then
  item "Removing existing pif.$FORMAT ...";
  rm -f custom.pif.$FORMAT;
fi;

item "Writing new pif.$FORMAT ...";
[ "$FORMAT" = "json" ] && echo '{' | tee -a pif.json;

for PROP in $LIST; do
  case $FORMAT in
    json) eval echo '\ \ \"$PROP\": \"'\$$PROP'\",';;
    prop) eval echo $PROP=\$$PROP;;
  esac;
done | sed '$s/,//' | tee -a pif.$FORMAT;
[ "$FORMAT" = "json" ] && echo '}' | tee -a pif.json;
