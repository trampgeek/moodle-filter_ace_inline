@filter @filter_ace_inline @javascript
Feature: highlight/html-classic/python scenario fixtures
  In order to trust every data-* attribute combination this filter supports
  As a developer
  I need every fixture under tests/scenarios/highlight/html-classic/python/
  to render and behave (editor config, execution output, structural UI)
  exactly as its attribute combination specifies

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

  Scenario: highlight_html-classic_python_perm001
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm001 |
    And "highlight/html-classic/python/perm001.txt" exists in question "highlight_html-classic_python_perm001" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm001" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist

  Scenario: highlight_html-classic_python_perm002
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm002 |
    And "highlight/html-classic/python/perm002.txt" exists in question "highlight_html-classic_python_perm002" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm002" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline

  Scenario: highlight_html-classic_python_perm003
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm003 |
    And "highlight/html-classic/python/perm003.txt" exists in question "highlight_html-classic_python_perm003" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm003" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline

  Scenario: highlight_html-classic_python_perm004
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm004 |
    And "highlight/html-classic/python/perm004.txt" exists in question "highlight_html-classic_python_perm004" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm004" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "minLines" value "20" with filter ace inline

  Scenario: highlight_html-classic_python_perm005
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm005 |
    And "highlight/html-classic/python/perm005.txt" exists in question "highlight_html-classic_python_perm005" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm005" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "maxLines" value "3" with filter ace inline

  Scenario: highlight_html-classic_python_perm006
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm006 |
    And "highlight/html-classic/python/perm006.txt" exists in question "highlight_html-classic_python_perm006" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm006" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline

  Scenario: highlight_html-classic_python_perm020
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm020 |
    And "highlight/html-classic/python/perm020.txt" exists in question "highlight_html-classic_python_perm020" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm020" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline

  Scenario: highlight_html-classic_python_perm021
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm021 |
    And "highlight/html-classic/python/perm021.txt" exists in question "highlight_html-classic_python_perm021" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm021" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline

  Scenario: highlight_html-classic_python_perm022
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm022 |
    And "highlight/html-classic/python/perm022.txt" exists in question "highlight_html-classic_python_perm022" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm022" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline

  Scenario: highlight_html-classic_python_perm025
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm025 |
    And "highlight/html-classic/python/perm025.txt" exists in question "highlight_html-classic_python_perm025" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm025" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline

  Scenario: highlight_html-classic_python_perm027
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm027 |
    And "highlight/html-classic/python/perm027.txt" exists in question "highlight_html-classic_python_perm027" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm027" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline

  Scenario: highlight_html-classic_python_perm054
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | highlight_html-classic_python_perm054 |
    And "highlight/html-classic/python/perm054.txt" exists in question "highlight_html-classic_python_perm054" "questiontext" from scenarios for filter ace inline
    When I am on the "highlight_html-classic_python_perm054" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should not exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline
