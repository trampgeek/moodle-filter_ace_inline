#!/usr/bin/env python3
"""Generates a Behat feature-file suite as flat files directly under
tests/behat/ (scenarios_<render>_<authoring>_python.feature), one file per
tests/scenarios/<render>/<authoring>/python/ leaf directory, with one
Scenario per fixture in it. Flat and directly in tests/behat/ - not a
subdirectory - because Moodle core only discovers a component's Behat
features via a non-recursive glob of tests/behat/*.feature; see
DEFAULT_BEHAT_OUTPUT_DIR's comment below for how this was confirmed.

Python only: this is a genuine per-attribute assertion suite (not a smoke
test), and getting the same coverage for c/sql would mean maintaining a
second set of expected-output/expected-getOption tables in lock-step with
BASE_CODE and ATTR_META for each language, for no real additional signal -
attribute *parsing* is already exercised for all three languages by
generate_scenarios.py's fixtures/qbank, and attribute *behaviour* does not
vary by language. This suite replaces most of the hand-written
tests/behat/*.feature scenarios from TESTING.md Phases A-E.

Reduced by default, `--comprehensive` for the full suite: the same
"behaviour doesn't vary by language, so don't repeat every check for every
language" reasoning above also applies, mostly, across authoring mode
(html-classic/html-simplified/markdown-classic/markdown-simplified) - once
attribute values have been extracted from whichever syntax authored them,
the same JS runs on the same normalised parameters regardless of source
syntax. "Mostly" - unlike the language case, this suite does NOT skip the
other three authoring modes entirely, because cross-authoring-mode testing
has caught genuine bugs in the past: syntax-specific *extraction* (Simplified
Mode's colon-split parsing, Markdown Extra's brace-list parsing) is a real,
separate code path per authoring mode, distinct from the shared runtime
behaviour once extraction has happened. So the default (reduced) suite
keeps, for every authoring mode, every fixture's structural/getOption/
button-name/file-upload-id assertions (REFERENCE_AUTHORING_MODE's `--
comprehensive`-only extra rows aside - all of these check *what got
extracted*, i.e. per-syntax correctness) but only runs the execution/output
assertions (which check shared post-extraction *behaviour*, not extraction)
on REFERENCE_AUTHORING_MODE ("html-classic" - the most direct syntax, no
decoding step of its own). It also only runs the full 99-row combinatorial
permutations.csv sweep on REFERENCE_AUTHORING_MODE; the other three
authoring modes are restricted to is_baseline_row() fixtures (the "NONE"
baseline plus each single attribute alone) - enough to confirm every
attribute's syntax-specific extraction works at all per authoring mode,
without re-running the full attribute-interaction combinatorics four times
over for interactions that, once extracted, behave identically regardless of
source syntax. `--comprehensive` restores the full original suite: every
row, every authoring mode, every assertion - see
generate_behat_suite_from_scenarios()'s docstring for exactly what changes.

For each fixture's attribute combination (read from permutations.csv via
generate_scenarios.ATTR_META/load_rows(), not re-parsed from the fixture
file, so the expected values used here are always the same values the
fixture was actually generated with), a Scenario asserts:

- Structural: an Ace editor exists unless data-hidden is set (in which case
  it must NOT exist - apply_ace_editor.js never creates one for hidden
  blocks); the execution UI area exists iff the render mode is Interactive
  (data-hidden implies Interactive by construction - see
  generate_scenarios.applicable_render_modes - so hidden+no-UI-area can
  never actually occur).
- Per-attribute Ace option values, via getOption(), for every attribute
  whose effect is a static editor config value: start-line-number/
  line-numbers -> firstLineNumber, font-size -> fontSize, min-lines ->
  minLines, max-lines -> maxLines, readonly -> readOnly, dark-theme-mode ->
  theme. Skipped entirely when data-hidden is set, since no editor exists
  to query. See GETOPTION_NAMES/getoption_expected_value() and
  generate_scenarios.py's resolve_attr_value()/data-min-lines comment for
  why min-lines is safe to check with exact equality despite
  apply_ace_editor.js applying it as Math.max(numLines, params['min-lines']),
  and why min-lines/max-lines' expected values must be recomputed per
  fixture rather than read as a single constant.
- For start-line-number/line-numbers specifically, also the actual rendered
  gutter sequence (every .ace_gutter-cell Ace painted into the DOM, checked
  to start at the right number and increment by exactly 1 per line), not
  just the firstLineNumber option above. The two catch different bugs: a
  2026-08 regression set firstLineNumber to a string instead of a number,
  which getOption() still reported back correctly (it does not coerce), but
  which corrupted every rendered line number after the first via string
  concatenation instead of addition - only visible by reading the gutter
  itself. See line_number_sequence_assertions() and
  i_see_sole_editor_line_numbers_starting_at() in behat_filter_ace_inline.php.
- button-name, via the button's own text.
- file-upload-id, via the companion <input> element's mere presence (no
  real file gets uploaded through Behat, so its execution-time effect is
  indistinguishable from baseline output - only its markup can be checked).
- Execution output, for every Interactive fixture (pressing the button and
  checking the result, not just checking the button exists): exactly one of
  code-mapper/file-taids/stdin-taid/baseline determines the primary output,
  in that priority order, since only one program ever actually executes and
  code-mapper fully replaces it while file-taids and stdin-taid are never
  combined in the same fixture (see BASE_CODE_MARKER precedence below and
  generate_scenarios.py's BASE_CODE comment). max-output-length and
  html-output are independent of that choice and of each other, and are
  layered on top of whichever marker applies.

Known, deliberate gap: data-params/data-prefix/data-suffix get no execution
assertion at all - not just no dedicated marker. ace_interactive.js builds
the executed code as `params.prefix + code + params.suffix`, plain string
concatenation with no inserted separator, so prefix="pass" glued directly
onto BASE_CODE's first/last lines ("passimport os...", "...pass") is a
Python SyntaxError regardless of what BASE_CODE contains - this is a
property of the concatenation itself, not something a different fixture
body could avoid. Fixtures with data-prefix or data-suffix therefore skip
the whole press-and-check-output block (see has_unexecutable_affix in
build_scenario()), keeping only their structural/getOption checks. Also,
Markdown Extra's {...} attribute-list parser breaks on anything but a bare
alphanumeric token (see generate_scenarios.py's PREFIX_SUFFIX comment), so
prefix/suffix's placeholder values ("pass"/"int") could not have contained
the punctuation a real print()/output statement would need anyway, even
before considering the missing separator. data-params only sets a Jobe
cputime limit, which has no observable effect to assert either.

Design: Gherkin generation (build_scenario, build_feature_file) is pure -
no filesystem access, just an attribute list in and a feature-file string
out. Directory walking (generate_behat_suite_from_scenarios) is a separate
function that only finds fixtures, looks up their attributes, groups them,
and writes files - same split as generate_qbank_xml.py.

Requires:
- The two path-aware Behat steps already added for the scenarios/ tree:
  scenario_fixture_exists_in_question_contents() and
  ..._as_markdown() in tests/behat/behat_filter_ace_inline.php.
- A new generalised getOption() step, i_see_ace_option_value(), added
  alongside (not replacing) the existing marker-based i_see_min_lines_value()
  - this suite gives every fixture its own dedicated question page, so
  there is always exactly one Ace editor on the page and no marker-based
  <pre> lookup is needed.
- Likewise i_see_sole_editor_line_numbers_starting_at(), the no-marker
  sibling of i_see_line_numbers_starting_at() - same one-editor-per-page
  reasoning as i_see_ace_option_value() above.

Does not run automatically - see the `if __name__ == "__main__"` guard at
the bottom.
"""
import argparse
import os
import re
import time
from collections import defaultdict
from pathlib import Path

