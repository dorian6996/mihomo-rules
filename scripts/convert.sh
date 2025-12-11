#!/usr/bin/env bash
set -euo pipefail
ROOT="$(pwd)"
TMPDIR="${ROOT}/tmp_dat"
OUTDIR="${ROOT}/lists"
GEOSITE_OUTDIR="${OUTDIR}/geosite"
GEOIP_OUTDIR="${OUTDIR}/geoip"
mkdir -p "$TMPDIR" "$OUTDIR" "$GEOSITE_OUTDIR" "$GEOIP_OUTDIR"
GEOIP_URL="https://github.com/jameszeroX/zkeen-ip/releases/latest/download/zkeenip.dat"
GEOSITE_URL="https://github.com/jameszeroX/zkeen-domains/releases/latest/download/zkeen.dat"
GEOIP_DAT="${TMPDIR}/zkeenip.dat"
GEOSITE_DAT="${TMPDIR}/zkeen.dat"
download_with_retry() {
  local url="$1"
  local output="$2"
  local max_attempts=5
  local attempt=1
  local wait_time=10
 
  while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt/$max_attempts: Downloading $(basename "$output")..."
   
    if curl -L --fail --connect-timeout 30 --max-time 300 --retry 3 --retry-delay 5 -o "$output" "$url"; then
      echo "✓ Successfully downloaded $(basename "$output")"
      return 0
    else
      echo "✗ Download failed (attempt $attempt/$max_attempts)"
      if [ $attempt -lt $max_attempts ]; then
        echo "Waiting ${wait_time}s before retry..."
        sleep $wait_time
        wait_time=$((wait_time * 2))
      fi
    fi
   
    attempt=$((attempt + 1))
  done
 
  echo "ERROR: Failed to download after $max_attempts attempts"
  return 1
}
echo "[1] Download .dat files..."
download_with_retry "$GEOIP_URL" "$GEOIP_DAT"  # Используем функцию для надёжности
download_with_retry "$GEOSITE_URL" "$GEOSITE_DAT"
echo "[2] Install geodat2srs..."
export GOPATH="${HOME}/go"
export GOBIN="${GOPATH}/bin"
mkdir -p "$GOBIN"
GO111MODULE=on go install github.com/runetfreedom/geodat2srs@latest
GEOCONV="${GOBIN}/geodat2srs"
if [ ! -x "$GEOCONV" ]; then
  echo "Error: geodat2srs not found at $GEOCONV"
  exit 1
fi
# Добавляем установку mihomo CLI для convert-ruleset
echo "[2.5] Install mihomo CLI for ruleset compilation..."
GO111MODULE=on go install github.com/MetaCubeX/mihomo/cmd/mihomo@latest
MIHOMO="${GOBIN}/mihomo"
if [ ! -x "$MIHOMO" ]; then
  echo "Error: mihomo not found at $MIHOMO"
  exit 1
fi
# Use a fresh temp output folder for the converter to avoid mixing old files
CONVERTER_TMP="${TMPDIR}/conv_out"
rm -rf "$CONVERTER_TMP"
mkdir -p "$CONVERTER_TMP"
echo "[3] Convert geoip -> temporary folder..."
"$GEOCONV" geoip -i "$GEOIP_DAT" -o "$CONVERTER_TMP" --prefix "zkeen-ip-"
echo "[4] Convert geosite -> temporary folder..."
"$GEOCONV" geosite -i "$GEOSITE_DAT" -o "$CONVERTER_TMP" --prefix "zkeen-site-"
echo "[5] Normalize outputs to lists/geoip and lists/geosite (as YAML source)..."
# Helper: process files matching a prefix (could be files or directories)
process_prefix() {
  prefix="$1"
  destdir="$2" # target lists subdir
  behavior="$3" # domain or ipcidr
  mkdir -p "$destdir"
  # find all files/dirs in CONVERTER_TMP that start with prefix
  shopt -s nullglob
  for entry in "${CONVERTER_TMP}/${prefix}"*; do
    name="$(basename "$entry")"
    # derive category name: remove prefix and any extension
    category="${name#${prefix}}"
    # remove common extensions
    category="${category%%.*}"
    # sanitize category (replace spaces with underscores)
    category="${category// /_}"
    tmpfile="${destdir}/${category}.tmp"
    yamlfile="${destdir}/${category}.yaml"
    # if entry is a dir, find all files inside; if file — cat it
    if [ -d "$entry" ]; then
      # collect all text content inside dir
      find "$entry" -type f -print0 | xargs -0 cat 2>/dev/null | sed '/^\s*$/d' | sort -u > "$tmpfile" || true
    else
      # assume it's a text file (if binary, converter shouldn't produce binary)
      cat "$entry" 2>/dev/null | sed '/^\s*$/d' | sort -u > "$tmpfile" || true
    fi
    # if produced non-empty tmp file, wrap in YAML payload
    if [ -s "$tmpfile" ]; then
      echo "payload:" > "$yamlfile"
      # add '-' prefix to each line for YAML list
      sed 's/^/  - /' "$tmpfile" >> "$yamlfile"
      rm -f "$tmpfile"
      echo "Prepared YAML source: $yamlfile"
    else
      rm -f "$tmpfile"
      echo "skipped empty category $category"
    fi
  done
  shopt -u nullglob
}
# process geoip and geosite prefixes with behavior
process_prefix "zkeen-ip-" "$GEOIP_OUTDIR" "ipcidr"
process_prefix "zkeen-site-" "$GEOSITE_OUTDIR" "domain"
echo "[5.5] Compile YAML sources to binary .mrs..."
# Compile all .yaml to .mrs
for yaml in "$GEOSITE_OUTDIR"/*.yaml "$GEOIP_OUTDIR"/*.yaml; do
  if [ -f "$yaml" ]; then
    category=$(basename "$yaml" .yaml)
    mrs="${yaml%.yaml}.mrs"
    # Detect behavior from dir
    if [[ "$yaml" == *geosite* ]]; then
      behavior="domain"
    else
      behavior="ipcidr"
    fi
    "$MIHOMO" convert-ruleset "$behavior" yaml "$yaml" "$mrs"
    if [ -f "$mrs" ]; then
      echo "Compiled $mrs"
      rm "$yaml"  # Optional: remove source after compile
    else
      echo "Failed to compile $yaml"
    fi
  fi
done
echo "[6] Cleanup"
rm -rf "$TMPDIR"
echo "Done. Generated binary .mrs files in ${OUTDIR}/ (geosite/ and geoip/)"
