@filter @filter_ace_inline @javascript
Feature: Extended Markdown rendering modes for the Ace inline filter
  In order to display and run code written as plain Markdown-fenced code blocks
  As a teacher
  I need the Extended Markdown rendering mode to correctly distinguish between
  highlighted (read-only) and interactive rendering, for different languages

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
      | Test questions   | description | extendedmarkdowndemo |
    And "extendedmarkdowndemo.txt" exists in question "extendedmarkdowndemo" "questiontext" as markdown for filter ace inline
    And I have enabled the sandbox and ace inline filter
    And the following config values are set as admin:
      | enable_markdown | 2 | filter_ace_inline |

  Scenario: A bare language string renders C as highlighted and read-only
    When I am on the "extendedmarkdowndemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloCHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should exist
    And "//pre[contains(., 'HelloCHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1]/following-sibling::div[1][contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see "keyword" highlighting on "int" with filter ace inline
    And I should see "function" highlighting on "printf" with filter ace inline
    And I should see "string" highlighting on "HelloCHighlight" with filter ace inline

  Scenario: A language string with ":interactive" renders C as editable with a Try it! button
    When I am on the "extendedmarkdowndemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloCInteractive')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should not exist
    And "//pre[contains(., 'HelloCInteractive')]/following-sibling::div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'Try it!')]" "xpath_element" should exist
    And I should see "string" highlighting on "HelloCInteractive" with filter ace inline

  Scenario: A bare language string renders Python as highlighted and read-only
    When I am on the "extendedmarkdowndemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloPyHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should exist
    And "//pre[contains(., 'HelloPyHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1]/following-sibling::div[1][contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see "keyword" highlighting on "def" with filter ace inline
    And I should see "keyword" highlighting on "print" with filter ace inline
    And I should see "string" highlighting on "HelloPyHighlight" with filter ace inline

  Scenario: A language string with ":interactive" renders Python as editable with a Try it! button
    When I am on the "extendedmarkdowndemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloPyInteractive')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' readonly ')]" "xpath_element" should not exist
    And "//pre[contains(., 'HelloPyInteractive')]/following-sibling::div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'Try it!')]" "xpath_element" should exist
    And I should see "string" highlighting on "HelloPyInteractive" with filter ace inline
