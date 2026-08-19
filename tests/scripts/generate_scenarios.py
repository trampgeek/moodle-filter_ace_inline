#!/usr/bin/env python3
"""Generates fixture .txt files under tests/scenarios/<render>/<authoring>/<language>/
from the curated attribute-combination list in permutations.csv.

Structure: tests/scenarios/{highlight,interactive}/{html-classic,html-simplified,
markdown-classic,markdown-simplified}/{c,python,sql}/permNNN.txt

These are fixtures only - no Behat feature files/assertions are generated here
(by design: this is a separate layer from tests/behat/, see TESTING.md Phases A-E).

Key decisions, spelled out here since they aren't obvious from the code:

- Render mode: a row containing any Interactive-only attribute (button-name,
  readonly, hidden, stdin-taid, file-taids, file-upload-id, params, code-mapper,
  prefix, suffix, html-output, max-output-length) is generated for Interactive
  only. A row containing only dual-mode attributes (start-line-number, font-size,
  min-lines, max-lines, dark-theme-mode, line-numbers) is generated for both.

- Authoring mode: "line-numbers" is a Simplified-mode-only pseudo-attribute (no
  data-* equivalent), so rows containing it are skipped for html-classic/
  markdown-classic. "data-params", "data-prefix", "data-suffix", "data-file-taids"
  have values that can't survive colon-splitting (JSON/code containing colons or
  spaces - confirmed in the filter's own README/TESTING.md), so rows containing
  any of those are skipped for html-simplified/markdown-simplified.

- SQL is Highlight-only: nothing in this plugin's existing tests ever runs SQL
  through Jobe (sql_highlighting.feature only checks highlighting), so rows
  requiring Interactive are skipped for the sql language entirely.

- Attribute values are fixed, arbitrary-but-valid placeholders (see ATTR_META) -
  these fixtures verify attribute *parsing*, not each attribute's runtime
  behaviour (that's what tests/behat/ already covers per-attribute). Companion
  elements (textarea/input/script) needed by stdin-taid/file-taids/
  file-upload-id/code-mapper are prepended as raw HTML, same technique already
  used in tests/fixtures/simplifiedclassmodeattrsdemo.txt. Two exceptions -
  min-lines and max-lines - are resolved per-fixture instead of being purely
  fixed (see resolve_attr_value()): min-lines is bumped up, per language, to
  stay comfortably above that language's own BASE_CODE line count, and
  max-lines is bumped up to stay above min-lines' own value whenever a row
  configures both together - both to keep the values realistic/self-
  consistent rather than because their exact number matters for parsing.
"""
import csv
import json
import os
import time
from typing import cast

type ATTR = dict[str, dict[str, int|str|bool|None]]

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(SCRIPT_DIR))
SCENARIOS_DIR = os.path.join(SCRIPT_DIR, "..", "scenarios")
CSV_PATH = os.path.join(SCRIPT_DIR, "permutations.csv")

RENDER_MODES = ["highlight", "interactive"]
AUTHORING_MODES = ["html-classic", "html-simplified", "markdown-classic", "markdown-simplified"]
LANGUAGES = ["python", "c", "sql"]

