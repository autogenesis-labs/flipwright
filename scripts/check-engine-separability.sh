#!/usr/bin/env bash
# Engine separability check (R13, architecture.md §7):
#   1. No engine crate depends on a path outside engine/.
#   2. No FlipWright or pinball names inside engine/.
#   3. engine/ builds and passes its tests on its own, with the FlipWright crates removed.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
engine="$root/engine"

bad_deps="$(cargo metadata --format-version 1 --no-deps --manifest-path "$root/Cargo.toml" |
  jq -r --arg e "$engine/" '
    .packages[] | select(.manifest_path | startswith($e)) | . as $p
    | .dependencies[] | select(.path != null and ((.path + "/") | startswith($e) | not))
    | "\($p.name) -> \(.name) (\(.path))"')"
if [[ -n "$bad_deps" ]]; then
  echo "error: engine crates depend on code outside engine/:" >&2
  echo "$bad_deps" >&2
  exit 1
fi

if grep -rniE 'flipwright|pinball|flipper|plunger' "$engine"; then
  echo "error: game-specific names found in engine/ (see above)" >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cp -R "$engine" "$tmp/engine"
cp "$root/Cargo.lock" "$root/rust-toolchain.toml" "$tmp/engine/"
cat > "$tmp/engine/Cargo.toml" <<'TOML'
[workspace]
resolver = "3"
members = ["crates/*"]
TOML
cd "$tmp/engine"
cargo test --workspace --all-targets
echo "engine separability: ok"