from generate_scenarios import ATTR_META, load_rows, resolve_attr_value

SCRIPT_DIR = Path(__file__).resolve().parent
TESTS_DIR = SCRIPT_DIR.parent
DEFAULT_SCENARIOS_DIR = TESTS_DIR / "scenarios"
# Must be tests/behat itself, not a subdirectory: Moodle core discovers a
# component's Behat features via a single, non-recursive
# glob("$path/tests/behat/*.feature") (behat_config_util.php,
# get_components_features()/get_behat_tests_path()) - confirmed by reading
# that source directly after a generated tests/behat/scenarios/<render>/
# <authoring>/*.feature layout produced zero discovered scenarios in a real
# run. Nothing nested any deeper than tests/behat/ is ever found, by moodle-
# docker, moodle-plugin-ci, or any other Moodle Behat runner - this isn't a
# local-environment quirk. Output filenames are correspondingly flat (see
# generate_behat_suite_from_scenarios()), not one-directory-per-combination.
DEFAULT_BEHAT_OUTPUT_DIR = TESTS_DIR / "behat"
GENERATED_FEATURE_PREFIX = "scenarios_"

MARKDOWN_AUTHORING_PREFIX = "markdown-"
LANGUAGE = "python"

PERM_FILENAME_RE = re.compile(r"^perm(\d+)$")