# value, whether it forces Interactive, whether usable in Simplified (colon) mode,
# the key used in Simplified colon-encoding (usually same as the data-* suffix),
# and any companion raw-HTML this attribute needs.
ATTR_META: ATTR = {
    "data-start-line-number": dict(value="7", interactive_only=False, simplified_ok=True, skey="start-line-number"),
    "data-font-size": dict(value="18pt", interactive_only=False, simplified_ok=True, skey="font-size"),
    # This base placeholder is bumped per-language at render time (see
    # resolve_attr_value()) to always be at least 5 more than that
    # language's own BASE_CODE line count: apply_ace_editor.js applies this
    # as minLines: Math.max(numLines, params['min-lines']), so a configured
    # value not comfortably clear of the code's natural height would risk
    # being masked by that height and getOption('minLines') would reflect
    # the code, not this attribute - making the attribute's effect
    # unobservable. 20 already safely exceeds Python's line count (13) on
    # its own, so Math.max always resolves to this exact configured value
    # there and resolve_attr_value() leaves it untouched; generate_behat_
    # suite.py (Python-only - see its own docstring) can assert
    # getOption('minLines') == 20 directly. BASE_CODE["c"] is longer
    # (29 lines), so resolve_attr_value() bumps this placeholder up to 34
    # there, preserving the same exact-equality property for any C getOption
    # suite that gets added later.
    "data-min-lines": dict(value="20", interactive_only=False, simplified_ok=True, skey="min-lines"),
    # This base placeholder is bumped at render time (see
    # resolve_attr_value()) to always be at least 5 more than data-min-lines'
    # own (possibly per-language-bumped) value, whenever a row configures
    # both attributes together - otherwise apply_ace_editor.js would be
    # handed a maxLines smaller than minLines, not a realistic editor
    # configuration and not what those fixtures are meant to exercise. Rows
    # that configure data-max-lines alone (no data-min-lines) are unaffected
    # and keep this literal, deliberately-tiny value - small enough that the
    # editor's own un-overridden height always exceeds it, exercising
    # max-lines' scrolling/truncation behaviour on its own.
    "data-max-lines": dict(value="3", interactive_only=False, simplified_ok=True, skey="max-lines"),
    "data-dark-theme-mode": dict(value="2", interactive_only=False, simplified_ok=True, skey="dark-theme-mode"),
    "data-button-name": dict(value="RunIt", interactive_only=True, simplified_ok=True, skey="button-name"),
    "data-readonly": dict(value="true", interactive_only=True, simplified_ok=True, skey="readonly"),
    "data-hidden": dict(value="true", interactive_only=True, simplified_ok=True, skey="hidden"),
    "data-stdin-taid": dict(value="stdinbox1", interactive_only=True, simplified_ok=True, skey="stdin-taid",
                             companion="textarea"),
    "data-file-taids": dict(value='{"in1.txt": "filebox1"}', interactive_only=True, simplified_ok=False,
                             markdown_classic_ok=False, companion="filetextarea"),
    "data-file-upload-id": dict(value="uploadbox1", interactive_only=True, simplified_ok=True, skey="file-upload-id",
                                 companion="input"),
    "data-params": dict(value='{"cputime": 5}', interactive_only=True, simplified_ok=False, markdown_classic_ok=False),
    "data-code-mapper": dict(value="mapFn1", interactive_only=True, simplified_ok=True, skey="code-mapper",
                              companion="script"),
    "data-prefix": dict(value=None, interactive_only=True, simplified_ok=False),  # per-language, see PREFIX_SUFFIX
    "data-suffix": dict(value=None, interactive_only=True, simplified_ok=False),
    "data-html-output": dict(value="true", interactive_only=True, simplified_ok=True, skey="html-output"),
    # Deliberately tiny: every possible execution output BASE_CODE can produce
    # ("hello", "stdin:...", "files:...", "mapped") is at least 5 characters,
    # so this reliably triggers truncation regardless of what else a fixture
    # combines it with - see generate_behat_suite.py's expected_output_marker().
    "data-max-output-length": dict(value="4", interactive_only=True, simplified_ok=True, skey="max-output-length"),
    "line-numbers": dict(value="3", interactive_only=False, simplified_ok=True, skey="line-numbers",
                          simplified_only=True),
}

# Single, plain alphanumeric tokens only - anything with punctuation (even just a
# bare ";") has been observed to corrupt Markdown Extra's {...} attribute-list
# parser, same failure mode as the brace-bearing JSON values above.
PREFIX_SUFFIX = {"python": "pass", "c": "int", "sql": "int"}

