#!/usr/bin/env python3
"""Generates Moodle question-bank XML files under tests/qbank/top/, mirroring
tests/scenarios/<render>/<authoring>/<language>/*.txt one-for-one.

The leading "top/" is required by moodle-qbank_gitsync, not by Moodle's XML
import itself: Gitsync only recognises a repo whose questions live under a
literal top/ directory (mirroring the "top" category every Moodle question
bank has), and walks the directories below it to derive question categories
- see moodle-qbank_gitsync's own testrepoparent/testrepo example and
doc/importrepotomoodle.md.

A gitsync_category.xml is generated in every directory under top/ (not just
leaf directories holding fixtures). Gitsync's own docs say categories get
auto-created from directory names when these files are absent - true for
importing the whole top/ tree in one go, but a *targeted* import
(`--subdirectory`) requires a real category file for every directory from
the import target downwards, confirmed the hard way: omitting them fails at
each level in turn with "Required category file does not exist". Since
targeted, scoped imports (e.g. just top/highlight/html-classic) are exactly
the kind of thing this fixture set is for, category files are always
generated rather than relying on the whole-tree-only fallback. Review the
resulting category names in Moodle before treating them as final, since
"html-classic"/"perm044" etc. are fixture-generator naming, not curated
question-bank category names - the category text is just "top/" + the
directory path, unmodified.

Each fixture becomes a single "description" question (Moodle's built-in
non-graded, informative-only question type - the same qtype used throughout
tests/behat/*.feature for loading these fixtures) whose questiontext is the
fixture's raw content, verbatim. The questiontext format is "markdown" for
fixtures from a markdown-* authoring folder and "html" for fixtures from a
html-* authoring folder - this mirrors the distinction already made in
tests/behat/behat_filter_ace_inline.php between "exists in question ... for
filter ace inline" (html) and "... as markdown for filter ace inline"
(markdown), and matters because a markdown fixture loaded as html (or vice
versa) would not exercise the code path it's meant to test.

The questiontext also lists the ace-inline data-* attribute names this
specific example exercises (e.g. "data-start-line-number, data-min-lines",
or "none" for the "NONE" baseline permutation) - not the render mode,
authoring mode or language, which are already implied by the question name
and Scenario path above it. Looked up from permutations.csv via the perm
number in the fixture's filename (see PERM_FILENAME_RE), the same source of
truth generate_scenarios.py used to generate the fixture in the first
place - not re-parsed from the fixture's own markup, which would require
separately handling all four authoring modes' different attribute syntaxes
for no benefit.

Design: XML generation (build_question_xml) is a pure function, independent
of the filesystem - it takes a name/content/format and returns an XML
string. Directory walking (generate_qbank_from_scenarios) is a separate
function that only handles finding fixtures and writing output files. This
split means the XML generator can be reused or tested without touching disk,
and the walker can change (e.g. new render/authoring/language dirs, or a
differently-shaped source tree) without needing to know anything about the
XML format itself.

Does not run automatically - see the `if __name__ == "__main__"` guard at
the bottom. Intended to be reviewed and then either imported and called, or
run directly, at the user's discretion.
"""
import os
import re
import time
from pathlib import Path

from generate_scenarios import load_rows

SCRIPT_DIR = Path(__file__).resolve().parent
TESTS_DIR = SCRIPT_DIR.parent
DEFAULT_SCENARIOS_DIR = TESTS_DIR / "scenarios"
DEFAULT_QBANK_DIR = TESTS_DIR / "qbank"

MARKDOWN_AUTHORING_PREFIX = "markdown-"

# Matches generate_behat_suite.py's own PERM_FILENAME_RE: a fixture's
# attribute list is looked up from permutations.csv via the perm number in
# its filename, not re-parsed from the fixture's own markup - this is the
# same source of truth generate_scenarios.py used to generate the fixture in
# the first place, so the two can never disagree about what attributes a
# fixture is supposed to exercise.
PERM_FILENAME_RE = re.compile(r"^perm(\d+)$")


