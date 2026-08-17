# Behat coverage audit: prefix attributes × render mode × authoring mode

This document audits how thoroughly the Behat suite exercises the attribute
table in [README.md](README.md#additional-display-and-behaviour-attributes)
(everything except `data-lang`/`data-ace-lang`, which are covered separately
by the various `*_highlighting.feature` files). It was produced by tracing
actual test fixtures against the plugin's PHP/JS source and, where the
answer wasn't obvious from reading, by verifying directly against Moodle's
own Markdown parser (see [Finding 1](#finding-1-markdown-standard-mode--has-zero-test-coverage)).

## The six combinations

Every attribute can potentially be exercised along two independent axes:

**Render mode** — does the `<pre>` end up read-only-highlighted, or an
editable/runnable interactive Ace box?
- **Highlight**
- **Interactive**

**Authoring mode** — how the author actually specifies the attribute:
- **TinyMCE** — written directly onto the `<pre>` tag via TinyMCE's Source
  Code view, e.g. `<pre data-ace-interactive-code data-button-name="Run">`.
  There is no Behat-drivable way to operate the TinyMCE WYSIWYG editor
  itself; every existing "TinyMCE" test instead injects the equivalent raw
  HTML directly into the question via the `exists in question ... for filter
  ace inline` step. This is a faithful proxy — the README's own TinyMCE
  worked example instructs authors to hand-edit the `<pre>` tag exactly this
  way — with one caveat: it can't verify TinyMCE's `<script>`-stripping
  behaviour, which is why `data-code-mapper` (needs an inline `<script>`) is
  documented as not supported in TinyMCE at all.
- **Markdown standard** — a Markdown Extra fenced-code-block attribute list
  immediately after the opening fence, e.g.
  `` ``` {data-ace-interactive-code= data-lang=Java data-hidden=true} ``.
  Requires the question field to actually be Markdown-formatted (the
  `as markdown for filter ace inline` Behat step).
- **Simplified mode** — the plugin's own colon-encoded fenced-block info
  string, e.g. `` ```python3:interactive:max-lines:3 ``. Also requires the
  `as markdown` step.

## Finding 1: Markdown standard mode (`{}`) has zero test coverage

Verified directly with Moodle's real Markdown parser (`format_text($md,
FORMAT_MARKDOWN)`):

```
Input:
``` {data-ace-interactive-code= data-lang=Java data-hidden=true data-button-name=Markdown}

Output:
<pre><code data-ace-interactive-code="" data-lang="Java" data-hidden="true" data-button-name="Markdown">
```

This is real, working behaviour — MarkdownExtra converts the `{}` attribute
list into genuine HTML attributes on `<code>`, and `apply_ace_editor.js`
(lines 106-132) has a dedicated second pass specifically for reading
attributes off `<code>` rather than `<pre>`, which is exercised by the
Simplified-mode tests (whose colon-encoded class also lands on `<code>`).

But the `` ```{...} `` syntax itself appears **nowhere** in any fixture or
`.feature` file - only in the two README examples (lines 96 and 241). Of the
14 attributes the table marks as "Markdown"-supported, none has ever been
exercised through this code path by a test.

## Finding 2: the five dual-render-mode attributes never get both modes tested in the same authoring mode

Only five attributes are documented as working in *both* Highlight and
Interactive: `data-start-line-number`, `data-font-size`, `data-min-lines`,
`data-max-lines`, `data-dark-theme-mode`. In TinyMCE/raw style, four of them
are only ever tested Interactive (`customisedemo.txt`, `paramsdemo.txt`) and
the fifth (`data-min-lines`) is only ever tested Highlight - no attribute
gets both render modes tested via that authoring path. In Simplified mode,
`data-font-size` and `data-max-lines` are likewise Interactive-only;
`data-dark-theme-mode` is the one attribute with genuine full coverage
(`c:dark-theme-mode:2` for Highlight, `python3:interactive:dark-theme-mode:0`
for Interactive).

## Finding 3: README inaccuracy (resolved in Phase D)

`data-max-output-length`'s table row listed only "Interactive, TinyMCE,
Markdown" - no "Simplified Mode" - yet `simplifiedclassmodeattrsdemo.txt`
tests it in Simplified mode and passes. Traced `extractSimplifiedClassModeParameters()`
in `ui_parameters.js`: it has no attribute-specific allow/deny list - it
generically extracts *any* key present in `ACE_INTERACTIVE`'s defaults via
colon-encoding, and `max-output-length` is one of those keys. Its value is a
plain integer, so nothing about colon-delimited encoding conflicts with it -
unlike `data-params`, `data-prefix`, `data-suffix` and `data-file-taids`,
whose values (JSON objects, multi-line code) genuinely can't survive being
colon-split, which is presumably why the table correctly excludes *those*
from Simplified Mode. So this was a real, working, intentional-by-construction
feature - just a missing table entry, not accidental behaviour. Fixed by
adding "Simplified Mode" to the table row; no code or test changes needed.

## Coverage matrix (post-implementation)

Legend: ✅ tested · ❌ gap (claimed, untested) · — not claimed/not applicable
· ✅* tested only via one of Phase A's representative scenarios, standing in
for the rest since they share the same `extractUiParameters()`/
`extractSimplifiedClassModeParameters()` code path (see Finding 1) - not
individually re-verified per attribute.

| Attribute | TinyMCE·Highlight | TinyMCE·Interactive | Markdown{}·Highlight | Markdown{}·Interactive | Simplified·Highlight | Simplified·Interactive |
|---|---|---|---|---|---|---|
| data-start-line-number | ✅ | ✅ | ❌ | ❌ | — | — |
| data-font-size | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |
| data-min-lines | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| data-max-lines | ✅ | ✅ | ❌ | ✅* | ✅ | ✅ |
| data-dark-theme-mode | ✅ | ✅ | ✅* | ❌ | ✅ | ✅ |
| data-button-name | — | ✅ | — | ✅* | — | ✅ |
| data-readonly | — | ✅ | — | ✅* | — | ✅ |
| data-hidden | — | ✅ | — | ✅* | — | ✅ |
| data-stdin-taid | — | ✅ | — | ❌ | — | ✅ |
| data-file-taids | — | ✅ | — | — | — | — |
| data-file-upload-id | — | ✅ | — | ❌ | — | ✅ |
| data-params | — | ✅ | — | — | — | — |
| data-code-mapper | — | ✅ (raw HTML, not TinyMCE) | — | ❌ | — | ✅ |
| data-prefix | — | ✅ | — | ❌ | — | — |
| data-suffix | — | ✅ | — | ❌ | — | — |
| data-html-output | — | ✅ | — | ✅* | — | ✅ |
| data-max-output-length | — | ✅ | — | ❌ | — | ✅ (Finding 3 - now a documented feature, not a discrepancy) |
| line-numbers (Simplified-only) | — | — | — | — | ✅ | (not seen) |

Remaining gaps after Phases A-D: `data-stdin-taid`, `data-file-upload-id`,
`data-code-mapper`, `data-prefix`, `data-suffix` untested via Markdown `{}`
(low-risk per Finding 1's shared-code-path reasoning, but not proven);
`data-min-lines` untested via any Simplified-mode path (not investigated -
would need a colon-encoded min-lines block, e.g. `` ```c:min-lines:5 ``, and
the same `getOption('minLines')` verification technique used in Phase B).

## Implementation plan

Ordered by value: Phase A closes the one complete authoring-mode hole (14
attributes × 0 coverage); Phases B-C are narrower render-mode gaps within
authoring modes that are otherwise well tested; Phase D is a
docs-vs-behaviour decision, not new tests. **Phases A-E are done** (A-D on
2026-08-14, E on 2026-08-15). Phase E started as a holding area for a problem
found along the way that was out of scope for this plan, then got root-caused
and fixed too - see below.

### Phase A - Markdown standard mode (`{}` block-spec) coverage - done, later superseded
Added `tests/behat/markdown_standard_mode.feature` (7 scenarios) +
`tests/fixtures/markdownstandarddemo.txt`, loaded via the `as markdown` step.
**2026-08-18: removed.** All 7 scenarios (highlight rendering, button-name,
hidden, max-lines, dark-theme-mode, html-output, readonly, all via
markdown-classic `{}` authoring) are now covered, more thoroughly, by the
generated `tests/behat/scenarios/{highlight,interactive}/markdown-classic/
python.feature` suite (see `tests/scripts/generate_behat_suite.py`) - the
only scenario content not carried over was a syntax-highlighting span check,
which was out of this document's own stated scope (data-lang/highlighting
correctness is covered separately by `*_highlighting.feature`) and a
low-value duplicate of the editor-initialization check the new suite already
performs. This was a conservative, whole-file-only removal pass done first;
a second, scenario-level pruning pass followed the same day (see below) for
files that mixed redundant and unique scenarios.
Verified directly against Moodle's real Markdown parser first (see Finding 1)
before writing fixtures, since two syntax assumptions turned out to be wrong:
bare attributes with no `=` are silently dropped by MarkdownExtra's parser
entirely (`data-hidden` alone → gone; `data-hidden=` with an empty value
works fine), and quoted multi-word attribute values (`data-button-name="Two
Words"`) break the whole fence, not just that attribute - so all values in
the fixture are single unquoted words. Covers both render modes, and both
boolean-flag (`data-hidden`, `data-readonly`, `data-html-output`) and
value-taking (`data-lang`, `data-button-name`, `data-max-lines`,
`data-dark-theme-mode`) attributes. Verified non-vacuous by temporarily
breaking one assertion and confirming Behat caught it.