# Raw source, never pre-escaped - Markdown Extra escapes fenced-code-block
# content itself, so pre-escaping here would double-escape (confirmed
# empirically: "&lt;" fed into a ``` fence renders as "&amp;lt;"). The two
# HTML-authoring renderers below call html_escape_code() themselves instead.
#
# Both the C and Python snippets are deliberately more than a bare
# print()/printf() - each is designed so tests/scripts/generate_behat_suite.py
# can verify data-stdin-taid and data-file-taids/data-file-upload-id by their
# actual effect on execution output, not just by their presence in the
# markup, and so both languages' fixtures behave identically (files checked
# first, then stdin, then a "hello" baseline) even though only the Python
# fixtures currently get that assertion in generate_behat_suite.py.
# data-stdin-taid and data-file-taids/data-file-upload-id are never combined
# in the same fixture (permutations.py excludes that pairing), so checking
# for the uploaded file first, then stdin, is unambiguous - whichever
# mechanism a given fixture actually configured is the one that will have
# real content. The in1.txt filename is hardcoded to match data-file-taids'
# value below, rather than listing the working directory as the Python
# snippet does - dirent.h directory listing has no exact os.listdir()
# equivalent worth the extra style-guide surface area for the same result.
#
# Both snippets follow tests/scripts/styleguidelines.html. C in particular:
# explicit function comment (rule 65) and function-block braces on their own
# line (rule 50) are "must" rules there, not just recommendations; the rest
# below are "should" rules, followed anyway for consistency: a single return
# at the end (rule 41, so the file/stdin/baseline branches are if/else, not
# early returns), if-else braces on the same line as the keyword (rule 51,
# note this is the opposite of rule 50's function-brace placement), explicit
# non-NULL/non-EOF comparisons rather than implicit truthiness (rule 36),
# and nesting no more than three deep (rule 58: file-check -> stdin-check ->
# the stdin-echo while loop). `while ((c = fgetc(file)) != EOF)` and
# `while ((c = getchar()) != EOF)` use rule 44's explicitly-permitted
# assignment-in-condition exception for exactly this idiom.
# Triple-quoted so each entry reads as real source in this file, not as a
# stack of '...\n' literals. Content must still match exactly what the old
# concatenated-literal form produced - no leading blank line (content starts
# immediately after the opening \"\"\") and no trailing newline (the closing
# \"\"\" is glued onto the last line of content, not on a line of its own).
BASE_CODE = {
    "python": """import os
import sys

text_files = [f for f in os.listdir() if f.endswith(".txt")]
if text_files:
    with open(text_files[0]) as fh:
        print("files:" + fh.read())
else:
    stdin_data = sys.stdin.read()
    if stdin_data:
        print("stdin:" + stdin_data)
    else:
        print("hello")""",
    "c": """#include <stdio.h>

// Prints the contents of in1.txt if present, else stdin if given,
// else a default greeting.
int main(void)
{
    FILE *file = fopen("in1.txt", "r");
    if (file != NULL) {
        int c = 0;
        printf("files:");
        while ((c = fgetc(file)) != EOF) {
            putchar(c);
        }
        fclose(file);
    } else {
        int first = getchar();
        if (first != EOF) {
            int c = 0;
            printf("stdin:");
            putchar(first);
            while ((c = getchar()) != EOF) {
                putchar(c);
            }
        } else {
            printf("hello");
        }
    }
    return 0;
}""",
    # SQL is highlight-only (see the module docstring), so unlike python/c
    # above there is no execution behaviour to design for here - this is
    # just a longer, more representative example for highlighting/min-lines/
    # max-lines fixture quality. Formatted per https://www.sqlstyle.guide:
    # uppercase reserved words; the CREATE TABLE column/type alignment
    # follows that guide's own worked example exactly (name and type each
    # padded to the widest one present, one space minimum); the SELECT's
    # SELECT/FROM/JOIN/ON/WHERE/AND keywords are right-aligned to a common
    # "river" (also straight from the guide's worked example), while
    # GROUP BY/HAVING/ORDER BY are simply left-indented rather than
    # river-aligned, matching the one such case the guide itself shows
    # (a GROUP BY that does not extend the SELECT/FROM/WHERE river width).
    "sql": """CREATE TABLE staff (
    PRIMARY KEY (staff_num),
    staff_num  INT(5)        NOT NULL,
    first_name VARCHAR(100)  NOT NULL,
    last_name  VARCHAR(100)  NOT NULL,
    hire_date  DATE          NOT NULL,
    salary     DECIMAL(10,2) NOT NULL
);

SELECT s.staff_num, s.first_name, s.last_name, COUNT(o.order_id) AS order_count
  FROM staff AS s
  JOIN orders AS o
    ON o.staff_num = s.staff_num
 WHERE s.hire_date >= '2020-01-01'
   AND s.salary > 50000
  GROUP BY s.staff_num, s.first_name, s.last_name
  HAVING COUNT(o.order_id) > 10
  ORDER BY s.last_name ASC;""",
}

