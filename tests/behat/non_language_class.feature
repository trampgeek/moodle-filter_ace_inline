@filter @filter_ace_inline @javascript
Feature: Non-language classes are left alone in Simplified class mode
  In order to keep ordinary preformatted content looking the way its author wrote it
  As a teacher
  I need Simplified mode to treat a single class as a language specifier only when it
  actually names a language and the <pre> has a genuine <code> fence pair, so neither a
  layout class such as "tablecell" nor a real language name on a bare <pre> with no <code>
  child turns a plain <pre> into an Ace editor

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email           |
      | teacher  | Teacher   | 1        | teach1@empl.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user     | course    | role           |
      | teacher  | C1        | editingteacher |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And the following "questions" exist:
      | questioncategory | qtype       | name                 |
      | Test questions   | description | nonlanguageclassdemo |
    And "nonlanguageclassdemo.txt" exists in question "nonlanguageclassdemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter
    And the following config values are set as admin:
      | simplified_mode | 1 | filter_ace_inline |

  Scenario: A layout class on a table cell's pre is not treated as a language specifier
    When I am on the "nonlanguageclassdemo" "core_question > preview" page logged in as teacher
    # The Simplified Mode block on the same page renders, so the filter definitely ran.
    Then I should see "keyword" highlighting on "def" with filter ace inline
    # ... but the plain preformatted table cells are untouched: still visible (Ace hides the
    # original pre once it has replaced it) and with no editor anywhere in the table.
    And "//pre[contains(., 'TABLECELLMARKER')]" "xpath_element" should be visible
    And "//pre[contains(., 'EXAMPLEMARKER')]" "xpath_element" should be visible
    And "//table//div[contains(concat(' ', normalize-space(@class), ' '), ' ace_editor ')]" "xpath_element" should not exist

  Scenario: A real language class with no <code> fence pair is not treated as a language specifier
    When I am on the "nonlanguageclassdemo" "core_question > preview" page logged in as teacher
    # The Simplified Mode block on the same page renders, so the filter definitely ran.
    Then I should see "keyword" highlighting on "def" with filter ace inline
    # "python3" names a real Ace language - only the missing <code> child should be why this
    # is rejected. If this ever starts failing while the tablecell/example checks above still
    # pass, the language check is doing the work and the <pre><code> pairing check has broken.
    And "//pre[contains(., 'NOCODEMARKER')]" "xpath_element" should be visible
    And "//pre[contains(., 'NOCODEMARKER')]/following-sibling::div[contains(concat(' ', normalize-space(@class), ' '), ' ace_editor ')]" "xpath_element" should not exist