# ---------------------------------------------------------------------------
# XML generation - pure functions, no filesystem access.
# ---------------------------------------------------------------------------

def escape_cdata(content: str) -> str:
    """CDATA sections can't contain the literal sequence ']]>' - split any
    occurrence across adjacent CDATA sections, which is the standard XML
    workaround (']]>' becomes ']]]]><![CDATA[>').
    """
    return content.replace("]]>", "]]]]><![CDATA[>")


def build_question_xml(name: str, content: str, questiontext_format: str, source_comment: str = "",
                        attributes: list[str] | None = None) -> str:
    """Returns a complete <quiz>...</quiz> XML document containing one
    "description" question with the given name and questiontext.

    :param name: Question name (shown in the question bank listing).
    :param content: Raw questiontext content (HTML or Markdown source),
        embedded verbatim inside a CDATA section.
    :param questiontext_format: "html" or "markdown".
    :param source_comment: Optional free-text noted in an XML comment above
        the question, e.g. the source fixture's path, for traceability back
        to tests/scenarios/.
    :param attributes: The ace-inline data-* attribute names (e.g.
        "data-start-line-number") this specific example exercises, per
        permutations.csv - not the render mode/authoring mode/language,
        which are already implied by name/source_comment's directory path.
        An empty list (or None) means the "NONE" baseline permutation - no
        attributes at all.
    """
    if questiontext_format not in ("html", "markdown"):
        raise ValueError(f"Unexpected questiontext_format: {questiontext_format!r}")

    comment = f"<!-- {source_comment} -->\n  " if source_comment else ""
    escaped_comment = escape_cdata(source_comment)
    escaped_content = escape_cdata(content)
    attributes_text = escape_cdata(", ".join(attributes) if attributes else "none")

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<quiz>
  {comment}<question type="description">
    <name>
      <text>{name}</text>
    </name>
    <questiontext format="{questiontext_format}">
      <text><![CDATA[<p>Scenario: {escaped_comment}</p></br><p>Attributes: {attributes_text}</p></br> {escaped_content}]]></text>
    </questiontext>
    <generalfeedback format="html">
      <text></text>
    </generalfeedback>
    <defaultgrade>0</defaultgrade>
    <penalty>0</penalty>
    <hidden>0</hidden>
    <idnumber></idnumber>
  </question>
</quiz>
"""


def build_category_xml(category_path: str) -> str:
    """Returns a complete <quiz>...</quiz> XML document containing one
    Moodle "category" pseudo-question, in the shape moodle-qbank_gitsync
    expects to find as gitsync_category.xml in each category directory -
    see its testrepoparent/testrepo/top/cat-1/gitsync_category.xml.

    :param category_path: Full category path including the leading "top",
        slash-separated, e.g. "top/highlight/html-classic".
    """
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<quiz>
  <question type="category">
    <category>
      <text>{category_path}</text>
    </category>
    <info format="moodle_auto_format">
      <text>Generated by tests/scripts/generate_qbank_xml.py</text>
    </info>
    <idnumber></idnumber>
  </question>
</quiz>
"""


# ---------------------------------------------------------------------------
# Directory walking - filesystem access, delegates XML construction above.
# ---------------------------------------------------------------------------

def question_name_for(relative_path: Path) -> str:
    """Derives a unique, readable question name from a fixture's path
    relative to tests/scenarios/, e.g.
    highlight/markdown-simplified/c/perm053.txt -> highlight_markdown-simplified_c_perm053
    """
    parts = list(relative_path.parts[:-1]) + [relative_path.stem]
    return "_".join(parts)


