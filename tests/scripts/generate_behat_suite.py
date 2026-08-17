#!/usr/bin/env python3
"""Generates a Behat feature-file suite under tests/behat/scenarios/, one
file per tests/scenarios/<render>/<authoring>/python/ leaf directory, with
one Scenario per fixture in it.

Python only: this is a genuine per-attribute assertion suite (not a smoke
test), and getting the same coverage for c/sql would mean maintaining a
second set of expected-output/expected-getOption tables in lock-step with
BASE_CODE and ATTR_META for each language, for no real additional signal -
attribute *parsing* is already exercised for all three languages by
generate_scenarios.py's fixtures/qbank, and attribute *behaviour* does not
vary by language. This suite replaces most of the hand-written
tests/behat/*.feature scenarios from TESTING.md Phases A-E.

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
  to query. See GETOPTION_CHECKS and generate_scenarios.py's data-min-lines
  comment for why min-lines is safe to check with exact equality despite
  apply_ace_editor.js applying it as Math.max(numLines, params['min-lines']).
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

Does not run automatically - see the `if __name__ == "__main__"` guard at
the bottom.
"""
import os
import re
import time
from collections import defaultdict
from pathlib import Path

from generate_scenarios import ATTR_META, load_rows

SCRIPT_DIR = Path(__file__).resolve().parent
TESTS_DIR = SCRIPT_DIR.parent
DEFAULT_SCENARIOS_DIR = TESTS_DIR / "scenarios"
DEFAULT_BEHAT_OUTPUT_DIR = TESTS_DIR / "behat" / "scenarios"

MARKDOWN_AUTHORING_PREFIX = "markdown-"
LANGUAGE = "python"

PERM_FILENAME_RE = re.compile(r"^perm(\d+)$")

# attr -> (Ace getOption() name, expected value as getOption()/String() would
# return it). readonly and dark-theme-mode are not straight passthroughs of
# ATTR_META's raw value (readOnly is a JS boolean, stringified; theme is a
# full "ace/theme/..." path derived from the dark-theme-mode number) so they
# are given explicitly rather than read out of ATTR_META.
GETOPTION_CHECKS = {
    "data-start-line-number": ("firstLineNumber", ATTR_META["data-start-line-number"]["value"]),
    "line-numbers": ("firstLineNumber", ATTR_META["line-numbers"]["value"]),
    "data-font-size": ("fontSize", ATTR_META["data-font-size"]["value"]),
    "data-min-lines": ("minLines", ATTR_META["data-min-lines"]["value"]),
    "data-max-lines": ("maxLines", ATTR_META["data-max-lines"]["value"]),
    "data-readonly": ("readOnly", "true"),
    "data-dark-theme-mode": ("theme", "ace/theme/tomorrow_night"),
}

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
    """
    marker = base_output_marker(attrs)
    if "data-max-output-length" in attrs:
        max_len = int(ATTR_META["data-max-output-length"]["value"])
        return marker[:max_len] + "... (truncated)"
    return marker


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


def getoption_assertions(attrs: list[str]) -> list[str]:
    """Gherkin lines (no leading keyword) for every getOption()-checkable
    attribute present, or none at all if data-hidden means there is no
    editor to query.
    """
    if "data-hidden" in attrs:
        return []
    lines = []
    for attr in attrs:
        if attr in GETOPTION_CHECKS:
            optionname, value = GETOPTION_CHECKS[attr]
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


def build_scenario(relative_path: Path, attrs: list[str], is_interactive: bool) -> str:
    """Returns one indented "Scenario: ..." Gherkin block (no trailing
    blank line) for a single fixture.
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
    assertions += button_name_assertion(attrs)
    assertions += file_upload_id_assertion(attrs)

    for i, assertion in enumerate(assertions):
        keyword = "Then" if i == 0 else "And"
        lines.append(f"    {keyword} {assertion}")

    has_unexecutable_affix = "data-prefix" in attrs or "data-suffix" in attrs
    if is_interactive and not has_unexecutable_affix:
        expected = expected_output_text(attrs)
        lines.append(f'    And I press "{button_label(attrs)}"')
        if "data-html-output" in attrs:
            lines.append(f'    Then I should see the filter-ace-inline-html div containing "{expected}"')
        else:
            lines.append(f'    Then I should see "{expected}"')

    return "\n".join(lines)


def build_feature_file(render: str, authoring: str, scenarios: list) -> str:
    """Returns a complete .feature file (Feature header + Background +
    every scenario in `scenarios`, each already a full "Scenario: ..." block
    as returned by build_scenario()).
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

    header = f"""@filter @filter_ace_inline @javascript
Feature: {title}
  In order to trust every data-* attribute combination this filter supports
  As a developer
  I need every fixture under tests/scenarios/{render}/{authoring}/{LANGUAGE}/
  to render and behave (editor config, execution output, structural UI)
  exactly as its attribute combination specifies

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
                                         behat_output_dir: Path = DEFAULT_BEHAT_OUTPUT_DIR) -> int:
    """Walks scenarios_dir for python/*.txt fixtures, groups them by their
    (render, authoring) leaf directory, and writes one .feature file per
    group under behat_output_dir. Returns the number of feature files
    written.

    Each fixture's attribute list is looked up from permutations.csv (via
    the perm number in its filename), not re-parsed from the fixture's own
    markup - this is the same source of truth generate_scenarios.py used to
    generate the fixture in the first place, so the two can never disagree
    about what a fixture is supposed to contain.

    Clears out any *.feature files already under behat_output_dir first, so
    that fixtures removed from tests/scenarios/ since the last run don't
    leave stale, no-longer-matching scenarios behind.
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
            groups[(render, authoring)].append((relative_path, attrs))

    if behat_output_dir.exists():
        for stale in behat_output_dir.rglob("*.feature"):
            stale.unlink()

    written = 0
    for (render, authoring), fixtures in sorted(groups.items()):
        is_interactive = render == "interactive"
        scenarios = [
            build_scenario(p, attrs, is_interactive)
            for p, attrs in sorted(fixtures, key=lambda pair: pair[0])
        ]
        feature_content = build_feature_file(render, authoring, scenarios)

        outdir = behat_output_dir / render / authoring
        outdir.mkdir(parents=True, exist_ok=True)
        outpath = outdir / f"{LANGUAGE}.feature"
        write_with_retry(outpath, feature_content)
        written += 1

    return written


if __name__ == "__main__":
    count = generate_behat_suite_from_scenarios()
    print(f"Wrote {count} feature files to {DEFAULT_BEHAT_OUTPUT_DIR}")