### Phase B - TinyMCE Highlight-mode gaps for the dual-render attributes - done
Added Highlight-mode blocks for `data-start-line-number`, `data-font-size`,
`data-max-lines`, `data-dark-theme-mode`, plus an Interactive-mode block for
`data-min-lines`, to `customisedemo.txt` and `customisation.feature`. Found
and fixed two real problems along the way, both confirmed via a live
diagnostic Behat step before and after:
- **`data-min-lines` was never actually exercisable at all**, in either
  render mode: `apply_ace_editor.js` computes `minLines: Math.max(numLines,
  params['min-lines'])`, so the option only has any visible effect when the
  actual code is *shorter* than the minimum - the existing fixture's block
  had 6 lines of code with `data-min-lines="2"`, so the minimum could never
  bind. Replaced with 1-line blocks and `min-lines="5"`. DOM line-counting
  turned out not to be a reliable verification signal either (Ace doesn't
  necessarily render one node per blank padding line - it just reserves
  vertical space), so added a new step, `I should see a min-lines value of
  :number after :marker`, that reads the live Ace instance's own `minLines`
  option instead (`editNode.env.editor.getOption('minLines')`).
- **`i_see_font_size`'s xpath was silently broken for any non-interactive
  editor**: `starts-with(@class, ' ace_editor')` requires a literal leading
  space before `ace_editor` in the class attribute, which the interactive
  editor's class string happens to have but the highlight editor's doesn't -
  so the check would have false-negative'd on every highlight-mode font-size
  test that was ever written, had one existed before now. Fixed to the
  robust `contains(concat(' ', normalize-space(@class), ' '), ' ace_editor ')`
  pattern already used elsewhere in this file for the same reason.