# The authoring mode that gets the full 99-row combinatorial sweep and
# execution/output assertions even in the reduced (default) suite - see the
# module docstring's "Reduced by default" section. html-classic is the most
# direct syntax (data-* attributes written as-is, no colon-splitting or
# brace-list decoding of its own), so it's the natural "ground truth" mode.
REFERENCE_AUTHORING_MODE = "html-classic"


def is_baseline_row(attrs: list[str]) -> bool:
    """True for the "NONE" row (empty attrs) or any single-attribute row -
    the rows still run against every authoring mode in the reduced suite,
    to confirm each authoring mode's own syntax-specific extraction works
    for every individual attribute, without the full multi-attribute
    combinatorial sweep permutations.csv otherwise provides (that sweep is
    only needed once - see REFERENCE_AUTHORING_MODE above).
    """
    return len(attrs) <= 1

# attr -> Ace getOption() name.
GETOPTION_NAMES = {
    "data-start-line-number": "firstLineNumber",
    "line-numbers": "firstLineNumber",
    "data-font-size": "fontSize",
    "data-min-lines": "minLines",
    "data-max-lines": "maxLines",
    "data-readonly": "readOnly",
    "data-dark-theme-mode": "theme",
}


def getoption_expected_value(attr: str, attrs: list[str]) -> str:
    """The exact string getOption()/String() should return for `attr`, given
    every attribute this fixture's permutation row configures (attrs).

    data-min-lines/data-max-lines are resolved the same way
    generate_scenarios.py rendered them (via resolve_attr_value(), passing
    LANGUAGE - this suite is Python-only, see the module docstring) rather
    than read as a fixed constant: their rendered value depends on
    BASE_CODE's line count and, for max-lines, on whether min-lines is also
    in this same row (see resolve_attr_value()'s own docstring) - not purely
    on ATTR_META's placeholder. readonly and dark-theme-mode are not
    straight passthroughs of ATTR_META's raw value either (readOnly is a JS
    boolean, stringified; theme is a full "ace/theme/..." path derived from
    the dark-theme-mode number) so they are given explicitly. Every other
    attribute's ATTR_META placeholder is rendered verbatim, so reading it
    directly is correct.
    """
    if attr == "data-readonly":
        return "true"
    if attr == "data-dark-theme-mode":
        return "ace/theme/tomorrow_night"
    if attr in ("data-min-lines", "data-max-lines"):
        return resolve_attr_value(attr, attrs, LANGUAGE)
    return str(ATTR_META[attr]["value"])

DEFAULT_BUTTON_LABEL = "Try it!"

# What data-file-taids'/data-stdin-taid's companion elements are seeded with
# by generate_scenarios.companion_html(), and what BASE_CODE["python"] does
# with them - see that file for both. Kept here as literal strings, rather
# than imported, since they are Gherkin-visible expected text, not
# generation logic.
FILE_TAIDS_OUTPUT = "files:file contents"
STDIN_TAID_OUTPUT = "stdin:hello"
BASELINE_OUTPUT = "hello"


