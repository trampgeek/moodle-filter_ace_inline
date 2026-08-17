#!/usr/bin/env python3
"""Generates Moodle question-bank XML files under tests/qbank/, mirroring
tests/scenarios/<render>/<authoring>/<language>/*.txt one-for-one.

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
import time
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
TESTS_DIR = SCRIPT_DIR.parent
DEFAULT_SCENARIOS_DIR = TESTS_DIR / "scenarios"
DEFAULT_QBANK_DIR = TESTS_DIR / "qbank"

MARKDOWN_AUTHORING_PREFIX = "markdown-"


# ---------------------------------------------------------------------------
# XML generation - pure functions, no filesystem access.
# ---------------------------------------------------------------------------

def escape_cdata(content: str) -> str:
    """CDATA sections can't contain the literal sequence ']]>' - split any
    occurrence across adjacent CDATA sections, which is the standard XML
    workaround (']]>' becomes ']]]]><![CDATA[>').
    """
    return content.replace("]]>", "]]]]><![CDATA[>")


def build_question_xml(name: str, content: str, questiontext_format: str, source_comment: str = "") -> str:
    """Returns a complete <quiz>...</quiz> XML document containing one
    "description" question with the given name and questiontext.

    :param name: Question name (shown in the question bank listing).
    :param content: Raw questiontext content (HTML or Markdown source),
        embedded verbatim inside a CDATA section.
    :param questiontext_format: "html" or "markdown".
    :param source_comment: Optional free-text noted in an XML comment above
        the question, e.g. the source fixture's path, for traceability back
        to tests/scenarios/.
    """
    if questiontext_format not in ("html", "markdown"):
        raise ValueError(f"Unexpected questiontext_format: {questiontext_format!r}")

    comment = f"<!-- {source_comment} -->\n  " if source_comment else ""
    escaped_comment = escape_cdata(source_comment)
    escaped_content = escape_cdata(content)

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<quiz>
  {comment}<question type="description">
    <name>
      <text>{name}</text>
    </name>
    <questiontext format="{questiontext_format}">
      <text><![CDATA[<p>Scenario: {escaped_comment}</p></br> {escaped_content}]]></text>
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
    file per fixture under qbank_dir. Returns the number of files written.
    """
    written = 0
    for dirpath, _dirnames, filenames in os.walk(scenarios_dir):
        for filename in sorted(filenames):
            if not filename.endswith(".txt"):
                continue

            fixture_path = Path(dirpath) / filename
            relative_path = fixture_path.relative_to(scenarios_dir)

            content = read_with_retry(fixture_path)
            questiontext_format = questiontext_format_for(relative_path)
            name = question_name_for(relative_path)
            xml = build_question_xml(
                name=name,
                content=content,
                questiontext_format=questiontext_format,
                source_comment=f"generated from tests/scenarios/{relative_path.as_posix()}",
            )

            output_path = qbank_dir / relative_path.with_suffix(".xml")
            output_path.parent.mkdir(parents=True, exist_ok=True)
            write_with_retry(output_path, xml)
            written += 1

    return written


if __name__ == "__main__":
    count = generate_qbank_from_scenarios()
    print(f"Wrote {count} question XML files to {DEFAULT_QBANK_DIR}")