- Also caught a copy-paste version of the same "content shorter than the
  limit" mistake in the new `data-max-lines` Highlight block (wrote exactly
  2 lines of code for `max-lines="2"`, so nothing needed to scroll out of
  view) - fixed by padding with 2 extra lines, same fix later reapplied in
  Phase C for the Simplified-mode equivalent.

### Phase C - Simplified-mode Highlight-mode gaps - done
Added Highlight-mode (`` ```c:font-size:22pt ``, `` ```c:max-lines:2 `` with
padding lines, no `:interactive`) variants of `data-font-size` and
`data-max-lines` to `simplifiedclassmodeattrsdemo.txt` and
`simplified_class_mode_attributes.feature`, applying the same "more lines
than the limit" lesson from Phase B up front.

### Phase D - Resolve the `data-max-output-length` / Simplified Mode discrepancy - done
Traced `extractSimplifiedClassModeParameters()` in `ui_parameters.js`: no
attribute-specific allow/deny list, it generically extracts any key present
in `ACE_INTERACTIVE`'s defaults via colon-encoding, and `max-output-length`
is one of those keys with a plain-integer value that survives colon-splitting
cleanly - unlike `data-params`/`data-prefix`/`data-suffix`/`data-file-taids`,
whose JSON/multi-line-code values can't. So this was a real, intentional-by-
construction feature, just a missing table entry. Added "Simplified Mode" to
the README row; no code or test changes needed.

## Phase E - fixed

**Symptom:** any scenario stepping through `I navigate to "Plugins > Filters
> Ace inline" in site administration` (logged in as `admin`) intermittently
failed with `Link "Plugins > Filters > Ace inline" not found`, only when run
as part of a large full-suite Behat run - never when run alone or in a small
subset (confirmed 3/3 passes in isolation with the unmodified step, right
after seeing it fail in two separate full-suite runs on two different
scenarios in two different files). So this was a load/timing-dependent flake
in Moodle core's own admin-navigation search UI (`behat_navigation.php`'s
`select_on_administration_page()`), not a deterministic bug - and not caused
by anything in this plan, which doesn't touch admin navigation.