LANG_TAG = {"python": "python3", "c": "c", "sql": "sql"}

# Minimum margin data-min-lines must clear above a language's own BASE_CODE
# line count, and data-max-lines must clear above data-min-lines' own value
# when both are configured together - see the ATTR_META comments on those
# two attributes for why each margin matters.
MIN_LINES_MARGIN = 5
MAX_LINES_MARGIN = 5


def code_line_count(language: str) -> int:
    """Number of lines in this language's BASE_CODE snippet."""
    return BASE_CODE[language].count("\n") + 1


def resolve_attr_value(attr: str, attrs: list[str], language: str) -> str:
    """Resolves the placeholder value to actually render for one attribute
    of one fixture. Every attribute value is fixed (ATTR_META's own
    placeholder, or - for data-prefix/data-suffix - PREFIX_SUFFIX[language])
    except two, whose value must instead be computed relative to something
    else about this specific fixture:

    - data-min-lines: bumped up to MIN_LINES_MARGIN more than this
      language's own BASE_CODE line count, if ATTR_META's own placeholder
      isn't already comfortably above it (true for python and sql, not c -
      see ATTR_META's own comment on this attribute).
    - data-max-lines: bumped up to MAX_LINES_MARGIN more than data-min-lines'
      own (possibly just-bumped) value, but only when this fixture's row
      also configures data-min-lines - otherwise unaffected.

    :param attr: The data-* attribute (or "line-numbers") to resolve.
    :param attrs: Every attribute this fixture's permutation row configures
        (from permutations.csv via generate_scenarios.load_rows()) - needed
        to detect the data-min-lines/data-max-lines interaction above.
    :param language: "python", "c" or "sql".
    """
    meta = ATTR_META[attr]
    if attr == "data-min-lines":
        return str(max(int(cast(str, meta["value"])), code_line_count(language) + MIN_LINES_MARGIN))
    if attr == "data-max-lines" and "data-min-lines" in attrs:
        min_lines_value = int(resolve_attr_value("data-min-lines", attrs, language))
        return str(max(int(cast(str, meta["value"])), min_lines_value + MAX_LINES_MARGIN))
    return PREFIX_SUFFIX[language] if meta["value"] is None else str(meta["value"])


def html_escape_code(code: str) -> str:
    """Escapes code for embedding directly as final HTML (html-classic/
    html-simplified) - NOT used for markdown-* renderers, which must receive
    raw source since Markdown Extra escapes fenced-code-block content itself.
    """
    return code.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


# What code-mapper's companion function replaces the executed code with -
# deliberately NOT an identity/pass-through, since "mapper ran" and "mapper
# had no effect" would otherwise be indistinguishable by output alone.
# Per-language because the mapper's return value becomes the code that
# actually gets sent for execution - a Python print() would be a syntax
# error if it ended up sent to a C fixture (not that this currently happens:
# code-mapper is Interactive-only and SQL is never Interactive, so only
# "python" and "c" are ever looked up here - "sql" is included anyway so a
# future change that lifts that restriction doesn't KeyError).
MAPPER_REPLACEMENT_CODE = {
    "python": 'print("mapped")',
    "c": '#include <stdio.h>\nint main(void){printf("mapped");return 0;}',
    "sql": "SELECT 'mapped';",
}


