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

echo "[1] Download .dat files..."
curl -L --fail -o "$GEOIP_DAT" "$GEOIP_URL"
curl -L --fail -o "$GEOSITE_DAT" "$GEOSITE_URL"

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
