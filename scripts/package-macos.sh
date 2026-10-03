#!/usr/bin/env bash
# Build a self-contained macOS app (with its own Java runtime) via jpackage.
# Usage: scripts/package-macos.sh [app-image|dmg]   (default: app-image)
# Requires JDK 25+ in JAVA_HOME; run `mvn package` first.
set -euo pipefail

cd "$(dirname "$0")/.."
TYPE="${1:-app-image}"
JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 25+)}"
VERSION="$(sed -n 's:^    <version>\(.*\)</version>:\1:p' pom.xml | head -n1)"
# macOS bundle versions must not start with 0 and have at most three parts
APP_VERSION="$(echo "$VERSION" | sed -E 's/^([0-9]+)\.([0-9]+)\.0*([0-9]+).*/\1.\2.\3/')"

INPUT="target/jpackage-input"
OUT="target/jpackage"
rm -rf "$INPUT" "$OUT"
mkdir -p "$INPUT"
cp target/Zettelkasten.jar "$INPUT/"

"$JAVA_HOME/bin/jpackage" \
    --type "$TYPE" \
    --name Zettelkasten \
    --app-version "$APP_VERSION" \
    --vendor "Zettelkasten-Team" \
    --input "$INPUT" \
    --main-jar Zettelkasten.jar \
    --main-class de.danielluedecke.zettelkasten.ZettelkastenApp \
    --icon src/main/resources/logo/zkn3_2.icns \
    --mac-package-identifier de.danielluedecke.zettelkasten.ZettelkastenApp \
    --add-modules java.base,java.compiler,java.desktop,java.logging,java.management,java.naming,java.net.http,java.prefs,java.scripting,java.sql,java.xml,jdk.localedata,jdk.unsupported \
    --jlink-options "--strip-debug --no-man-pages --no-header-files" \
    --java-options "-Dapple.laf.useScreenMenuBar=true" \
    --dest "$OUT"

echo "Built: $(ls -d "$OUT"/*)"