def companion_html(attrs: list[str], language: str) -> str:
    """Raw HTML for any textarea/input/script companion elements these attrs need."""
    parts = []
    for attr in attrs:
        companion = ATTR_META[attr].get("companion")
        if companion == "textarea":
            parts.append('<textarea id="stdinbox1">hello</textarea>')
        elif companion == "filetextarea":
            parts.append('<textarea id="filebox1">file contents</textarea>')
        elif companion == "input":
            parts.append('<input id="uploadbox1" type="file">')
        elif companion == "script":
            replacement = json.dumps(MAPPER_REPLACEMENT_CODE[language])
            parts.append(f"<script>\nfunction mapFn1(s) {{ return {replacement}; }}\n</script>")
    return "\n".join(parts)


def render_html(attrs: list[str], is_interactive: bool, language: str) -> str:
    """html-classic: <pre data-x=y ...><code>...</code></pre> - all data-*
    attributes (name always prefixed data-) live on the <pre>, exactly as a
    TinyMCE author would hand-write it; the inner <code> is a plain wrapper
    with no attributes of its own, present only so the markup contains a
    literal "<code" substring (see render_html_simplified()'s docstring for
    why that substring matters at the PHP filter level).
    """
    marker = "ace-interactive-code" if is_interactive else "ace-highlight-code"
    bits = [f"data-{marker}", f'data-lang="{LANG_TAG[language]}"']
    for attr in attrs:
        value = resolve_attr_value(attr, attrs, language)
        name = attr[len("data-"):] if attr.startswith("data-") else attr
        # Double quotes inside the value (e.g. data-file-taids'/data-params' JSON)
        # must be entity-escaped or they prematurely close the HTML attribute -
        # matches the convention already used in tests/fixtures/taidsdemo.txt.
        escaped_value = str(value).replace('"', "&quot;")
        bits.append(f'data-{name}="{escaped_value}"')
    pre_open = "<pre " + " ".join(bits) + ">"
    return f"{pre_open}<code>{html_escape_code(BASE_CODE[language])}</code></pre>"


def render_html_simplified(attrs: list[str], is_interactive: bool, language: str) -> str:
    """html-simplified: <pre class="lang:attr:value:..."><code>code</code></pre> -
    the colon-encoded class lives on the <pre> itself (matching how every
    other authoring mode keeps its markers/attributes on the <pre>, and how
    a real author would write "the class goes on the block element"), with
    a plain, attribute-less <code> also present purely so the raw markup
    contains a literal "<code" substring.

    That substring matters because text_filter.php's do_ace_editor() only
    ever queues the JS module for a page when the text contains an explicit
    "ace-interactive-code"/"ace-highlight-code" marker, or - only when
    simplified_mode is on - the literal substring "<code". Nothing about
    the plugin's actual Simplified-mode parsing requires the class to be on
    <code> rather than <pre>: apply_ace_editor.js's own <pre>-handling pass
    calls isSimplifiedClassMode(pre.classList, config) and
    extractSimplifiedClassModeParameters() directly against the <pre>'s own
    classList, independently of whatever is nested inside it.

    An earlier version of this function put the class on <code> instead
    (based on an empirical probe showing that shape works), because a bare
    <pre class="..."> with no <code> substring anywhere fails the PHP gate
    outright. This version keeps the <code> only as a substring-satisfying
    placeholder, restoring class-on-<pre> as the fixture's actual authored
    shape. If this version's fixtures fail where the <code>-class version
    passed, that is a real gap in apply_ace_editor.js's <pre>-handling pass
    - not a test bug - and should be investigated there, not worked around
    here.
    """
    class_parts = [LANG_TAG[language]]
    if is_interactive:
        class_parts.append("interactive")
    for attr in attrs:
        meta = ATTR_META[attr]
        value = resolve_attr_value(attr, attrs, language)
        # ATTR's per-attribute dict type is a single int|str|bool|None union
        # across all keys (it doesn't model each key's own type), so meta's
        # static type for "skey" is wider than reality here. Every attr this
        # function is ever called with has a real string skey - applicable_
        # authoring_modes() only allows attrs with simplified_ok=True into
        # simplified mode, and every simplified_ok=True entry in ATTR_META
        # defines one - so the cast documents an invariant enforced
        # elsewhere, not an unchecked assumption made here.
        class_parts.append(cast(str, meta["skey"]))
        class_parts.append(str(value))
    class_str = ":".join(class_parts)
    return f'<pre class="{class_str}"><code>{html_escape_code(BASE_CODE[language])}</code></pre>'


