@filter @filter_ace_inline @javascript
Feature: C(++) datatype-name highlighting for the Ace inline filter
  In order to visually distinguish typedef-style and struct/class type names in C(++) code
  As a teacher
  I need "_t"-suffixed and PascalCase identifiers to be highlighted as datatypes,
  without affecting ordinary identifiers, macros, keywords or built-in language constants

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
      | questioncategory | qtype       | name          |
      | Test questions   | description | cdatatypedemo |
    And "cdatatypedemo.txt" exists in question "cdatatypedemo" "questiontext" for filter ace inline
    And I have enabled the sandbox and ace inline filter

  Scenario: A PascalCase struct/type name is highlighted as a datatype
    When I am on the "cdatatypedemo" "core_question > preview" page logged in as teacher
    Then "//span[starts-with(@class, 'ace_support ace_type') and contains(text(), 'MyStructDatatype')]" "xpath_element" should exist

  Scenario: An "_t"-suffixed built-in typedef is highlighted as a datatype
    When I am on the "cdatatypedemo" "core_question > preview" page logged in as teacher
    Then "//span[starts-with(@class, 'ace_support ace_type') and contains(text(), 'size_t')]" "xpath_element" should exist
    And "//span[starts-with(@class, 'ace_support ace_type') and contains(text(), 'uint32_t')]" "xpath_element" should exist

  Scenario: A plain lowercase identifier is left as an ordinary identifier
    When I am on the "cdatatypedemo" "core_question > preview" page logged in as teacher
    Then "//span[starts-with(@class, 'ace_identifier') and contains(text(), 'plainvar')]" "xpath_element" should exist
    And "//span[starts-with(@class, 'ace_support ace_type') and contains(text(), 'plainvar')]" "xpath_element" should not exist

  Scenario: An ALL_CAPS macro-style name is not mistaken for PascalCase
    When I am on the "cdatatypedemo" "core_question > preview" page logged in as teacher
    Then "//span[starts-with(@class, 'ace_identifier') and contains(text(), 'ALL_CAPS_MACRO')]" "xpath_element" should exist
    And "//span[starts-with(@class, 'ace_support ace_type') and contains(text(), 'ALL_CAPS_MACRO')]" "xpath_element" should not exist

  Scenario: The "int" keyword itself is unaffected and still highlighted as a storage type
    When I am on the "cdatatypedemo" "core_question > preview" page logged in as teacher
    Then "//span[starts-with(@class, 'ace_storage ace_type') and contains(text(), 'int')]" "xpath_element" should exist
