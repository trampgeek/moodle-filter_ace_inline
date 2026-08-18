#!/usr/bin/env bash
# Fails if version.php's $plugin->release, README.md's top-of-file "Version
# X.Y.Z" line, and CHANGES.md's newest "* Version X.Y.Z" entry don't all
# agree. Run directly (`./scripts/check-version-consistency.sh`) or via the
# pre-commit/pre-push hooks in .githooks/ (see CLAUDE.md for how to enable
# those for a fresh checkout).
#
# Deliberately just three independent sed one-liners rather than a shared
# parser: each file's version string has a different surrounding syntax
# (PHP assignment, prose sentence, Markdown list item), so a real parser
# would be three format-specific branches anyway - this is the same thing
# without the ceremony. Plain BRE sed rather than grep -P/-E, since BSD
# grep (macOS's default) has no -P and this needs to run identically on
# both BSD and GNU systems without relying on a specific grep flavour.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

version_php=$(sed -n "s/.*\$plugin->release = 'v\([0-9.]*\)'.*/\1/p" version.php | head -1)
readme_version=$(sed -n 's/^Version \([0-9.]*\),.*/\1/p' README.md | head -1)
changes_version=$(sed -n 's/^ \* Version \([0-9.]*\).*/\1/p' CHANGES.md | head -1)

if [ -z "$version_php" ]; then
    echo "check-version-consistency: could not find \$plugin->release in version.php" >&2
    exit 1
fi
if [ -z "$readme_version" ]; then
    echo "check-version-consistency: could not find a 'Version X.Y.Z,' line in README.md" >&2
    exit 1
fi
if [ -z "$changes_version" ]; then
    echo "check-version-consistency: could not find a '* Version X.Y.Z' entry in CHANGES.md" >&2
    exit 1
fi

if [ "$version_php" = "$readme_version" ] && [ "$version_php" = "$changes_version" ]; then
    exit 0
fi

cat >&2 <<EOF
check-version-consistency: version mismatch, refusing to commit/push.

  version.php   \$plugin->release = 'v$version_php'
  README.md     Version $readme_version,
  CHANGES.md    * Version $changes_version   (newest entry)

All three must match. Update whichever is stale, then retry.
EOF
exit 1
