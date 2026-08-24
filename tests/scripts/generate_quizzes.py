#!/usr/bin/env python3
"""Generates moodle-qbank_gitsync quiz-data JSON files under tests/quizzes/,
one per leaf (render, authoring, language) category in tests/qbank/top/,
each quiz containing every question already generated for that category.

Flat, not nested to match tests/qbank/top/'s own tree: gitsync's
import_quiz.php resolves --quizdatapath relative to a single --directory
(not a "top"-rooted category tree - that convention is specific to question
repos, not quiz repos), and each file's own name carries the category it
came from (e.g. highlight-html-classic-python_quiz.json), so nesting would
add structure without adding information. The trailing "_quiz.json" is
required by import_quiz.php's own auto-discovery (it scans a directory for
a file matching /.*_quiz\\.json/ when no --quizdatapath is given), which is
also exactly why every file needs a *different* name - with more than one
_quiz.json file in the directory, auto-discovery can't disambiguate and
--quizdatapath must be given explicitly per quiz.

Each quiz's questions are referenced by "nonquizfilepath", not embedded or
duplicated: this is gitsync's mechanism for building a quiz out of
questions from an *already-imported*, separate repo (here, tests/qbank/),
matched against that repo's own manifest file at quiz-import time via
`--nonquizmanifestpath`. See moodle-qbank_gitsync's classes/import_quiz.php
(import_quiz_data(), the nonquizmanifestentries/nonquizfilepath handling)
and doc/importquiztomoodle.md's second example. Nothing here needs that
manifest to exist yet, or to know which questions have actually been
imported so far - the path is resolved against whatever manifest is
supplied when a quiz is actually imported, which can happen independently
of when this script runs.

Twenty leaves, not the twenty-four a naive render x authoring x language
count would suggest: SQL is highlight-only throughout this fixture set
(generate_scenarios.py explicitly skips it for interactive - Jobe execution
was never wired up for SQL), so the four interactive/*/sql combinations
don't exist as real categories. Walking tests/qbank/top/ directly (rather
than assuming a fixed set of leaves) means this script produces exactly
however many non-empty leaves actually exist, automatically, rather than
hardcoding that exclusion a second time.

Does not run automatically - see the `if __name__ == "__main__"` guard at
the bottom.
"""
import json
import time
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
TESTS_DIR = SCRIPT_DIR.parent
DEFAULT_QBANK_DIR = TESTS_DIR / "qbank"
DEFAULT_QUIZZES_DIR = TESTS_DIR / "quizzes"

CATEGORY_FILE = "gitsync_category.xml"


# ---------------------------------------------------------------------------
# Quiz JSON generation - pure function, no filesystem access.
# ---------------------------------------------------------------------------

def build_quiz_json(name: str, intro: str, question_paths: list[str]) -> str:
    """Returns a complete quiz-data JSON document (as moodle-qbank_gitsync's
    import_quiz.php/import_quiz_data.php expect - see
    testrepoparent/testrepo_quiz_quiz-1/import-quiz_quiz.json in that repo
    for the reference example this mirrors field-for-field) referencing
    question_paths by "nonquizfilepath", one question per slot, all on a
    single page.

    :param name: Quiz name, shown in Moodle's course page and quiz list.
    :param intro: Quiz intro/description text.
    :param question_paths: "/top/..."-rooted paths (as recorded in a
        gitsync question manifest's "filepath" field) of the questions to
        include, in the order they should appear.
    """
    questions = [
        {
            "nonquizfilepath": path,
            "slot": str(slot),
            "page": "1",
            "requireprevious": 0,
            "maxmark": "1.0000000",
        }
        for slot, path in enumerate(question_paths, start=1)
    ]
    quiz = {
        "quiz": {
            "name": name,
            "intro": intro,
            "introformat": "0",
            "questionsperpage": "0",
            "grade": "100.00000",
            "navmethod": "free",
        },
        "sections": [
            {
                "firstslot": "1",
                "heading": name,
                "shufflequestions": 0,
            }
        ],
        "questions": questions,
        "feedback": [],
    }
    return json.dumps(quiz, indent=4) + "\n"


# ---------------------------------------------------------------------------
# Directory walking - filesystem access, delegates JSON construction above.
# ---------------------------------------------------------------------------

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


def generate_quizzes_from_qbank(qbank_dir: Path = DEFAULT_QBANK_DIR,
                                 quizzes_dir: Path = DEFAULT_QUIZZES_DIR) -> int:
    """Walks qbank_dir/top/ for (render, authoring, language) leaf
    directories and writes one flat quiz-data JSON file per non-empty leaf
    directly under quizzes_dir. Returns the number of quiz files written.

    Clears out any *_quiz.json files already under quizzes_dir first, so
    that leaves removed from tests/qbank/ since the last run don't leave
    stale quizzes behind - same reasoning as the other generator scripts'
    stale-file cleanup this session, after two real bugs were caused by
    skipping it.
    """
    top_dir = qbank_dir / "top"

    if quizzes_dir.exists():
        for stale in quizzes_dir.glob("*_quiz.json"):
            stale.unlink()

    written = 0
    for render_dir in sorted(top_dir.iterdir()):
        if not render_dir.is_dir():
            continue
        for authoring_dir in sorted(render_dir.iterdir()):
            if not authoring_dir.is_dir():
                continue
            for language_dir in sorted(authoring_dir.iterdir()):
                if not language_dir.is_dir():
                    continue

                render, authoring, language = render_dir.name, authoring_dir.name, language_dir.name
                question_files = sorted(
                    f for f in language_dir.glob("*.xml") if f.name != CATEGORY_FILE
                )
                if not question_files:
                    continue

                question_paths = [
                    f"/top/{render}/{authoring}/{language}/{f.name}" for f in question_files
                ]
                name = f"{render}-{authoring}-{language}"
                intro = (
                    f"All {render}/{authoring}/{language} fixtures from "
                    f"moodle-filter_ace_inline's tests/qbank - see tests/scripts/generate_quizzes.py."
                )
                quiz_json = build_quiz_json(name, intro, question_paths)

                quizzes_dir.mkdir(parents=True, exist_ok=True)
                output_path = quizzes_dir / f"{name}_quiz.json"
                write_with_retry(output_path, quiz_json)
                written += 1

    return written


if __name__ == "__main__":
    count = generate_quizzes_from_qbank()
    print(f"Wrote {count} quiz JSON files to {DEFAULT_QUIZZES_DIR}")