def render_markdown_classic(attrs: list[str], is_interactive: bool, language: str) -> str:
    """markdown-classic: ``` {data-x=y ...} fenced block attribute list."""
    marker = "ace-interactive-code" if is_interactive else "ace-highlight-code"
    bits = [f"data-{marker}=", f"data-lang={LANG_TAG[language]}"]
    for attr in attrs:
        value = resolve_attr_value(attr, attrs, language)
        name = attr[len("data-"):] if attr.startswith("data-") else attr
        bits.append(f"data-{name}={value}")
    header = " ".join(bits)
    return f"``` {{{header}}}\n{BASE_CODE[language]}\n```"


def render_markdown_simplified(attrs: list[str], is_interactive: bool, language: str) -> str:
    """markdown-simplified: ```lang:interactive:attr:value:... colon-encoded fence info."""
    class_parts = [LANG_TAG[language]]
    if is_interactive:
        class_parts.append("interactive")
    for attr in attrs:
        meta = ATTR_META[attr]
        value = resolve_attr_value(attr, attrs, language)
        # See the matching cast in render_html_simplified() above - same
        # reasoning applies here.
        class_parts.append(cast(str, meta["skey"]))
        class_parts.append(str(value))
    info = ":".join(class_parts)
    return f"```{info}\n{BASE_CODE[language]}\n```"


RENDERERS = {
    "html-classic": render_html,
    "html-simplified": render_html_simplified,
    "markdown-classic": render_markdown_classic,
    "markdown-simplified": render_markdown_simplified,
}


def load_rows() -> list[list[str]]:
    """Reads permutations.csv into a list of attribute-name lists, one per
    row. A row that is exactly "NONE" is a deliberate baseline scenario -
    no data-* attributes at all, just whichever render mode/authoring
    mode/language it's generated under - and becomes an empty list rather
    than a literal ["NONE"] attribute. Every downstream consumer already
    handles an empty attrs list correctly with no special-casing (the
    renderers just emit no data-* attributes/companions, and
    applicable_render_modes()/applicable_authoring_modes() both fall
    through to their most permissive case on an empty list), so this
    translation is the only change NONE needs.
    """
    rows: list[list[str]] = []
    with open(CSV_PATH, newline="") as f:
        for row in csv.reader(f):
            attrs = [a.strip() for a in row if a.strip()]
            if attrs == ["NONE"]:
                rows.append([])
            elif attrs:
                rows.append(attrs)
    return rows


def applicable_render_modes(attrs: list[str]) -> list[str]:
    if any(ATTR_META[a]["interactive_only"] for a in attrs):
        return ["interactive"]
    return ["highlight", "interactive"]


