#!/bin/sh

N="
";

item() { echo "$N- $@"; }
die() { echo "$N$N! $@"; exit 1; }

file_getprop() {
  grep -m1 "^$2=" "$1" 2>/dev/null | cut -d= -f2-
}

FORMAT=json;
LOCAL="$(readlink -f "$PWD")/";
cd "$LOCAL";

item "Using output directory: $LOCAL";

item "Parsing build.prop files ...";

# File paths
BUILD_PROP="build.prop"
PRODUCT_BUILD_PROP="product-build.prop"
VENDOR_BUILD_PROP="vendor-build.prop"

# Fields to extract
BRAND=$(file_getprop "$BUILD_PROP" ro.product.brand)
[ -z "$BRAND" ] && BRAND=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.product.brand)
[ -z "$BRAND" ] && BRAND=$(file_getprop "$VENDOR_BUILD_PROP" ro.product.vendor.brand)

DEVICE=$(file_getprop "$BUILD_PROP" ro.product.device)
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.product.device)
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$VENDOR_BUILD_PROP" ro.product.vendor.device)

FINGERPRINT=$(file_getprop "$BUILD_PROP" ro.build.fingerprint)
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.build.fingerprint)
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$VENDOR_BUILD_PROP" ro.vendor.build.fingerprint)

MANUFACTURER=$(file_getprop "$BUILD_PROP" ro.product.manufacturer)
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.product.manufacturer)
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$VENDOR_BUILD_PROP" ro.product.vendor.manufacturer)

MODEL=$(file_getprop "$BUILD_PROP" ro.product.model)
[ -z "$MODEL" ] && MODEL=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.product.model)
[ -z "$MODEL" ] && MODEL=$(file_getprop "$VENDOR_BUILD_PROP" ro.product.vendor.model)

PRODUCT=$(file_getprop "$BUILD_PROP" ro.product.name)
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.product.name)
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$VENDOR_BUILD_PROP" ro.product.vendor.name)

ID=$(file_getprop "$BUILD_PROP" ro.build.id)
[ -z "$ID" ] && ID=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.build.id)
[ -z "$ID" ] && ID=$(file_getprop "$VENDOR_BUILD_PROP" ro.vendor.build.id)

SECURITY_PATCH=$(file_getprop "$BUILD_PROP" ro.build.version.security_patch)
[ -z "$SECURITY_PATCH" ] && SECURITY_PATCH=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.build.version.security_patch)
[ -z "$SECURITY_PATCH" ] && SECURITY_PATCH=$(file_getprop "$VENDOR_BUILD_PROP" ro.vendor.build.version.security_patch)

DEVICE_INITIAL_SDK_INT=$(file_getprop "$BUILD_PROP" ro.product.first_api_level)
[ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop "$BUILD_PROP" ro.build.version.sdk)
[ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.first_api_level)
[ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop "$PRODUCT_BUILD_PROP" ro.product.build.version.sdk)
[ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop "$VENDOR_BUILD_PROP" ro.product.first_api_level)
[ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop "$VENDOR_BUILD_PROP" ro.vendor.build.version.sdk)

# Setting output file name
OUTPUT_FILE="${LOCAL}pif.${FORMAT}";

if [ -f "$OUTPUT_FILE" ]; then
  item "Removing existing $OUTPUT_FILE ...";
  rm -f "$OUTPUT_FILE";
fi;

item "Writing new $OUTPUT_FILE ...";
case $FORMAT in
  json) CMNT='  //'; EVALPRE='\ \ \ \ \"'; PRE='    "'; MID='": "'; POST='",';;
  prop) CMNT='#'; MID='=';;
esac;

{
  [ "$FORMAT" = "json" ] && echo '{';

  echo "${PRE}ID${MID}${ID}${POST}";
  echo "${PRE}BRAND${MID}${BRAND}${POST}";
  echo "${PRE}DEVICE${MID}${DEVICE}${POST}";
  echo "${PRE}FINGERPRINT${MID}${FINGERPRINT}${POST}";
  echo "${PRE}MANUFACTURER${MID}${MANUFACTURER}${POST}";
  echo "${PRE}MODEL${MID}${MODEL}${POST}";
  echo "${PRE}PRODUCT${MID}${PRODUCT}${POST}";
  echo "${PRE}SECURITY_PATCH${MID}${SECURITY_PATCH}${POST}";
  # echo "${PRE}DEVICE_INITIAL_SDK_INT${MID}${DEVICE_INITIAL_SDK_INT}${POST}"; 
  echo "${PRE}DEVICE_INITIAL_SDK_INT${MID}21\"";  # New line setting DEVICE_INITIAL_SDK_INT to 21

  [ "$FORMAT" = "json" ] && echo '}';
} | tee "$OUTPUT_FILE";

item "Finished generating $OUTPUT_FILE";