**Root-caused via elimination**, not just observed: bisected the multi-level
path via diagnostic steps and found `Plugins > Filters` (2 levels) always
succeeds, but going one level deeper to *any* specific plugin's settings page
by name intermittently fails - reproduced identically for a completely
unrelated sibling plugin (`Editor selector`), ruling out anything specific to
`filter_ace_inline` (its lang strings, its settings.php, its admin tree
registration are all fine - confirmed the exact link text "Ace inline" does
render correctly on the settings category page when reached directly).

**Fix:** replaced `I navigate to "Plugins > Filters > Ace inline" in site
administration` with `I visit "/admin/settings.php?section=filtersettingace_inline"`
in both `admin_settings.feature` (5 occurrences) and `course_settings.feature`
(1 occurrence) - a direct URL visit using Moodle's standard
`filtersetting<component>` section-name convention (verified against the
sibling plugin's URL pattern), bypassing the flaky JS-driven search navigation
entirely rather than trying to fix timing in Moodle core itself. Verified via
a full `@filter_ace_inline` suite run with the fix in place.

## Phase F - superseded by the generated tests/behat/scenarios/ suite - done (2026-08-18)

Once `tests/scripts/generate_scenarios.py`/`generate_behat_suite.py` existed
and were actually run (producing 620 fixtures/qbank entries and 282
generated Python Behat scenarios across 8 files), most of Phases A-C's
hand-written coverage became redundant. Handled in two passes:

**Whole-file removal** (Phase A, above): `markdown_standard_mode.feature` +
`markdownstandarddemo.txt` - every scenario fully covered, nothing unique.

**Scenario-level pruning**: for files that mixed redundant scenarios with
scenarios the generated suite's one-fixture-per-page architecture structurally
cannot reproduce, removed only the redundant ones (and trimmed each shared
fixture's now-unused `<pre>`/fenced blocks to match, verified against
Moodle's real Markdown/format_text() parser after trimming):
- `customisation.feature` (17 → 4 scenarios) + `customisedemo.txt` (14 → 4
  blocks). Kept: cross-checking that the highlighting *language* runs
  independently of the actual execution language; html-output combined with
  a `language-markup` CSS-class-authored block (a different code path than
  `data-lang`); both legacy class-marker scenarios. In the course of this,
  found and fixed a pre-existing bug unrelated to this cleanup: the two
  legacy-marker scenarios had their titles swapped relative to what they
  actually tested (the one titled "ace-highlight-code" pressed a button and
  checked real execution output - that's the interactive marker; the one
  titled "ace-interactive-code" only checked a highlight span with no button
  - that's the highlight marker).
- `simplified_class_mode_attributes.feature` (14 → 2 scenarios) +
  `simplifiedclassmodeattrsdemo.txt` (18 → 3 blocks, 2 of which are kept
  only as page-order context for the scenario below, no longer individually
  asserted on). Kept: the "an earlier block's line-numbers does not leak
  into a later block" regression test (needs multiple blocks sharing one
  page, structurally impossible in the generated suite); dark-theme-mode
  forcing the *light* theme (value `0`) - the generated suite only exercises
  forcing dark (value `2`), so this is a real, distinct gap, not a duplicate.
- `simplified_class_mode.feature` (5 → 1 scenario) + `simplifiedclassmodedemo.txt`
  (4 → 1 block). Kept: a bare language string picking up the *admin's*
  configured dark-theme-mode default when no per-block override is given -
  not reproduced anywhere else.
- `codemapper.feature` (2 → 1 scenario) + `codemapperdemo.txt` (2 → 1 block,
  the `<script>` companion for the removed happy-path scenario dropped
  along with it). Kept: the error path when `data-code-mapper` names a
  function that doesn't exist on the page.

Confirmed no dangling references (grepped every removed fixture marker
across `tests/behat/*.feature` and `tests/fixtures/*.txt`) and no other
consumers of any removed file before deleting. Left untouched, confirmed
out of scope (real Jobe execution/error-path testing the generated suite
deliberately doesn't attempt, or an unrelated concern entirely): `taids.feature`,
`params.feature`, `prefixsuffix.feature`, `tryit_basic.feature`,
`tryit_tiny.feature`, every `*_highlighting.feature`, `admin_settings.feature`,
`course_settings.feature`, `xss_prevention.feature`.

### Out of scope for this plan
`data-file-taids` and `data-params` are TinyMCE/Interactive-only per the
table and already well tested there - no gap. `data-code-mapper` not being
tested "in TinyMCE" is expected (not claimed - `<script>` stripping), though
its Markdown-`{}` variant is still covered by Phase A.