def applicable_authoring_modes(attrs: list[str]) -> list[str]:
    has_line_numbers = "line-numbers" in attrs
    has_simplified_incompatible = any(not ATTR_META[a]["simplified_ok"] for a in attrs)
    # data-params/data-file-taids hold JSON values with their own embedded braces,
    # colons and spaces, which corrupt Markdown Extra's {...} attribute-list parser
    # even though they're perfectly valid as real HTML attribute values (confirmed
    # empirically: the whole fence fails to parse as code at all). Single-token
    # values (e.g. data-prefix/data-suffix's placeholders) are fine in {} - only
    # brace-bearing JSON values are excluded here.
    has_markdown_classic_incompatible = any(not ATTR_META[a].get("markdown_classic_ok", True) for a in attrs)
    modes: list[str] = []
    if not has_line_numbers:
        modes.append("html-classic")
        if not has_markdown_classic_incompatible:
            modes.append("markdown-classic")
    if not has_simplified_incompatible:
        modes.append("html-simplified")
        modes.append("markdown-simplified")
    return modes


def write_with_retry(path: str, content: str, attempts: int = 5, delay: float = 1.0) -> None:
    """Writes content to path, retrying on TimeoutError.

    This repo lives under OneDrive-managed storage; writing hundreds of files
    in quick succession has been observed to make OneDrive's sync daemon
    transiently lock an individual file (read OR write), raising
    TimeoutError: [Errno 60] on whichever file it's contending with at that
    moment - a different file each run, not a problem with any specific
    file's content. A short retry clears it every time it's been hit so far.
    """
    for attempt in range(attempts):
        try:
            with open(path, "w") as f:
                f.write(content)
            return
        except TimeoutError:
            # Re-raise on the last attempt instead of stashing the exception
            # in a variable to raise afterwards - that would type as
            # Exception | None (a plain "last_error = None" initial value),
            # and casting it to Exception at the raise site would be
            # asserting something not actually true if attempts <= 0. A
            # bare `raise` inside the except block re-raises the exception
            # currently being handled, which mypy always accepts.
            if attempt == attempts - 1:
                raise
            time.sleep(delay)


def main() -> None:
    # Clear stale fixtures first. Row indices in permutations.csv can and do
    # shift (e.g. inserting a new row at the top shifts every later row's
    # permNNN.txt filename by one), and which indices are applicable to a
    # given render/authoring/language directory depends on that row's own
    # attrs - so a shift does not uniformly relabel existing files, it
    # silently orphans some of them under filenames the new run no longer
    # writes to. Without this, those orphaned files would sit on disk
    # forever, misrepresenting whatever row currently occupies that index.
    # Same fix generate_behat_suite.py already applies to its output dir.
    if os.path.isdir(SCENARIOS_DIR):
        for dirpath, _dirnames, filenames in os.walk(SCENARIOS_DIR):
            for filename in filenames:
                if filename.endswith(".txt"):
                    os.remove(os.path.join(dirpath, filename))

    rows = load_rows()
    counts: dict[tuple[str, str, str], int] = {}
    for idx, attrs in enumerate(rows, start=1):
        render_modes = applicable_render_modes(attrs)
        authoring_modes = applicable_authoring_modes(attrs)
        for render in render_modes:
            for authoring in authoring_modes:
                for language in LANGUAGES:
                    if language == "sql" and render == "interactive":
                        continue  # SQL is never Jobe-executable in this plugin's tests.
                    is_interactive = render == "interactive"
                    body = RENDERERS[authoring](attrs, is_interactive, language)
                    extra = companion_html(attrs, language)
                    content = (extra + "\n\n" + body) if extra else body
                    content += "\n"

                    outdir = os.path.join(SCENARIOS_DIR, render, authoring, language)
                    os.makedirs(outdir, exist_ok=True)
                    outpath = os.path.join(outdir, f"perm{idx:03d}.txt")
                    write_with_retry(outpath, content)
                    key = (render, authoring, language)
                    counts[key] = counts.get(key, 0) + 1

    total = sum(counts.values())
    print(f"Generated {total} fixture files from {len(rows)} permutation rows.\n")
    for render in RENDER_MODES:
        for authoring in AUTHORING_MODES:
            for language in LANGUAGES:
                key = (render, authoring, language)
                if key in counts:
                    print(f"  {render}/{authoring}/{language}: {counts[key]}")


if __name__ == "__main__":
    main()
