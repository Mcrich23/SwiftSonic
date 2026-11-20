#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

base_path="${1:-/}"
if [[ "$base_path" != /* || "$base_path" == *[\?\#\"\'\<\>\&\ ]* || "$base_path" == *..* ]]; then
    echo "Usage: ./build-site.sh [/hosting/base/path]" >&2
    exit 1
fi
base_path="${base_path%/}"
export CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$CLANG_MODULE_CACHE_PATH"

swift package --cache-path .build/cache --config-path .build/config \
    --security-path .build/security --disable-sandbox dump-symbol-graph

docc="$(dirname "$(command -v swift)")/docc"
if [[ ! -x "$docc" ]]; then
    docc="${DEVELOPER_DIR:-$(xcode-select -p)}/Toolchains/XcodeDefault.xctoolchain/usr/bin/docc"
fi
if [[ ! -x "$docc" ]]; then
    echo "DocC was not found. Select a full Xcode installation or use a Swift toolchain that includes DocC." >&2
    exit 1
fi
"$docc" convert Sources/SwiftSonic/SwiftSonic.docc \
    --additional-symbol-graph-dir .build/out/symbolgraph \
    --output-path Build \
    --fallback-display-name SwiftSonic \
    --fallback-bundle-identifier com.mcrich.swiftsonic \
    --hosting-base-path "${base_path:-/}" \
    --transform-for-static-hosting \
    --experimental-enable-custom-templates \
    --warnings-as-errors

mkdir -p Build/swiftsonic
cp -R Styling/. Build/swiftsonic/
python3 - "$base_path" <<'PY'
from pathlib import Path
import sys

base = sys.argv[1]
for page in Path("Build").rglob("*.html"):
    html = page.read_text()
    html = html.replace("</head>", '<link rel="stylesheet" href="/swiftsonic/theme.css"></head>')
    for attribute in ("href", "src"):
        for prefix in ("/swiftsonic/", "/documentation/swiftsonic/"):
            html = html.replace(f'{attribute}="{prefix}', f'{attribute}="{base}{prefix}')
    page.write_text(html)
PY

cat > Build/index.html <<HTML
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Swiftsonic 2026</title>
<meta http-equiv="refresh" content="0;url=${base_path}/documentation/swiftsonic/">
<link rel="canonical" href="${base_path}/documentation/swiftsonic/">
</head>
<body><a href="${base_path}/documentation/swiftsonic/">Swiftsonic 2026 conference guide</a></body>
</html>
HTML
touch Build/.nojekyll
echo "Built site in Build/; serve at ${base_path:-/} and open ${base_path}/documentation/swiftsonic/"
