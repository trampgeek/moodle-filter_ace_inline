/**
 * This file is part of Moodle - http:moodle.org/
 *
 * Moodle is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Moodle is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Moodle.  If not, see <http:www.gnu.org/licenses/>.
 */

/**
 * A C/C++ Ace mode that additionally highlights datatype-looking identifiers:
 * names ending in "_t" (size_t, MyType_t, ...) and PascalCase names
 * (MyStruct, FooBar, ...), tokenised as "support.type" so both bundled Ace
 * themes render them distinctly from plain identifiers and core keywords.
 *
 * Built at runtime on top of CodeRunner's vendored ace/mode-c_cpp.js rather
 * than editing that file directly, so it survives CodeRunner/Ace upgrades
 * and only affects editors this filter creates.
 *
 * @module     filter_ace_inline/local/c_datatype_mode
 * @copyright  2026 Andrew Bainbridge-Smith
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

// Matches "_t"-suffixed identifiers (size_t, MyType_t) or PascalCase
// identifiers (MyStruct, FooBar). PascalCase requires a lowercase letter
// after the leading uppercase one, so ALL_CAPS macros/constants (NULL,
// INT_MAX) are left untouched.
const DATATYPE_REGEX = "\\b(?:[A-Za-z_][A-Za-z0-9_]*_t|[A-Z][A-Za-z0-9]*[a-z][A-Za-z0-9]*)\\b";

// The exact regex string used by the generic identifier/keyword rule in
// CodeRunner's vendored c_cpp highlight rules; our rule must be spliced in
// immediately before it so it gets first refusal on each identifier match.
const KEYWORD_RULE_REGEX = "[a-zA-Z_$][a-zA-Z0-9_$]*";

let cachedMode = null;

// Ace constructs HighlightRules once per editor session, so without this the warning below
// would repeat for every C/C++ block on the page. The cause is the same each time, so say it once.
let keywordRuleWarningIssued = false;

/**
 * Builds (once) and returns an Ace Mode instance for C/C++ that additionally
 * classifies "_t"-suffixed and PascalCase identifiers as "support.type"
 * tokens, without modifying CodeRunner's vendored ace/mode-c_cpp.js.
 *
 * Ace only registers ace/mode/c_cpp_highlight_rules once it has actually
 * fetched and executed CodeRunner's vendored ace/mode-c_cpp.js, which on a
 * page's first C/C++ editor has not necessarily happened yet. So this first
 * awaits Ace's own module loader for the base mode before subclassing it,
 * rather than racing ace.require() against that load.
 * @return {Promise<Object>} An Ace Mode instance suitable for the editor's 'mode' config option.
 */
export const getCDatatypeMode = async() => {
    if (cachedMode) {
        return cachedMode;
    }

    await new Promise((resolve) => globalThis.ace.config.loadModule(["mode", "ace/mode/c_cpp"], resolve));

    const oop = globalThis.ace.require("ace/lib/oop");
    const CCppHighlightRules = globalThis.ace.require("ace/mode/c_cpp_highlight_rules").c_cppHighlightRules;
    const CCppMode = globalThis.ace.require("ace/mode/c_cpp").Mode;

    const CDatatypeHighlightRules = function() {
        CCppHighlightRules.call(this);
        const startRules = this.$rules.start;
        const keywordRuleIndex = startRules.findIndex((rule) => rule.regex === KEYWORD_RULE_REGEX);
        if (keywordRuleIndex === -1) {
            // CodeRunner's vendored c_cpp_highlight_rules no longer has a rule matching
            // KEYWORD_RULE_REGEX (e.g. after a CodeRunner/Ace upgrade changed it) - splicing
            // at -1 would silently insert our rule before whatever happens to be last, in
            // some arbitrary wrong position. Fail visibly instead and fall back to plain,
            // correct C/C++ highlighting for this mode instance rather than risk corrupting
            // rule ordering.
            if (!keywordRuleWarningIssued) {
                keywordRuleWarningIssued = true;
                globalThis.console.warn('filter_ace_inline: could not find the C/C++ keyword rule to splice ' +
                    'datatype highlighting before; skipping datatype highlighting for this session.');
            }
            return;
        }
        startRules.splice(keywordRuleIndex, 0, {
            token: "support.type",
            regex: DATATYPE_REGEX
        });
    };
    oop.inherits(CDatatypeHighlightRules, CCppHighlightRules);

    const CDatatypeMode = function() {
        CCppMode.call(this);
        this.HighlightRules = CDatatypeHighlightRules;
    };
    oop.inherits(CDatatypeMode, CCppMode);

    cachedMode = new CDatatypeMode();
    return cachedMode;
};
