@filter @filter_ace_inline @javascript
Feature: interactive/markdown-simplified/python scenario fixtures
  In order to trust every data-* attribute combination this filter supports
  As a developer
  I need every fixture under tests/scenarios/interactive/markdown-simplified/python/
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

  Scenario: interactive_markdown-simplified_python_perm001
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm001 |
    And "interactive/markdown-simplified/python/perm001.txt" exists in question "interactive_markdown-simplified_python_perm001" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm001" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm002
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm002 |
    And "interactive/markdown-simplified/python/perm002.txt" exists in question "interactive_markdown-simplified_python_perm002" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm002" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm003
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm003 |
    And "interactive/markdown-simplified/python/perm003.txt" exists in question "interactive_markdown-simplified_python_perm003" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm003" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm004
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm004 |
    And "interactive/markdown-simplified/python/perm004.txt" exists in question "interactive_markdown-simplified_python_perm004" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm004" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm005
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm005 |
    And "interactive/markdown-simplified/python/perm005.txt" exists in question "interactive_markdown-simplified_python_perm005" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm005" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm006
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm006 |
    And "interactive/markdown-simplified/python/perm006.txt" exists in question "interactive_markdown-simplified_python_perm006" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm006" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm007
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm007 |
    And "interactive/markdown-simplified/python/perm007.txt" exists in question "interactive_markdown-simplified_python_perm007" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm007" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm008
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm008 |
    And "interactive/markdown-simplified/python/perm008.txt" exists in question "interactive_markdown-simplified_python_perm008" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm008" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm009
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm009 |
    And "interactive/markdown-simplified/python/perm009.txt" exists in question "interactive_markdown-simplified_python_perm009" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm009" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm010
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm010 |
    And "interactive/markdown-simplified/python/perm010.txt" exists in question "interactive_markdown-simplified_python_perm010" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm010" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "stdin:hello"

  Scenario: interactive_markdown-simplified_python_perm012
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm012 |
    And "interactive/markdown-simplified/python/perm012.txt" exists in question "interactive_markdown-simplified_python_perm012" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm012" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//input[@id='uploadbox1']" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm014
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm014 |
    And "interactive/markdown-simplified/python/perm014.txt" exists in question "interactive_markdown-simplified_python_perm014" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm014" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "mapped"

  Scenario: interactive_markdown-simplified_python_perm017
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm017 |
    And "interactive/markdown-simplified/python/perm017.txt" exists in question "interactive_markdown-simplified_python_perm017" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm017" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_markdown-simplified_python_perm018
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm018 |
    And "interactive/markdown-simplified/python/perm018.txt" exists in question "interactive_markdown-simplified_python_perm018" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm018" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hell... (truncated)"

  Scenario: interactive_markdown-simplified_python_perm019
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm019 |
    And "interactive/markdown-simplified/python/perm019.txt" exists in question "interactive_markdown-simplified_python_perm019" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm019" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm020
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm020 |
    And "interactive/markdown-simplified/python/perm020.txt" exists in question "interactive_markdown-simplified_python_perm020" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm020" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm021
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm021 |
    And "interactive/markdown-simplified/python/perm021.txt" exists in question "interactive_markdown-simplified_python_perm021" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm021" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm022
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm022 |
    And "interactive/markdown-simplified/python/perm022.txt" exists in question "interactive_markdown-simplified_python_perm022" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm022" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm023
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm023 |
    And "interactive/markdown-simplified/python/perm023.txt" exists in question "interactive_markdown-simplified_python_perm023" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm023" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "firstLineNumber" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm024
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm024 |
    And "interactive/markdown-simplified/python/perm024.txt" exists in question "interactive_markdown-simplified_python_perm024" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm024" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "3" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm025
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm025 |
    And "interactive/markdown-simplified/python/perm025.txt" exists in question "interactive_markdown-simplified_python_perm025" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm025" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm026
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm026 |
    And "interactive/markdown-simplified/python/perm026.txt" exists in question "interactive_markdown-simplified_python_perm026" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm026" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "firstLineNumber" value "3" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm027
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm027 |
    And "interactive/markdown-simplified/python/perm027.txt" exists in question "interactive_markdown-simplified_python_perm027" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm027" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm028
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm028 |
    And "interactive/markdown-simplified/python/perm028.txt" exists in question "interactive_markdown-simplified_python_perm028" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm028" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm029
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm029 |
    And "interactive/markdown-simplified/python/perm029.txt" exists in question "interactive_markdown-simplified_python_perm029" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm029" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm030
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm030 |
    And "interactive/markdown-simplified/python/perm030.txt" exists in question "interactive_markdown-simplified_python_perm030" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm030" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm031
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm031 |
    And "interactive/markdown-simplified/python/perm031.txt" exists in question "interactive_markdown-simplified_python_perm031" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm031" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm032
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm032 |
    And "interactive/markdown-simplified/python/perm032.txt" exists in question "interactive_markdown-simplified_python_perm032" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm032" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm033
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm033 |
    And "interactive/markdown-simplified/python/perm033.txt" exists in question "interactive_markdown-simplified_python_perm033" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm033" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm034
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm034 |
    And "interactive/markdown-simplified/python/perm034.txt" exists in question "interactive_markdown-simplified_python_perm034" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm034" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm035
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm035 |
    And "interactive/markdown-simplified/python/perm035.txt" exists in question "interactive_markdown-simplified_python_perm035" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm035" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm036
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm036 |
    And "interactive/markdown-simplified/python/perm036.txt" exists in question "interactive_markdown-simplified_python_perm036" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm036" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm037
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm037 |
    And "interactive/markdown-simplified/python/perm037.txt" exists in question "interactive_markdown-simplified_python_perm037" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm037" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm040
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm040 |
    And "interactive/markdown-simplified/python/perm040.txt" exists in question "interactive_markdown-simplified_python_perm040" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm040" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hello"

  Scenario: interactive_markdown-simplified_python_perm041
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm041 |
    And "interactive/markdown-simplified/python/perm041.txt" exists in question "interactive_markdown-simplified_python_perm041" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm041" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see "hell... (truncated)"

  Scenario: interactive_markdown-simplified_python_perm044
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm044 |
    And "interactive/markdown-simplified/python/perm044.txt" exists in question "interactive_markdown-simplified_python_perm044" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm044" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hell... (truncated)"

  Scenario: interactive_markdown-simplified_python_perm047
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm047 |
    And "interactive/markdown-simplified/python/perm047.txt" exists in question "interactive_markdown-simplified_python_perm047" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm047" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "readOnly" value "true" with filter ace inline
    And I press "Try it!"
    Then I should see the filter-ace-inline-html div containing "hell... (truncated)"

  Scenario: interactive_markdown-simplified_python_perm054
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm054 |
    And "interactive/markdown-simplified/python/perm054.txt" exists in question "interactive_markdown-simplified_python_perm054" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm054" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And I press "Try it!"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm055
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm055 |
    And "interactive/markdown-simplified/python/perm055.txt" exists in question "interactive_markdown-simplified_python_perm055" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm055" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm059
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm059 |
    And "interactive/markdown-simplified/python/perm059.txt" exists in question "interactive_markdown-simplified_python_perm059" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm059" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And I should see an ace option "fontSize" value "18pt" with filter ace inline
    And I should see an ace option "firstLineNumber" value "7" with filter ace inline
    And I should see an ace option "minLines" value "20" with filter ace inline
    And I should see an ace option "theme" value "ace/theme/tomorrow_night" with filter ace inline
    And I should see an ace option "maxLines" value "3" with filter ace inline
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"

  Scenario: interactive_markdown-simplified_python_perm063
    Given the following "questions" exist:
      | questioncategory | qtype       | name |
      | Test questions   | description | interactive_markdown-simplified_python_perm063 |
    And "interactive/markdown-simplified/python/perm063.txt" exists in question "interactive_markdown-simplified_python_perm063" "questiontext" from scenarios as markdown for filter ace inline
    When I am on the "interactive_markdown-simplified_python_perm063" "core_question > preview" page logged in as teacher
    Then "//div[contains(@class, 'ace_editor')]" "xpath_element" should not exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]" "xpath_element" should exist
    And "//div[contains(@class, 'filter-ace-inline-ui-area')]//button[contains(@class, 'btn-ace-inline-execution') and contains(text(), 'RunIt')]" "xpath_element" should exist
    And I press "RunIt"
    Then I should see "hello"