# ---------------------------------------------------------------------------
# Gherkin generation - pure functions, no filesystem access.
# ---------------------------------------------------------------------------

def question_name_for(relative_path: Path) -> str:
    """Mirrors generate_qbank_xml.py's naming so the same fixture gets the
    same identifier in both generated artefacts, e.g.
    highlight/markdown-simplified/python/perm053.txt ->
    highlight_markdown-simplified_python_perm053
    """
    parts = list(relative_path.parts[:-1]) + [relative_path.stem]
    return "_".join(parts)


def base_output_marker(attrs: list[str]) -> str:
    """The primary expected execution-output text for this attribute combo,
    before any max-output-length truncation. Priority order matches what
    can actually happen at execution time: code-mapper fully replaces the
    executed code (see generate_scenarios.MAPPER_REPLACEMENT_CODE) so it
    overrides everything else; file-taids and stdin-taid are mutually
    exclusive by construction (permutations.csv never combines them) so
    checking file-taids first is unambiguous, not a priority choice;
    file-upload-id has no dedicated marker (see module docstring) so combos
    with only that attribute fall through to the baseline.
    """
    if "data-code-mapper" in attrs:
        return "mapped"
    if "data-file-taids" in attrs:
        return FILE_TAIDS_OUTPUT
    if "data-stdin-taid" in attrs:
        return STDIN_TAID_OUTPUT
    return BASELINE_OUTPUT


def expected_output_text(attrs: list[str]) -> str:
    """base_output_marker(), truncated the same way utils.js's limit() does
    (s.substr(0, maxLen) + '... (truncated)') if data-max-output-length is
    set. ATTR_META's value (4) is deliberately shorter than every possible
    marker (all >= 5 characters), so truncation always actually fires.

    NOT used when data-html-output is also present - see
    expected_html_output_text() for why that path is different, not just a
    variant of this one.
    """
    marker = base_output_marker(attrs)
    if "data-max-output-length" in attrs:
        max_len = int(ATTR_META["data-max-output-length"]["value"])
        return marker[:max_len] + "... (truncated)"
    return marker


def expected_html_output_text(attrs: list[str]) -> str:
    """base_output_marker(), never truncated, regardless of
    data-max-output-length. ace_interactive.js's displaySuccess() only calls
    combinedOutput()/limit() (the truncating path) when html-output is NOT
    active or the run didn't succeed; on a successful html-output run it
    instead does `html.innerHTML = response.output` directly, the raw output
    untouched - confirmed by reading that function, not assumed. A fixture
    combining html-output with max-output-length therefore still has to show
    the full, untruncated marker text.
    """
    return base_output_marker(attrs)


def button_label(attrs: list[str]) -> str:
    if "data-button-name" in attrs:
        return ATTR_META["data-button-name"]["value"]
    return DEFAULT_BUTTON_LABEL


def structural_assertions(attrs: list[str], is_interactive: bool) -> list[str]:
    """Whether an Ace editor and/or the execution UI area should exist.
    data-hidden means no editor is ever created (apply_ace_editor.js takes
    a branch where editNode is never built); data-hidden is interactive_only
    in ATTR_META so it always implies is_interactive, and the UI area is
    still created in that branch (addUi still runs), so the "hidden but not
    interactive" case this would otherwise need to special-case can never
    occur.
    """
    editor_xpath = "//div[contains(@class, 'ace_editor')]"
    ui_area_xpath = "//div[contains(@class, 'filter-ace-inline-ui-area')]"
    is_hidden = "data-hidden" in attrs
    assertions = []
    if is_hidden:
        assertions.append(f'"{editor_xpath}" "xpath_element" should not exist')
        assertions.append(f'"{ui_area_xpath}" "xpath_element" should exist')
    else:
        assertions.append(f'"{editor_xpath}" "xpath_element" should exist')
        if is_interactive:
            assertions.append(f'"{ui_area_xpath}" "xpath_element" should exist')
        else:
            assertions.append(f'"{ui_area_xpath}" "xpath_element" should not exist')
    return assertions


