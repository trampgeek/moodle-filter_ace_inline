@filter @filter_ace_inline @javascript
Feature: Simplified class mode rendering for the Ace inline filter
  In order to display and run code written as plain Markdown-fenced code blocks
  As a teacher
  I need Simplified mode's colon-separated class syntax to correctly distinguish
  between highlighted (read-only) and interactive rendering, for different languages

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
      | questioncategory | qtype       | name                    |
      | Test questions   | description | simplifiedclassmodedemo |
    And "simplifiedclassmodedemo.txt" exists in question "simplifiedclassmodedemo" "questiontext" as markdown for filter ace inline
    And I have enabled the sandbox and ace inline filter
    And the following config values are set as admin:
      | simplified_mode | 1 | filter_ace_inline |

  Scenario: A bare language string renders C as highlighted and read-only
    When I am on the "simplifiedclassmodedemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloCHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should exist
    And "//pre[contains(., 'HelloCHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1]/following-sibling::div[1][contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    # "int" is a storage/type-declaring keyword in Ace's tokenisation (ace_storage ace_type),
    # not ace_keyword. This asserted "keyword" until the token match was made exact, and passed
    # only because Python's "print" in a later block on this page is an ace_keyword containing
    # the substring "int".
    And I should see "type" highlighting on "int" with filter ace inline
    And I should see "function" highlighting on "printf" with filter ace inline
    And I should see "string" highlighting on "HelloCHighlight" with filter ace inline

  Scenario: A language string with ":interactive" renders C as editable with a Try it! button
    When I am on the "simplifiedclassmodedemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloCInteractive')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should not exist
    And "//pre[contains(., 'HelloCInteractive')]/following-sibling::div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'Try it!')]" "xpath_element" should exist
    And I should see "string" highlighting on "HelloCInteractive" with filter ace inline

  Scenario: A bare language string renders Python as highlighted and read-only
    When I am on the "simplifiedclassmodedemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloPyHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should exist
    And "//pre[contains(., 'HelloPyHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1]/following-sibling::div[1][contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see "keyword" highlighting on "def" with filter ace inline
    And I should see "keyword" highlighting on "print" with filter ace inline
    And I should see "string" highlighting on "HelloPyHighlight" with filter ace inline

  Scenario: A language string with ":interactive" renders Python as editable with a Try it! button
    When I am on the "simplifiedclassmodedemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloPyInteractive')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should not exist
    And "//pre[contains(., 'HelloPyInteractive')]/following-sibling::div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'Try it!')]" "xpath_element" should exist
    And I should see "string" highlighting on "HelloPyInteractive" with filter ace inline

  Scenario: A bare language string with no per-block override picks up the admin's dark-theme-mode default
    Given the following config values are set as admin:
      | dark_theme_mode | 2 | filter_ace_inline |
    When I am on the "simplifiedclassmodedemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloCHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' ace-tomorrow-night ')]" "xpath_element" should exist