def questiontext_format_for(relative_path: Path) -> str:
    """The authoring-mode path component (2nd segment) determines format:
    markdown-classic/markdown-simplified -> "markdown", html-* -> "html".
    """
    authoring_mode = relative_path.parts[1]
    return "markdown" if authoring_mode.startswith(MARKDOWN_AUTHORING_PREFIX) else "html"


def write_with_retry(path: Path, content: str, attempts: int = 5, delay: float = 1.0) -> None:
    """Writes content to path, retrying on TimeoutError - this repo lives
    under OneDrive-managed storage, which has been observed (see
    generate_scenarios.py) to transiently lock an individual file during
    bulk writes. Same fix as there.
    """
    for attempt in range(attempts):
        try:
            path.write_text(content)
            return
        except TimeoutError:
            if attempt == attempts - 1:
                raise
            time.sleep(delay)


def read_with_retry(path: Path, attempts: int = 5, delay: float = 1.0) -> str:
    """As write_with_retry(), but for reads - the same OneDrive contention
    has been observed on reads as well as writes.
    """
    for attempt in range(attempts):
        try:
            return path.read_text()
        except TimeoutError:
            if attempt == attempts - 1:
                raise
            time.sleep(delay)
    raise AssertionError("unreachable")


def generate_qbank_from_scenarios(scenarios_dir: Path = DEFAULT_SCENARIOS_DIR,
                                   qbank_dir: Path = DEFAULT_QBANK_DIR) -> int:
    """Walks scenarios_dir for *.txt fixtures and writes one mirrored *.xml
    file per fixture under qbank_dir/top/, plus one gitsync_category.xml in
    every directory under qbank_dir/top/ (including ones with no fixtures
    directly in them, only subdirectories - e.g. top/highlight itself, not
    just top/highlight/html-classic/python). Returns the number of question
    XML files written (category files aren't counted, since they're a fixed
    function of the directory tree shape, not of how many fixtures exist).

    Clears out any *.xml files already under qbank_dir first (not just
    qbank_dir/top/, since this moved under a new top/ prefix and older runs
    before that change would otherwise leave orphaned copies at the old,
    now-stale paths) - same reasoning as generate_scenarios.py's stale-file
    cleanup.
    """
    if qbank_dir.exists():
        for stale in qbank_dir.rglob("*.xml"):
            stale.unlink()

    rows = load_rows()

    written = 0
    category_dirs = set()
    for dirpath, _dirnames, filenames in os.walk(scenarios_dir):
        relative_dir = Path(dirpath).relative_to(scenarios_dir)
        if relative_dir != Path("."):
            category_dirs.add(relative_dir)

        for filename in sorted(filenames):
            if not filename.endswith(".txt"):
                continue

            fixture_path = Path(dirpath) / filename
            relative_path = fixture_path.relative_to(scenarios_dir)

            content = read_with_retry(fixture_path)
            questiontext_format = questiontext_format_for(relative_path)
            name = question_name_for(relative_path)
            match = PERM_FILENAME_RE.match(relative_path.stem)
            attributes = rows[int(match.group(1)) - 1] if match else []
            xml = build_question_xml(
                name=name,
                content=content,
                questiontext_format=questiontext_format,
                source_comment=f"generated from tests/scenarios/{relative_path.as_posix()}",
                attributes=attributes,
            )

            output_path = qbank_dir / "top" / relative_path.with_suffix(".xml")
            output_path.parent.mkdir(parents=True, exist_ok=True)
            write_with_retry(output_path, xml)
            written += 1

    for relative_dir in category_dirs:
        category_path = "top/" + relative_dir.as_posix()
        category_xml = build_category_xml(category_path)
        category_output_dir = qbank_dir / "top" / relative_dir
        category_output_dir.mkdir(parents=True, exist_ok=True)
        write_with_retry(category_output_dir / "gitsync_category.xml", category_xml)

    return written


if __name__ == "__main__":
    count = generate_qbank_from_scenarios()
    print(f"Wrote {count} question XML files to {DEFAULT_QBANK_DIR}")
