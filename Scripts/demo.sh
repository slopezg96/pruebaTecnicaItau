#!/bin/bash
# Demo end-to-end de la integración de CocoaPods + Fastlane (vía Bundler):
# instala dependencias, corre los tests unitarios con Fastlane y abre el
# reporte HTML generado. Pensado para correr en una demo en vivo con un
# solo comando.
#
# Uso: ./Scripts/demo.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
RESET="\033[0m"

section() {
  echo ""
  echo -e "${BOLD}${CYAN}== $1 ==${RESET}"
}

# --- Resolver un Ruby >= 3.0 (el Ruby de sistema de macOS suele ser 2.6.x,
# demasiado antiguo para las gems actuales de CocoaPods/Fastlane) ---
RUBY_BIN="ruby"
ruby_major_version() {
  "$1" -e 'print RUBY_VERSION.split(".")[0]' 2>/dev/null || echo 0
}

if [ "$(ruby_major_version ruby)" -lt 3 ]; then
  if [ -x /opt/homebrew/opt/ruby/bin/ruby ]; then
    RUBY_BIN="/opt/homebrew/opt/ruby/bin/ruby"
  elif [ -x /usr/local/opt/ruby/bin/ruby ]; then
    RUBY_BIN="/usr/local/opt/ruby/bin/ruby"
  else
    echo "El Ruby de sistema es < 3.0 y no se encontró un Ruby de Homebrew."
    echo "Instalalo con: brew install ruby"
    exit 1
  fi
fi
BUNDLE_BIN="$(dirname "$RUBY_BIN")/bundle"
[ -x "$BUNDLE_BIN" ] || BUNDLE_BIN="bundle"

echo -e "${BOLD}Demo: CocoaPods + Fastlane (BookStore)${RESET}"
echo "Ruby: $("$RUBY_BIN" -v)"

section "1/5 · bundle install (gems locales al proyecto, sin instalación global)"
"$BUNDLE_BIN" config set --local path 'vendor/bundle'
"$BUNDLE_BIN" install

section "2/5 · bundle exec pod install (CocoaPods)"
"$BUNDLE_BIN" exec pod install

section "3/5 · bundle exec fastlane test (11 tests XCTest en simulador)"
"$BUNDLE_BIN" exec fastlane test

section "4/5 · bundle exec fastlane build (compila la app para simulador)"
"$BUNDLE_BIN" exec fastlane build

section "5/5 · Reporte HTML de los tests"
REPORT="fastlane/test_output/report.html"
if [ -f "$REPORT" ]; then
  echo "Generado en: $REPORT"
  if command -v open >/dev/null 2>&1; then
    open "$REPORT"
  fi
else
  echo "No se encontró $REPORT (revisá la salida del paso 3/5)."
fi

echo ""
echo -e "${GREEN}${BOLD}Demo completa: CocoaPods instalado, Fastlane con 2 lanes corridos y verdes.${RESET}"
