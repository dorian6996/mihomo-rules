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

# Функция для скачивания с retry
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
download_with_retry "$GEOIP_URL" "$GEOIP_DAT"
download_with_retry "$GEOSITE_URL" "$GEOSITE_DAT"

echo "[2] Install geodat2srs..."
export GOPATH="${HOME}/go"
export GOBIN="${GOPATH}/bin"
mkdir -p "$GOBIN"
GO111MODULE=on go install github.com/runetfreedom/geodat2srs@latest

GEOCONV="${GOBIN}/geodat2srs"
CONVERTER_TMP="${TMPDIR}/conv_out"
rm -rf "$CONVERTER_TMP"
mkdir -p "$CONVERTER_TMP"

echo "[3] Convert GeoIP → temporary folder..."
"$GEOCONV" geoip -i "$GEOIP_DAT" -o "$CONVERTER_TMP" --prefix "zkeen-ip-" --format mrs

echo "[4] Convert GeoSite → temporary folder..."
"$GEOCONV" geosite -i "$GEOSITE_DAT" -o "$CONVERTER_TMP" --prefix "zkeen-site-" --format mrs

echo "[5] Process and move files to lists/geoip and lists/geosite"

process_prefix() {
  prefix="$1"
  destdir="$2"
  
  mkdir -p "$destdir"
  shopt -s nullglob
  
  for entry in "${CONVERTER_TMP}/${prefix}"*; do
    name="$(basename "$entry")"
    category="${name#${prefix}}"
    category="${category%%.*}"
    category="${category// /_}"
    outfile="${destdir}/${category}.mrs"
    
    if [ -d "$entry" ]; then
      find "$entry" -type f -print0 | xargs -0 cat 2>/dev/null > "$outfile.tmp" || true
    else
      cp "$entry" "$outfile.tmp" || true
    fi
    
    if [ -s "$outfile.tmp" ]; then
      mv "$outfile.tmp" "$outfile"
      echo "Created $outfile"
    else
      rm -f "$outfile.tmp"
      echo "Skipped empty category $category"
    fi
  done
  
  shopt -u nullglob
}

process_prefix "zkeen-ip-" "$GEOIP_OUTDIR"
process_prefix "zkeen-site-" "$GEOSITE_OUTDIR"

echo "[6] Cleanup"
rm -rf "$TMPDIR"

echo "Done. Generated .mrs files in ${OUTDIR}/ (geosite/ and geoip/)"
