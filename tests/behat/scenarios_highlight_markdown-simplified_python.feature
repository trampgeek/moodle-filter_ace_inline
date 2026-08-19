@filter @filter_ace_inline @javascript
Feature: highlight/markdown-simplified/python scenario fixtures
  In order to trust every data-* attribute combination this filter supports
  As a developer
  I need fixtures under tests/scenarios/highlight/markdown-simplified/python/
  to render and behave (editor config, execution output, structural UI)
  exactly as their attribute combination specifies
  Only the baseline (no-attribute and single-attribute) fixtures under this
  directory are covered here - see generate_behat_suite.py's module docstring
  for why the full attribute-combination sweep only runs on html-classic.
  Run generate_behat_suite.py --comprehensive to regenerate this file with
  every fixture and full execution-output assertions instead.

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email           |
      | teacher  | Teacher   | 1        | teach1@empl.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user    | course | role           |
      | teacher | C1     | editingteacher |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And I have enabled the sandbox and ace inline filter
    And the following config values are set as admin:
      | simplified_mode | 1 | filter_ace_inline |

  Scenario: highlight_markdown-simplified_python_perm001
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_markdown-simplified_python_perm001 |
    And "highlight/markdown-simplified/python/perm001.txt" exists in question "highlight_markdown-simplified_python_perm001" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "highlight_markdown-simplified_python_perm001" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist

  Scenario: highlight_markdown-simplified_python_perm002
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_markdown-simplified_python_perm002 |
    And "highlight/markdown-simplified/python/perm002.txt" exists in question "highlight_markdown-simplified_python_perm002" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "highlight_markdown-simplified_python_perm002" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline

  Scenario: highlight_markdown-simplified_python_perm003
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_markdown-simplified_python_perm003 |
    And "highlight/markdown-simplified/python/perm003.txt" exists in question "highlight_markdown-simplified_python_perm003" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "highlight_markdown-simplified_python_perm003" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline

  Scenario: highlight_markdown-simplified_python_perm004
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_markdown-simplified_python_perm004 |
    And "highlight/markdown-simplified/python/perm004.txt" exists in question "highlight_markdown-simplified_python_perm004" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "highlight_markdown-simplified_python_perm004" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "minLines" value "20" with filter ace inline

  Scenario: highlight_markdown-simplified_python_perm005
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_markdown-simplified_python_perm005 |
    And "highlight/markdown-simplified/python/perm005.txt" exists in question "highlight_markdown-simplified_python_perm005" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "highlight_markdown-simplified_python_perm005" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "maxLines" value "3" with filter ace inline

  Scenario: highlight_markdown-simplified_python_perm006
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_markdown-simplified_python_perm006 |
    And "highlight/markdown-simplified/python/perm006.txt" exists in question "highlight_markdown-simplified_python_perm006" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "highlight_markdown-simplified_python_perm006" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline

  Scenario: highlight_markdown-simplified_python_perm019
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_markdown-simplified_python_perm019 |
    And "highlight/markdown-simplified/python/perm019.txt" exists in question "highlight_markdown-simplified_python_perm019" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "highlight_markdown-simplified_python_perm019" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "firstLineNumber" value "3" with filter ace inline
