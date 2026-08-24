@filter @filter_ace_inline @javascript
Feature: Simplified class mode display and behaviour attributes
  In order to control the display and behaviour of Simplified mode code blocks
  As a teacher
  I need to be able to combine the colon-separated attributes documented in the
  README with highlighted or interactive Simplified mode code blocks, for
  different languages

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
      | questioncategory | qtype       | name                         |
      | Test questions   | description | simplifiedclassmodeattrsdemo |
    And "simplifiedclassmodeattrsdemo.txt" exists in question "simplifiedclassmodeattrsdemo" "questiontext" as markdown for filter ace inline
    And I have enabled the sandbox and ace inline filter
    And the following config values are set as admin:
      | simplified_mode | 1 | filter_ace_inline |

  Scenario: an earlier block's line-numbers does not leak into a later highlighted block with no line-numbers of its own (C, highlighted)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'darkforcec')]/following-sibling::div[contains(@class, 'ace_editor')][1]//div[contains(@class, 'ace_gutter-active-line') and text()='5']" "xpath_element" should not exist

  Scenario: dark-theme-mode forces the light theme regardless of the site default (Python, interactive)
    When I am on the "simplifiedclassmodeattrsdemo" "core_question > preview" page logged in as teacher
    Then "//pre[contains(., 'lightforcepy')]/following-sibling::div[contains(@class, 'ace_editor')][1][contains(concat(' ', normalize-space(@class), ' '), ' ace-tm ')]" "xpath_element" should exist
