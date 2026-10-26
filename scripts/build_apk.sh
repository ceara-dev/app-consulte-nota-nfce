#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
else
  FLUTTER=(flutter)
fi

MODE="${MODE:-release}"
if [[ "$MODE" != "release" && "$MODE" != "debug" ]]; then
  echo "MODE deve ser 'release' ou 'debug' (recebido: $MODE)" >&2
  exit 1
fi

VERSION="$(awk '/^version:/ {print $2}' pubspec.yaml | cut -d+ -f1)"
OUT_DIR="$ROOT_DIR/dist"
ARTIFACT="nota-clara-${VERSION}-${MODE}.apk"

echo "==> Flutter"
"${FLUTTER[@]}" --version | sed -n '1p'

echo "==> Dependências"
"${FLUTTER[@]}" pub get

echo "==> Build ($MODE)"
if [[ "$MODE" == "release" ]]; then
  "${FLUTTER[@]}" build apk --release
  SOURCE="$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"
else
  "${FLUTTER[@]}" build apk --debug
  SOURCE="$ROOT_DIR/build/app/outputs/flutter-apk/app-debug.apk"
fi

mkdir -p "$OUT_DIR"
cp "$SOURCE" "$OUT_DIR/$ARTIFACT"
(
  cd "$OUT_DIR"
  sha256sum "$ARTIFACT" > "$ARTIFACT.sha256"
)

echo
echo "APK gerado: $OUT_DIR/$ARTIFACT"
echo "Checksum:   $OUT_DIR/$ARTIFACT.sha256"
echo "Instale com: adb install -r \"$OUT_DIR/$ARTIFACT\""
