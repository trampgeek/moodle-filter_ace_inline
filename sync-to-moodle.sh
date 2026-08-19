#!/usr/bin/env bash
# Mirrors this plugin into the moodle-dev checkout for testing, and (unless
# --no-build is passed) rebuilds its AMD JS there using Moodle's own Grunt
# tooling, copying the resulting amd/build/* output back into this repo.
#
# Moodle's AMD build resolves each source file's real filesystem path to work
# out its module name, so the plugin has to physically exist inside the
# moodle-dev checkout while building - a symlink pointing back to this repo
# does not work. See ../moodle-filter_editor_selector/CLAUDE.md for the full
# explanation (discovered there first; this script is copied from that
# plugin's sync-to-moodle.sh with the destination path changed).
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOODLE_DIR="${MOODLE_DIR:-$HOME/working/moodle-dev/moodle}"
DEST="$MOODLE_DIR/public/filter/ace_inline"
# Node 22 is what Moodle's Grunt tooling expects. Default is the Homebrew location on macOS;
# override NODE_BIN elsewhere, or leave it unset/empty to use whatever node is already on PATH.
NODE_BIN="${NODE_BIN-/opt/homebrew/opt/node@22/bin}"

if [ ! -d "$MOODLE_DIR" ]; then
    echo "Error: Moodle checkout not found at $MOODLE_DIR" >&2
    exit 1
fi

mkdir -p "$DEST"
rsync -a --delete --exclude='.git' --exclude='sync-to-moodle.sh' "$SRC/" "$DEST/"
echo "Synced $SRC -> $DEST"

if [ "${1:-}" = "--no-build" ]; then
    exit 0
fi

if [ ! -d "$SRC/amd/src" ]; then
    exit 0
fi

(
    cd "$MOODLE_DIR"
    PATH="${NODE_BIN:+$NODE_BIN:}$PATH" npx grunt amd --root=public/filter/ace_inline --force
)

rsync -a "$DEST/amd/build/" "$SRC/amd/build/"
echo "Copied built AMD JS back to $SRC/amd/build"
