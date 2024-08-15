#!/bin/sh

case "$1" in
  -h|--help|help) echo "sh migrate.sh [-f] [-o] [-a] [in-file] [out-file]"; exit 0;;
esac;

N="
";

case "$1" in
  -i|--install|install) INSTALL=1; shift;;
  *) echo "custom.pif.json migration script \
    $N  by osm0sis @ xda-developers $N";;
esac;

item() { echo "- $@"; }
die() { [ "$INSTALL" ] || echo "$N$N! $@"; exit 1; }
grep_get_json() { eval set -- "$(cat "$FILE" | tr -d '\r\n' | grep -m1 -o "\"$1\""'.*' | cut -d: -f2-)"; echo "$1" | sed -e 's|"|\\\\\\"|g' -e 's|[,}]*$||'; }
grep_check_json() { grep -q "$1" "$FILE" && [ "$(grep_get_json $1)" ]; }

case "$1" in
  -f|--force|force) FORCE=1; shift;;
esac;
case "$1" in
  -o|--override|override) OVERRIDE=1; shift;;
esac;
case "$1" in
  -a|--advanced|advanced) ADVANCED=1; shift;;
esac;

if [ -f "$1" ]; then
  FILE="$1";
  DIR="$1";
else
  case "$0" in
    *.sh) DIR="$0";;
    *) DIR="$(lsof -p $$ 2>/dev/null | grep -o '/.*migrate.sh$')";;
  esac;
fi;
DIR=$(dirname "$(readlink -f "$DIR")");
[ -z "$FILE" ] && FILE="$DIR/custom.pif.json";

OUT="$2";
[ -z "$OUT" ] && OUT="$DIR/custom.pif.json";

[ -f "$FILE" ] || die "No json file found";

grep_check_json api_level && [ ! "$FORCE" ] && die "No migration required";

[ "$INSTALL" ] || item "Parsing fields ...";

# Exclude INCREMENTAL, TYPE, TAGS, and ID from FPFIELDS
FPFIELDS="BRAND PRODUCT DEVICE RELEASE"
ALLFIELDS="MANUFACTURER MODEL FINGERPRINT $FPFIELDS SECURITY_PATCH"

for FIELD in $ALLFIELDS; do
  eval $FIELD=\"$(grep_get_json $FIELD)\";
done;

# Skip ID field processing
#if [ -n "$ID" ] && ! grep_check_json build.id; then
#  item 'Simple entry ID found, changing to ID field and "*.build.id" property ...';
#fi;

if [ -z "$RELEASE" -o "$OVERRIDE" ]; then
  if [ "$OVERRIDE" ]; then
    item "Overriding values for fields derivable from FINGERPRINT ...";
  else
    item "Missing default fields found, deriving from FINGERPRINT ...";
  fi;
  IFS='/:' read F1 F2 F3 F4 F5 F6 F7 F8 <<EOF
$(grep_get_json FINGERPRINT)
EOF
  i=1;
  for FIELD in $FPFIELDS; do
    eval [ -z \"\$$FIELD\" -o \"$OVERRIDE\" ] \&\& $FIELD=\"\$F$i\";
    i=$((i+1));
  done;
fi;

if [ -z "$SECURITY_PATCH" -o "$SECURITY_PATCH" = "null" ]; then
  item 'Missing required SECURITY_PATCH field and "*.security_patch" property value found, leaving empty ...';
  unset SECURITY_PATCH;
fi;

if [ -f "$OUT" ]; then
  item "Renaming old file to $(basename "$OUT").bak ...";
  mv -f "$OUT" "$OUT.bak";
fi;

[ "$INSTALL" ] || item "Writing fields and properties to updated custom.pif.json ...";

(echo "{";
for FIELD in $ALLFIELDS; do
  eval echo '\ \ \ \ \"$FIELD\": \"'\$$FIELD'\",';
done | sed '$s/,$//';  # Rimuove solo l'ultima virgola senza aggiungere graffe extra
if [ "$ADVANCED" ]; then
  echo "$N  // Advanced Settings";
  echo '    "verboseLogs": "0"';
fi
echo "}"
) > "$OUT";

[ "$INSTALL" ] || cat "$OUT";