LINE_NUMBER_ATTRS = ("data-start-line-number", "line-numbers")


def line_number_sequence_assertions(attrs: list[str]) -> list[str]:
    """Gherkin line (no leading keyword) verifying the actual rendered gutter sequence for
    start-line-number/line-numbers, on top of getoption_assertions()'s firstLineNumber check -
    see the module docstring for why both are needed. At most one line: permutations.csv never
    combines data-start-line-number with line-numbers in the same row (they are two different
    spellings of the same effect, not independent attributes). None at all if data-hidden means
    there is no editor to query, matching getoption_assertions().
    """
    if "data-hidden" in attrs:
        return []
    for attr in LINE_NUMBER_ATTRS:
        if attr in attrs:
            value = getoption_expected_value(attr, attrs)
            return [f"I should see line numbers starting at {value} with filter ace inline"]
    return []


def getoption_assertions(attrs: list[str]) -> list[str]:
    """Gherkin lines (no leading keyword) for every getOption()-checkable
    attribute present, or none at all if data-hidden means there is no
    editor to query.
    """
    if "data-hidden" in attrs:
        return []
    lines = []
    for attr in attrs:
        if attr in GETOPTION_NAMES:
            optionname = GETOPTION_NAMES[attr]
            value = getoption_expected_value(attr, attrs)
            lines.append(f'I should see an ace option "{optionname}" value "{value}" with filter ace inline')
    return lines


def button_name_assertion(attrs: list[str]) -> list[str]:
    if "data-button-name" not in attrs:
        return []
    label = ATTR_META["data-button-name"]["value"]
    xpath = (
        "//div[contains(@class, 'filter-ace-inline-ui-area')]"
        f"//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), '{label}')]"
    )
    return [f'"{xpath}" "xpath_element" should exist']


def file_upload_id_assertion(attrs: list[str]) -> list[str]:
    if "data-file-upload-id" not in attrs:
        return []
    upload_id = ATTR_META["data-file-upload-id"]["value"]
    return [f'"//input[@id=\'{upload_id}\']" "xpath_element" should exist']


def build_scenario(relative_path: Path, attrs: list[str], is_interactive: bool,
                    include_execution: bool = True) -> str:
    """Returns one indented "Scenario: ..." Gherkin block (no trailing
    blank line) for a single fixture.

    :param include_execution: Whether to include the press-button/check-
        output assertions. False for the reduced suite's non-reference-
        authoring-mode scenarios (see REFERENCE_AUTHORING_MODE) - execution
        behaviour is identical regardless of which syntax the attributes
        were extracted from, so re-checking it there would be pure
        redundancy, not extra coverage. Every other assertion (structural,
        getOption, button-name, file-upload-id) still runs regardless, since
        those check what THIS authoring mode's own syntax actually extracted
        - genuinely per-syntax coverage, not shared behaviour.
    """
    authoring_mode = relative_path.parts[1]
    is_markdown = authoring_mode.startswith(MARKDOWN_AUTHORING_PREFIX)

    name = question_name_for(relative_path)
    posix_path = relative_path.as_posix()
    load_step = (
        f'And "{posix_path}" exists in question "{name}" "questiontext" from scenarios as markdown for filter ace inline'
        if is_markdown else
        f'And "{posix_path}" exists in question "{name}" "questiontext" from scenarios for filter ace inline'
    )

    lines = [
        f"  Scenario: {name}",
        "    Given the following \"questions\" exist:",
        "      | questioncategory | qtype       | name |",
        f"      | Test questions   | description | {name} |",
        f"    {load_step}",
        f'    When I am on the "{name}" "core_question > preview" page logged in as teacher',
    ]

    assertions = structural_assertions(attrs, is_interactive)
    assertions += getoption_assertions(attrs)
    assertions += line_number_sequence_assertions(attrs)
    assertions += button_name_assertion(attrs)
    assertions += file_upload_id_assertion(attrs)

    for i, assertion in enumerate(assertions):
        keyword = "Then" if i == 0 else "And"
        lines.append(f"    {keyword} {assertion}")

    has_unexecutable_affix = "data-prefix" in attrs or "data-suffix" in attrs
    if is_interactive and not has_unexecutable_affix and include_execution:
        lines.append(f'    And I press "{button_label(attrs)}"')
        if "data-html-output" in attrs:
            expected = expected_html_output_text(attrs)
            lines.append(f'    Then I should see the filter-ace-inline-html div containing "{expected}"')
        else:
            expected = expected_output_text(attrs)
            lines.append(f'    Then I should see "{expected}"')

    return "\n".join(lines)


