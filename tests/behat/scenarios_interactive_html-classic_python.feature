@filter @filter_ace_inline @javascript
Feature: interactive/html-classic/python scenario fixtures
  In order to trust every data-* attribute combination this filter supports
  As a developer
  I need fixtures under tests/scenarios/interactive/html-classic/python/
  to render and behave (editor config, execution output, structural UI)
  exactly as their attribute combination specifies
  Every fixture under this directory is covered.

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

  Scenario: interactive_html-classic_python_perm001
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm001 |
    And "interactive/html-classic/python/perm001.txt" exists in question "interactive_html-classic_python_perm001" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm001" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm002
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm002 |
    And "interactive/html-classic/python/perm002.txt" exists in question "interactive_html-classic_python_perm002" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm002" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm003
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm003 |
    And "interactive/html-classic/python/perm003.txt" exists in question "interactive_html-classic_python_perm003" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm003" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm004
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm004 |
    And "interactive/html-classic/python/perm004.txt" exists in question "interactive_html-classic_python_perm004" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm004" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm005
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm005 |
    And "interactive/html-classic/python/perm005.txt" exists in question "interactive_html-classic_python_perm005" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm005" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm006
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm006 |
    And "interactive/html-classic/python/perm006.txt" exists in question "interactive_html-classic_python_perm006" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm006" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm007
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm007 |
    And "interactive/html-classic/python/perm007.txt" exists in question "interactive_html-classic_python_perm007" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm007" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm008
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm008 |
    And "interactive/html-classic/python/perm008.txt" exists in question "interactive_html-classic_python_perm008" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm008" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm009
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm009 |
    And "interactive/html-classic/python/perm009.txt" exists in question "interactive_html-classic_python_perm009" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm009" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm010
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm010 |
    And "interactive/html-classic/python/perm010.txt" exists in question "interactive_html-classic_python_perm010" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm010" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "stdin:hello"

  Scenario: interactive_html-classic_python_perm011
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm011 |
    And "interactive/html-classic/python/perm011.txt" exists in question "interactive_html-classic_python_perm011" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm011" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "files:file contents"

  Scenario: interactive_html-classic_python_perm012
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm012 |
    And "interactive/html-classic/python/perm012.txt" exists in question "interactive_html-classic_python_perm012" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm012" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm013
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm013 |
    And "interactive/html-classic/python/perm013.txt" exists in question "interactive_html-classic_python_perm013" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm013" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm014
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm014 |
    And "interactive/html-classic/python/perm014.txt" exists in question "interactive_html-classic_python_perm014" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm014" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "mapped"

  Scenario: interactive_html-classic_python_perm015
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm015 |
    And "interactive/html-classic/python/perm015.txt" exists in question "interactive_html-classic_python_perm015" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm015" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm016
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm016 |
    And "interactive/html-classic/python/perm016.txt" exists in question "interactive_html-classic_python_perm016" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm016" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm017
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm017 |
    And "interactive/html-classic/python/perm017.txt" exists in question "interactive_html-classic_python_perm017" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm017" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm018
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm018 |
    And "interactive/html-classic/python/perm018.txt" exists in question "interactive_html-classic_python_perm018" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm018" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hell... (truncated)"

  Scenario: interactive_html-classic_python_perm020
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm020 |
    And "interactive/html-classic/python/perm020.txt" exists in question "interactive_html-classic_python_perm020" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm020" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm021
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm021 |
    And "interactive/html-classic/python/perm021.txt" exists in question "interactive_html-classic_python_perm021" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm021" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm022
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm022 |
    And "interactive/html-classic/python/perm022.txt" exists in question "interactive_html-classic_python_perm022" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm022" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm025
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm025 |
    And "interactive/html-classic/python/perm025.txt" exists in question "interactive_html-classic_python_perm025" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm025" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm027
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm027 |
    And "interactive/html-classic/python/perm027.txt" exists in question "interactive_html-classic_python_perm027" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm027" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm028
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm028 |
    And "interactive/html-classic/python/perm028.txt" exists in question "interactive_html-classic_python_perm028" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm028" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm029
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm029 |
    And "interactive/html-classic/python/perm029.txt" exists in question "interactive_html-classic_python_perm029" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm029" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm030
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm030 |
    And "interactive/html-classic/python/perm030.txt" exists in question "interactive_html-classic_python_perm030" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm030" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm031
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm031 |
    And "interactive/html-classic/python/perm031.txt" exists in question "interactive_html-classic_python_perm031" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm031" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm032
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm032 |
    And "interactive/html-classic/python/perm032.txt" exists in question "interactive_html-classic_python_perm032" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm032" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm033
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm033 |
    And "interactive/html-classic/python/perm033.txt" exists in question "interactive_html-classic_python_perm033" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm033" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm034
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm034 |
    And "interactive/html-classic/python/perm034.txt" exists in question "interactive_html-classic_python_perm034" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm034" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm035
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm035 |
    And "interactive/html-classic/python/perm035.txt" exists in question "interactive_html-classic_python_perm035" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm035" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm036
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm036 |
    And "interactive/html-classic/python/perm036.txt" exists in question "interactive_html-classic_python_perm036" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm036" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm037
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm037 |
    And "interactive/html-classic/python/perm037.txt" exists in question "interactive_html-classic_python_perm037" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm037" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm038
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm038 |
    And "interactive/html-classic/python/perm038.txt" exists in question "interactive_html-classic_python_perm038" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm038" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "files:file contents"

  Scenario: interactive_html-classic_python_perm039
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm039 |
    And "interactive/html-classic/python/perm039.txt" exists in question "interactive_html-classic_python_perm039" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm039" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm040
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm040 |
    And "interactive/html-classic/python/perm040.txt" exists in question "interactive_html-classic_python_perm040" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm040" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm041
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm041 |
    And "interactive/html-classic/python/perm041.txt" exists in question "interactive_html-classic_python_perm041" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm041" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see "hell... (truncated)"

  Scenario: interactive_html-classic_python_perm042
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm042 |
    And "interactive/html-classic/python/perm042.txt" exists in question "interactive_html-classic_python_perm042" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm042" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm043
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm043 |
    And "interactive/html-classic/python/perm043.txt" exists in question "interactive_html-classic_python_perm043" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm043" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hell... (truncated)"

  Scenario: interactive_html-classic_python_perm044
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm044 |
    And "interactive/html-classic/python/perm044.txt" exists in question "interactive_html-classic_python_perm044" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm044" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm045
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm045 |
    And "interactive/html-classic/python/perm045.txt" exists in question "interactive_html-classic_python_perm045" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm045" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm046
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm046 |
    And "interactive/html-classic/python/perm046.txt" exists in question "interactive_html-classic_python_perm046" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm046" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see "hell... (truncated)"

  Scenario: interactive_html-classic_python_perm047
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm047 |
    And "interactive/html-classic/python/perm047.txt" exists in question "interactive_html-classic_python_perm047" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm047" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm048
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm048 |
    And "interactive/html-classic/python/perm048.txt" exists in question "interactive_html-classic_python_perm048" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm048" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm049
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm049 |
    And "interactive/html-classic/python/perm049.txt" exists in question "interactive_html-classic_python_perm049" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm049" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm050
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm050 |
    And "interactive/html-classic/python/perm050.txt" exists in question "interactive_html-classic_python_perm050" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm050" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm051
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm051 |
    And "interactive/html-classic/python/perm051.txt" exists in question "interactive_html-classic_python_perm051" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm051" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm052
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm052 |
    And "interactive/html-classic/python/perm052.txt" exists in question "interactive_html-classic_python_perm052" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm052" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm053
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm053 |
    And "interactive/html-classic/python/perm053.txt" exists in question "interactive_html-classic_python_perm053" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm053" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm054
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm054 |
    And "interactive/html-classic/python/perm054.txt" exists in question "interactive_html-classic_python_perm054" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm054" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm055
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm055 |
    And "interactive/html-classic/python/perm055.txt" exists in question "interactive_html-classic_python_perm055" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm055" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm056
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm056 |
    And "interactive/html-classic/python/perm056.txt" exists in question "interactive_html-classic_python_perm056" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm056" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm057
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm057 |
    And "interactive/html-classic/python/perm057.txt" exists in question "interactive_html-classic_python_perm057" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm057" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm058
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm058 |
    And "interactive/html-classic/python/perm058.txt" exists in question "interactive_html-classic_python_perm058" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm058" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "files:file contents"

  Scenario: interactive_html-classic_python_perm059
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm059 |
    And "interactive/html-classic/python/perm059.txt" exists in question "interactive_html-classic_python_perm059" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm059" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm060
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm060 |
    And "interactive/html-classic/python/perm060.txt" exists in question "interactive_html-classic_python_perm060" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm060" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm061
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm061 |
    And "interactive/html-classic/python/perm061.txt" exists in question "interactive_html-classic_python_perm061" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm061" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline

  Scenario: interactive_html-classic_python_perm062
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm062 |
    And "interactive/html-classic/python/perm062.txt" exists in question "interactive_html-classic_python_perm062" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm062" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "files:file contents"

  Scenario: interactive_html-classic_python_perm063
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm063 |
    And "interactive/html-classic/python/perm063.txt" exists in question "interactive_html-classic_python_perm063" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm063" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_html-classic_python_perm064
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm064 |
    And "interactive/html-classic/python/perm064.txt" exists in question "interactive_html-classic_python_perm064" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm064" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm065
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm065 |
    And "interactive/html-classic/python/perm065.txt" exists in question "interactive_html-classic_python_perm065" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm065" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm066
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm066 |
    And "interactive/html-classic/python/perm066.txt" exists in question "interactive_html-classic_python_perm066" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm066" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "files:file contents"

  Scenario: interactive_html-classic_python_perm067
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm067 |
    And "interactive/html-classic/python/perm067.txt" exists in question "interactive_html-classic_python_perm067" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm067" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm068
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm068 |
    And "interactive/html-classic/python/perm068.txt" exists in question "interactive_html-classic_python_perm068" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm068" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm069
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm069 |
    And "interactive/html-classic/python/perm069.txt" exists in question "interactive_html-classic_python_perm069" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm069" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "files:file contents"

  Scenario: interactive_html-classic_python_perm070
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm070 |
    And "interactive/html-classic/python/perm070.txt" exists in question "interactive_html-classic_python_perm070" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm070" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline

  Scenario: interactive_html-classic_python_perm071
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm071 |
    And "interactive/html-classic/python/perm071.txt" exists in question "interactive_html-classic_python_perm071" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm071" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "files:file contents"

  Scenario: interactive_html-classic_python_perm072
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm072 |
    And "interactive/html-classic/python/perm072.txt" exists in question "interactive_html-classic_python_perm072" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm072" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm073
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm073 |
    And "interactive/html-classic/python/perm073.txt" exists in question "interactive_html-classic_python_perm073" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm073" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm074
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm074 |
    And "interactive/html-classic/python/perm074.txt" exists in question "interactive_html-classic_python_perm074" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm074" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm075
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm075 |
    And "interactive/html-classic/python/perm075.txt" exists in question "interactive_html-classic_python_perm075" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm075" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "files:file contents"

  Scenario: interactive_html-classic_python_perm076
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm076 |
    And "interactive/html-classic/python/perm076.txt" exists in question "interactive_html-classic_python_perm076" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm076" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline

  Scenario: interactive_html-classic_python_perm077
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm077 |
    And "interactive/html-classic/python/perm077.txt" exists in question "interactive_html-classic_python_perm077" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm077" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "files:file contents"

  Scenario: interactive_html-classic_python_perm078
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm078 |
    And "interactive/html-classic/python/perm078.txt" exists in question "interactive_html-classic_python_perm078" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm078" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm079
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm079 |
    And "interactive/html-classic/python/perm079.txt" exists in question "interactive_html-classic_python_perm079" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm079" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_html-classic_python_perm080
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm080 |
    And "interactive/html-classic/python/perm080.txt" exists in question "interactive_html-classic_python_perm080" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm080" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm081
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm081 |
    And "interactive/html-classic/python/perm081.txt" exists in question "interactive_html-classic_python_perm081" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm081" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "files:file contents"

  Scenario: interactive_html-classic_python_perm082
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm082 |
    And "interactive/html-classic/python/perm082.txt" exists in question "interactive_html-classic_python_perm082" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm082" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm083
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm083 |
    And "interactive/html-classic/python/perm083.txt" exists in question "interactive_html-classic_python_perm083" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm083" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "RunIt"
    Then I should see the filter-ace-inline-html div containing "files:file contents"

  Scenario: interactive_html-classic_python_perm084
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm084 |
    And "interactive/html-classic/python/perm084.txt" exists in question "interactive_html-classic_python_perm084" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm084" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm085
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm085 |
    And "interactive/html-classic/python/perm085.txt" exists in question "interactive_html-classic_python_perm085" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm085" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm086
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm086 |
    And "interactive/html-classic/python/perm086.txt" exists in question "interactive_html-classic_python_perm086" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm086" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "files:file contents"

  Scenario: interactive_html-classic_python_perm087
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm087 |
    And "interactive/html-classic/python/perm087.txt" exists in question "interactive_html-classic_python_perm087" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm087" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm088
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm088 |
    And "interactive/html-classic/python/perm088.txt" exists in question "interactive_html-classic_python_perm088" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm088" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm089
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm089 |
    And "interactive/html-classic/python/perm089.txt" exists in question "interactive_html-classic_python_perm089" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm089" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm090
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm090 |
    And "interactive/html-classic/python/perm090.txt" exists in question "interactive_html-classic_python_perm090" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm090" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "RunIt"
    Then I should see the filter-ace-inline-html div containing "files:file contents"

  Scenario: interactive_html-classic_python_perm091
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm091 |
    And "interactive/html-classic/python/perm091.txt" exists in question "interactive_html-classic_python_perm091" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm091" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm092
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm092 |
    And "interactive/html-classic/python/perm092.txt" exists in question "interactive_html-classic_python_perm092" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm092" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm093
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm093 |
    And "interactive/html-classic/python/perm093.txt" exists in question "interactive_html-classic_python_perm093" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm093" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm094
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm094 |
    And "interactive/html-classic/python/perm094.txt" exists in question "interactive_html-classic_python_perm094" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm094" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "RunIt"
    Then I should see the filter-ace-inline-html div containing "files:file contents"

  Scenario: interactive_html-classic_python_perm095
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm095 |
    And "interactive/html-classic/python/perm095.txt" exists in question "interactive_html-classic_python_perm095" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm095" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm096
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm096 |
    And "interactive/html-classic/python/perm096.txt" exists in question "interactive_html-classic_python_perm096" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm096" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm097
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm097 |
    And "interactive/html-classic/python/perm097.txt" exists in question "interactive_html-classic_python_perm097" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm097" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm098
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm098 |
    And "interactive/html-classic/python/perm098.txt" exists in question "interactive_html-classic_python_perm098" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm098" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I should see an ace option "maxLines" value "25" with filter ace inline
    And I should see line numbers starting at 7 with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist

  Scenario: interactive_html-classic_python_perm099
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_html-classic_python_perm099 |
    And "interactive/html-classic/python/perm099.txt" exists in question "interactive_html-classic_python_perm099" "questiontext" from scenarios for filter ace inline
    When I am on the "interactive_html-classic_python_perm099" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
