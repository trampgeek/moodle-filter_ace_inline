# CLAUDE.md

Guidance for Claude Code (or any AI assistant) working in this repo. For user-facing feature
documentation, see [README.md](README.md).

## Local dev environment

Local testing runs against a Docker-based Moodle stack (`moodle-docker`: webserver, jobe,
selenium, postgres, mailpit). Sync this plugin's source into that stack with `./sync-to-moodle.sh`
(`--no-build` for a quick resync that skips the AMD/Grunt build step).

**PHPUnit**: on a fresh moodle-dev checkout, PHPUnit must be initialized once before first use:
`php public/admin/tool/phpunit/cli/init.php` (run from the Moodle root).

**Behat**: after adding, renaming, or deleting any `.feature` file, Behat's cached feature-file
listing goes stale and test runs fail with "No specifications found" until you re-run
`php public/admin/tool/behat/cli/run.php --enable` (also from the Moodle root).

**codechecker / phpdoc**: `.github/workflows/ci.yml` runs these without `continue-on-error`, so
failures block CI. A standalone `moodle-plugin-ci` (via `composer create-project`) can run the same
checks locally without a full CI job.

## Jobe sandbox: local file-upload testing gotcha

Jobe caches uploaded file content by MD5 hash. If a long-lived local Jobe container (one that's
been running across multiple test sessions) is reused, submitting the *same* file content that was
uploaded in an earlier session produces an immediate cache hit — this looks identical to a broken
upload/retry flow in logs (e.g. `httpcode=200` on first submit when you expected a `404`-then-upload
sequence). This produced a false-positive "bug" during investigation of `qtype_coderunner`'s
Jobe-upload retry logic (2026-08): the flow was actually correct, but reused test content masked
it. When debugging file-upload behavior against Jobe, use fresh/unique file content per test run,
or restart the Jobe container, before concluding the upload logic itself is broken.

## Terminology

The colon-based fenced-code-block class syntax (e.g. ` ```python:interactive `) is called
**"Simplified Class Mode"** in code and tests. It was previously called "Extended Markdown" —
that name is deprecated and was renamed throughout `amd/src/`, `tests/behat/`, and
`tests/fixtures/` (see `isSimplifiedClassMode`, `extractSimplifiedClassModeParameters`,
`simplified_class_mode*.feature`). Do not reintroduce the old name in new code; it may still
appear in the README's historical change log, which is left as-is.

## `tests/fixtures/test-sandbox-config.php`

This file must **never** be committed or pushed. It holds a developer's personal local Jobe
sandbox config (including a real local IP/host). It's excluded via `.gitignore` and additionally
marked with `git update-index --skip-worktree` so local edits never show as dirty. To set up your
own local config, copy `tests/fixtures/test-sandbox-config-dist.php` to
`tests/fixtures/test-sandbox-config.php` and fill in your own Jobe host details.