def build_feature_file(render: str, authoring: str, scenarios: list, comprehensive: bool) -> str:
    """Returns a complete .feature file (Feature header + Background +
    every scenario in `scenarios`, each already a full "Scenario: ..." block
    as returned by build_scenario()).

    :param comprehensive: Only affects the Feature description text below,
        not which scenarios are included (that's already decided by the
        caller, in generate_behat_suite_from_scenarios()) - documents, in
        the file itself, whether this authoring mode got the full 99-row
        sweep or just the reduced suite's baseline-row subset, so that's
        discoverable directly from the generated file without needing to
        know how it was invoked.
    """
    title = f"{render}/{authoring}/{LANGUAGE} scenario fixtures"
    background = """  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email           |
      | teacher  | Teacher   | 1        | teach1@empl.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user    | course | role           |
      | teacher | C1     | editingteacher |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And I have enabled the sandbox and ace inline filter"""
    # Simplified mode's colon-encoded class syntax is not recognised at all
    # unless this admin setting is on (confirmed the hard way: every
    # html-simplified/markdown-simplified fixture failed with "ace_editor
    # not found" - the <pre> was never even converted into an Ace block -
    # until this step was added, matching what the hand-written
    # simplified_class_mode*.feature files already did).
    if authoring.endswith("simplified"):
        background += """
    And the following config values are set as admin:
      | simplified_mode | 1 | filter_ace_inline |"""

    is_full = comprehensive or authoring == REFERENCE_AUTHORING_MODE
    scope_note = (
        "  Every fixture under this directory is covered."
        if is_full else
        "  Only the baseline (no-attribute and single-attribute) fixtures under this\n"
        "  directory are covered here - see generate_behat_suite.py's module docstring\n"
        "  for why the full attribute-combination sweep only runs on "
        f"{REFERENCE_AUTHORING_MODE}.\n"
        "  Run generate_behat_suite.py --comprehensive to regenerate this file with\n"
        "  every fixture and full execution-output assertions instead."
    )
    header = f"""@filter @filter_ace_inline @javascript
Feature: {title}
  In order to trust every data-* attribute combination this filter supports
  As a developer
  I need fixtures under tests/scenarios/{render}/{authoring}/{LANGUAGE}/
  to render and behave (editor config, execution output, structural UI)
  exactly as their attribute combination specifies
{scope_note}

"""

    body = "\n\n".join(scenarios)
    return header + background + "\n\n" + body + "\n"


# ---------------------------------------------------------------------------
# Directory walking - filesystem access, delegates Gherkin construction above.
# ---------------------------------------------------------------------------

def write_with_retry(path: Path, content: str, attempts: int = 5, delay: float = 1.0) -> None:
    """Writes content to path, retrying on TimeoutError - this repo lives
    under OneDrive-managed storage, which has been observed (see
    generate_scenarios.py) to transiently lock an individual file during
    bulk writes. Same fix as there.
    """
    last_error = None
    for _attempt in range(attempts):
        try:
            path.write_text(content)
            return
        except TimeoutError as e:
            last_error = e
            time.sleep(delay)
    raise last_error


