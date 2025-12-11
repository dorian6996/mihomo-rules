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
curl -L --fail -o "$GEOIP_DAT" "$GEOIP_URL"
curl -L --fail -o "$GEOSITE_DAT" "$GEOSITE_URL"

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

# Use a fresh temp output folder for the converter to avoid mixing old files
CONVERTER_TMP="${TMPDIR}/conv_out"
rm -rf "$CONVERTER_TMP"
mkdir -p "$CONVERTER_TMP"

echo "[3] Convert geoip -> temporary folder..."
"$GEOCONV" geoip -i "$GEOIP_DAT" -o "$CONVERTER_TMP" --prefix "zkeen-ip-"

echo "[4] Convert geosite -> temporary folder..."
"$GEOCONV" geosite -i "$GEOSITE_DAT" -o "$CONVERTER_TMP" --prefix "zkeen-site-"

echo "[5] Normalize outputs to lists/geoip and lists/geosite..."

# Helper: process files matching a prefix (could be files or directories)
process_prefix() {
  prefix="$1"
  destdir="$2"   # target lists subdir
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

    outfile="${destdir}/${category}.mrs"

    # if entry is a dir, find all files inside; if file — cat it
    if [ -d "$entry" ]; then
      # collect all text content inside dir
      find "$entry" -type f -print0 | xargs -0 cat 2>/dev/null | sed '/^\s*$/d' | sort -u > "${outfile}.tmp" || true
    else
      # assume it's a text file (if binary, converter shouldn't produce binary)
      cat "$entry" 2>/dev/null | sed '/^\s*$/d' | sort -u > "${outfile}.tmp" || true
    fi

    # if produced non-empty tmp file, move to final (atomic)
    if [ -s "${outfile}.tmp" ]; then
      mv "${outfile}.tmp" "$outfile"
      echo "wrote $outfile"
    else
      rm -f "${outfile}.tmp"
      # if empty and existing file exists from previous run, keep existing (optional: remove)
      echo "skipped empty category $category"
    fi
  done
  shopt -u nullglob
}

# process geoip and geosite prefixes
process_prefix "zkeen-ip-" "$GEOIP_OUTDIR"
process_prefix "zkeen-site-" "$GEOSITE_OUTDIR"

echo "[6] Cleanup"
rm -rf "$TMPDIR"

echo "Done. Generated files in ${OUTDIR}/ (geosite/ and geoip/)"
