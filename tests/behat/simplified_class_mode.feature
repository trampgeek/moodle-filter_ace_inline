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

  Scenario: A bare language string with no per-block override picks up the admin's dark-theme-mode default
    Given the following config values are set as admin:
      | dark_theme_mode | 2 | filter_ace_inline |
    When I am on the "simplifiedclassmodedemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'HelloCHighlight')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' ace-tomorrow-night ')]" "xpath_element" should exist
