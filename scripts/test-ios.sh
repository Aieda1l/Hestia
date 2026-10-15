#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

for executable in xcrun xcodebuild python3; do
    if ! command -v "$executable" >/dev/null 2>&1; then
        echo "BLOCKED: $executable is required on a Mac with Xcode installed" >&2
        exit 2
    fi
done

if [[ ! -d Hestia.xcodeproj ]]; then
    echo "BLOCKED: generate Hestia.xcodeproj with xcodegen generate first" >&2
    exit 2
fi

SIMULATOR_ID="$(xcrun simctl list -j devices available | python3 -c 'import json,re,sys; data=json.load(sys.stdin)["devices"]; matches=[d["udid"] for runtime,group in data.items() if (re.search(r"iOS-(\d+)",runtime) and int(re.search(r"iOS-(\d+)",runtime).group(1)) >= 17) for d in group if d.get("isAvailable") and d.get("name", "").startswith("iPhone")]; print(matches[0] if matches else "")')"
if [[ -z "$SIMULATOR_ID" ]]; then
    echo "BLOCKED: no available iPhone Simulator with iOS 17 or newer is installed" >&2
    exit 2
fi

xcodebuild -project Hestia.xcodeproj -scheme Hestia \
    -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
    CODE_SIGNING_ALLOWED=NO "$@"