def generate_behat_suite_from_scenarios(scenarios_dir: Path = DEFAULT_SCENARIOS_DIR,
                                         behat_output_dir: Path = DEFAULT_BEHAT_OUTPUT_DIR,
                                         comprehensive: bool = False) -> int:
    """Walks scenarios_dir for python/*.txt fixtures, groups them by their
    (render, authoring) leaf directory, and writes one flat
    scenarios_<render>_<authoring>_python.feature file per group directly
    under behat_output_dir (tests/behat/ itself - see
    DEFAULT_BEHAT_OUTPUT_DIR's comment for why it can't be a subdirectory).
    Returns the number of feature files written - always 8 (every (render,
    authoring) combination), regardless of `comprehensive`: only which
    fixtures/assertions each file contains changes, not the file set itself
    - see the module docstring's "Reduced by default" section.

    Each fixture's attribute list is looked up from permutations.csv (via
    the perm number in its filename), not re-parsed from the fixture's own
    markup - this is the same source of truth generate_scenarios.py used to
    generate the fixture in the first place, so the two can never disagree
    about what a fixture is supposed to contain.

    :param comprehensive: False (default) generates the reduced suite:
        REFERENCE_AUTHORING_MODE gets every fixture with full assertions;
        every other authoring mode is restricted to is_baseline_row()
        fixtures, with execution/output assertions dropped (see
        build_scenario()'s include_execution). True restores the original,
        full suite - every fixture, every authoring mode, every assertion -
        useful for a one-off deep check, e.g. after changing how a specific
        authoring mode's syntax is parsed.

    Clears out any scenarios_*.feature files already under behat_output_dir
    first, so that fixtures removed from tests/scenarios/ since the last run
    don't leave stale, no-longer-matching scenarios behind. Scoped to that
    prefix specifically (not every *.feature file) since behat_output_dir is
    tests/behat/ itself, shared with the hand-written suite. This also means
    switching `comprehensive` between runs can never leave a mix of
    reduced- and comprehensive-suite files on disk at once: every run always
    regenerates and fully replaces all 8 files under its own single mode.
    """
    rows = load_rows()

    groups = defaultdict(list)
    for dirpath, _dirnames, filenames in os.walk(scenarios_dir):
        for filename in sorted(filenames):
            if not filename.endswith(".txt"):
                continue
            fixture_path = Path(dirpath) / filename
            relative_path = fixture_path.relative_to(scenarios_dir)
            render, authoring, language = relative_path.parts[:3]
            if language != LANGUAGE:
                continue
            match = PERM_FILENAME_RE.match(relative_path.stem)
            perm_number = int(match.group(1))
            attrs = rows[perm_number - 1]

            is_reference = authoring == REFERENCE_AUTHORING_MODE
            if not comprehensive and not is_reference and not is_baseline_row(attrs):
                continue
            include_execution = comprehensive or is_reference

            groups[(render, authoring)].append((relative_path, attrs, include_execution))

    if behat_output_dir.exists():
        for stale in behat_output_dir.glob(f"{GENERATED_FEATURE_PREFIX}*.feature"):
            stale.unlink()

    written = 0
    for (render, authoring), fixtures in sorted(groups.items()):
        is_interactive = render == "interactive"
        scenarios = [
            build_scenario(p, attrs, is_interactive, include_execution)
            for p, attrs, include_execution in sorted(fixtures, key=lambda triple: triple[0])
        ]
        feature_content = build_feature_file(render, authoring, scenarios, comprehensive)

        behat_output_dir.mkdir(parents=True, exist_ok=True)
        outpath = behat_output_dir / f"{GENERATED_FEATURE_PREFIX}{render}_{authoring}_{LANGUAGE}.feature"
        write_with_retry(outpath, feature_content)
        written += 1

    return written


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate the Behat feature-file suite from tests/scenarios/ fixtures. "
                    "By default generates the reduced suite (see module docstring); "
                    "pass --comprehensive for the full combinatorial suite."
    )
    parser.add_argument(
        "--comprehensive", action="store_true",
        help="Generate the full suite: every permutation row, every authoring mode, "
             "every assertion (including execution/output) - the suite this defaulted "
             "to before the reduced suite was introduced.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    count = generate_behat_suite_from_scenarios(comprehensive=args.comprehensive)
    suite_kind = "comprehensive" if args.comprehensive else "reduced"
    print(f"Wrote {count} feature files ({suite_kind} suite) to {DEFAULT_BEHAT_OUTPUT_DIR}")
